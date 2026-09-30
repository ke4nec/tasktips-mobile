import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasktips/app/app_model.dart';
import 'package:tasktips/domain/todo.dart';
import 'package:tasktips/infra/store.dart';
import 'package:tasktips/ui/pages/detail_page.dart';

class MemoryModel extends AppModel {
  Completer<void>? gate;
  bool failWrites = false;
  final writes = <String>[];
  MemoryModel() : super(TodoStore(Directory('/unused-review-memory'))) {
    deviceId = 'review-device';
    todos = [
      Todo(
        id: 'one',
        title: '',
        body: '',
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
        deviceId: deviceId,
      ),
    ];
  }
  @override
  Future<void> writeTodo(Todo updated, {bool autosync = true}) async {
    writes.add(updated.body);
    await gate?.future;
    if (failWrites) throw const FileSystemException('模拟磁盘写入失败');
    todos[0] = updated;
    notifyListeners();
  }
}

void main() {
  testWidgets('周期快照不保存输入法组合文本', (tester) async {
    final m = MemoryModel();
    await tester.pumpWidget(
      MaterialApp(
        home: DetailPage(model: m, todoId: 'one'),
      ),
    );
    await tester.tap(find.byType(TextField));
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: 'nihao',
        selection: TextSelection.collapsed(offset: 5),
        composing: TextRange(start: 0, end: 5),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(m.writes, isEmpty);
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: '你好',
        selection: TextSelection.collapsed(offset: 2),
      ),
    );
    await tester.pump(const Duration(milliseconds: 450));
    expect(m.byId('one')!.body, '你好');
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('慢速保存期间返回仍保存最后一次输入', (tester) async {
    final m = MemoryModel();
    final nav = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: nav,
        home: const Scaffold(body: Text('home')),
      ),
    );
    nav.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => DetailPage(model: m, todoId: 'one'),
      ),
    );
    await tester.pumpAndSettle();
    m.gate = Completer<void>();
    await tester.enterText(find.byType(TextField), 'first version');
    await tester.pump(const Duration(milliseconds: 450));
    expect(m.writes, ['first version']);
    await tester.enterText(find.byType(TextField), 'latest version');
    await tester.pump(const Duration(milliseconds: 450));
    await tester.tap(find.byType(BackButton));
    await tester.pump();
    await tester.tap(find.byType(BackButton));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(DetailPage), findsOneWidget, reason: '保存未完成不能退出');
    m.gate!.complete();
    await tester.pump();
    await tester.pump();
    final actual = m.byId('one')!.body;
    await tester.pumpWidget(const SizedBox.shrink());
    expect(actual, 'latest version');
  });
  testWidgets('返回时保存失败则保留编辑页，重试保存最新正文', (tester) async {
    final m = MemoryModel()..failWrites = true;
    final nav = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: nav,
        home: const Scaffold(body: Text('home')),
      ),
    );
    nav.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => DetailPage(model: m, todoId: 'one'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '不能丢失');
    // 防抖尚未到时立即返回，关闭流程本身也必须检查这一次保存是否成功。
    await tester.tap(find.byType(BackButton));
    await tester.pump();
    await tester.tap(find.byType(BackButton));
    await tester.pump();
    expect(find.byType(DetailPage), findsOneWidget);
    expect(m.byId('one')!.body, isEmpty);
    expect(find.text('不能丢失'), findsOneWidget);
    m.failWrites = false;
    await tester.tap(find.text('重试'));
    await tester.pump();
    expect(m.byId('one')!.body, '不能丢失');
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('保存失败后的返回确认为底部弹层且可留在本页', (tester) async {
    final m = MemoryModel()..failWrites = true;
    final nav = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: nav,
        home: const Scaffold(body: Text('home')),
      ),
    );
    nav.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => DetailPage(model: m, todoId: 'one'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '不能丢失');
    // 防抖保存已触发并失败，再返回即进入确认弹层。
    await tester.pump(const Duration(milliseconds: 450));
    await tester.tap(find.byType(BackButton));
    await tester.pump();
    await tester.tap(find.byType(BackButton));
    await tester.pump();
    // 全 app 确认弹层统一为底部 sheet，不再用居中 AlertDialog。
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('留在本页'), findsOneWidget);
    expect(find.text('尝试保存并返回'), findsOneWidget);
    await tester.pumpAndSettle();
    await tester.tap(find.text('留在本页'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byType(DetailPage), findsOneWidget);
    // 再次返回仍先弹确认；选择重试保存失败后停留本页、正文保留。
    await tester.tap(find.byType(BackButton));
    await tester.pump();
    expect(find.byType(BottomSheet), findsOneWidget);
    await tester.pumpAndSettle();
    await tester.tap(find.text('尝试保存并返回'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(DetailPage), findsOneWidget);
    expect(find.text('不能丢失'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('编辑态优先级行与格式工具栏间不叠加安全区空白', (tester) async {
    // 手势导航条：底部安全区 40（物理 120 / dpr 3）。
    tester.view.physicalSize = const Size(2400, 1800);
    tester.view.devicePixelRatio = 3.0;
    tester.view.padding = const FakeViewPadding(bottom: 120);
    addTearDown(tester.view.reset);
    final m = MemoryModel();
    await tester.pumpWidget(
      MaterialApp(
        home: DetailPage(model: m, todoId: 'one'),
      ),
    );
    await tester.pumpAndSettle();
    // 编辑态格式工具栏垫在元数据栏下方且自带 SafeArea，两行之间只剩
    // 4 呼吸间距 + 1px 分隔线（设计稿 .editor-toolbar 的 border-top），
    // 不再空出一条安全区高度。
    final metaRow = tester.getRect(
      find
          .ancestor(of: find.text('优先级'), matching: find.byType(InkWell))
          .first,
    );
    final toolbarBtn = tester.getRect(find.byTooltip('标题'));
    expect(toolbarBtn.top - metaRow.bottom, 5.0);
    // 预览态无格式工具栏，元数据栏成为最底部元素，仍需让出导航栏。
    await tester.tap(find.byTooltip('预览'));
    await tester.pumpAndSettle();
    final lastRow = tester.getRect(
      find.ancestor(of: find.text('标签'), matching: find.byType(InkWell))
          .first,
    );
    expect(600 - lastRow.bottom, 44.0); // 4 呼吸 + 40 安全区
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('外部移除编辑页后在飞保存仍会排空最新正文', (tester) async {
    final m = MemoryModel()..gate = Completer<void>();
    await tester.pumpWidget(
      MaterialApp(
        home: DetailPage(model: m, todoId: 'one'),
      ),
    );
    await tester.enterText(find.byType(TextField), '旧输入');
    await tester.pump(const Duration(milliseconds: 450));
    await tester.enterText(find.byType(TextField), '最新输入');
    await tester.pumpWidget(const SizedBox.shrink());
    m.gate!.complete();
    await tester.pump();
    await tester.pump();
    expect(m.byId('one')!.body, '最新输入');
    expect(tester.takeException(), isNull);
  });
}
