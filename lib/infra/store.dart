/// 本地文件仓库：content/tips、classification.json、index.json、state、recovery。
/// 原子写入：临时文件 → rename；保留 `recovery/<id>.prev.md` 副本。
library;

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import '../core/ulid.dart';
import '../domain/classification.dart';
import '../domain/todo.dart';
import 'markdown_doc.dart';

/// 图片导入被拒（格式不支持/超限）：保留编辑内容并提示原因。
class ImageRejectException implements Exception {
  final String message;
  const ImageRejectException(this.message);
  @override
  String toString() => message;
}

class TodoStore {
  final Directory root; // <data>/TaskTips 等价的应用专属目录
  TodoStore(this.root);

  Directory get contentDir => Directory(p.join(root.path, 'content'));
  Directory get tipsDir => Directory(p.join(contentDir.path, 'tips'));
  Directory get imagesDir => Directory(p.join(tipsDir.path, 'images'));

  /// 魔数白名单（不信任文件名与 MIME）：PNG/JPEG/GIF/WebP/BMP，SVG 拒绝。
  /// 返回扩展名；不识别返回 null。
  static String? sniffImageExtension(Uint8List b) {
    if (b.length >= 4) {
      if (b[0] == 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47) {
        return 'png';
      }
      // RIFF....WEBP：需满 12 字节才判定（与桌面 image_store.rs 一致）
      if (b.length >= 12 &&
          b[0] == 0x52 && b[1] == 0x49 && b[2] == 0x46 && b[3] == 0x46 &&
          b[8] == 0x57 && b[9] == 0x45 && b[10] == 0x42 && b[11] == 0x50) {
        return 'webp';
      }
    }
    if (b.length >= 6) {
      // 仅接受 GIF87a / GIF89a 全 6 字节（桌面 image_store.rs 同）
      if ((b[0] == 0x47 && b[1] == 0x49 && b[2] == 0x46 && b[3] == 0x38 &&
              b[4] == 0x37 && b[5] == 0x61) ||
          (b[0] == 0x47 && b[1] == 0x49 && b[2] == 0x46 && b[3] == 0x38 &&
              b[4] == 0x39 && b[5] == 0x61)) {
        return 'gif';
      }
    }
    if (b.length >= 3 && b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF) {
      return 'jpg';
    }
    if (b.length >= 2 && b[0] == 0x42 && b[1] == 0x4D) return 'bmp';
    return null;
  }

  static const maxImageBytes = 10 * 1024 * 1024;

  /// 保存图片：魔数校验 + ≤10MiB，生成 `images/<ULID>.<ext>`（绝不使用用户
  /// 原始文件名），临时文件 + rename 原子写。返回正文引用相对路径。
  /// 校验失败抛参数错误（调用方保留编辑内容并提示原因，禁止截断）。
  Future<String> saveImage(Uint8List bytes) async {
    if (bytes.isEmpty) throw const ImageRejectException('图片内容为空');
    if (bytes.length > maxImageBytes) {
      throw ImageRejectException(
          '图片超过 10MiB 上限（当前 ${(bytes.length / 1024 / 1024).toStringAsFixed(1)}MiB）');
    }
    final ext = sniffImageExtension(bytes);
    if (ext == null) {
      throw const ImageRejectException('不支持的图片格式（支持 PNG/JPEG/GIF/WebP/BMP，不支持 SVG）');
    }
    final name = '${newUlid()}.$ext';
    final f = File(p.join(imagesDir.path, name));
    final tmp = File('${f.path}.tmp');
    await tmp.writeAsBytes(bytes, flush: true);
    await tmp.rename(f.path);
    return 'images/$name';
  }
  Directory get stateDir => Directory(p.join(root.path, 'state'));
  Directory get recoveryDir => Directory(p.join(root.path, 'recovery'));

  File _tipFile(String id) => File(p.join(tipsDir.path, '$id.md'));
  File get classificationFile =>
      File(p.join(contentDir.path, 'classification.json'));
  File get indexFile => File(p.join(contentDir.path, 'index.json'));
  File get settingsFile => File(p.join(stateDir.path, 'settings.json'));
  File get deviceIdFile => File(p.join(stateDir.path, 'device_id.json'));

  static const retentionDays = 30;

  /// 墓碑保留期（对齐桌面 index.rs TOMBSTONE_RETENTION_DAYS）。
  static const tombstoneRetentionDays = 90;

  Future<void> init() async {
    for (final d in [contentDir, tipsDir, imagesDir, stateDir, recoveryDir]) {
      await d.create(recursive: true);
    }
  }

  // ---------- device id ----------

  Future<String> loadOrCreateDeviceId() async {
    final f = deviceIdFile;
    if (await f.exists()) {
      final j = jsonDecode(await f.readAsString()) as Map<String, Object?>;
      final id = j['deviceId'] as String?;
      if (id != null && id.isNotEmpty) return id;
    }
    final id = _uuidV4();
    await _atomicWriteString(f, jsonEncode({'deviceId': id}));
    return id;
  }

  String _uuidV4() {
    final b = List<int>.generate(16, (_) => _rnd.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    String hex(int v) => v.toRadixString(16).padLeft(2, '0');
    final h = b.map(hex).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-'
        '${h.substring(16, 20)}-${h.substring(20)}';
  }

  static final _rnd = Random.secure();

  // ---------- todos ----------

  /// 全量扫描 tips/*.md。单条损坏不阻断，返回只读条目信息。
  Future<ScanResult> scanTodos() async {
    final todos = <Todo>[];
    final corrupt = <CorruptTip>[];
    await for (final e in tipsDir.list()) {
      if (e is! File || !e.path.endsWith('.md')) continue;
      final name = p.basename(e.path);
      try {
        final parsed = parseTodoDoc(await e.readAsString());
        todos.add(todoFromFields(parsed.fields, parsed.body));
      } catch (err) {
        await _keepRecoveryCopy(name, e);
        corrupt.add(CorruptTip(name, err.toString()));
      }
    }
    return ScanResult(todos, corrupt);
  }

  Future<void> _keepRecoveryCopy(String fileName, File src) async {
    try {
      final dst = File(p.join(recoveryDir.path, '$fileName.prev'));
      if (!await dst.exists()) await src.copy(dst.path);
    } catch (_) {}
  }

  /// 原子保存：先复制上一版到 recovery，再写 tmp 后 rename。
  Future<void> saveTodo(Todo t) async {
    final f = _tipFile(t.id);
    if (await f.exists()) {
      await _keepRecoveryCopy('${t.id}.md', f);
    }
    await _atomicWriteString(f, serializeTodoDoc(t));
  }

  Future<Todo?> readTodo(String id) async {
    final f = _tipFile(id);
    if (!await f.exists()) return null;
    final parsed = parseTodoDoc(await f.readAsString());
    return todoFromFields(parsed.fields, parsed.body);
  }

  /// 物理删除文件。墓碑必须由调用方先持久化到 index.json。
  Future<void> deleteTodoFile(String id) async {
    await _tipFile(id).deleteIfExists();
  }

  // ---------- classification ----------

  /// 返回 (数据, 是否损坏)。损坏时备份原件并返回空，不阻断启动；
  /// 调用方据损坏标志进入只读/暂停推送状态（设计 §4.1）。
  Future<(Classification, bool)> loadClassification() async {
    final f = classificationFile;
    if (!await f.exists()) return (Classification([], []), false);
    try {
      final raw = await f.readAsString();
      return (
        Classification.fromJson(
            (jsonDecode(raw) as Map).cast<String, Object?>(), raw: raw),
        false
      );
    } catch (_) {
      await _keepRecoveryCopy('classification.json', f);
      return (Classification([], []), true);
    }
  }

  /// 未修改时按原文写回（与桌面端 pretty 序列化逐字节一致的保障）。
  Future<void> saveClassification(Classification c) async {
    if (!c.dirty && c.rawJson != null) {
      await _atomicWriteString(classificationFile, c.rawJson!);
      return;
    }
    final text = const JsonEncoder.withIndent('  ').convert(c.toJson());
    await _atomicWriteString(classificationFile, text);
    c
      ..rawJson = text
      ..dirty = false;
  }

  /// 供同步适配层从原始 JSON 字节构建分类/索引。
  Classification classificationFromRawJson(String raw) =>
      Classification.fromJson(
          (jsonDecode(raw) as Map).cast<String, Object?>(),
          raw: raw);

  IndexData indexFromRawJson(String raw) =>
      IndexData.fromJson((jsonDecode(raw) as Map).cast<String, Object?>());

  static const _jsonEncoder = JsonEncoder.withIndent('  ');

  String classificationJson(Classification c) => _jsonEncoder.convert(c.toJson());

  /// index 对象的哈希与推送 payload 唯一形态：与 saveIndex 相同的规范 JSON。
  String indexJson(IndexData i) => canonicalJson(i.toJson());

  // ---------- index（自定义排序 + 墓碑） ----------

  Future<(IndexData, bool)> loadIndex() async {
    final f = indexFile;
    if (!await f.exists()) return (IndexData.empty(), false);
    try {
      final j = jsonDecode(await f.readAsString()) as Map<String, Object?>;
      return (IndexData.fromJson(j), false);
    } catch (_) {
      await _keepRecoveryCopy('index.json', f);
      return (IndexData.empty(), true);
    }
  }

  /// 始终写规范形态（字典序 + 2 空格缩进，不含 lastScanAt）：
  /// 与桌面端 normalize_json_payload 输出逐字节一致，是跨端哈希收敛的基础。
  Future<void> saveIndex(IndexData idx) async {
    await _atomicWriteString(indexFile, canonicalJson(idx.toJson()));
  }

  // ---------- settings（本机状态，不同步） ----------

  Future<Map<String, Object?>> loadSettings() async {
    final f = settingsFile;
    if (!await f.exists()) return {};
    try {
      return jsonDecode(await f.readAsString()) as Map<String, Object?>;
    } catch (_) {
      return {};
    }
  }

  Future<void> saveSettings(Map<String, Object?> s) async {
    await _atomicWriteString(
        settingsFile, const JsonEncoder.withIndent('  ').convert(s));
  }

  // ---------- 原子写入 ----------

  Future<void> _atomicWriteString(File f, String s) async {
    final tmp = File('${f.path}.tmp');
    await tmp.writeAsString(s, flush: true);
    await f.parent.create(recursive: true);
    await tmp.rename(f.path);
  }
}

class CorruptTip {
  final String fileName;
  final String reason;
  CorruptTip(this.fileName, this.reason);
}

class ScanResult {
  final List<Todo> todos;
  final List<CorruptTip> corrupt;
  ScanResult(this.todos, this.corrupt);
}

class Tombstone {
  final String id; // 对象 ID
  final String kind; // 与桌面 ObjectKind 墓碑域一致：todo / image
  final String deletedAt; // RFC 3339 原文（保持跨端字节一致，纳秒精度不截断）
  final int revision;
  final String deviceId;
  final String projectId; // 桌面端 index 墓碑恒写，本机缺省 "local"
  final Object? baseRevision; // 桌面端记录的来源基线；本机创建恒 null
  final Map<String, Object?> extra; // 未知字段原样保留

  Tombstone(this.id, this.kind, this.deletedAt, this.revision, this.deviceId,
      {this.projectId = 'local', this.baseRevision, Map<String, Object?>? extra})
      : extra = extra ?? {};

  DateTime get deletedAtUtc => DateTime.parse(deletedAt).toUtc();

  Map<String, Object?> toJson() => {
        'projectId': projectId,
        'kind': kind,
        'id': id,
        'revision': revision,
        if (baseRevision != null) 'baseRevision': baseRevision,
        'deletedAt': deletedAt,
        'deviceId': deviceId,
        ...extra,
      };

  static Tombstone fromJson(Map<String, Object?> j) {
    final deletedAt = j['deletedAt'];
    if (deletedAt is! String || deletedAt.isEmpty) {
      // 桌面端 deletedAt 为必填：缺失视为损坏，交由调用方的损坏隔离路径
      throw FormatException('墓碑缺少 deletedAt: ${j['id']}');
    }
    return Tombstone(
      j['id'] as String,
      j['kind'] as String,
      deletedAt,
      (j['revision'] as num).toInt(),
      (j['deviceId'] as String?) ?? '',
      projectId: (j['projectId'] as String?) ?? 'local',
      baseRevision: j['baseRevision'],
      extra: _extras(j, const {
        'projectId', 'kind', 'id', 'revision', 'baseRevision',
        'deletedAt', 'deviceId',
      }),
    );
  }
}

Map<String, Object?> _extras(Map<String, Object?> j, Set<String> known) {
  final out = <String, Object?>{};
  j.forEach((k, v) {
    if (!known.contains(k)) out[k] = v;
  });
  return out;
}

class IndexData {
  int schemaVersion;
  Map<String, List<String>> customOrder; // view -> todo id 列表（inbox/all）
  List<Tombstone> tombstones;

  IndexData(this.schemaVersion, this.customOrder, this.tombstones);

  static IndexData empty() => IndexData(1, {}, []);

  Map<String, Object?> toJson() => {
        'schemaVersion': schemaVersion,
        // 对齐桌面 TipIndex：customOrder 为 None（本端空 map）时整个键省略
        if (customOrder.isNotEmpty) 'customOrder': customOrder,
        'tombstones': tombstones.map((t) => t.toJson()).toList(),
      };

  static IndexData fromJson(Map<String, Object?> j) => IndexData(
        (j['schemaVersion'] as num?)?.toInt() ?? 1,
        (((j['customOrder'] as Map?) ?? {})
            .map((k, v) =>
                MapEntry(k.toString(), (v as List).map((e) => e.toString()).toList()))
          // 桌面端 CustomOrder 为 typed 结构（inbox/all），未知键解析即丢弃；
          // 本端同样只保留该键域，避免两端对未知键的保留策略不对称
          ..removeWhere((k, _) => k != 'inbox' && k != 'all')),
        ((j['tombstones'] as List?) ?? [])
            .map((e) => Tombstone.fromJson((e as Map).cast<String, Object?>()))
            .toList(),
      );
}

/// 规范 JSON：递归按 key 字典序排列后 2 空格缩进输出。
/// 与桌面端 serde_json::Value（BTreeMap 字典序）+ to_string_pretty 逐字节一致，
/// 是 index 对象哈希与推送 payload 的统一形态。
const _canonicalEncoder = JsonEncoder.withIndent('  ');

Object? _sortKeysDeep(Object? v) {
  if (v is Map) {
    final keys = v.keys.map((k) => k.toString()).toList()..sort();
    return {
      for (final k in keys) k: _sortKeysDeep(v[k]),
    };
  }
  if (v is List) return v.map(_sortKeysDeep).toList();
  return v;
}

String canonicalJson(Object? value) =>
    _canonicalEncoder.convert(_sortKeysDeep(value));

extension _FileDelete on File {
  Future<void> deleteIfExists() async {
    if (await exists()) await delete();
  }
}
