import 'package:flutter/material.dart';

import '../../app/app_model.dart';
import '../app.dart';
import '../theme.dart';

/// 同步页（阶段2实现连接与调度；当前为本地状态占位，不发起网络请求）。
class SyncPage extends StatelessWidget {
  final AppModel model;
  const SyncPage({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final a = appColors(context, Theme.of(context).brightness);
    return SecondaryScaffold(
      title: '同步',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.cloud_off_outlined, color: a.muted),
                      const SizedBox(width: 8),
                      const Text('未连接服务端',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '当前内容仅保存在本机。连接服务端后可在桌面端、手机等多设备间接续编辑。',
                    style: TextStyle(fontSize: 14, color: a.muted, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.link),
              title: const Text('连接服务端'),
              subtitle: const Text('登录并选择项目（阶段2提供）'),
              enabled: false,
              onTap: null,
            ),
          ),
        ],
      ),
    );
  }
}

