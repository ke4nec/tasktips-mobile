/// 同步基线与日志的本地持久化（state/，不参与同步）。
/// 按规范化服务端地址 + 账号 ID + 项目 ID 隔离。
library;

import 'dart:convert';

/// 单对象远端基线：已确认的 revision 与内容哈希。
class ObjectBaseline {
  final String kind;
  final String id;
  int revision;
  String? contentHash;

  ObjectBaseline(this.kind, this.id, this.revision, this.contentHash);

  Map<String, Object?> toJson() =>
      {'kind': kind, 'id': id, 'revision': revision, 'contentHash': contentHash};

  static ObjectBaseline fromJson(Map<String, Object?> j) => ObjectBaseline(
      j['kind'] as String,
      j['id'] as String,
      (j['revision'] as num).toInt(),
      j['contentHash'] as String?);
}

/// 未完成的 push 请求：请求 ID + 不可变请求内容，响应丢失后原样重试。
class PendingPush {
  final String requestId;
  final int generation;
  final List<Map<String, Object?>> objects;
  final List<Map<String, Object?>> tombstones;

  PendingPush(this.requestId, this.generation, this.objects, this.tombstones);

  Map<String, Object?> toJson() => {
        'requestId': requestId,
        'generation': generation,
        'objects': objects,
        'tombstones': tombstones,
      };

  static PendingPush fromJson(Map<String, Object?> j) => PendingPush(
      j['requestId'] as String,
      (j['generation'] as num).toInt(),
      ((j['objects'] as List?) ?? [])
          .map((e) => (e as Map).cast<String, Object?>())
          .toList(),
      ((j['tombstones'] as List?) ?? [])
          .map((e) => (e as Map).cast<String, Object?>())
          .toList());
}

class ConflictRecord {
  final String kind;
  final String id;
  final int localRevision;
  final int remoteRevision;
  final String? remoteContentHash;
  bool resolved;

  ConflictRecord(this.kind, this.id, this.localRevision, this.remoteRevision,
      this.remoteContentHash,
      {this.resolved = false});

  Map<String, Object?> toJson() => {
        'kind': kind,
        'id': id,
        'localRevision': localRevision,
        'remoteRevision': remoteRevision,
        'remoteContentHash': remoteContentHash,
        'resolved': resolved,
      };

  static ConflictRecord fromJson(Map<String, Object?> j) => ConflictRecord(
      j['kind'] as String,
      j['id'] as String,
      (j['localRevision'] as num).toInt(),
      (j['remoteRevision'] as num).toInt(),
      j['remoteContentHash'] as String?,
      resolved: j['resolved'] == true);
}

/// 本机同步日志：仅时间、方向、数量、结果与错误码，不含正文/凭据。
class SyncLogEntry {
  final DateTime at;
  final String direction; // upload / download / login / bootstrap
  final int count;
  final String result; // ok / error / conflict
  final String? errorCode;

  SyncLogEntry(this.at, this.direction, this.count, this.result, [this.errorCode]);

  Map<String, Object?> toJson() => {
        'at': at.toUtc().toIso8601String(),
        'direction': direction,
        'count': count,
        'result': result,
        if (errorCode != null) 'errorCode': errorCode,
      };

  static SyncLogEntry fromJson(Map<String, Object?> j) => SyncLogEntry(
      DateTime.parse(j['at'] as String),
      j['direction'] as String,
      (j['count'] as num?)?.toInt() ?? 0,
      j['result'] as String,
      j['errorCode'] as String?);
}

class SyncStateData {
  String? serverUrl; // 规范化（scheme + host[:port]）
  String? accountId;
  String? email;
  String? projectId;
  int? generation;
  String? pullCursor;
  final Map<String, ObjectBaseline> baselines = {};
  PendingPush? pendingPush;
  final List<ConflictRecord> conflicts = [];
  final List<SyncLogEntry> logs = [];
  bool autoSync = false;
  bool bootstrapped = false;

  Map<String, Object?> toJson() => {
        'schemaVersion': 1,
        'serverUrl': serverUrl,
        'accountId': accountId,
        'email': email,
        'projectId': projectId,
        'generation': generation,
        'pullCursor': pullCursor,
        'baselines': baselines.map((k, v) => MapEntry(k, v.toJson())),
        'pendingPush': pendingPush?.toJson(),
        'conflicts': conflicts.map((c) => c.toJson()).toList(),
        'logs': logs.map((l) => l.toJson()).toList(),
        'autoSync': autoSync,
        'bootstrapped': bootstrapped,
      };

  static SyncStateData fromJson(Map<String, Object?> j) {
    final s = SyncStateData();
    s.serverUrl = j['serverUrl'] as String?;
    s.accountId = j['accountId'] as String?;
    s.email = j['email'] as String?;
    s.projectId = j['projectId'] as String?;
    s.generation = (j['generation'] as num?)?.toInt();
    s.pullCursor = j['pullCursor'] as String?;
    ((j['baselines'] as Map?) ?? {}).forEach((k, v) {
      s.baselines[k as String] =
          ObjectBaseline.fromJson((v as Map).cast<String, Object?>());
    });
    s.pendingPush = j['pendingPush'] == null
        ? null
        : PendingPush.fromJson((j['pendingPush'] as Map).cast<String, Object?>());
    s.conflicts.addAll(((j['conflicts'] as List?) ?? [])
        .map((e) => ConflictRecord.fromJson((e as Map).cast<String, Object?>())));
    s.logs.addAll(((j['logs'] as List?) ?? [])
        .map((e) => SyncLogEntry.fromJson((e as Map).cast<String, Object?>())));
    s.autoSync = j['autoSync'] == true;
    s.bootstrapped = j['bootstrapped'] == true;
    return s;
  }

  void addLog(SyncLogEntry e) {
    logs.insert(0, e);
    if (logs.length > 200) logs.removeRange(200, logs.length);
  }

  String baselineKey(String kind, String id) => '$kind/$id';
}

class SyncStateStore {
  // 简单 JSON 文件持久化；凭据另存安全存储。
  // ignore: unused_field
  final String _path;
  SyncStateStore(this._path);

  static const _encoder = JsonEncoder.withIndent('  ');

  SyncStateData load(String raw) =>
      raw.isEmpty ? SyncStateData() : SyncStateData.fromJson(
          (jsonDecode(raw) as Map).cast<String, Object?>());

  String save(SyncStateData d) => _encoder.convert(d.toJson());
}
