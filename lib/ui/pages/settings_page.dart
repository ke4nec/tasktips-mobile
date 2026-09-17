import 'package:flutter/material.dart';

import '../../app/app_model.dart';
import '../app.dart';
import '../theme.dart';

/// 设置页（设计稿 settingsPage）：外观 / 数据 / 关于 三组 setting-row，
/// 行内 trailing 显示当前值，主题用底部面板三选。
class SettingsPage extends StatelessWidget {
  final AppModel model;
  const SettingsPage({super.key, required this.model});

  static const appVersion = '0.1.0';

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
            _section(context, '数据'),
            _navRow(
              context,
              '同步',
              model.sync?.state.autoSync == true ? '自动同步已开启' : '自动同步已关闭',
              Icons.sync_outlined,
              () => openSyncPage(context, model),
            ),
            _navRow(context, '回收站', '${model.trashedTodos.length} 项 Todo',
                Icons.delete_outline, () => openTrashPage(context, model)),
            if (model.corrupt.isNotEmpty ||
                model.classificationCorrupt ||
                model.indexCorrupt)
              _navRow(context, '损坏内容', _corruptSummary(), Icons.warning_amber,
                  () => _showCorrupt(context)),
            _navRow(context, '本地存储', '内容保存在应用专属空间',
                Icons.folder_outlined, () => _showStorage(context)),
            _section(context, '关于'),
            _navRow(context, '关于 TaskTips', '版本 $appVersion',
                Icons.info_outline, () => _showAbout(context)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Text('本地优先，随时记下要做的事。',
                  style: TextStyle(fontSize: 12, color: a.muted)),
            ),
          ],
        ),
      ),
    );
  }

  String _corruptSummary() {
    final n = model.corrupt.length +
        (model.classificationCorrupt ? 1 : 0) +
        (model.indexCorrupt ? 1 : 0);
    return '$n 项无法读取';
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

  String _themeLabel(ThemeModeSetting m) => switch (m) {
        ThemeModeSetting.system => '跟随系统',
        ThemeModeSetting.light => '浅色',
        ThemeModeSetting.dark => '深色',
      };

  /// 解析后的实际深浅色（跟随系统时给出当前生效值）。
  String _themeDescription(BuildContext context) {
    final m = model.themeMode;
    if (m != ThemeModeSetting.system) return _themeLabel(m);
    final dark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    return '跟随系统 · ${dark ? '深色' : '浅色'}';
  }

  Widget _themeRow(BuildContext context, AppColors a) {
    return ListTile(
      leading: const Icon(Icons.palette_outlined),
      title: const Text('主题', style: TextStyle(fontSize: 16)),
      subtitle: Text(_themeDescription(context),
          style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final v = await showModalBottomSheet<ThemeModeSetting>(
          context: context,
          backgroundColor: a.panel,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          builder: (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final m in ThemeModeSetting.values)
                  ListTile(
                    title: Text(_themeLabel(m)),
                    trailing: model.themeMode == m
                        ? const Icon(Icons.check)
                        : null,
                    onTap: () => Navigator.pop(ctx, m),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
        if (v != null) await model.setThemeMode(v);
      },
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

  Future<void> _showStorage(BuildContext context) async {
    final a = appColors(context, Theme.of(context).brightness);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: a.panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('本地存储',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Text(
                'Todo 内容、目录、标签和图片保存在本机。连接同步后可与其他设备交换内容。',
                style: TextStyle(fontSize: 14, height: 1.5, color: a.muted),
              ),
              const SizedBox(height: 12),
              Text('路径：${model.store.root.path}',
                  style: TextStyle(fontSize: 12, color: a.muted)),
              Text('当前 ${model.todos.length} 条 Todo',
                  style: TextStyle(fontSize: 12, color: a.muted)),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('知道了'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAbout(BuildContext context) async {
    final a = appColors(context, Theme.of(context).brightness);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: a.panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('关于 TaskTips',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Text('本地优先的轻量 Todo 工具\n版本 $appVersion',
                  style: TextStyle(fontSize: 14, height: 1.6, color: a.muted)),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('知道了'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 损坏内容只读提示（设计 §4.1：保留原件并提示更新或恢复，不静默丢弃）。
  Future<void> _showCorrupt(BuildContext context) async {
    final a = appColors(context, Theme.of(context).brightness);
    final lines = <String>[
      for (final c in model.corrupt) 'Todo ${c.fileName}：${c.reason}',
      if (model.classificationCorrupt) 'classification.json 无法读取（已备份到 recovery/）',
      if (model.indexCorrupt) 'index.json 无法读取（已备份到 recovery/，自动推送已暂停）',
    ];
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: a.panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('损坏内容',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Text(
                '以下内容只读展示，原件与恢复副本已保留（recovery/）。'
                '可能由更高版本的应用写入，请更新应用或从恢复副本找回。',
                style: TextStyle(fontSize: 14, height: 1.5, color: a.muted),
              ),
              const SizedBox(height: 8),
              for (final l in lines)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(l,
                      style: TextStyle(fontSize: 13, color: a.danger)),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('知道了'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
