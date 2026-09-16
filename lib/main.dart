import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:workmanager/workmanager.dart';

import 'app/app_model.dart';
import 'app/share_service.dart';
import 'infra/store.dart';
import 'sync/session.dart';
import 'sync/sync_engine.dart';
import 'ui/app.dart' show TaskTipsApp, navigatorKey;
import 'ui/pages/detail_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Boot());
}

/// WorkManager 后台周期同步回调（系统调度，不承诺准点执行）。
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // 后台任务内只做同步引擎的轻量重建；跨进程仍由服务端 CAS 保证互斥
    final dir = await getApplicationSupportDirectory();
    final model = AppModel(TodoStore(dir));
    await model.load();
    final sync = SyncEngine(model, SyncSession());
    await sync.loadState();
    if (sync.state.autoSync && sync.state.projectId != null) {
      await sync.syncNow();
    }
    return true;
  });
}

class Boot extends StatefulWidget {
  const Boot({super.key});

  @override
  State<Boot> createState() => _BootState();
}

class _BootState extends State<Boot> with WidgetsBindingObserver {
  late final Future<AppModel> _model;
  final _share = ShareService();
  SyncEngine? _sync;
  Timer? _autoSyncTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _model = () async {
      final dir = await getApplicationSupportDirectory();
      final model = AppModel(TodoStore(dir));
      await model.load();
      // 接入同步引擎；本地修改保存后自动触发（如已开启）
      final sync = SyncEngine(model, SyncSession());
      await sync.loadState();
      model.sync = sync;
      _sync = sync;
      // 启动触发一次自动同步
      if (sync.state.autoSync) {
        Future.microtask(() => sync.syncNow());
      }
      // 分享处理：引导未完成时挂起，完成后补建
      var handlerReady = model.onboardingDone;
      if (handlerReady) {
        _share.setHandler((text) => _createFromShare(model, text));
      } else {
        model.addListener(() {
          if (model.onboardingDone && !handlerReady) {
            handlerReady = true;
            _share.setHandler((text) => _createFromShare(model, text));
          }
        });
      }
      // 自动同步开启时注册 WorkManager 15 分钟周期任务（系统调度）
      await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
      if (sync.state.autoSync) {
        await Workmanager().registerPeriodicTask(
          'tasktips-sync', 'tasktipsPeriodicSync',
          frequency: const Duration(minutes: 15),
          existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
        );
      }
      final initial = await _share.initialSharedText();
      if (initial != null) {
        if (model.onboardingDone) {
          _createFromShare(model, initial);
        } else {
          // 首次引导不得吞掉待处理的分享内容
          _share.queuePending(initial);
        }
      }
      return model;
    }();
    _share.start();
    // 前台每 60 秒检查
    _autoSyncTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      final s = _sync;
      if (s != null && s.state.autoSync) {
        Future.microtask(() => s.syncNow());
      }
    });
  }

  /// 分享内容创建预填 Todo 并打开编辑页。
  void _createFromShare(AppModel model, String text) {
    Future.microtask(() async {
      final t = await model.createTodo();
      await model.writeTodo(t.copyWith(body: text));
      navigatorKey.currentState?.push(
        MaterialPageRoute(
            builder: (_) => DetailPage(model: model, todoId: t.id)),
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoSyncTimer?.cancel();
    _share.stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final s = _sync;
    if (s == null) return;
    if (state == AppLifecycleState.resumed) {
      // 恢复前台触发自动同步
      if (s.state.autoSync) {
        Future.microtask(() => s.syncNow());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppModel>(
      future: _model,
      builder: (context, snap) {
        if (snap.hasError) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            home: Scaffold(
              body: Center(child: Text('本地数据初始化失败：${snap.error}')),
            ),
          );
        }
        if (!snap.hasData) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }
        return TaskTipsApp(model: snap.data!);
      },
    );
  }
}
