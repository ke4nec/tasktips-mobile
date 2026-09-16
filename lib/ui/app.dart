import 'package:flutter/material.dart';

import '../app/app_model.dart';
import 'pages/detail_page.dart';
import 'pages/folder_page.dart';
import 'pages/inbox_page.dart';
import 'pages/onboarding_page.dart';
import 'pages/settings_page.dart';
import 'pages/sync_page.dart';
import 'pages/today_page.dart';
import 'pages/trash_page.dart';
import 'theme.dart';

/// 全局导航键：分享入口等服务级跳转使用。
final navigatorKey = GlobalKey<NavigatorState>();

class TaskTipsApp extends StatelessWidget {
  final AppModel model;
  const TaskTipsApp({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: model,
      builder: (context, _) => MaterialApp(
        navigatorKey: navigatorKey,
        title: 'TaskTips',
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        themeMode: switch (model.themeMode) {
          ThemeModeSetting.system => ThemeMode.system,
          ThemeModeSetting.light => ThemeMode.light,
          ThemeModeSetting.dark => ThemeMode.dark,
        },
        home: model.onboardingDone
            ? HomeShell(model: model)
            : OnboardingPage(model: model),
      ),
    );
  }
}

/// 主导航壳：底部 4 个 Tab + FAB（今日/列表/分类可见）。
class HomeShell extends StatefulWidget {
  final AppModel model;
  const HomeShell({super.key, required this.model});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with WidgetsBindingObserver {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 恢复前台时重新计算今日分组并检查回收站到期
    if (state == AppLifecycleState.resumed) {
      widget.model.refreshToday();
      widget.model.purgeExpiredTrash();
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = widget.model;
    final pages = [
      TodayPage(model: model),
      InboxPage(model: model),
      FolderPage(model: model),
      SettingsPage(model: model),
    ];
    final showFab = _tab <= 2;
    return Scaffold(
      body: IndexedStack(index: _tab, children: pages),
      floatingActionButton: showFab
          ? FloatingActionButton(
              onPressed: () => _createTodo(context),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_today), label: '今日'),
          NavigationDestination(icon: Icon(Icons.checklist), selectedIcon: Icon(Icons.checklist_rounded), label: '列表'),
          NavigationDestination(icon: Icon(Icons.folder_outlined), selectedIcon: Icon(Icons.folder), label: '分类'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: '设置'),
        ],
      ),
    );
  }

  Future<void> _createTodo(BuildContext context) async {
    final m = widget.model;
    final t = await m.createTodo(dueDate: _tab == 0 ? m.today : null);
    if (!mounted) return;
    openDetailPage(context, m, t.id);
  }
}

/// 二级页面通用脚手架：隐藏底部导航，保留返回按钮。
class SecondaryScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? bottomBar;

  const SecondaryScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.bottomBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(title),
        actions: actions,
      ),
      body: body,
      bottomNavigationBar: bottomBar,
    );
  }
}

/// 供设置页等入口跳转到二级页面。
void openSecondaryPage(BuildContext context, Widget page) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
}

void openSyncPage(BuildContext context, AppModel model) =>
    openSecondaryPage(context, SyncPage(model: model));

void openTrashPage(BuildContext context, AppModel model) =>
    openSecondaryPage(context, TrashPage(model: model));

void openDetailPage(BuildContext context, AppModel model, String todoId) {
  Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => DetailPage(model: model, todoId: todoId)));
}
