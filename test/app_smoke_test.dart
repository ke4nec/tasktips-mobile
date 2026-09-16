import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tasktips/app/app_model.dart';
import 'package:tasktips/infra/store.dart';
import 'package:tasktips/ui/app.dart';

/// 慢环境（CI 容器）下带超时的轮询泵帧。
Future<void> _pumpUntil(WidgetTester tester, Finder finder,
    {int maxRounds = 50}) async {
  for (var i = 0; i < maxRounds; i++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<(Directory, AppModel)> _boot() async {
  final dir = await Directory.systemTemp.createTemp('tt_ui');
  final model = AppModel(TodoStore(dir));
  await model.load();
  return (dir, model);
}

void main() {
  testWidgets('首次启动显示引导，完成后进入主导航', (tester) async {
    Directory? dir;
    AppModel? model;
    await tester.runAsync(() async {
      final r = await _boot();
      dir = r.$1;
      model = r.$2;
    });
    addTearDown(() => dir!.delete(recursive: true));
    expect(model!.onboardingDone, isFalse);

    await tester.pumpWidget(TaskTipsApp(model: model!));
    await tester.pumpAndSettle();
    expect(find.text('开始记录'), findsOneWidget);

    await tester.tap(find.text('开始记录'));
    await tester.pumpAndSettle();
    expect(find.text('今日'), findsWidgets);
    expect(find.text('分类'), findsWidgets);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('主题切换后仍正常渲染', (tester) async {
    Directory? dir;
    AppModel? model;
    await tester.runAsync(() async {
      final r = await _boot();
      dir = r.$1;
      model = r.$2;
      await model!.completeOnboarding();
    });
    addTearDown(() => dir!.delete(recursive: true));

    await tester.pumpWidget(TaskTipsApp(model: model!));
    await tester.pumpAndSettle();

    await tester.runAsync(
        () => model!.setThemeMode(ThemeModeSetting.dark));
    await _pumpUntil(tester, find.byType(NavigationBar));
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
