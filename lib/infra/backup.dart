/// 本机备份包：经系统文件选择器导出/恢复 content/ 全量（未同步用户的迁移通路）。
///
/// 入包：content/tips/**（含 images/）、content/classification.json、
/// content/index.json，以及包根 manifest.json。
/// 不进包：state/（设备身份/同步基线/未完成请求/凭据引用）、recovery/、
/// 本机设置——恢复后按新设备走 bootstrap，不复用旧提交上下文（设计 §4.4）。
/// 恢复语义：覆盖本机。先把现 content/ 改名快照到 `recovery/backup-<ts>/`，
/// 失败回滚（删残留、迁回原件）。恢复后内容按本机改动参与下次同步。
library;

import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;

import 'store.dart';

class BackupException implements Exception {
  final String message;
  const BackupException(this.message);
  @override
  String toString() => message;
}

const _kBackupFormat = 'tasktips-backup';
const _kBackupFormatVersion = 1;
const _kManifestName = 'manifest.json';

/// 导出备份包到 [destPath]（调用方经 SAF 拿到可写路径）。
Future<void> exportBackup(TodoStore store, String destPath,
    {required String appVersion}) async {
  final contentDir = store.contentDir;
  final encoder = ZipFileEncoder();
  try {
    encoder.create(destPath);
    if (await contentDir.exists()) {
      await for (final e in contentDir.list(recursive: true)) {
        if (e is! File) continue;
        if (e.path.endsWith('.tmp')) continue; // 跳过原子写残留
        final rel = p.relative(e.path, from: contentDir.path);
        await encoder.addFile(e, 'content/$rel');
      }
    }
    final manifest = utf8.encode(jsonEncode({
      'format': _kBackupFormat,
      'formatVersion': _kBackupFormatVersion,
      'appVersion': appVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
    }));
    encoder.addArchiveFile(
        ArchiveFile(_kManifestName, manifest.length, manifest));
    await encoder.close();
  } catch (_) {
    try {
      await encoder.close();
    } catch (_) {}
    rethrow;
  }
}

/// 从备份包恢复（覆盖本机）。校验失败或写入失败时回滚并抛 [BackupException]。
Future<void> importBackup(TodoStore store, String srcPath,
    {Future<void> Function()? prepareRestoredContent}) async {
  late final Archive archive;
  try {
    archive = ZipDecoder()
        .decodeBytes(await File(srcPath).readAsBytes());
  } catch (e) {
    throw BackupException('备份文件无法解析：$e');
  }
  final manifestFile = archive.files
      .where((f) => f.name == _kManifestName && f.isFile)
      .firstOrNull;
  if (manifestFile == null) {
    throw const BackupException('备份文件缺少 manifest');
  }
  late final Map<String, Object?> manifest;
  try {
    manifest =
        (jsonDecode(utf8.decode(manifestFile.content as List<int>)) as Map)
            .cast<String, Object?>();
  } catch (_) {
    throw const BackupException('备份 manifest 已损坏');
  }
  if (manifest['format'] != _kBackupFormat ||
      manifest['formatVersion'] != _kBackupFormatVersion) {
    throw const BackupException('不支持的备份格式版本');
  }
  // 路径安全：仅允许包根 manifest 与 content/ 下相对路径，拒绝绝对路径与 `..`
  final entries = <ArchiveFile>[];
  for (final f in archive.files) {
    if (!f.isFile || f.name == _kManifestName) continue;
    final name = f.name.replaceAll('\\', '/');
    if (!name.startsWith('content/') ||
        name.contains('..') ||
        p.isAbsolute(name)) {
      throw BackupException('备份包含非法路径：${f.name}');
    }
    entries.add(f);
  }

  final contentDir = store.contentDir;
  final stamp = DateTime.now()
      .toUtc()
      .toIso8601String()
      .replaceAll(':', '-')
      .replaceAll('.', '-');
  final stash = Directory(p.join(store.recoveryDir.path, 'backup-$stamp'));  final hadContent = await contentDir.exists();
  try {
    await store.recoveryDir.create(recursive: true);
    if (hadContent) {
      await contentDir.rename(stash.path); // 现状快照，可反悔
    }
    await contentDir.create(recursive: true);
    for (final f in entries) {
      final rel = f.name.substring('content/'.length);
      if (rel.isEmpty) continue;
      final out = File(p.join(contentDir.path, rel));
      await out.parent.create(recursive: true);
      await out.writeAsBytes(f.content as List<int>, flush: true);
    }
    // 同步层在同一回滚边界内补齐删除意图；任何失败仍恢复原 content/。
    await prepareRestoredContent?.call();
  } catch (e) {
    // 回滚：删残留、迁回原件
    try {
      if (await contentDir.exists()) {
        await contentDir.delete(recursive: true);
      }
      if (hadContent) await stash.rename(contentDir.path);
    } catch (_) {}
    throw BackupException('恢复失败，已回滚：$e');
  }
}

/// 快照本机 content/ 到 `recovery/<prefix>-<ts>/`（切换项目“放弃本地”前可反悔用）。
/// 拷贝失败时不改动现状，返回快照目录。
Future<Directory> stashContentDir(TodoStore store, String prefix) async {
  final stamp = DateTime.now()
      .toUtc()
      .toIso8601String()
      .replaceAll(':', '-')
      .replaceAll('.', '-');
  final dst = Directory(p.join(store.recoveryDir.path, '$prefix-$stamp'));
  await store.recoveryDir.create(recursive: true);
  final src = store.contentDir;
  if (await src.exists()) {
    await for (final e in src.list(recursive: true)) {
      if (e is! File || e.path.endsWith('.tmp')) continue;
      final rel = p.relative(e.path, from: src.path);
      final out = File(p.join(dst.path, 'content', rel));
      await out.parent.create(recursive: true);
      await e.copy(out.path);
    }
  }
  return dst;
}
