import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasktips/app/app_model.dart';
import 'package:tasktips/domain/todo.dart';
import 'package:tasktips/infra/store.dart';
import 'package:tasktips/ui/app.dart';
import 'package:tasktips/ui/pages/today_page.dart';

String _addDays(String today, int days) {
  final t = DateTime.parse(today);
  final d = DateTime(t.year, t.month, t.day + days);
  return '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

Future<(Directory, AppModel)> _boot() async {
  final dir = await Directory.systemTemp.createTemp('tt_today');
  final model = AppModel(TodoStore(dir));
  await model.load();
  await model.completeOnboarding();
  return (dir, model);
}

Future<Todo> _mk(AppModel m, String title, String? due) async {
  final t = await m.createTodo(dueDate: due);
  final u = t.copyWith(body: title);
  await m.writeTodo(u);
  return m.byId(t.id)!;
}

void main() {
  testWidgets('今日页展示明天/3天/7天/30天分组且默认各3条可展开', (tester) async {
    Directory? dir;
    AppModel? model;
    await tester.runAsync(() async {
      final r = await _boot();
      dir = r.$1;
      model = r.$2;
      final today = model!.today;
      await _mk(model!, '过期任务', _addDays(today, -1));
      await _mk(model!, '今日任务', today);
      await _mk(model!, '明天任务', _addDays(today, 1));
      await _mk(model!, '三天任务', _addDays(today, 3));
      await _mk(model!, '七天任务', _addDays(today, 7));
      await _mk(model!, '三十天任务', _addDays(today, 30));
      // 7天桶放5条验证折叠
      for (var i = 0; i < 5; i++) {
        await _mk(model!, '七天多条$i', _addDays(today, 6));
      }
    });
    addTearDown(() => dir!.delete(recursive: true));
    // 高视口一次性容下所有分组：Sliver 懒构建只建可视区，小屏下标题不在树里
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(MaterialApp(home: TodayPage(model: model!)));
    await tester.pump();

    expect(find.text('已过期'), findsOneWidget);
    expect(find.text('今天到期'), findsOneWidget);
    // “明天”同时是分组标题和 TodoTile 内日期文案，故用 findsWidgets
    expect(find.text('明天'), findsWidgets);
    expect(find.text('3天内'), findsOneWidget);
    expect(find.text('7天内'), findsOneWidget);
    expect(find.text('30天内'), findsOneWidget);

    // 7天桶共6条（1+5），默认只显示3条
    expect(find.text('七天多条0'), findsNothing);
    await tester.tap(find.text('展开全部 6'));
    await tester.pump();
    expect(find.text('七天多条0'), findsOneWidget);
    await tester.tap(find.text('收起'));
    await tester.pump();
    expect(find.text('七天多条0'), findsNothing);
  });

  testWidgets('今日为空时显示未来安排而非空白页', (tester) async {
    Directory? dir;
    AppModel? model;
    await tester.runAsync(() async {
      final r = await _boot();
      dir = r.$1;
      model = r.$2;
      await _mk(model!, '明天任务', _addDays(model!.today, 1));
    });
    addTearDown(() => dir!.delete(recursive: true));

    await tester.pumpWidget(MaterialApp(home: TodayPage(model: model!)));
    await tester.pump();

    expect(find.text('今天没有到期任务'), findsOneWidget);
    expect(find.text('明天'), findsWidgets);
    expect(find.text('明天任务'), findsOneWidget);
  });

  testWidgets('底部今日 Tab 有数字气泡，无任务时隐藏', (tester) async {
    Directory? dir;
    AppModel? model;
    await tester.runAsync(() async {
      final r = await _boot();
      dir = r.$1;
      model = r.$2;
      // 关掉启动更新检查：避免网络定时器残留导致测试 teardown 断言失败
      await model!.setAutoUpdateCheck(false);
      await _mk(model!, '今日任务A', model!.today);
      await _mk(model!, '过期任务B', _addDays(model!.today, -2));
      await _mk(model!, '未来任务不计数', _addDays(model!.today, 5));
    });
    addTearDown(() => dir!.delete(recursive: true));

    await tester.pumpWidget(TaskTipsApp(model: model!));
    await tester.pump();

    // 今日视图总数=2（过期+今天），未来任务不进气泡
    final badges = tester.widgetList<Badge>(find.byType(Badge));
    expect(badges.where((b) => b.isLabelVisible), isNotEmpty);
    expect(find.text('2'), findsWidgets);

    // 完成后气泡消失
    await tester.runAsync(() async {
      for (final t in model!.todos) {
        await model!.setCompleted(t.id, true);
      }
    });
    await tester.pump();
    final badges2 = tester.widgetList<Badge>(find.byType(Badge));
    expect(badges2.every((b) => !b.isLabelVisible), isTrue);
  });
}
