/// 同步引擎：bootstrap / pull / push / 冲突 / 日志。
/// 语义遵循 docs/tasktips-mobile-design.md §4.2–4.4 与服务端 OpenAPI。
library;

import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:tasktips_api/tasktips_api.dart' as api;

import '../app/app_model.dart';
import '../domain/todo.dart';
import '../infra/markdown_doc.dart';
import 'session.dart';
import 'sync_state.dart';

class SyncException implements Exception {
  final String code;
  final String message;
  SyncException(this.code, this.message);
  @override
  String toString() => 'SyncException($code): $message';
}

enum SyncStatus { disconnected, connected, syncing, synced, partialFailed, conflict, error }

class SyncEngine extends ChangeNotifier {
  final AppModel model;
  final SyncSession session;
  late final Dio dio;
  late final api.TasktipsApi client;
  SyncStateData state = SyncStateData();

  SyncStatus status = SyncStatus.disconnected;
  String? lastError;
  List<api.Device> devices = [];
  bool busy = false;

  /// 连接代次：logout/更换项目时 +1；在飞异步流发现代次变化即放弃写入，
  /// 保证旧连接的迟到响应不会写入新连接状态。
  int _epoch = 0;

  /// 自动同步退避：连续失败后指数等待，手动同步不受限。
  int _consecutiveFailures = 0;
  DateTime? _lastFailureAt;
  bool get _backoffActive {
    final last = _lastFailureAt;
    if (last == null || _consecutiveFailures == 0) return false;
    final idx = (_consecutiveFailures - 1).clamp(0, 3);
    final wait = Duration(seconds: const [30, 60, 120, 300][idx]);
    return DateTime.now().isBefore(last.add(wait));
  }

  /// sync-state.json 解析失败：墓碑/基线状态不明，自动推送暂停。
  bool stateLoadFailed = false;

  SyncEngine(this.model, this.session, {Dio? httpClient}) {
    // httpClient 注入接缝：单测传入带 stub 拦截器的 Dio，不再发起真实网络
    dio = httpClient ??
        Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 60),
        ));
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (o, h) {
        if (session.accessToken != null) {
          o.headers['Authorization'] = 'Bearer ${session.accessToken}';
        }
        h.next(o);
      },
      onError: (e, h) async {
        // 401 时串行刷新 token 后重放一次
        if (e.response?.statusCode == 401 && session.refreshToken != null) {
          try {
            await session.serializeRefresh(() async {
              final plain = api.TasktipsApi(dio: Dio(BaseOptions(
                  baseUrl: dio.options.baseUrl.isNotEmpty
                      ? dio.options.baseUrl
                      : (state.serverUrl ?? ''))));
              final r = await plain.getAuthenticationApi().refreshToken(
                  refreshTokenRequest: api.RefreshTokenRequest((b) {
                b.refreshToken = session.refreshToken!;
              }));
              await session.updateTokens(
                  r.data!.accessToken, r.data!.refreshToken, r.data!.expiresIn);
            });
            final req = e.requestOptions;
            req.headers['Authorization'] = 'Bearer ${session.accessToken}';
            final resp = await dio.fetch(req);
            return h.resolve(resp);
          } catch (_) {
            // 刷新失败：清空凭据，避免失效 refresh token 留在安全存储、
            // 重启后被 loadState 重新判为“已连接”的死循环（阶段4 §5.1）
            await session.clear();
            return h.next(e);
          }
        }
        h.next(e);
      },
    ));
    client = api.TasktipsApi(dio: dio, interceptors: []);
  }

  api.AuthenticationApi get _auth => client.getAuthenticationApi();
  api.DevicesApi get _devicesApi => client.getDevicesApi();
  api.ProjectsApi get _projectsApi => client.getProjectsApi();
  api.PayloadsApi get _payloadsApi => client.getPayloadsApi();
  api.SynchronizationApi get _syncApi => client.getSynchronizationApi();

  // ---------- 状态持久化 ----------

  File get _stateFile => File('${model.store.stateDir.path}/sync-state.json');

  Future<void> loadState() async {
    if (await _stateFile.exists()) {
      try {
        state = SyncStateStore('').load(await _stateFile.readAsString());
        stateLoadFailed = false;
      } catch (_) {
        // 基线/墓碑状态不明：不静默重置为空继续推，先暂停自动推送
        state = SyncStateData();
        stateLoadFailed = true;
      }
    }
    await session.loadRefreshToken();
    dio.options.baseUrl = state.serverUrl ?? '';
    if (session.refreshToken != null && state.serverUrl != null) {
      status = SyncStatus.connected;
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    await _stateFile.parent.create(recursive: true);
    final tmp = File('${_stateFile.path}.tmp');
    await tmp.writeAsString(SyncStateStore('').save(state), flush: true);
    await tmp.rename(_stateFile.path);
  }

  void _log(String direction, int count, String result, [String? code]) {
    state.addLog(SyncLogEntry(DateTime.now(), direction, count, result, code));
  }

  // ---------- 登录与项目 ----------

  Future<String?> connect({
    required String serverUrl,
    required String email,
    required String password,
  }) async {
    final err = validateServerUrl(serverUrl);
    if (err != null) return err;
    final normalized = normalizeServerUrl(serverUrl);
    try {
      final plain = api.TasktipsApi(
          dio: Dio(BaseOptions(baseUrl: normalized)), interceptors: []);
      final login = await plain.getAuthenticationApi().login(
          loginRequest: api.LoginRequest((b) {
        b.email = email;
        b.password = password;
        b.deviceId = model.deviceId;
      }));
      state.serverUrl = normalized;
      state.email = email;
      dio.options.baseUrl = normalized;
      await session.updateTokens(
          login.data!.accessToken, login.data!.refreshToken, login.data!.expiresIn);
      final me = await _auth.getCurrentUser();
      state.accountId = me.data!.id;
      await registerDevice();
      await refreshDevices();
      await _persist();
      status = SyncStatus.connected;
      state.submitPaused = null; // 重连成功清除旧的暂停标记
      _log('login', 1, 'ok');
      notifyListeners();
      return null;
    } on DioException catch (e) {
      _log('login', 1, 'error', 'HTTP_${e.response?.statusCode ?? 'network'}');
      return _dioMessage(e, '连接失败');
    }
  }

  Future<void> registerDevice() async {
    await _devicesApi.registerDevice(
        registerDeviceRequest: api.RegisterDeviceRequest((b) {
      b.deviceId = model.deviceId;
      b.displayName = 'Android ${model.deviceId.substring(0, 8)}';
      b.platform = 'android';
      b.appVersion = '1.0.0';
    }));
  }

  Future<void> refreshDevices() async {
    final r = await _devicesApi.listDevices();
    devices = r.data!.items.toList();
    notifyListeners();
  }

  Future<List<api.Project>> listProjects() async {
    final r = await _projectsApi.listProjects();
    return r.data!.items.toList();
  }

  Future<api.Project> createProject(String name) async {
    final r = await _projectsApi.createProject(
        projectRequest: api.ProjectRequest((b) => b.name = name));
    return r.data!;
  }

  Future<void> selectProject(String projectId) async {
    if (state.projectId != null && state.projectId != projectId) {
      // 更换项目：隔离同步基线，不自动迁移本地内容；
      // 递增连接代次使旧项目在飞的同步流全部失效
      _epoch++;
      busy = false;
      final server = state.serverUrl;
      final account = state.accountId;
      final email = state.email;
      state = SyncStateData()
        ..serverUrl = server
        ..accountId = account
        ..email = email;
    }
    state.projectId = projectId;
    await _persist();
    notifyListeners();
  }

  /// 重新选择项目（保留账号连接）：清空项目上下文回到项目选择页；
  /// 选择不同项目时 selectProject 会隔离同步基线并失效在飞流。
  Future<void> beginProjectSwitch() async {
    _epoch++;
    busy = false;
    state.projectId = null;
    await _persist();
    notifyListeners();
  }

  Future<void> logout() async {
    // 先失效在飞流，再等待可能的服务端登出，避免旧响应写入新状态
    _epoch++;
    busy = false;
    final ep = _epoch;
    try {
      if (session.refreshToken != null) {
        await _auth.logout();
      }
    } catch (_) {}
    await session.clear();
    if (_epoch != ep) return;
    state = SyncStateData();
    devices = [];
    status = SyncStatus.disconnected;
    state.addLog(SyncLogEntry(DateTime.now(), 'login', 0, 'logout'));
    await _persist();
    notifyListeners();
  }

  // ---------- 对象序列化与哈希 ----------

  Uint8List todoBytes(Todo t) => utf8.encode(serializeTodoDoc(t));

  Uint8List classificationBytes() =>
      utf8.encode(model.store.classificationJson(model.classification));

  Uint8List indexBytes() =>
      utf8.encode(model.store.indexJson(model.index));

  String sha256Of(List<int> bytes) => crypto.sha256.convert(bytes).toString();

  // classification/index 的哈希按内容版本缓存：未变更时 push 不再
  // 重复做全量 JSON 序列化 + SHA-256（版本号由 AppModel 在每次变更时递增）
  int _classHashVersion = -1;
  String? _classHash;
  int _indexHashVersion = -1;
  String? _indexHash;

  String classificationHash() {
    if (_classHashVersion != model.classificationVersion) {
      _classHashVersion = model.classificationVersion;
      _classHash = sha256Of(classificationBytes());
    }
    return _classHash!;
  }

  String indexHash() {
    if (_indexHashVersion != model.indexVersion) {
      _indexHashVersion = model.indexVersion;
      _indexHash = sha256Of(indexBytes());
    }
    return _indexHash!;
  }

  // ---------- 首次连接预览（只读） ----------

  Future<SyncPreview> preview() async {
    _requireProject();
    var pageToken = '';
    final remoteIds = <String>{};
    final remoteDeleted = <String>{};
    var conflicts = 0;
    while (true) {
      final r = (await _syncApi.bootstrapSync(
              projectId: state.projectId!,
              bootstrapRequest: api.BootstrapRequest((b) {
                if (pageToken.isNotEmpty) b.pageToken = pageToken;
              })))
          .data!;
      for (final item in r.items) {
        final m = _changeMap(item);
        final key = state.baselineKey(m['kind'] as String, m['id'] as String);
        remoteIds.add(key);
        if (m['type'] == 'tombstone') {
          remoteDeleted.add(key);
        } else {
          final base = state.baselines[key];
          if (base != null &&
              base.contentHash != m['contentHash'] &&
              _localDirty(m['kind'] as String, m['id'] as String, base)) {
            conflicts++;
          }
        }
      }
      if (!r.hasMore) break;
      pageToken = r.nextPageToken!;
    }
    final localIds = _localKeys();
    final localOnly = localIds
        .where((k) => !remoteIds.contains(k) && !remoteDeleted.contains(k))
        .length;
    final remoteOnly = remoteIds.difference(localIds).length;
    return SyncPreview(localOnly, remoteOnly, conflicts);
  }

  bool _localDirty(String kind, String id, ObjectBaseline base) {
    switch (kind) {
      case 'todo':
        final t = model.byId(id);
        return t != null && t.revision > base.revision;
      default:
        final hash = kind == 'classification' ? classificationHash() : indexHash();
        return hash != base.contentHash;
    }
  }

  Set<String> _localKeys() {
    final keys = model.todos.map((t) => state.baselineKey('todo', t.id)).toSet();
    keys.add(state.baselineKey('classification', 'classification'));
    keys.add(state.baselineKey('index', 'index'));
    return keys;
  }

  void _requireProject() {
    if (state.serverUrl == null) throw SyncException('NOT_CONNECTED', '未连接服务端');
    if (state.projectId == null) throw SyncException('NO_PROJECT', '未选择项目');
  }

  Map<String, Object?> _changeMap(api.SyncChange change) {
    final oneOf = change.oneOf.value;
    if (oneOf is api.SyncObjectChange) {
      return {
        'type': 'object',
        'kind': oneOf.kind.name,
        'id': oneOf.id,
        'revision': oneOf.revision,
        'baseRevision': oneOf.baseRevision,
        'contentHash': oneOf.contentHash,
        'updatedAt': oneOf.updatedAt,
        'deviceId': oneOf.deviceId,
      };
    }
    final t = oneOf as api.SyncTombstoneChange;
    return {
      'type': 'tombstone',
      'kind': t.kind.name,
      'id': t.id,
      'revision': t.revision,
      'deletedAt': t.deletedAt,
      'deviceId': t.deviceId,
    };
  }

  // ---------- bootstrap ----------

  /// 完整 bootstrap：分页读取；最终 cursor 在快照完整落盘后启用。
  Future<void> bootstrapAndApply() async {
    _requireProject();
    final firstBootstrap = !state.bootstrapped;
    final ep = _epoch;
    try {
      var pageToken = '';
      while (true) {
        final r = (await _syncApi.bootstrapSync(
                projectId: state.projectId!,
                bootstrapRequest: api.BootstrapRequest((b) {
                  if (pageToken.isNotEmpty) b.pageToken = pageToken;
                })))
            .data!;
        final prefetched = await _prefetchPayloads(r.items);
        for (final item in r.items) {
          await _applyChange(item, prefetched: prefetched, notify: false);
        }
        model.notifyListeners(); // 整页应用完合并通知一次
        // bootstrap 中途不落盘 bootstrapped/cursor：快照不完整时重启会
        // 重新走 bootstrap，避免基于残缺基线推送
        if (!r.hasMore) {
          state.generation = r.generation;
          state.bootstrapped = true;
          state.pullCursor = r.cursor;
          break;
        }
        pageToken = r.nextPageToken!;
      }
      // 首次接入确认完成后默认开启自动同步（设计 §4.4）
      if (firstBootstrap && !state.autoSync) state.autoSync = true;
      _log('bootstrap', 1, 'ok');
      await _persist();
      if (firstBootstrap && state.autoSync) {
        notifyListeners(); // 让 UI 反映 autoSync 变化
      }
    } on DioException catch (e) {
      if (_epoch != ep) return;
      _log('bootstrap', 1, 'error', 'HTTP_${e.response?.statusCode ?? 'network'}');
      rethrow;
    } catch (e) {
      if (_epoch != ep) return;
      _log('bootstrap', 1, 'error', 'LOCAL');
      rethrow;
    }
  }

  // ---------- 应用远端变更 ----------

  Future<void> _applyChange(api.SyncChange change,
      {Map<String, Uint8List>? prefetched, bool notify = true}) async {
    final m = _changeMap(change);
    final kind = m['kind'] as String;
    final id = m['id'] as String;
    final key = state.baselineKey(kind, id);
    if (m['type'] == 'tombstone') {
      final revision = (m['revision'] as num).toInt();
      if (kind == 'todo') {
        final base = state.baselines[key];
        final t = model.byId(id);
        final localDirty =
            t != null && (base == null || base.revision < t.revision);
        if (localDirty) {
          // 删除 vs 本机未同步编辑：保留本机并记录冲突（远端版本为删除），
          // 不静默丢弃
          state.conflicts.add(ConflictRecord(
              kind, id, t.revision, revision, null,
              remoteDeleted: true));
        } else {
          final f = File('${model.store.tipsDir.path}/$id.md');
          if (await f.exists()) await f.delete();
          model.todos.removeWhere((t) => t.id == id);
        }
      } else if (kind == 'image') {
        final ext = _imageExtFor(id);
        if (ext != null) {
          final f = File(
              '${model.store.imagesDir.path}/$id${id.contains('.') ? '' : '.$ext'}');
          if (await f.exists() && state.baselines[key] == null) {
            // 本机未同步的图片：保留并记录冲突（远端版本为删除）
            state.conflicts.add(ConflictRecord(
                kind, id, 1, revision, null,
                remoteDeleted: true));
          } else if (await f.exists()) {
            await f.delete();
          }
        }
      }
      state.baselines[key] = ObjectBaseline(kind, id, revision, null);
      if (notify) model.notifyListeners();
      return;
    }
    final hash = m['contentHash'] as String;
    final revision = (m['revision'] as num).toInt();
    final base = state.baselines[key];
    if (base != null && base.revision == revision && base.contentHash == hash) {
      return; // 已确认
    }
    // 本机待保存内容与远端更新并存 → 整对象冲突，保留本机并记录
    if (base != null && _localDirty(kind, id, base)) {
      state.conflicts.add(ConflictRecord(kind, id, base.revision, revision, hash));
      return;
    }
    final bytes = prefetched?[hash] ?? await _downloadPayload(hash);
    if (sha256Of(bytes) != hash) {
      throw SyncException('HASH_MISMATCH', '$kind/$id 哈希校验失败');
    }
    await _writeRemoteObject(kind, id, bytes, notify: notify);
    state.baselines[key] = ObjectBaseline(kind, id, revision, hash);
  }

  /// 按批（4 并发）预取本页待应用对象的 payload，替代逐条串行下载。
  Future<Map<String, Uint8List>> _prefetchPayloads(
      Iterable<api.SyncChange> changes) async {
    final hashes = <String>{};
    for (final change in changes) {
      final m = _changeMap(change);
      if (m['type'] != 'object') continue;
      final key = state.baselineKey(m['kind'] as String, m['id'] as String);
      final base = state.baselines[key];
      final hash = m['contentHash'] as String?;
      if (base == null || base.contentHash != hash) hashes.add(hash!);
    }
    final out = <String, Uint8List>{};
    final pending = hashes.toList();
    const chunk = 4;
    for (var i = 0; i < pending.length; i += chunk) {
      final part = pending.skip(i).take(chunk).toList();
      final results = await Future.wait(
          part.map((h) async => MapEntry(h, await _downloadPayload(h))));
      out.addEntries(results);
    }
    return out;
  }

  Future<Uint8List> _downloadPayload(String hash) async {
    final r = await _payloadsApi.getPayload(
        projectId: state.projectId!, contentHash: hash);
    return r.data!;
  }

  Future<void> _writeRemoteObject(String kind, String id, Uint8List bytes,
      {bool notify = true}) async {
    // image 是二进制对象：不做文本解码（utf8.decode 会抛 FormatException
    // 中断整页 pull），校验哈希后直接落盘。
    if (kind == 'image') {
      final ext = _imageExtFor(id);
      if (ext == null) {
        // 无法确定扩展名的 image 对象：跳过并记录，不中断同步
        _log('download', 1, 'skipped', 'IMAGE_NAME_UNKNOWN');
        return;
      }
      final f = File('${model.store.imagesDir.path}/$id.$ext');
      final tmp = File('${f.path}.tmp');
      await tmp.writeAsBytes(bytes, flush: true);
      await tmp.rename(f.path);
      if (notify) model.notifyListeners();
      return;
    }
    final text = utf8.decode(bytes);
    switch (kind) {
      case 'todo':
        final parsed = parseTodoDoc(text);
        final t = todoFromFields(parsed.fields, parsed.body);
        await model.store.saveTodo(t);
        final i = model.todos.indexWhere((e) => e.id == id);
        if (i >= 0) {
          model.todos[i] = t;
        } else {
          model.todos.add(t);
        }
      case 'classification':
        final c = model.store.classificationFromRawJson(text);
        model.classification = c;
        await model.store.saveClassification(c);
        model.classificationVersion++;
        model.classificationCorrupt = false; // 远端权威副本已修复本地损坏
      case 'index':
        final idx = model.store.indexFromRawJson(text);
        model.index = idx;
        await model.store.saveIndex(idx);
        model.indexVersion++;
        model.indexCorrupt = false;
      default:
        break;
    }
    if (notify) model.notifyListeners();
  }

  /// image 对象 id 形如 `<ulid>.<ext>`；若 id 为主名（无扩展名），
  /// 则在 images/ 中查找以 `<id>.` 开头的现有文件。
  String? _imageExtFor(String id) {
    final dot = id.lastIndexOf('.');
    if (dot > 0 && dot < id.length - 1) {
      final ext = id.substring(dot + 1).toLowerCase();
      if (const {'png', 'jpg', 'gif', 'webp', 'bmp'}.contains(ext)) return ext;
      return null; // 带点但扩展名不合法：不猜
    }
    try {
      for (final e in model.store.imagesDir.listSync()) {
        final name = e.uri.pathSegments.last;
        if (name.startsWith('$id.')) return name.substring(id.length + 1);
      }
    } catch (_) {}
    return null;
  }

  // ---------- pull ----------

  Future<void> pull() async {
    _requireProject();
    if (state.pullCursor == null) return;
    while (true) {
      final resp = (await _syncApi.pullSyncChanges(
              projectId: state.projectId!,
              pullRequest: api.PullRequest((b) {
                b.cursor = state.pullCursor!;
                b.limit = 500;
              })))
          .data!;
      // generation 回退/变化（服务端恢复、快照重建）：本机基线不再可信，
      // 中止并重新 bootstrap，不按旧 cursor 继续
      if (state.generation != null && resp.generation != state.generation) {
        state.bootstrapped = false;
        state.pullCursor = null;
        await _persist();
        throw SyncException('GENERATION_MISMATCH', '项目已变更，需要重新同步');
      }
      var applied = 0;
      final prefetched = await _prefetchPayloads(resp.changes);
      for (final change in resp.changes) {
        await _applyChange(change, prefetched: prefetched, notify: false);
        applied++;
      }
      if (applied > 0) {
        _log('download', applied, 'ok');
        model.notifyListeners(); // 整页应用完合并通知一次
      }
      // 该页对象/墓碑可靠保存后才推进 cursor
      state.pullCursor = resp.nextCursor;
      state.generation = resp.generation;
      await _persist();
      if (!resp.hasMore) break;
    }
  }

  // ---------- push ----------

  /// 各对象 payload 限额（完整序列化字节，禁止截断后上传）。
  static const _payloadLimits = {
    'todo': 8 * 1024 * 1024,
    'classification': 5 * 1024 * 1024,
    'index': 5 * 1024 * 1024,
    'image': 10 * 1024 * 1024,
  };

  Future<void> pushDirty() async {
    _requireProject();
    // 墓碑/基线状态不明（sync-state 损坏）或 index 损坏：暂停自动推送
    if (stateLoadFailed || model.indexCorrupt) {
      throw SyncException('STATE_UNAVAILABLE', '本机同步状态/索引数据损坏，已暂停自动推送，请先核对数据');
    }
    // 未完成请求原样重试（幂等），不把新编辑内容套入旧请求 ID
    if (state.pendingPush != null) {
      await _submitPush(state.pendingPush!);
      if (state.pendingPush != null) return; // 仍然失败，等待下次
    }
    final objects = <Map<String, Object?>>[];
    final tombstones = <Map<String, Object?>>[];

    // 分类/索引文件损坏时禁止推送（避免空对象反向覆盖远端）
    final skipClassFiles = model.classificationCorrupt;

    for (final t in model.todos) {
      final key = state.baselineKey('todo', t.id);
      final base = state.baselines[key];
      // 被拒绝对象：本地版本未变化前不再重试（校验失败停止重试该对象）
      final rej = state.rejected[key];
      if (rej != null && rej.revision >= t.revision) continue;
      if (base == null || base.revision < t.revision) {
        final bytes = todoBytes(t);
        final hash = sha256Of(bytes);
        if (base?.contentHash == hash) continue; // 内容未变，无需重传
        if (bytes.length > _payloadLimits['todo']!) {
          _recordRejected(key, 'PAYLOAD_TOO_LARGE', t.revision, hash);
          continue; // 单项超限保留本地并记录原因，不阻断其他对象
        }
        await _ensurePayloadUploaded(hash, bytes);
        objects.add({
          'kind': 'todo',
          'id': t.id,
          'schemaVersion': 1,
          'revision': t.revision,
          'baseRevision': base?.revision,
          'contentHash': hash,
          'updatedAt': t.updatedAt.toUtc().toIso8601String(),
          'deviceId': model.deviceId,
        });
      }
    }

    // 本地图片：文件名即对象 id（images/<ulid>.<ext>），新文件全量上传
    try {
      for (final e in model.store.imagesDir.listSync()) {
        final name = e.uri.pathSegments.last;
        if (e is! File || _imageExtFor(name) == null) continue;
        final key = state.baselineKey('image', name);
        if (state.baselines[key] != null) continue;
        final bytes = await e.readAsBytes();
        final hash = sha256Of(bytes);
        // 被拒图片：内容变化后才重试，同内容不再上传
        final rej = state.rejected[key];
        if (rej != null && rej.contentHash == hash) continue;
        if (bytes.length > _payloadLimits['image']!) {
          _recordRejected(key, 'PAYLOAD_TOO_LARGE', 1, hash);
          continue;
        }
        await _ensurePayloadUploaded(hash, bytes);
        objects.add({
          'kind': 'image',
          'id': name,
          'schemaVersion': 1,
          'revision': 1,
          'baseRevision': null,
          'contentHash': hash,
          'updatedAt': DateTime.now().toUtc().toIso8601String(),
          'deviceId': model.deviceId,
        });
      }
    } catch (_) {}

    if (!skipClassFiles) {
      for (final kind in ['classification', 'index']) {
        final key = state.baselineKey(kind, kind);
        final base = state.baselines[key];
        // 未变更时直接跳过，不再序列化全文计算哈希
        final hash =
            kind == 'classification' ? classificationHash() : indexHash();
        if (base?.contentHash == hash) continue;
        final rej = state.rejected[key];
        if (rej != null && rej.contentHash == hash) continue; // 同内容曾被拒
        final bytes =
            kind == 'classification' ? classificationBytes() : indexBytes();
        if (bytes.length > _payloadLimits[kind]!) {
          _recordRejected(key, 'PAYLOAD_TOO_LARGE', -1, hash);
          continue;
        }
        await _ensurePayloadUploaded(hash, bytes);
        objects.add({
          'kind': kind,
          'id': kind,
          'schemaVersion': 1,
          'revision': (base?.revision ?? 0) + 1,
          'baseRevision': base?.revision,
          'contentHash': hash,
          'updatedAt': DateTime.now().toUtc().toIso8601String(),
          'deviceId': model.deviceId,
        });
      }
    }

    for (final ts in model.index.tombstones) {
      final key = state.baselineKey(ts.kind, ts.id);
      final base = state.baselines[key];
      if (base == null || base.revision < ts.revision) {
        tombstones.add({
          'kind': ts.kind,
          'id': ts.id,
          'revision': ts.revision,
          'baseRevision': base?.revision,
          'deletedAt': ts.deletedAt.toUtc().toIso8601String(),
          'deviceId': model.deviceId,
        });
      }
    }

    if (objects.isEmpty && tombstones.isEmpty) return;
    // OpenAPI pushSyncChanges maxItems=100：分批提交，每批独立 requestId，
    // 前一批成功后才提交下一批；失败时剩余内容留待下轮
    final items = [...objects, ...tombstones];
    for (var i = 0; i < items.length; i += 100) {
      final batch = items.skip(i).take(100).toList();
      final batchObjects =
          batch.where((e) => e.containsKey('contentHash')).toList();
      final batchTombstones =
          batch.where((e) => !e.containsKey('contentHash')).toList();
      final pending = PendingPush(
          _newRequestId(), state.generation ?? 1, batchObjects, batchTombstones);
      state.pendingPush = pending;
      await _persist();
      await _submitPush(pending);
      if (state.pendingPush != null) return; // 本批失败，等待下次
    }
  }

  void _recordRejected(String key, String code, int revision, String? hash) {
    state.rejected[key] = RejectedRecord(code, revision, hash);
    _log('upload', 1, 'rejected', code);
  }

  Future<void> _ensurePayloadUploaded(String hash, Uint8List bytes) async {
    try {
      await _payloadsApi.headPayload(
          projectId: state.projectId!, contentHash: hash);
      return; // 已存在
    } on DioException catch (e) {
      if (e.response?.statusCode != 404) rethrow;
    }
    await _payloadsApi.putPayload(
      projectId: state.projectId!,
      contentHash: hash,
      contentLength: bytes.length,
      contentType: 'application/octet-stream',
      body: MultipartFile.fromBytes(bytes),
    );
  }

  String _newRequestId() =>
      'push-${DateTime.now().millisecondsSinceEpoch}-${model.deviceId.substring(0, 8)}';

  api.ObjectKind _kind(String name) => api.ObjectKind.valueOf(name);

  Future<void> _submitPush(PendingPush pending) async {
    final ep = _epoch;
    try {
      final r = await _syncApi.pushSyncChanges(
          projectId: state.projectId!,
          pushRequest: api.PushRequest((b) {
            b.requestId = pending.requestId;
            b.generation = pending.generation;
            for (final o in pending.objects) {
              b.objects.add(api.PushObject((ob) {
                ob.kind = _kind(o['kind'] as String);
                ob.id = o['id'] as String;
                ob.schemaVersion = (o['schemaVersion'] as num).toInt();
                ob.revision = (o['revision'] as num).toInt();
                ob.baseRevision = (o['baseRevision'] as num?)?.toInt();
                ob.contentHash = o['contentHash'] as String;
                ob.updatedAt = DateTime.parse(o['updatedAt'] as String);
                ob.deviceId = o['deviceId'] as String;
              }));
            }
            for (final o in pending.tombstones) {
              b.tombstones.add(api.PushTombstone((ob) {
                ob.kind = _kind(o['kind'] as String);
                ob.id = o['id'] as String;
                ob.revision = (o['revision'] as num).toInt();
                ob.baseRevision = (o['baseRevision'] as num?)?.toInt();
                ob.deletedAt = DateTime.parse(o['deletedAt'] as String);
                ob.deviceId = o['deviceId'] as String;
              }));
            }
          }));
      if (_epoch != ep) return; // 连接已更换：丢弃旧响应
      final resp = r.data!;
      var applied = 0;
      for (final res in resp.results) {
        final oneOf = res.oneOf.value;
        final String kind, id;
        if (oneOf is api.PushAppliedResult) {
          kind = oneOf.kind.name;
          id = oneOf.id;
          applied++;
          final key = state.baselineKey(kind, id);
          final hash = pending.objects
              .where((o) => o['id'] == id && o['kind'] == kind)
              .map((o) => o['contentHash'] as String)
              .firstOrNull;
          state.baselines[key] = ObjectBaseline(kind, id, oneOf.revision, hash);
          state.rejected.remove(key); // 成功后清除历史拒绝记录
        } else if (oneOf is api.PushConflictResult) {
          kind = oneOf.kind.name;
          id = oneOf.id;
          state.conflicts.add(ConflictRecord(
              kind, id, oneOf.expectedRevision ?? 0, oneOf.actualRevision ?? 0, null));
        } else {
          final rej = oneOf as api.PushRejectedResult;
          final key = state.baselineKey(rej.kind.name, rej.id);
          final pendingObj = pending.objects
              .where((o) => o['id'] == rej.id && o['kind'] == rej.kind.name)
              .firstOrNull;
          final revision = pendingObj == null
              ? -1
              : (pendingObj['revision'] as num).toInt();
          // 记录被拒对象（含当时哈希）：本地未变化前不再重试
          state.rejected[key] = RejectedRecord(
              rej.code.name, revision, pendingObj?['contentHash'] as String?);
          _log('upload', 1, 'rejected', rej.code.name);
        }
      }
      // 服务端对每个条目都给出结果：请求已完成（含被拒条目），
      // 清除待提交；被拒对象由 rejected 记录承接，不再以新请求重试
      state.pendingPush = null;
      _log('upload', applied,
          state.conflicts.any((c) => !c.resolved) ? 'conflict' : 'ok');
      await _persist();
    } on DioException catch (e) {
      if (_epoch != ep) return;
      final code = e.response?.statusCode;
      if (code == 409) {
        final errCode = _errorCodeOf(e);
        if (errCode == 'IDEMPOTENCY_CONFLICT') {
          // 同 requestId 不同内容：放弃旧请求，下轮以新请求重建
          state.pendingPush = null;
          await _persist();
          throw SyncException('IDEMPOTENCY_CONFLICT', '请求上下文冲突，已重建');
        }
        // generation 变化：旧上下文的请求永远无法成功，丢弃并重新 bootstrap
        state.pendingPush = null;
        state.generation = null;
        state.bootstrapped = false;
        state.pullCursor = null;
        await _persist();
        throw SyncException('GENERATION_MISMATCH', '项目已变更，需要重新同步');
      }
      // 响应丢失：请求保持原样，稍后原样重试
      _log('upload', 0, 'error', 'HTTP_${code ?? 'network'}');
      rethrow;
    }
  }

  /// 认证终局失效判定（阶段4 §5.1）：设备被撤销 / 账号被禁用 /
  /// 凭据无效（刷新已失败或无 refresh token 时的 401）。
  /// 命中后必须走 [handleTerminalAuthFailure] 清凭据转 disconnected，
  /// 不得让失效凭据留存导致“已连接但一直失败”循环。
  bool isTerminalAuthFailure(DioException e) {
    switch (errorCodeOf(e)) {
      case 'DEVICE_REVOKED':
      case 'ACCOUNT_DISABLED':
      case 'AUTHENTICATION_REQUIRED':
        return true;
      default:
        return false;
    }
  }

  /// 终局失效处理：暂停自动提交 + 清空凭据 + 转 disconnected + 持久化，
  /// 用户重新登录后恢复。幂等，可重复调用。
  Future<void> handleTerminalAuthFailure(DioException e) async {
    state.submitPaused = errorCodeOf(e) ?? 'HTTP_${e.response?.statusCode ?? 'network'}';
    await session.clear();
    status = SyncStatus.disconnected;
    lastError = _dioMessage(e, '登录已失效，请重新登录');
    await _persist();
    notifyListeners();
  }

  @visibleForTesting
  String? errorCodeOf(DioException e) => _errorCodeOf(e);

  @visibleForTesting
  String dioMessage(DioException e, String fallback) => _dioMessage(e, fallback);

  @visibleForTesting
  bool get debugBackoffActive => _backoffActive;

  @visibleForTesting
  void debugSetBackoff({required int failures, DateTime? at}) {
    _consecutiveFailures = failures;
    _lastFailureAt = at;
  }

  /// 从错误响应体解析服务端 ErrorCode（openapi ErrorResponse.code）。
  String? _errorCodeOf(DioException e) {
    final data = e.response?.data;
    if (data is Map) return data['code'] as String?;
    if (data is String) {
      try {
        final j = jsonDecode(data);
        if (j is Map) return j['code'] as String?;
      } catch (_) {}
    }
    return null;
  }

  // ---------- 冲突解决 ----------

  /// 保留本机：以远端 revision 为 base 提交新版本。
  /// 请求先持久化为 pendingPush：响应丢失时按原 requestId 幂等重试。
  Future<void> resolveKeepLocal(String kind, String id) async {
    final c = state.conflicts
        .firstWhere((c) => c.kind == kind && c.id == id && !c.resolved);
    final Uint8List bytes;
    if (kind == 'todo') {
      bytes = todoBytes(model.byId(id)!);
    } else if (kind == 'classification') {
      bytes = classificationBytes();
    } else if (kind == 'index') {
      bytes = indexBytes();
    } else {
      // image：从本地文件读取原始字节
      final ext = _imageExtFor(id);
      if (ext == null) throw SyncException('IMAGE_MISSING', '本地图片文件缺失');
      bytes = await File(
              '${model.store.imagesDir.path}/$id${id.contains('.') ? '' : '.$ext'}')
          .readAsBytes();
    }
    final hash = sha256Of(bytes);
    await _ensurePayloadUploaded(hash, bytes);
    final pending = PendingPush(_newRequestId(), state.generation ?? 1, [
      {
        'kind': kind,
        'id': id,
        'schemaVersion': 1,
        'revision': c.remoteRevision + 1,
        'baseRevision': c.remoteRevision,
        'contentHash': hash,
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
        'deviceId': model.deviceId,
      }
    ], []);
    state.pendingPush = pending;
    await _persist();
    await _submitPush(pending);
    if (state.pendingPush != null) return; // 提交失败：保持未解决，待重试
    state.conflicts.remove(c);
    state.rejected.remove(state.baselineKey(kind, id));
    await _persist();
    notifyListeners();
  }

  /// 采用远端：拉取远端对象覆盖本机（恢复副本由 store 保存流程自动保留）。
  /// push 冲突（无远端 hash）与删除冲突按各自语义处理：
  /// - 无 hash：丢弃本地基线并触发重新 bootstrap，由快照重新应用远端版本；
  /// - 远端为删除墓碑：接受删除（移除本地文件并确认基线）。
  Future<void> resolveUseRemote(String kind, String id) async {
    final c = state.conflicts
        .firstWhere((c) => c.kind == kind && c.id == id && !c.resolved);
    final hash = c.remoteContentHash;
    if (c.remoteDeleted) {
      // 接受删除：删除本地内容，基线记为墓碑已确认
      if (kind == 'todo') {
        await model.store.deleteTodoFile(id);
        model.todos.removeWhere((t) => t.id == id);
      } else if (kind == 'image') {
        final ext = _imageExtFor(id);
        if (ext != null) {
          final f = File('${model.store.imagesDir.path}/$id'
              '${id.contains('.') ? '' : '.$ext'}');
          if (await f.exists()) await f.delete();
        }
      }
      state.baselines[state.baselineKey(kind, id)] =
          ObjectBaseline(kind, id, c.remoteRevision, null);
    } else if (hash != null) {
      final bytes = await _downloadPayload(hash);
      if (sha256Of(bytes) == hash) {
        await _writeRemoteObject(kind, id, bytes);
        state.baselines[state.baselineKey(kind, id)] =
            ObjectBaseline(kind, id, c.remoteRevision, hash);
      }
    } else {
      // push 冲突无远端 hash：丢弃基线，重新 bootstrap 拉取远端当前版本
      state.baselines.remove(state.baselineKey(kind, id));
      state.bootstrapped = false;
      state.pullCursor = null;
    }
    state.conflicts.remove(c);
    await _persist();
    notifyListeners();
  }

  // ---------- 顶层同步 ----------

  /// 本地是否有未同步变更（供 UI 显示"待同步"）。
  /// 口径与 pushDirty 一致：todo / 图片 / 分类 / 索引 / 墓碑任一有未提交
  /// 且未被拒同内容（rejected 同版本/同哈希不再提示），即视为待同步。
  bool get hasUnsyncedChanges {
    if (state.pendingPush != null) return true;
    for (final t in model.todos) {
      final base = state.baselines[state.baselineKey('todo', t.id)];
      if (base == null || base.revision < t.revision) {
        if (state.rejected[state.baselineKey('todo', t.id)] == null ||
            state.rejected[state.baselineKey('todo', t.id)]!.revision <
                t.revision) {
          return true;
        }
      }
    }
    // 本地图片：未建基线、且未被拒同内容
    try {
      for (final e in model.store.imagesDir.listSync()) {
        if (e is! File) continue;
        final name = e.uri.pathSegments.last;
        if (_imageExtFor(name) == null) continue;
        final key = state.baselineKey('image', name);
        if (state.baselines[key] != null) continue;
        final rej = state.rejected[key];
        if (rej != null) {
          try {
            if (rej.contentHash == sha256Of(e.readAsBytesSync())) continue;
          } catch (_) {}
        }
        return true;
      }
    } catch (_) {}
    // 分类/索引：哈希与基线不一致、且未被拒同内容
    for (final kind in ['classification', 'index']) {
      final key = state.baselineKey(kind, kind);
      final hash = kind == 'classification' ? classificationHash() : indexHash();
      if (state.baselines[key]?.contentHash == hash) continue;
      final rej = state.rejected[key];
      if (rej != null && rej.contentHash == hash) continue;
      return true;
    }
    // 未提交的墓碑
    for (final ts in model.index.tombstones) {
      final key = state.baselineKey(ts.kind, ts.id);
      final base = state.baselines[key];
      if (base == null || base.revision < ts.revision) return true;
    }
    return false;
  }

  /// 手动同步不受退避与暂停限制；自动触发（保存后/定时/前台恢复）受限。
  Future<void> syncNow({bool manual = false}) async {
    if (busy) return;
    if (!manual) {
      if (state.submitPaused != null) return; // 登录失效/撤销/维护：暂停自动提交
      if (_backoffActive) return; // 失败退避中
    }
    // 跨进程互斥：前台与 WorkManager 后台同轮只允许一个写入者
    final lock = await SyncLock.acquire(model.store.stateDir.path);
    if (lock == null) return;
    busy = true;
    final ep = _epoch;
    var retriedGeneration = false;
    try {
      while (true) {
        status = SyncStatus.syncing;
        notifyListeners();
        try {
          if (!state.bootstrapped) {
            await bootstrapAndApply();
          }
          if (_epoch != ep) return;
          await pull();
          await pushDirty();
          state.submitPaused = null;
          _consecutiveFailures = 0;
          _lastFailureAt = null;
          status = state.pendingPush != null || state.rejected.isNotEmpty
              ? SyncStatus.partialFailed
              : state.conflicts.any((c) => !c.resolved)
                  ? SyncStatus.conflict
                  : SyncStatus.synced;
          lastError = null;
          break;
        } on SyncException catch (e) {
          if (_epoch != ep) return;
          if (e.code == 'GENERATION_MISMATCH' && !retriedGeneration) {
            // 重新 bootstrap 后再试一轮
            retriedGeneration = true;
            continue;
          }
          rethrow;
        }
      }
    } on SyncException catch (e) {
      if (_epoch == ep) {
        status = SyncStatus.error;
        lastError = e.message;
        _noteFailure();
      }
    } on DioException catch (e) {
      if (_epoch == ep) {
        if (isTerminalAuthFailure(e)) {
          // 设备撤销/账号禁用/凭据无效：清凭据转 disconnected，不再以 error 态重试
          await handleTerminalAuthFailure(e);
        } else {
          status = SyncStatus.error;
          lastError = _dioMessage(e, '同步失败');
          _noteFailure(e);
        }
      }
    } catch (e) {
      if (_epoch == ep) {
        status = SyncStatus.error;
        lastError = e.toString();
        _noteFailure();
      }
    } finally {
      lock.release();
      if (_epoch == ep) {
        busy = false;
        notifyListeners();
      }
    }
  }

  void _noteFailure([DioException? e]) {
    _consecutiveFailures++;
    _lastFailureAt = DateTime.now();
    // 登录失效/设备撤销/项目维护：暂停自动提交，直到手动同步成功或重连
    final code = e?.response?.statusCode;
    if (code == 401 || code == 403 || code == 423) {
      state.submitPaused = _errorCodeOf(e!) ?? 'HTTP_$code';
      _persist();
    }
  }

  Future<void> setAutoSync(bool enabled) async {
    state.autoSync = enabled;
    if (enabled) state.submitPaused = null;
    await _persist();
    notifyListeners();
  }

  String _dioMessage(DioException e, String fallback) {
    // 优先解析服务端 ErrorCode（openapi ErrorResponse.code）
    switch (_errorCodeOf(e)) {
      case 'ACCOUNT_DISABLED':
        return '账号已被禁用';
      case 'DEVICE_REVOKED':
        return '设备已被撤销，请重新登录';
      case 'AUTH_INVALID':
      case 'SESSION_EXPIRED':
        return '登录已失效，请重新登录';
      case 'PROJECT_MAINTENANCE':
        return '项目维护中，稍后再试';
      case 'RATE_LIMITED':
        return '请求过于频繁，稍后再试';
    }
    switch (e.response?.statusCode) {
      case 401:
        return '登录已失效，请重新登录';
      case 403:
        return '没有权限，设备可能已被撤销';
      case 423:
        return '项目维护中，稍后再试';
      case 429:
        return '请求过于频繁，稍后再试';
      default:
        return e.type == DioExceptionType.connectionError ||
                e.type == DioExceptionType.connectionTimeout
            ? '网络不可用'
            : fallback;
    }
  }
}

/// 跨进程同步互斥锁：state/sync.lock 记录持有者与时间戳。
/// 存在新鲜锁（<15 分钟，非本实例）时获取失败；陈旧锁视为崩溃残留可抢占。
/// 公开以便回归测试直接覆盖互斥语义。
class SyncLock {
  final File _file;
  SyncLock(this._file);

  static Future<SyncLock?> acquire(String stateDir) async {
    final f = File('$stateDir/sync.lock');
    try {
      if (await f.exists()) {
        final raw = await f.readAsString();
        final ts = int.tryParse(raw.split('\n').first) ?? 0;
        final age = DateTime.now().millisecondsSinceEpoch - ts;
        if (age < 15 * 60 * 1000 && age > -60 * 1000) return null; // 他人持有
      }
      await f.writeAsString(
          '${DateTime.now().millisecondsSinceEpoch}\n', flush: true);
      return SyncLock(f);
    } catch (_) {
      return null; // 锁文件不可写：保守放弃本轮
    }
  }

  Future<void> release() async {
    try {
      await _file.delete();
    } catch (_) {}
  }
}

class SyncPreview {
  final int localOnly;
  final int remoteOnly;
  final int conflicts;
  SyncPreview(this.localOnly, this.remoteOnly, this.conflicts);
}
