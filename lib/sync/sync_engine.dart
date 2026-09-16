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

  SyncEngine(this.model, this.session) {
    dio = Dio(BaseOptions(
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
      } catch (_) {
        state = SyncStateData();
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
      b.appVersion = '0.1.0';
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
      // 更换项目：隔离同步基线，不自动迁移本地内容
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

  Future<void> logout() async {
    try {
      if (session.refreshToken != null) {
        await _auth.logout();
      }
    } catch (_) {}
    await session.clear();
    state = SyncStateData();
    devices = [];
    await _persist();
    status = SyncStatus.disconnected;
    _log('login', 0, 'logout');
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
    busy = true;
    status = SyncStatus.syncing;
    notifyListeners();
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
        // 该页对象可靠保存后才推进状态
        state.generation = r.generation;
        state.bootstrapped = true;
        if (!r.hasMore) {
          state.pullCursor = r.cursor;
          break;
        }
        pageToken = r.nextPageToken!;
        await _persist();
      }
      _log('bootstrap', 1, 'ok');
      status = SyncStatus.synced;
      await _persist();
    } on DioException catch (e) {
      _log('bootstrap', 1, 'error', 'HTTP_${e.response?.statusCode ?? 'network'}');
      status = SyncStatus.error;
      lastError = _dioMessage(e, '同步失败');
    } catch (e) {
      _log('bootstrap', 1, 'error', 'LOCAL');
      status = SyncStatus.error;
      lastError = e.toString();
    } finally {
      busy = false;
      notifyListeners();
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
      if (kind == 'todo') {
        final f = File('${model.store.tipsDir.path}/$id.md');
        if (await f.exists()) await f.delete();
        model.todos.removeWhere((t) => t.id == id);
      } else if (kind == 'image') {
        final ext = _imageExtFor(id);
        if (ext != null) {
          final f = File('${model.store.imagesDir.path}/$id${id.contains('.') ? '' : '.$ext'}');
          if (await f.exists()) await f.delete();
        }
      }
      state.baselines[key] =
          ObjectBaseline(kind, id, (m['revision'] as num).toInt(), null);
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
      case 'index':
        final idx = model.store.indexFromRawJson(text);
        model.index = idx;
        await model.store.saveIndex(idx);
        model.indexVersion++;
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

  Future<void> pushDirty() async {
    _requireProject();
    // 未完成请求原样重试（幂等），不把新编辑内容套入旧请求 ID
    if (state.pendingPush != null) {
      await _submitPush(state.pendingPush!);
      if (state.pendingPush != null) return; // 仍然失败，等待下次
    }
    final objects = <Map<String, Object?>>[];
    final tombstones = <Map<String, Object?>>[];

    for (final t in model.todos) {
      final key = state.baselineKey('todo', t.id);
      final base = state.baselines[key];
      if (base == null || base.revision < t.revision) {
        final bytes = todoBytes(t);
        final hash = sha256Of(bytes);
        if (base?.contentHash == hash) continue; // 内容未变，无需重传
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

    for (final kind in ['classification', 'index']) {
      final base = state.baselines[state.baselineKey(kind, kind)];
      // 未变更时直接跳过，不再序列化全文计算哈希
      final hash =
          kind == 'classification' ? classificationHash() : indexHash();
      if (base?.contentHash == hash) continue;
      final bytes =
          kind == 'classification' ? classificationBytes() : indexBytes();
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

    for (final ts in model.index.tombstones) {
      final base = state.baselines[state.baselineKey(ts.kind, ts.id)];
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
    final pending = PendingPush(
        _newRequestId(), state.generation ?? 1, objects, tombstones);
    state.pendingPush = pending;
    await _persist();
    await _submitPush(pending);
  }

  Future<void> _ensurePayloadUploaded(String hash, Uint8List bytes) async {
    // 对象限额：payload ≤ 10MiB，禁止截断后上传
    if (bytes.length > 10 * 1024 * 1024) {
      throw SyncException('PAYLOAD_TOO_LARGE', '对象超过 10 MiB 限制');
    }
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
      final resp = r.data!;
      var applied = 0;
      for (final res in resp.results) {
        final oneOf = res.oneOf.value;
        final String kind, id;
        if (oneOf is api.PushAppliedResult) {
          kind = oneOf.kind.name;
          id = oneOf.id;
          applied++;
          final hash = pending.objects
              .where((o) => o['id'] == id && o['kind'] == kind)
              .map((o) => o['contentHash'] as String)
              .firstOrNull;
          state.baselines[state.baselineKey(kind, id)] =
              ObjectBaseline(kind, id, oneOf.revision, hash);
        } else if (oneOf is api.PushConflictResult) {
          kind = oneOf.kind.name;
          id = oneOf.id;
          state.conflicts.add(ConflictRecord(
              kind, id, oneOf.expectedRevision ?? 0, oneOf.actualRevision ?? 0, null));
        } else {
          final rej = oneOf as api.PushRejectedResult;
          _log('upload', 1, 'rejected', rej.code.name);
          continue;
        }
      }
      // 逐项处理：只更新成功对象基线；全部条目处理完毕才清空请求
      if (resp.results.length ==
          pending.objects.length + pending.tombstones.length) {
        state.pendingPush = null;
      }
      _log('upload', applied,
          state.conflicts.any((c) => !c.resolved) ? 'conflict' : 'ok');
      await _persist();
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 409) {
        // generation 变化：暂停旧上下文提交，重新 bootstrap
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

  // ---------- 冲突解决 ----------

  /// 保留本机：以远端 revision 为 base 提交新版本。
  Future<void> resolveKeepLocal(String kind, String id) async {
    final c = state.conflicts
        .firstWhere((c) => c.kind == kind && c.id == id && !c.resolved);
    final bytes = kind == 'todo'
        ? todoBytes(model.byId(id)!)
        : kind == 'classification'
            ? classificationBytes()
            : indexBytes();
    final hash = sha256Of(bytes);
    await _ensurePayloadUploaded(hash, bytes);
    await _submitPush(PendingPush(_newRequestId(), state.generation ?? 1, [
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
    ], []));
    c.resolved = true;
    await _persist();
    notifyListeners();
  }

  /// 采用远端：拉取远端对象覆盖本机（恢复副本由 store 保存流程自动保留）。
  Future<void> resolveUseRemote(String kind, String id) async {
    final c = state.conflicts
        .firstWhere((c) => c.kind == kind && c.id == id && !c.resolved);
    final hash = c.remoteContentHash;
    if (hash != null) {
      final bytes = await _downloadPayload(hash);
      if (sha256Of(bytes) == hash) {
        await _writeRemoteObject(kind, id, bytes);
        state.baselines[state.baselineKey(kind, id)] =
            ObjectBaseline(kind, id, c.remoteRevision, hash);
      }
    }
    c.resolved = true;
    await _persist();
    notifyListeners();
  }

  // ---------- 顶层同步 ----------

  Future<void> syncNow() async {
    if (busy) return;
    busy = true;
    status = SyncStatus.syncing;
    notifyListeners();
    try {
      if (!state.bootstrapped) {
        await bootstrapAndApply();
        if (status == SyncStatus.error) return;
      }
      await pull();
      await pushDirty();
      status = state.pendingPush != null
          ? SyncStatus.partialFailed
          : state.conflicts.any((c) => !c.resolved)
              ? SyncStatus.conflict
              : SyncStatus.synced;
      lastError = null;
    } on SyncException catch (e) {
      status = SyncStatus.error;
      lastError = e.message;
    } on DioException catch (e) {
      status = SyncStatus.error;
      lastError = _dioMessage(e, '同步失败');
    } catch (e) {
      status = SyncStatus.error;
      lastError = e.toString();
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> setAutoSync(bool enabled) async {
    state.autoSync = enabled;
    await _persist();
    notifyListeners();
  }

  String _dioMessage(DioException e, String fallback) {
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

class SyncPreview {
  final int localOnly;
  final int remoteOnly;
  final int conflicts;
  SyncPreview(this.localOnly, this.remoteOnly, this.conflicts);
}
