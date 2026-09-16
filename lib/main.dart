import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'app/app_model.dart';
import 'infra/store.dart';
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

class _BootState extends State<Boot> {
  late final Future<AppModel> _model;

  @override
  void initState() {
    super.initState();
    _model = () async {
      final dir = await getApplicationSupportDirectory();
      final model = AppModel(TodoStore(dir));
      await model.load();
      return model;
    }();
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
