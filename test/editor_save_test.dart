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
