import 'dart:async';

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

/// 今日页搜索入口 → 跳转列表页并聚焦搜索框（由 HomeShell 注入实现）。
final ValueNotifier<int> inboxSearchFocusTick = ValueNotifier<int>(0);
void Function()? openInboxSearch;

class TaskTipsApp extends StatefulWidget {
  final AppModel model;
  const TaskTipsApp({super.key, required this.model});

  @override
  State<TaskTipsApp> createState() => _TaskTipsAppState();
}

class _TaskTipsAppState extends State<TaskTipsApp> {
  // MaterialApp 只依赖这两个字段；仅在它们变化时重建，避免每次数据
  // 变更（保存/勾选/同步）触发整棵树（含 4 个 Tab 全部页面）rebuild。
  late ThemeModeSetting _theme;
  late bool _onboarded;

  @override
  void initState() {
    super.initState();
    _theme = widget.model.themeMode;
    _onboarded = widget.model.onboardingDone;
    widget.model.addListener(_onModelChange);
  }

  @override
  void dispose() {
    widget.model.removeListener(_onModelChange);
    super.dispose();
  }

  void _onModelChange() {
    final m = widget.model;
    if (m.themeMode != _theme || m.onboardingDone != _onboarded) {
      setState(() {
        _theme = m.themeMode;
        _onboarded = m.onboardingDone;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'TaskTips',
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: switch (_theme) {
        ThemeModeSetting.system => ThemeMode.system,
        ThemeModeSetting.light => ThemeMode.light,
        ThemeModeSetting.dark => ThemeMode.dark,
      },
      home: _onboarded
          ? HomeShell(model: widget.model)
          : OnboardingPage(model: widget.model),
    );
  }
}

/// 主导航壳：底部 4 个 Tab + FAB。
/// FAB 在今日/列表/分类可见：设计文档 §2 为准（v0.2 设计稿 show() 尚未包含
/// 分类页，属旧版；文档明确“补齐分类页新建 Todo FAB”）。
class HomeShell extends StatefulWidget {
  final AppModel model;
  const HomeShell({super.key, required this.model});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with WidgetsBindingObserver {
  int _tab = 0;
  Timer? _dayTick;
  String _knownToday = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _knownToday = widget.model.today;
    // 前台跨午夜/时区变化时主动重算今日分组（设计 §3：恢复前台重算）
    _dayTick = Timer.periodic(const Duration(seconds: 30), (_) {
      final t = widget.model.today;
      if (t != _knownToday) {
        _knownToday = t;
        widget.model.refreshToday();
      }
    });
  }

  @override
  void dispose() {
    _dayTick?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 恢复前台时重新计算今日分组并检查回收站到期
    if (state == AppLifecycleState.resumed) {
      _knownToday = widget.model.today;
      widget.model.refreshToday();
      widget.model.purgeExpiredTrash();
    }
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    // 时区通常随区域设置变化：重算今日，不改写用户截止日期
    widget.model.refreshToday();
  }

  @override
  Widget build(BuildContext context) {
    final model = widget.model;
    // 今日页搜索入口的跨 Tab 联动：切到列表页并聚焦搜索框
    openInboxSearch = () {
      if (!mounted) return;
      setState(() => _tab = 1);
      inboxSearchFocusTick.value++;
    };
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
    Navigator.of(this.context)
        .push(MaterialPageRoute(builder: (_) => DetailPage(model: m, todoId: t.id)));
  }
}

/// 二级页面通用脚手架：隐藏底部导航，保留返回按钮。
class SecondaryScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? bottomBar;
  final Widget? floatingActionButton;

  const SecondaryScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.bottomBar,
    this.floatingActionButton,
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
      floatingActionButton: floatingActionButton,
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
