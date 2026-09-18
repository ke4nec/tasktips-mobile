import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tasktips/app/app_model.dart';
import 'package:tasktips/infra/store.dart';
import 'package:tasktips/ui/pages/detail_page.dart';
import 'package:tasktips/ui/pages/inbox_page.dart';
import 'package:tasktips/ui/widgets.dart';

Future<(Directory, AppModel)> _boot() async {
  final dir = await Directory.systemTemp.createTemp('tt_interact');
  final model = AppModel(TodoStore(dir));
  await model.load();
  return (dir, model);
}

/// 新建空记录：先落盘后打开编辑页。
Future<String> _createEmpty(AppModel model) async {
  final t = await model.createTodo();
  return t.id;
}

Widget _tileHarness(AppModel model, String id) => MaterialApp(
      home: Scaffold(
        body: ListView(
          children: [
            TodoTile(
              model: model,
              todo: model.byId(id)!,
              onOpen: () {},
            ),
          ],
        ),
      ),
    );

void main() {
  testWidgets('左滑条目并确认后移入回收站', (tester) async {
    late Directory dir;
    late AppModel model;
    late String id;
    await tester.runAsync(() async {
      final r = await _boot();
      dir = r.$1;
      model = r.$2;
      final t = await model.createTodo();
      await model.writeTodo(t.copyWith(body: '买牛奶'));
      id = t.id;
    });
    addTearDown(() => dir.delete(recursive: true));

    await tester.pumpWidget(_tileHarness(model, id));
    await tester.pumpAndSettle();
    expect(find.text('买牛奶'), findsOneWidget);

    await tester.runAsync(() async {
      await tester.fling(
          find.byKey(ValueKey('dismiss-$id')), const Offset(-400, 0), 1000);
      await tester.pumpAndSettle();
    });
    expect(find.text('“买牛奶”将移入回收站，30 天后自动删除。'), findsOneWidget);

    await tester.runAsync(() async {
      await tester.tap(find.widgetWithText(FilledButton, '移入回收站'));
      await tester.pumpAndSettle();
      // 滑出动画结束才落盘：轮询等 trash 完成
      for (var i = 0; i < 50 && !model.byId(id)!.isDeleted; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.pumpAndSettle();
    });
    expect(model.byId(id)!.isDeleted, isTrue);
    expect(model.trashedTodos.any((t) => t.id == id), isTrue);
    expect(find.text('买牛奶'), findsNothing);
  });

  testWidgets('左滑后取消则保留原条目', (tester) async {
    late Directory dir;
    late AppModel model;
    late String id;
    await tester.runAsync(() async {
      final r = await _boot();
      dir = r.$1;
      model = r.$2;
      final t = await model.createTodo();
      await model.writeTodo(t.copyWith(body: '别删我'));
      id = t.id;
    });
    addTearDown(() => dir.delete(recursive: true));

    await tester.pumpWidget(_tileHarness(model, id));
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      await tester.fling(
          find.byKey(ValueKey('dismiss-$id')), const Offset(-400, 0), 1000);
      await tester.pumpAndSettle();
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();
    });
    expect(model.byId(id)!.isDeleted, isFalse);
    expect(find.text('别删我'), findsOneWidget);
  });

  testWidgets('新建无内容返回不留记录', (tester) async {
    late Directory dir;
    late AppModel model;
    late String id;
    await tester.runAsync(() async {
      final r = await _boot();
      dir = r.$1;
      model = r.$2;
      id = await _createEmpty(model);
    });
    addTearDown(() => dir.delete(recursive: true));
    expect(model.todos.length, 1);

    await tester.pumpWidget(
        MaterialApp(home: DetailPage(model: model, todoId: id, isNew: true)));
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      // purge 为 fire-and-forget：轮询等删除落盘完成
      for (var i = 0; i < 50 && model.byId(id) != null; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
      }
    });
    expect(model.byId(id), isNull);
    expect(model.todos, isEmpty);
    expect(
        File('${dir.path}/content/tips/$id.md').existsSync(), isFalse);
  });

  testWidgets('新建写过内容返回则保留记录', (tester) async {
    late Directory dir;
    late AppModel model;
    late String id;
    await tester.runAsync(() async {
      final r = await _boot();
      dir = r.$1;
      model = r.$2;
      id = await _createEmpty(model);
    });
    addTearDown(() => dir.delete(recursive: true));

    await tester.pumpWidget(
        MaterialApp(home: DetailPage(model: model, todoId: id, isNew: true)));
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      await tester.enterText(find.byType(TextField), '写了内容');
      // 防抖 400ms 为真实计时：轮询等自动保存落盘
      for (var i = 0; i < 50 && model.byId(id)!.body != '写了内容'; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
    });
    expect(model.byId(id), isNotNull);
    expect(model.byId(id)!.body, '写了内容');
    expect(model.todos.length, 1);
  });

  testWidgets('旧记录（非新建）空正文返回不删除', (tester) async {
    late Directory dir;
    late AppModel model;
    late String id;
    await tester.runAsync(() async {
      final r = await _boot();
      dir = r.$1;
      model = r.$2;
      id = await _createEmpty(model);
    });
    addTearDown(() => dir.delete(recursive: true));

    // 非新建入口打开：即使正文为空也不丢弃
    await tester.pumpWidget(
        MaterialApp(home: DetailPage(model: model, todoId: id)));
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
    });
    expect(model.byId(id), isNotNull);
  });

  testWidgets('长按多选并批量移入回收站', (tester) async {
    late Directory dir;
    late AppModel model;
    late String id1;
    late String id2;
    await tester.runAsync(() async {
      final r = await _boot();
      dir = r.$1;
      model = r.$2;
      final a = await model.createTodo();
      await model.writeTodo(a.copyWith(body: '买牛奶'));
      final b = await model.createTodo();
      await model.writeTodo(b.copyWith(body: '买面包'));
      id1 = a.id;
      id2 = b.id;
    });
    addTearDown(() => dir.delete(recursive: true));

    await tester.pumpWidget(MaterialApp(home: InboxPage(model: model)));
    await tester.pumpAndSettle();
    // 搜索态关闭拖拽，长按进入多选（手势时钟走 fake async，不进 runAsync）
    await tester.enterText(find.byType(SearchBar), '买');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.byType(ReorderableListView), findsNothing);
    expect(find.text('买牛奶'), findsOneWidget);
    expect(find.text('买面包'), findsOneWidget);

    await tester.longPress(find.byKey(ValueKey(id1)));
    await tester.pumpAndSettle();
    expect(find.text('已选 1 项'), findsOneWidget);

    // 多选模式点按切换选中（不再打开详情）
    await tester.tap(find.text('买面包'));
    await tester.pumpAndSettle();
    expect(find.text('已选 2 项'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, '全选'));
    await tester.pumpAndSettle();
    expect(find.text('已选 2 项'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, '删除'));
    await tester.pumpAndSettle();
    expect(find.text('将 2 项移入回收站，30 天后自动删除。'), findsOneWidget);
    // 确认后的批量落盘走真实 IO，进 runAsync
    await tester.runAsync(() async {
      await tester.tap(find.widgetWithText(FilledButton, '移入回收站'));
      await tester.pumpAndSettle();
      for (var i = 0;
          i < 50 &&
              (!model.byId(id1)!.isDeleted || !model.byId(id2)!.isDeleted);
          i++) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.pumpAndSettle();
    });
    expect(model.trashedTodos.length, 2);
    expect(find.text('已将 2 项移入回收站'), findsOneWidget);
    expect(find.textContaining('已选'), findsNothing);
  });

  testWidgets('拖拽排序列表经菜单进入多选', (tester) async {
    late Directory dir;
    late AppModel model;
    await tester.runAsync(() async {
      final r = await _boot();
      dir = r.$1;
      model = r.$2;
      final t = await model.createTodo();
      await model.writeTodo(t.copyWith(body: '开会'));
    });
    addTearDown(() => dir.delete(recursive: true));

    await tester.pumpWidget(MaterialApp(home: InboxPage(model: model)));
    await tester.pumpAndSettle();
    // 默认视图为拖拽排序：长按被拖拽占用，走菜单进入多选
    expect(find.byType(ReorderableListView), findsOneWidget);

    await tester.tap(find.byTooltip('更多操作：开会'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('多选'));
    await tester.pumpAndSettle();
    expect(find.text('已选 1 项'), findsOneWidget);
    // 多选模式下拖拽关闭
    expect(find.byType(ReorderableListView), findsNothing);

    await tester.tap(find.widgetWithText(TextButton, '取消'));
    await tester.pumpAndSettle();
    expect(find.textContaining('已选'), findsNothing);
    expect(find.byType(ReorderableListView), findsOneWidget);
  });
}
