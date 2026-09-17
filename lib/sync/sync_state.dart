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
  /// 远端版本是删除（墓碑）时为 true：面板需标示“此版本为删除”。
  final bool remoteDeleted;
  bool resolved;

  ConflictRecord(this.kind, this.id, this.localRevision, this.remoteRevision,
      this.remoteContentHash,
      {this.remoteDeleted = false, this.resolved = false});

  Map<String, Object?> toJson() => {
        'kind': kind,
        'id': id,
        'localRevision': localRevision,
        'remoteRevision': remoteRevision,
        'remoteContentHash': remoteContentHash,
        'remoteDeleted': remoteDeleted,
        'resolved': resolved,
      };

  static ConflictRecord fromJson(Map<String, Object?> j) => ConflictRecord(
      j['kind'] as String,
      j['id'] as String,
      (j['localRevision'] as num).toInt(),
      (j['remoteRevision'] as num).toInt(),
      j['remoteContentHash'] as String?,
      remoteDeleted: j['remoteDeleted'] == true,
      resolved: j['resolved'] == true);
}

/// 被服务端拒绝的对象：记录错误码与当时 revision/hash，
/// 本地版本未变化前不再重试（校验失败停止重试该对象）。
class RejectedRecord {
  final String code;
  final int revision; // 分类/索引等无 revision 的对象以 -1 表示
  final String? contentHash;

  RejectedRecord(this.code, this.revision, this.contentHash);

  Map<String, Object?> toJson() =>
      {'code': code, 'revision': revision, if (contentHash != null) 'contentHash': contentHash};

  static RejectedRecord fromJson(Map<String, Object?> j) => RejectedRecord(
      j['code'] as String,
      (j['revision'] as num?)?.toInt() ?? -1,
      j['contentHash'] as String?);
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
  /// 被拒绝对象（key → 记录）：本地未变化前不再重试。
  final Map<String, RejectedRecord> rejected = {};
  /// 登录失效/设备撤销/项目维护时暂停自动提交，存错误码；手动同步不受限。
  String? submitPaused;
  /// 上次完整同步轮完成时间（UI 状态卡“上次同步”）。
  DateTime? lastSyncAt;
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
        'rejected': rejected.map((k, v) => MapEntry(k, v.toJson())),
        'submitPaused': submitPaused,
        'lastSyncAt': lastSyncAt?.toUtc().toIso8601String(),
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
    ((j['rejected'] as Map?) ?? {}).forEach((k, v) {
      s.rejected[k as String] =
          RejectedRecord.fromJson((v as Map).cast<String, Object?>());
    });
    s.submitPaused = j['submitPaused'] as String?;
    s.lastSyncAt = j['lastSyncAt'] == null
        ? null
        : DateTime.parse(j['lastSyncAt'] as String);
    return s;
  }

  void addLog(SyncLogEntry e) {
    logs.insert(0, e);
    if (logs.length > 200) logs.removeRange(200, logs.length);
  }

  String baselineKey(String kind, String id) => '$kind/$id';

  /// 记录/更新冲突：同一对象的未解决冲突只保留最新一条。
  /// 多轮 pull 反复收到同一对象的远端更新时不去重会累积出
  /// 多张重复冲突卡，且逐条解决后才真正清除。
  void addConflict(ConflictRecord c) {
    final i = conflicts.indexWhere(
        (e) => e.kind == c.kind && e.id == c.id && !e.resolved);
    if (i >= 0) {
      conflicts[i] = c;
    } else {
      conflicts.add(c);
    }
  }
}

/// sync-state.json 的字符串序列化（文件读写由引擎负责）。
class SyncStateStore {
  static const _encoder = JsonEncoder.withIndent('  ');

  static SyncStateData load(String raw) =>
      raw.isEmpty ? SyncStateData() : SyncStateData.fromJson(
          (jsonDecode(raw) as Map).cast<String, Object?>());

  static String save(SyncStateData d) => _encoder.convert(d.toJson());
}
