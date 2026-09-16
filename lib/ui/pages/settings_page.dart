import 'package:flutter/material.dart';

import '../../app/app_model.dart';
import '../app.dart';
import '../theme.dart';

/// 设置页：主题三态、同步/回收站入口、本地存储说明与版本信息。
class SettingsPage extends StatelessWidget {
  final AppModel model;
  const SettingsPage({super.key, required this.model});

  static const appVersion = '0.1.0+1';

  @override
  Widget build(BuildContext context) {
    final a = appColors(context, Theme.of(context).brightness);
    return AnimatedBuilder(
      animation: model,
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: const Text('设置')),
        body: ListView(
          children: [
            _section(context, '外观'),
            _themeRow(context, a),
            _section(context, '数据与同步'),
            _navRow(context, '同步', '连接服务端、状态与日志',
                Icons.sync_outlined, () => openSyncPage(context, model)),
            _navRow(context, '回收站', '已删除内容保留 30 天',
                Icons.delete_outline, () => openTrashPage(context, model)),
            _section(context, '本地存储'),
            _infoRow(context, '存储位置',
                '应用专属目录：${model.store.root.path}'),
            _infoRow(context, '占用', '${model.todos.length} 条 Todo'),
            _infoRow(context, '版本', appVersion),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String title) {
    final a = appColors(context, Theme.of(context).brightness);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(title,
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700, color: a.muted)),
    );
  }

  Widget _themeRow(BuildContext context, AppColors a) {
    return RadioGroup<ThemeModeSetting>(
      groupValue: model.themeMode,
      onChanged: (v) {
        if (v != null) model.setThemeMode(v);
      },
      child: Column(
        children: [
          for (final m in ThemeModeSetting.values)
            RadioListTile<ThemeModeSetting>(
              value: m,
              title: Text(switch (m) {
                ThemeModeSetting.system => '跟随系统',
                ThemeModeSetting.light => '浅色',
                ThemeModeSetting.dark => '深色',
              }),
            ),
        ],
      ),
    );
  }

  Widget _navRow(BuildContext context, String title, String subtitle,
      IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _infoRow(BuildContext context, String title, String value) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 16)),
      subtitle: Text(value, style: const TextStyle(fontSize: 14)),
    );
  }
}
