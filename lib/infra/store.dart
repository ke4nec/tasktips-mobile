/// 本地文件仓库：content/tips、classification.json、index.json、state、recovery。
/// 原子写入：临时文件 → rename；保留 `recovery/<id>.prev.md` 副本。
library;

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;

import '../domain/classification.dart';
import '../domain/todo.dart';
import 'markdown_doc.dart';

class TodoStore {
  final Directory root; // <data>/TaskTips 等价的应用专属目录
  TodoStore(this.root);

  Directory get contentDir => Directory(p.join(root.path, 'content'));
  Directory get tipsDir => Directory(p.join(contentDir.path, 'tips'));
  Directory get imagesDir => Directory(p.join(tipsDir.path, 'images'));
  Directory get stateDir => Directory(p.join(root.path, 'state'));
  Directory get recoveryDir => Directory(p.join(root.path, 'recovery'));

  File _tipFile(String id) => File(p.join(tipsDir.path, '$id.md'));
  File get classificationFile =>
      File(p.join(contentDir.path, 'classification.json'));
  File get indexFile => File(p.join(contentDir.path, 'index.json'));
  File get settingsFile => File(p.join(stateDir.path, 'settings.json'));
  File get deviceIdFile => File(p.join(stateDir.path, 'device_id.json'));

  static const retentionDays = 30;

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

  Future<Classification> loadClassification() async {
    final f = classificationFile;
    if (!await f.exists()) return Classification([], []);
    try {
      final j = jsonDecode(await f.readAsString()) as Map<String, Object?>;
      return Classification.fromJson(j);
    } catch (_) {
      // 损坏时备份原件并返回空，避免阻断启动
      await _keepRecoveryCopy('classification.json', f);
      return Classification([], []);
    }
  }

  Future<void> saveClassification(Classification c) async {
    await _atomicWriteString(
        classificationFile,
        const JsonEncoder.withIndent('  ').convert(c.toJson()));
  }

  /// 供同步适配层从原始 JSON 字节构建分类/索引。
  Classification classificationFromRawJson(String raw) =>
      Classification.fromJson(
          (jsonDecode(raw) as Map).cast<String, Object?>());

  IndexData indexFromRawJson(String raw) =>
      IndexData.fromJson((jsonDecode(raw) as Map).cast<String, Object?>());

  static const _jsonEncoder = JsonEncoder.withIndent('  ');

  String classificationJson(Classification c) => _jsonEncoder.convert(c.toJson());

  String indexJson(IndexData i) => _jsonEncoder.convert(i.toJson());

  // ---------- index（自定义排序 + 墓碑） ----------

  Future<IndexData> loadIndex() async {
    final f = indexFile;
    if (!await f.exists()) return IndexData.empty();
    try {
      final j = jsonDecode(await f.readAsString()) as Map<String, Object?>;
      return IndexData.fromJson(j);
    } catch (_) {
      await _keepRecoveryCopy('index.json', f);
      return IndexData.empty();
    }
  }

  Future<void> saveIndex(IndexData idx) async {
    await _atomicWriteString(
        indexFile, const JsonEncoder.withIndent('  ').convert(idx.toJson()));
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
  final String kind; // todo / category / tag / image
  final DateTime deletedAt;
  final int revision;
  final String deviceId;
  Tombstone(this.id, this.kind, this.deletedAt, this.revision, this.deviceId);

  Map<String, Object?> toJson() => {
        'id': id,
        'kind': kind,
        'deletedAt': deletedAt.toUtc().toIso8601String(),
        'revision': revision,
        'deviceId': deviceId,
      };

  static Tombstone fromJson(Map<String, Object?> j) => Tombstone(
        j['id'] as String,
        j['kind'] as String,
        DateTime.parse(j['deletedAt'] as String),
        (j['revision'] as num).toInt(),
        j['deviceId'] as String,
      );
}

class IndexData {
  int schemaVersion;
  Map<String, List<String>> customOrder; // view -> todo id 列表
  List<Tombstone> tombstones;
  DateTime? lastScanAt;

  IndexData(this.schemaVersion, this.customOrder, this.tombstones, this.lastScanAt);

  static IndexData empty() => IndexData(1, {}, [], null);

  Map<String, Object?> toJson() => {
        'schemaVersion': schemaVersion,
        'customOrder': customOrder,
        'tombstones': tombstones.map((t) => t.toJson()).toList(),
        'lastScanAt': lastScanAt?.toUtc().toIso8601String(),
      };

  static IndexData fromJson(Map<String, Object?> j) => IndexData(
        (j['schemaVersion'] as num?)?.toInt() ?? 1,
        ((j['customOrder'] as Map?) ?? {})
            .map((k, v) => MapEntry(k.toString(), (v as List).map((e) => e.toString()).toList())),
        ((j['tombstones'] as List?) ?? [])
            .map((e) => Tombstone.fromJson((e as Map).cast()))
            .toList(),
        j['lastScanAt'] == null ? null : DateTime.parse(j['lastScanAt'] as String),
      );
}

extension _FileDelete on File {
  Future<void> deleteIfExists() async {
    if (await exists()) await delete();
  }
}
