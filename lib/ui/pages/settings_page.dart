import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../app/app_model.dart';
import '../../app/update_service.dart';
import '../../infra/backup.dart';
import '../app.dart';
import '../theme.dart';
import '../update_flow.dart' show checkUpdateManually;
import '../widgets.dart' show ActiveModelBuilder, confirmDialog;

/// 设置页（设计稿 settingsPage）：外观 / 数据 / 关于 三组 setting-row，
/// 行内 trailing 显示当前值，主题用底部面板三选。
class SettingsPage extends StatelessWidget {
  final AppModel model;

  /// 所属 Tab 是否激活：离场时不再随 model 高频通知全量重建。
  final bool active;
  const SettingsPage({super.key, required this.model, this.active = true});

  // 与 pubspec.yaml versionName 保持一致（UpdateService 单源回退值）。
  static const appVersion = UpdateService.fallbackVersion;

  @override
  Widget build(BuildContext context) {
    final a = appColors(context, Theme.of(context).brightness);
    return ActiveModelBuilder(
      model: model,
      active: active,
      builder: (context) => Scaffold(
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
            _section(context, '应用更新'),
            SwitchListTile(
              secondary: const Icon(Icons.system_update_outlined),
              title: const Text('启动时自动检查更新', style: TextStyle(fontSize: 16)),
              subtitle: Text(
                  model.autoUpdateCheck ? '每次启动自动检查 GitHub 新版本' : '已关闭，仅手动检查',
                  style: const TextStyle(fontSize: 14)),
              value: model.autoUpdateCheck,
              onChanged: (v) => model.setAutoUpdateCheck(v),
            ),
            _CheckUpdateRow(),
            _section(context, '关于'),
            const _AboutRow(),
            const SizedBox(height: 24),
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
              const SizedBox(height: 8),
              Text('备份仅含 Todo 内容、目录、标签与图片，不含设备身份与同步凭据；'
                  '恢复后按本机改动参与下次同步。',
                  style: TextStyle(fontSize: 12, color: a.muted)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _exportBackup(context),
                      icon: const Icon(Icons.upload_outlined, size: 18),
                      label: const Text('导出备份'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _importBackup(context),
                      icon: const Icon(Icons.download_outlined, size: 18),
                      label: const Text('恢复备份'),
                    ),
                  ),
                ],
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

  /// 导出备份：先在应用目录打包，再经 SAF 写出。
  /// file_picker 13.x 的 saveFile 以 bytes 经 ContentResolver 写 content Uri
  ///（旧版返回 content:// 字符串，dart:io 无法直接写）。
  Future<void> _exportBackup(BuildContext context) async {
    final now = DateTime.now();
    final name = 'tasktips-backup-${now.year.toString().padLeft(4, '0')}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}-'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}.zip';
    // 临时包：state/ 已排除系统云备份，导出后即删
    final tmp = File(p.join(model.store.stateDir.path, 'backup-export.tmp.zip'));
    try {
      // 备份 manifest 记运行时版本（自更新后常数会滞后），取不到再回退。
      final v = await const UpdateService().currentVersion();
      await exportBackup(model.store, tmp.path, appVersion: v);
      final uri = await FilePicker.saveFile(
        dialogTitle: '导出备份',
        fileName: name,
        type: FileType.custom,
        allowedExtensions: ['zip'],
        mimeType: 'application/zip',
        bytes: await tmp.readAsBytes(),
      );
      if (uri == null) return; // 用户取消
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('备份已导出')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('导出失败：$e')));
      }
      return;
    } finally {
      try {
        if (await tmp.exists()) await tmp.delete();
      } catch (_) {}
    }
  }

  /// 恢复备份：覆盖本机全部内容（先快照现状，失败回滚），完成后重载并提示
  /// 将作为本机改动参与下次同步。
  Future<void> _importBackup(BuildContext context) async {
    final picked = await FilePicker.pickFile(
      dialogTitle: '选择备份文件',
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    final path = picked?.path;
    if (path == null) return; // 用户取消或非 file:// 引用
    if (!context.mounted) return;
    final ok = await confirmDialog(context,
        title: '恢复备份',
        message: '将用备份覆盖本机全部 Todo、目录与标签（现状先快照到 recovery/）。'
            '恢复后按本机改动参与下次同步。',
        confirmText: '恢复',
        destructive: true);
    if (!ok) return;
    try {
      await model.restoreBackup(path);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('恢复失败：$e')));
      }
      return;
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('已恢复备份，将作为本机改动参与下次同步')));
    }
  }

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

/// “检查更新”行：副标题显示本机已装版本（PackageInfo 运行时值），
/// 点击走手动检查流程（加载框→最新提示/失败提示/新版确认框）。
class _CheckUpdateRow extends StatefulWidget {
  const _CheckUpdateRow();

  @override
  State<_CheckUpdateRow> createState() => _CheckUpdateRowState();
}

class _CheckUpdateRowState extends State<_CheckUpdateRow> {
  late final Future<String> _version =
      const UpdateService().currentVersion();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _version,
      builder: (context, snap) {
        final v = snap.data ?? SettingsPage.appVersion;
        return ListTile(
          leading: const Icon(Icons.update_outlined),
          title: const Text('检查更新', style: TextStyle(fontSize: 16)),
          subtitle: Text('当前版本 $v · 点击手动检查',
              style: const TextStyle(fontSize: 14)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => checkUpdateManually(context),
        );
      },
    );
  }
}

/// “关于”行：版本号只在弹层内展示，行副标题不再重复版本号
///（“检查更新”行已显示当前版本）。
/// 点击弹层展示完整关于信息。
class _AboutRow extends StatefulWidget {
  const _AboutRow();

  @override
  State<_AboutRow> createState() => _AboutRowState();
}

class _AboutRowState extends State<_AboutRow> {
  late final Future<String> _version =
      const UpdateService().currentVersion();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _version,
      builder: (context, snap) {
        final v = snap.data ?? SettingsPage.appVersion;
        return ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('关于 TaskTips', style: TextStyle(fontSize: 16)),
          subtitle:
              const Text('查看版本与应用信息', style: TextStyle(fontSize: 14)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => showAboutSheet(context, v),
        );
      },
    );
  }
}

/// 关于弹层（顶层函数，供 _AboutRow 调用）。
Future<void> showAboutSheet(BuildContext context, String version) async {
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
            Text('本地优先的轻量 Todo 工具\n版本 $version',
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
