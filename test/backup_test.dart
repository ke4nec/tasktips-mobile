/// 本机备份包导出/恢复与切换重置测试。
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:tasktips/app/app_model.dart';
import 'package:tasktips/infra/backup.dart';
import 'package:tasktips/infra/store.dart';

Future<AppModel> _seedModel(Directory dir) async {
  final model = AppModel(TodoStore(dir));
  await model.load();
  await model.createCategory('工作');
  final cat = model.rootCategories.single;
  await model.createTag('重要');
  await model.createTodo(categoryId: cat.id, tagName: '重要');
  await model.createTodo();
  final png = Uint8List.fromList(
      [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
  await model.store.saveImage(png);
  model.index.customOrder['inbox'] = [model.todos.first.id];
  await model.store.saveIndex(model.index);
  // state/ 写入标记文件：必须永不进包
  await File(p.join(model.store.stateDir.path, 'marker.txt'))
      .writeAsString('secret');
  return model;
}

void main() {
  group('备份包往返', () {
    test('导出→导入到新目录：内容全等，state/ 不进包', () async {
      final dirA = await Directory.systemTemp.createTemp('tt_bakA');
      final modelA = await _seedModel(dirA);
      final zipPath = p.join(dirA.path, 'backup.zip');
      await exportBackup(modelA.store, zipPath, appVersion: '1.0.0');

      // 包内条目限定：content/ 与包根 manifest
      final archive =
          ZipDecoder().decodeBytes(await File(zipPath).readAsBytes());
      expect(archive.files.map((f) => f.name),
          everyElement(anyOf(equals('manifest.json'), startsWith('content/'))));
      expect(
          archive.files
              .where((f) => f.name.contains('state'))
              .isEmpty,
          isTrue);

      final dirB = await Directory.systemTemp.createTemp('tt_bakB');
      final storeB = TodoStore(dirB);
      await importBackup(storeB, zipPath);
      final modelB = AppModel(storeB);
      await modelB.load(); // 覆盖重载链路（含 deviceId 重读）
      expect(modelB.todos.length, modelA.todos.length);
      for (final t in modelA.todos) {
        expect(modelB.byId(t.id)!.body, t.body);
      }
      expect(storeB.classificationJson(modelB.classification),
          modelA.store.classificationJson(modelA.classification));
      expect(storeB.indexJson(modelB.index), modelA.store.indexJson(modelA.index));
      final imgA = modelA.store.imagesDir.listSync().single as File;
      final rel = p.relative(imgA.path, from: modelA.store.tipsDir.path);
      expect(await File(p.join(modelB.store.tipsDir.path, rel)).exists(),
          isTrue);
      // state/ 不进包：标记文件缺席，且新目录生成全新设备身份（不复用）
      expect(
          File(p.join(dirB.path, 'state', 'marker.txt')).existsSync(), isFalse);
      expect(modelB.deviceId, isNot(modelA.deviceId));

      await dirA.delete(recursive: true);
      await dirB.delete(recursive: true);
    });

    test('恢复覆盖本机：现状快照可查，内容被替换', () async {
      final dir = await Directory.systemTemp.createTemp('tt_bakC');
      final model = await _seedModel(dir);
      final before = model.todos.length;
      // 构造只有一条 Todo 的备份并覆盖恢复
      final dirS = await Directory.systemTemp.createTemp('tt_bakS');
      final seed = AppModel(TodoStore(dirS));
      await seed.load();
      await seed.createTodo();
      final zipPath = p.join(dirS.path, 'one.zip');
      await exportBackup(seed.store, zipPath, appVersion: '1.0.0');
      await importBackup(model.store, zipPath);
      await model.load();
      expect(model.todos.length, 1);
      expect(model.todos.length, isNot(before));
      // 快照保留
      final snaps = model.store.recoveryDir
          .listSync()
          .where((e) => p.basename(e.path).startsWith('backup-'));
      expect(snaps, isNotEmpty);

      await dir.delete(recursive: true);
      await dirS.delete(recursive: true);
    });
  });

  group('备份包校验', () {
    test('非 zip/缺 manifest/版本不对/非法路径均拒绝且不动现状', () async {
      final dir = await Directory.systemTemp.createTemp('tt_bakV');
      final model = await _seedModel(dir);
      final count = model.todos.length;

      Future<void> expectReject(Future<void> Function() fn) async {
        await expectLater(fn(), throwsA(isA<BackupException>()));
        final scan = await model.store.scanTodos();
        expect(scan.todos.length, count); // 现状完好
      }

      final garbage = File(p.join(dir.path, 'g.zip'))
        ..writeAsBytesSync([1, 2, 3, 4]);
      await expectReject(() async => importBackup(model.store, garbage.path));

      Future<String> zipOf(Map<String, Object?> manifest,
          [Map<String, List<int>> extra = const {}]) async {
        final enc = ZipFileEncoder();
        final path = p.join(dir.path,
            't${DateTime.now().microsecondsSinceEpoch}.zip');
        enc.create(path);
        final m = utf8.encode(jsonEncode(manifest));
        enc.addArchiveFile(ArchiveFile('manifest.json', m.length, m));
        extra.forEach((name, bytes) {
          enc.addArchiveFile(ArchiveFile(name, bytes.length, bytes));
        });
        await enc.close();
        return path;
      }

      const goodManifest = {
        'format': 'tasktips-backup',
        'formatVersion': 1,
      };
      await expectReject(() async => importBackup(
          model.store, await zipOf({'format': 'nope', 'formatVersion': 1})));
      await expectReject(() async => importBackup(
          model.store, await zipOf({'format': 'tasktips-backup', 'formatVersion': 99})));
      await expectReject(() async => importBackup(model.store,
          await zipOf(goodManifest, {'../evil.txt': [1]})));
      await expectReject(() async => importBackup(model.store,
          await zipOf(goodManifest, {'other/x.txt': [1]})));

      await dir.delete(recursive: true);
    });
  });
}
