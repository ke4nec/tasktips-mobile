import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'app/app_model.dart';
import 'infra/store.dart';
import 'sync/session.dart';
import 'sync/sync_engine.dart';
import 'ui/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Boot());
}

class Boot extends StatefulWidget {
  const Boot({super.key});

  @override
  State<Boot> createState() => _BootState();
}

class _BootState extends State<Boot> with WidgetsBindingObserver {
  late final Future<AppModel> _model;
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
      return model;
    }();
    // 前台每 60 秒检查
    _autoSyncTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      final s = _sync;
      if (s != null && s.state.autoSync) {
        Future.microtask(() => s.syncNow());
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoSyncTimer?.cancel();
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
