/// 分类生命周期（cohort 连坐/同批恢复）、名称校验、customOrder、
/// deriveTitle 与未分类口径的领域规则测试。
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tasktips/app/app_model.dart';
import 'package:tasktips/domain/query.dart';
import 'package:tasktips/domain/todo.dart';
import 'package:tasktips/infra/store.dart';

void main() {
  late Directory dir;
  late AppModel model;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('tt_cls');
    model = AppModel(TodoStore(dir));
    await model.load();
  });

  tearDown(() async {
    await dir.delete(recursive: true);
  });

  group('目录删除 cohort 连坐与同批恢复', () {
    test('删除目录时子树内 Todo 同批进入回收站，恢复时一并还原', () async {
      expect(await model.createCategory('工作'), isNull);
      final c = model.rootCategories.first;
      final t1 = await model.createTodo(categoryId: c.id);
      final t2 = await model.createTodo(); // 目录外，不受影响
      await model.trashCategory(c.id);

      expect(model.byId(t1.id)!.isDeleted, isTrue);
      expect(model.byId(t2.id)!.isDeleted, isFalse);
      // 同批时间戳一致（秒级）
      final catCohort = model.classification.byId(c.id)!.deletedAt!;
      final todoCohort = model.byId(t1.id)!.deletedAt!;
      expect(
          todoCohort.difference(DateTime.parse(catCohort).toUtc()).abs(),
          lessThan(const Duration(seconds: 1)));

      final err = await model.restoreCategory(c.id);
      expect(err, isNull);
      expect(model.byId(t1.id)!.isDeleted, isFalse);
      expect(model.classification.byId(c.id)!.isDeleted, isFalse);
    });

    test('此前单独删除的 Todo 不因目录恢复而复活', () async {
      expect(await model.createCategory('生活'), isNull);
      final c = model.rootCategories.first;
      final kept = await model.createTodo(categoryId: c.id);
      final solo = await model.createTodo(categoryId: c.id);
      await model.trashTodo(solo.id); // 单独先删
      await model.trashCategory(c.id);

      expect(await model.restoreCategory(c.id), isNull);
      expect(model.byId(kept.id)!.isDeleted, isFalse); // 同批恢复
      expect(model.byId(solo.id)!.isDeleted, isTrue); // 单独删除的不复活
    });

    test('孤儿子目录保留父引用：父目录恢复后自动归位', () async {
      expect(await model.createCategory('父目录'), isNull);
      final parent = model.rootCategories.firstWhere((e) => e.name == '父目录');
      expect(await model.createCategory('子目录', parentId: parent.id), isNull);
      final child = model.childCategories(parent.id).first;

      await model.trashCategory(parent.id);
      // 恢复子目录：父仍在回收站，子到根级展示但引用不断开
      expect(await model.restoreCategory(child.id), isNull);
      expect(model.classification.byId(child.id)!.parentId, parent.id);
      // 根级列表包含孤儿子目录
      expect(model.rootCategories.any((e) => e.id == child.id), isTrue);

      // 父目录随后恢复 → 子目录归位（不再是根级孤儿）
      expect(await model.restoreCategory(parent.id), isNull);
      expect(model.rootCategories.any((e) => e.id == child.id), isFalse);
      expect(model.childCategories(parent.id).any((e) => e.id == child.id), isTrue);
    });

    test('彻底删除目录连带同批 Todo 并写 todo 墓碑', () async {
      expect(await model.createCategory('项目'), isNull);
      final c = model.rootCategories.first;
      final t = await model.createTodo(categoryId: c.id);
      await model.trashCategory(c.id);
      await model.purgeCategory(c.id);

      expect(model.classification.byId(c.id), isNull);
      expect(model.byId(t.id), isNull);
      expect(
          model.index.tombstones.any((ts) => ts.kind == 'todo' && ts.id == t.id),
          isTrue);
      expect(model.index.tombstones.any((ts) => ts.kind == 'category'),
          isFalse); // 不写 category 墓碑
    });

    test('删除期间同级出现同名目录：恢复被拒并返回原因', () async {
      expect(await model.createCategory('重复'), isNull);
      final c = model.rootCategories.first;
      await model.trashCategory(c.id);
      expect(await model.createCategory('重复'), isNull); // 删除期间新建同名

      final err = await model.restoreCategory(c.id);
      expect(err, isNotNull);
      expect(model.classification.byId(c.id)!.isDeleted, isTrue); // 条目保留
    });

    test('标签恢复同名冲突被拒', () async {
      expect(await model.createTag('工作'), isNull);
      final id = model.visibleTags.first.id;
      await model.trashTag(id);
      expect(await model.createTag('工作'), isNull);
      final err = await model.restoreTag(id);
      expect(err, isNotNull);
      expect(model.classification.tagById(id)!.isDeleted, isTrue);
    });
  });

  group('名称校验对齐桌面端', () {
    test('目录 2-50 字符且禁特殊字符', () async {
      expect(await model.createCategory('一'), isNotNull); // 1 字符
      expect(await model.createCategory('a' * 51), isNotNull);
      expect(await model.createCategory('a/b'), isNotNull);
      expect(await model.createCategory('合\\法'), isNotNull);
      expect(await model.createCategory('a' * 50), isNull);
    });

    test('标签 1-20 字符', () async {
      expect(await model.createTag(''), isNotNull);
      expect(await model.createTag('a' * 21), isNotNull);
      expect(await model.createTag('a' * 20), isNull);
    });

    test('moveCategory 按最深子孙校验三级限制', () async {
      for (final n in ['A1', 'B1']) {
        expect(await model.createCategory(n), isNull);
      }
      final a1 = model.rootCategories.firstWhere((e) => e.name == 'A1');
      final b1 = model.rootCategories.firstWhere((e) => e.name == 'B1');
      expect(await model.createCategory('A2', parentId: a1.id), isNull);
      final a2 = model.childCategories(a1.id).first;
      expect(await model.createCategory('A3', parentId: a2.id), isNull);
      final a3 = model.childCategories(a2.id).first;
      // A3 子树高 1，移动到 B1（深 1）下 → 1+1-1=1 ≤3 合法
      expect(await model.moveCategory(a3.id, b1.id), isNull);
      // 移回 A2 下（深 2）：2+1-1=2 合法；再把 A2 整树移到 A3 下应拒（循环）
      expect(await model.moveCategory(a3.id, a2.id), isNull);
      expect(await model.moveCategory(a2.id, a3.id), isNotNull);
      // A3 在 B1 下建二级 B2，把 A2 树（高 2）移到 B2（深 3）→ 3+2-1=4 拒
      expect(await model.createCategory('B2', parentId: b1.id), isNull);
      expect(await model.createCategory('B3', parentId: model.childCategories(b1.id).firstWhere((e) => e.name != 'A3', orElse: () => model.childCategories(b1.id).first).id), isNull);
    });
  });

  group('未分类口径', () {
    test('categoryId 指向已删/不存在目录按未分类', () async {
      expect(await model.createCategory('临时'), isNull);
      final c = model.rootCategories.first;
      final t = await model.createTodo(categoryId: c.id);
      await model.trashCategory(c.id); // 目录删除 → Todo 也进回收站，先恢复 Todo
      await model.restoreTodo(t.id);

      final q = TodoQuery(view: TodoView.all, uncategorized: true);
      final r = model.query(q);
      expect(r.any((e) => e.id == t.id), isTrue); // 已删目录 → 未分类
    });
  });

  group('customOrder 默认排序', () {
    test('Inbox/All 默认视图按同步顺序置前，筛选时不用', () async {
      final a = await model.createTodo();
      final b = await model.createTodo();
      final c = await model.createTodo();
      model.index.customOrder['inbox'] = [c.id, a.id];

      final inbox = model.query(TodoQuery(view: TodoView.inbox));
      expect(inbox.map((t) => t.id).take(2), [c.id, a.id]); // 数组序在前
      expect(inbox.last.id, b.id); // 未列出的追加在后

      // 搜索激活时不使用自定义顺序（退回默认排序）
      final searched =
          model.query(TodoQuery(view: TodoView.inbox, search: 'x'));
      expect(searched, isEmpty);

      // 显式排序不用自定义顺序
      final sorted = model.query(TodoQuery(
          view: TodoView.inbox, defaultSort: false, sortKey: SortKey.createdAt));
      expect(sorted.map((t) => t.id), containsAll([a.id, b.id, c.id]));
    });
  });

  group('deriveTitle 剥离规则（对齐桌面 markdown.ts）', () {
    test('链接与图片保留可见文本', () {
      expect(deriveTitle('[链接文本](https://a.b)'), '链接文本');
      expect(deriveTitle('![alt](images/x.png)'), 'alt');
    });

    test('ATX 闭合井号剥离', () {
      expect(deriveTitle('## 标题 ##'), '标题');
    });

    test('嵌套块级前缀循环剥离', () {
      expect(deriveTitle('> - [ ] 任务'), '任务');
      expect(deriveTitle('1. - 项'), '项');
    });

    test('分隔线与 <br> 残留跳过取下一行', () {
      expect(deriveTitle('---\n真正标题'), '真正标题');
      expect(deriveTitle('<br>\n下一行'), '下一行');
      expect(deriveTitle('\\<br />\n文本'), '文本');
    });

    test('snake_case 下划线保留', () {
      expect(deriveTitle('snake_case_name'), 'snake_case_name');
    });

    test('粗斜体与删除线', () {
      expect(deriveTitle('***粗斜体***'), '粗斜体');
      expect(deriveTitle('~~删除~~'), '删除');
    });

    test('emoji 按码点截断', () {
      final title = deriveTitle('🙂' * 100);
      expect(title.runes.length, 80);
      expect(title.endsWith('…'), isTrue);
    });
  });
}
