import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:tasktips/app/app_model.dart';
import 'package:tasktips/domain/todo.dart';
import 'package:tasktips/infra/store.dart';

Todo _todo(String id, {String body = '正文', String? due}) => Todo(
      id: id,
      title: deriveTitle(body),
      body: body,
      dueDate: due,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
      deviceId: 'dev',
    );

void main() {
  late Directory tmp;
  late TodoStore store;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('tasktips_test');
    store = TodoStore(tmp);
    await store.init();
  });

  tearDown(() async {
    await tmp.delete(recursive: true);
  });

  test('目录逻辑分区创建', () async {
    expect(await store.tipsDir.exists(), isTrue);
    expect(await store.imagesDir.exists(), isTrue);
    expect(await store.stateDir.exists(), isTrue);
    expect(await store.recoveryDir.exists(), isTrue);
  });

  test('保存/读取往返', () async {
    final t = _todo('01A', body: '# 首行标题\n\n- [ ] 任务');
    await store.saveTodo(t);
    final read = await store.readTodo('01A');
    expect(read!.title, '首行标题');
    expect(read.body, t.body);
  });

  test('损坏文件隔离并生成恢复副本，不阻断其他 Todo', () async {
    await store.saveTodo(_todo('01GOOD'));
    await File(p.join(store.tipsDir.path, '01BAD.md'))
        .writeAsString('不是 markdown 文档');
    final scan = await store.scanTodos();
    expect(scan.todos.length, 1);
    expect(scan.corrupt.length, 1);
    expect(
        await File(p.join(store.recoveryDir.path, '01BAD.md.prev')).exists(),
        isTrue);
  });

  test('设备 ID 安装级持久', () async {
    final a = await store.loadOrCreateDeviceId();
    final b = await store.loadOrCreateDeviceId();
    expect(a, b);
    expect(RegExp(r'^[0-9a-f-]{36}$').hasMatch(a), isTrue);
  });

  test('墓碑先于文件删除持久化', () async {
    final model = AppModel(store);
    await model.load();
    final t = await model.createTodo();
    await model.trashTodo(t.id);
    await model.purgeTodo(t.id);
    final idx = await store.loadIndex();
    expect(idx.tombstones.any((ts) => ts.id == t.id), isTrue);
    expect(await store.readTodo(t.id), isNull);
  });

  test('回收站 30 天到期清理', () async {
    final model = AppModel(store);
    await model.load();
    final t = await model.createTodo();
    // 直接写入 31 天前的删除时间
    final trashed = model.byId(t.id)!
      ..deletedAt = DateTime.now().subtract(const Duration(days: 31));
    await store.saveTodo(trashed);
    await model.purgeExpiredTrash();
    expect(model.byId(t.id), isNull);
    final idx = await store.loadIndex();
    expect(idx.tombstones.any((ts) => ts.id == t.id), isTrue);
  });

  test('标签重命名同步更新关联 Todo', () async {
    final model = AppModel(store);
    await model.load();
    expect(await model.createTag('工作'), isNull);
    final t = await model.createTodo(tagName: '工作');
    final tagId = model.visibleTags.first.id;
    expect(await model.renameTag(tagId, 'Work'), isNull);
    expect(model.byId(t.id)!.tags, ['Work']);
  });

  test('目录三级限制与同名校验', () async {
    final model = AppModel(store);
    await model.load();
    final e1 = await model.createCategory('一级');
    expect(e1, isNull);
    final c1 = model.rootCategories.first;
    expect(await model.createCategory('二级', parentId: c1.id), isNull);
    final c2 = model.childCategories(c1.id).first;
    expect(await model.createCategory('三级', parentId: c2.id), isNull);
    final c3 = model.childCategories(c2.id).first;
    expect((await model.createCategory('四级', parentId: c3.id)), isNotNull);
    expect((await model.createCategory('一级')), isNotNull); // 同名
  });
}
