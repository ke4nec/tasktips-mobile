import 'package:flutter/material.dart';
import 'package:tasktips_api/tasktips_api.dart' as api;
import 'package:workmanager/workmanager.dart';

import '../../app/app_model.dart';
import '../../sync/sync_engine.dart';
import '../app.dart';
import '../theme.dart';
import '../widgets.dart' show confirmDialog;
import 'history_page.dart';

/// 同步页：连接服务端、项目选择、立即同步、自动同步开关、
/// 状态与错误、冲突处理、多设备信息与本机同步日志。
class SyncPage extends StatefulWidget {
  final AppModel model;
  const SyncPage({super.key, required this.model});

  @override
  State<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage> {
  final _serverCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _connecting = false;
  // FutureBuilder 的 future 缓存在 State：放 build 里会因任意 notify
  // （同步状态翻转等）重建而重复发起网络请求。
  Future<List<api.Project>>? _projectsFuture;
  Future<SyncPreview>? _previewFuture;
  String? _previewProjectId;

  SyncEngine? get _sync => widget.model.sync;

  @override
  void initState() {
    super.initState();
    // 设计 §4.2：预览后本机或远端又发生修改时重新计算，
    // 不按过期预览展示——本机数据变化即失效缓存。
    widget.model.addListener(_onModelChanged);
  }

  void _onModelChanged() {
    if (_previewFuture != null && mounted) {
      setState(() => _previewFuture = null);
    }
  }

  @override
  void dispose() {
    widget.model.removeListener(_onModelChanged);
    _serverCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = appColors(context, Theme.of(context).brightness);
    final sync = _sync;
    if (sync == null) {
      return const SecondaryScaffold(
        title: '同步',
        body: Center(child: Text('同步未初始化')),
      );
    }
    return SecondaryScaffold(
      title: '同步',
      actions: [
        if (sync.state.serverUrl != null)
          IconButton(
            tooltip: '立即同步',
            onPressed: sync.busy ? null : () => sync.syncNow(manual: true),
            icon: const Icon(Icons.sync),
          ),
      ],
      body: AnimatedBuilder(
        animation: sync,
        builder: (context, _) {
          if (sync.state.serverUrl == null) {
            return _loginForm(context, a);
          }
          if (sync.state.projectId == null) {
            return _projectPicker(context, a);
          }
          return _syncDashboard(context, a, sync);
        },
      ),
    );
  }

  // ---------- 登录 ----------

  Widget _loginForm(BuildContext context, AppColors a) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.cloud_outlined, color: a.muted),
                  const SizedBox(width: 8),
                  const Text('连接服务端',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ]),
                const SizedBox(height: 8),
                Text(
                  '登录后在桌面端、手机等多设备间接续编辑。连接前内容仅保存在本机。',
                  style: TextStyle(fontSize: 14, color: a.muted, height: 1.5),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _serverCtrl,
          decoration: const InputDecoration(
              labelText: '服务端地址（HTTPS）', hintText: 'https://sync.example.com'),
          keyboardType: TextInputType.url,
          autocorrect: false,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailCtrl,
          decoration: const InputDecoration(labelText: '邮箱'),
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordCtrl,
          decoration: const InputDecoration(labelText: '密码'),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _connecting ? null : _connect,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          child: _connecting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('登录'),
        ),
      ],
    );
  }

  Future<void> _connect() async {
    setState(() => _connecting = true);
    final err = await _sync!.connect(
      serverUrl: _serverCtrl.text,
      email: _emailCtrl.text,
      password: _passwordCtrl.text,
    );
    if (!mounted) return;
    setState(() => _connecting = false);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
    _passwordCtrl.clear();
  }

  // ---------- 项目选择 ----------

  /// 首连概况按项目缓存一次；点“立即同步”完成 bootstrap 后
  /// state.bootstrapped 变 true，此卡片整体不再构建。
  Future<SyncPreview> _previewFor(SyncEngine sync) {
    if (_previewFuture == null || _previewProjectId != sync.state.projectId) {
      _previewProjectId = sync.state.projectId;
      _previewFuture = sync.preview();
    }
    return _previewFuture!;
  }

  Widget _projectPicker(BuildContext context, AppColors a) {
    final sync = _sync!;
    _projectsFuture ??= sync.listProjects();
    return FutureBuilder<List<api.Project>>(
      future: _projectsFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('项目列表加载失败'),
                const SizedBox(height: 8),
                FilledButton(
                    onPressed: () => setState(
                        () => _projectsFuture = sync.listProjects()),
                    child: const Text('重试')),
              ],
            ),
          );
        }
        final projects = snap.data ?? [];
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('选择项目', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('当前账号：${sync.state.email ?? ''}',
                style: TextStyle(fontSize: 13, color: a.muted)),
            const SizedBox(height: 12),
            for (final p in projects)
              Card(
                child: ListTile(
                  title: Text(p.name),
                  subtitle:
                      Text('创建于 ${p.createdAt.toLocal().toString().substring(0, 10)}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => sync.selectProject(p.id),
                ),
              ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _createProject(context),
              icon: const Icon(Icons.add),
              label: const Text('新建项目'),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: () => sync.logout(), child: const Text('退出登录')),
          ],
        );
      },
    );
  }

  Future<void> _createProject(BuildContext context) async {
    final nameCtrl = TextEditingController();
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            left: 16, right: 16, top: 16,
            bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('新建项目', style: Theme.of(ctx).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
                controller: nameCtrl,
                autofocus: true,
                decoration: const InputDecoration(hintText: '项目名称')),
            const SizedBox(height: 12),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('创建')),
          ],
        ),
      ),
    );
    if (ok == true && nameCtrl.text.trim().isNotEmpty) {
      try {
        final p = await _sync!.createProject(nameCtrl.text.trim());
        await _sync!.selectProject(p.id);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('创建失败：$e')));
        }
      }
    }
    nameCtrl.dispose();
  }

  // ---------- 同步面板 ----------

  Widget _syncDashboard(BuildContext context, AppColors a, SyncEngine sync) {
    final unresolved = sync.state.conflicts.where((c) => !c.resolved).toList();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _statusCard(context, a, sync),
        if (sync.state.submitPaused != null) ...[
          const SizedBox(height: 8),
          // 登录失效/设备撤销/项目维护：自动提交已暂停，手动同步仍可用
          Card(
            color: a.dangerContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.pause_circle_outline,
                          size: 20, color: a.danger),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                            '自动同步已暂停（${sync.state.submitPaused}）。请重新登录或手动同步恢复。',
                            style:
                                TextStyle(fontSize: 13, color: a.danger)),
                      ),
                    ],
                  ),
                  // 终局失效（凭据已清空）时一键回到登录表单，本地内容保留
                  if (sync.status == SyncStatus.disconnected)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => sync.logout(),
                        child: const Text('重新登录'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
        if (!sync.state.bootstrapped) ...[
          const SizedBox(height: 8),
          _firstConnectCard(context, a, sync),
        ],
        const SizedBox(height: 8),
        _syncStats(a, sync),
        SwitchListTile(
          title: const Text('自动同步'),
          subtitle: const Text('启动、恢复前台、网络恢复与保存后触发；前台每 60 秒检查；'
              '后台 15 分钟周期任务由系统调度，不承诺准点执行'),
          value: sync.state.autoSync,
          onChanged: (v) async {
            await sync.setAutoSync(v);
            if (v) {
              await Workmanager().registerPeriodicTask(
                'tasktips-sync', 'tasktipsPeriodicSync',
                frequency: const Duration(minutes: 15),
                existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
              );
            } else {
              await Workmanager().cancelByUniqueName('tasktips-sync');
            }
          },
        ),
        if (unresolved.isNotEmpty) ...[
          const SizedBox(height: 8),
          _conflictCard(context, a, sync, unresolved),
        ],
        const SizedBox(height: 8),
        _devicesCard(context, a, sync),
        const SizedBox(height: 8),
        _logCard(context, a, sync),
        const SizedBox(height: 8),
        _accountCard(context, a, sync),
        const SizedBox(height: 8),
        _SnapshotRestoreSection(model: widget.model),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text('离线时继续编辑，连接恢复后再同步。',
              style: TextStyle(fontSize: 12, color: a.muted)),
        ),
        const SizedBox(height: 8),
        TextButton(
            onPressed: () => _confirmSwitchProject(context, sync),
            child: const Text('切换项目（重新预览确认）')),
        const SizedBox(height: 8),
        TextButton(
            onPressed: () => sync.logout(),
            child: const Text('退出登录（保留本地内容）')),
        const SizedBox(height: 24),
      ],
    );
  }

  /// 切换项目：回到项目选择页；选择不同项目时同步基线会被隔离，
  /// 重新走首连预览确认流程（跨项目数据迁移属待确认事项，不自动执行）。
  Future<void> _confirmSwitchProject(BuildContext context, SyncEngine sync) async {
    final ok = await confirmDialog(context,
        title: '切换项目',
        message: '将断开当前项目的同步上下文并回到项目选择。本地内容保留；'
            '选择不同项目后会重新预览确认，不会自动迁移内容。',
        confirmText: '切换项目');
    if (ok) await sync.beginProjectSwitch();
  }

  /// 首次连接：先读取远端概况，用户确认后才开始写入同步。
  Widget _firstConnectCard(BuildContext context, AppColors a, SyncEngine sync) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('首次接入',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('同步前先核对两端差异；确认后才会写入。冲突按整对象处理，不做字段合并。',
                style: TextStyle(fontSize: 13, color: a.muted)),
            const SizedBox(height: 8),
            FutureBuilder(
              future: _previewFor(sync),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(8),
                    child: SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                }
                if (snap.hasError) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('概况读取失败：${snap.error}',
                          style: TextStyle(fontSize: 13, color: a.danger)),
                      TextButton(
                        onPressed: () => setState(() {
                          _previewFuture = null;
                          _previewFor(sync);
                        }),
                        child: const Text('重试'),
                      ),
                    ],
                  );
                }
                final p = snap.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '本机待合入 ${p.localOnly} 项 · 远端待接收 ${p.remoteOnly} 项 · 潜在冲突 ${p.conflicts} 项',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    // 确认后才开始写入同步（bootstrap）；首连完成会默认开启自动同步
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: sync.busy
                            ? null
                            : () async {
                                await sync.syncNow(manual: true);
                                if (sync.state.autoSync) {
                                  await Workmanager().registerPeriodicTask(
                                    'tasktips-sync',
                                    'tasktipsPeriodicSync',
                                    frequency: const Duration(minutes: 15),
                                    existingWorkPolicy:
                                        ExistingPeriodicWorkPolicy.keep,
                                  );
                                }
                              },
                        icon: const Icon(Icons.sync),
                        label: const Text('确认并开始同步'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusCard(BuildContext context, AppColors a, SyncEngine sync) {
    // "待同步"：已连接/已同步但存在未上传的本机变更（§4.3 六态）
    final unsynced = !sync.busy && sync.hasUnsyncedChanges;
    final (label, color) = switch (sync.status) {
      SyncStatus.syncing => ('同步中…', a.brandInk),
      SyncStatus.connected => (
          sync.state.conflicts.any((c) => !c.resolved)
              ? '有冲突待处理'
              : unsynced
                  ? '待同步'
                  : '已连接',
          a.brandInk),
      SyncStatus.synced => (unsynced ? '待同步' : '已同步', a.brandInk),
      SyncStatus.conflict => ('有冲突待处理', a.danger),
      SyncStatus.partialFailed => ('部分失败', a.warn),
      SyncStatus.error => ('上次同步失败', a.danger),
      SyncStatus.disconnected => ('仅本机（未连接同步）', a.muted),
    };
    // 设计稿 .sync-card：brand-container 圆角 24 + 32dp 图标 + 副行说明
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: a.brandContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.circle, size: 10, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: a.text)),
            ),
            if (sync.busy)
              const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2)),
          ]),
          const SizedBox(height: 4),
          Text('${sync.state.serverUrl ?? ''} · ${sync.state.email ?? ''}',
              style: TextStyle(fontSize: 13, color: a.muted)),
          if (sync.lastError != null) ...[
            const SizedBox(height: 8),
            Text(sync.lastError!,
                style: TextStyle(fontSize: 13, color: a.danger)),
          ],
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: sync.busy ? null : () => sync.syncNow(manual: true),
                icon: const Icon(Icons.sync),
                label: const Text('立即同步'),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  /// 设计稿 .sync-stats：三格统计（推送/拉取/冲突），数据来自本机同步日志。
  Widget _syncStats(AppColors a, SyncEngine sync) {
    final logs = sync.state.logs;
    var pushed = 0, pulled = 0;
    for (final l in logs) {
      if (l.result == 'ok') {
        if (l.direction == 'upload') {
          pushed += l.count;
        } else if (l.direction == 'download') {
          pulled += l.count;
        }
      }
    }
    final conflicts = sync.state.conflicts.length;
    Widget cell(int n, String label) => Container(
          color: a.panel,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
          child: Column(
            children: [
              Text('$n',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: a.text)),
              const SizedBox(height: 3),
              Text(label, style: TextStyle(fontSize: 12, color: a.muted)),
            ],
          ),
        );
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: a.line),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(child: cell(pushed, '推送')),
          Expanded(child: cell(pulled, '拉取')),
          Expanded(child: cell(conflicts, '冲突')),
        ],
      ),
    );
  }

  Widget _conflictCard(
      BuildContext context, AppColors a, SyncEngine sync, List conflicts) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('冲突（${conflicts.length}）',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600, color: a.danger)),
            const SizedBox(height: 4),
            Text('两端都修改了同一对象。选择一个版本，另一版本保留在恢复副本中。',
                style: TextStyle(fontSize: 13, color: a.muted)),
            const SizedBox(height: 8),
            for (final c in conflicts)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(
                    '${_kindLabel(c.kind)} ${c.id.substring(0, c.id.length.clamp(0, 10))}'),
                subtitle: Text(c.remoteDeleted
                    ? '远端版本为删除（本机 r${c.localRevision}）'
                    : '本机 r${c.localRevision} / 远端 r${c.remoteRevision}'),
                trailing: Wrap(spacing: 4, children: [
                  TextButton(
                      onPressed: () => sync.resolveKeepLocal(c.kind, c.id),
                      child: const Text('保留本机')),
                  TextButton(
                      onPressed: () => sync.resolveUseRemote(c.kind, c.id),
                      child: Text(c.remoteDeleted ? '接受删除' : '采用远端')),
                ]),
              ),
          ],
        ),
      ),
    );
  }

  String _kindLabel(String kind) => switch (kind) {
        'todo' => 'Todo',
        'classification' => '分类',
        'index' => '索引',
        _ => kind
      };

  Widget _devicesCard(BuildContext context, AppColors a, SyncEngine sync) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Text('设备',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              const Spacer(),
              if (sync.devices.isNotEmpty)
                Text('${sync.devices.length} 台',
                    style: TextStyle(fontSize: 13, color: a.muted)),
            ]),
            const SizedBox(height: 4),
            Text('“最近活动”仅为服务端记录的最后活跃时间，不代表实时在线。',
                style: TextStyle(fontSize: 12, color: a.muted)),
            const SizedBox(height: 8),
            for (final d in sync.devices)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  Icon(
                      d.platform == 'android'
                          ? Icons.smartphone
                          : Icons.computer,
                      size: 18,
                      color: a.muted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.displayName,
                            style: const TextStyle(fontSize: 14)),
                        Text(
                          '${d.platform} · ${_lastSeen(d)}'
                          '${d.id == widget.model.deviceId ? ' · 本机' : ''}',
                          style: TextStyle(fontSize: 12, color: a.muted),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: '管理设备',
                    icon: Icon(Icons.more_vert,
                        size: 20, color: a.muted),
                    onSelected: (v) {
                      if (v == 'rename') {
                        _renameDevice(context, sync, d);
                      } else {
                        _revokeDevice(context, sync, d);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                          value: 'rename', child: Text('重命名')),
                      PopupMenuItem(
                          value: 'revoke', child: Text('撤销此设备')),
                    ],
                  ),
                ]),
              ),
            TextButton.icon(
              onPressed: () => sync.refreshDevices(),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('刷新'),
            ),
          ],
        ),
      ),
    );
  }

  /// 账号区：历史浏览与修改密码入口。
  Widget _accountCard(BuildContext context, AppColors a, SyncEngine sync) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('同步历史'),
            subtitle: const Text('按对象版本信封浏览'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => openSecondaryPage(
                context, HistoryPage(model: widget.model)),
          ),
          ListTile(
            leading: const Icon(Icons.password_outlined),
            title: const Text('修改密码'),
            subtitle: const Text('成功后其他设备需重新登录'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _changePassword(context, sync),
          ),
        ],
      ),
    );
  }

  Future<void> _renameDevice(
      BuildContext context, SyncEngine sync, api.Device d) async {
    final ctrl = TextEditingController(text: d.displayName);
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            left: 16, right: 16, top: 16,
            bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('重命名设备', style: Theme.of(ctx).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
                controller: ctrl,
                autofocus: true,
                maxLength: 128,
                decoration:
                    const InputDecoration(hintText: '设备名称（1-128 个字符）')),
            const SizedBox(height: 12),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('保存')),
          ],
        ),
      ),
    );
    final name = ctrl.text;
    ctrl.dispose();
    if (ok != true) return;
    final err = await sync.renameDevice(d.id, name);
    if (err != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  Future<void> _revokeDevice(
      BuildContext context, SyncEngine sync, api.Device d) async {
    final isSelf = d.id == widget.model.deviceId;
    final ok = await confirmDialog(context,
        title: '撤销此设备',
        message: isSelf
            ? '撤销本机设备将立即断开同步并清除本机凭据，需要重新登录。本地内容保留。此操作立即生效且不可恢复。'
            : '撤销后该设备下次同步将收到“设备已被撤销”提示。此操作立即生效且不可恢复。',
        confirmText: '撤销',
        destructive: true);
    if (!ok) return;
    final err = await sync.revokeDevice(d.id);
    if (err != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  Future<void> _changePassword(BuildContext context, SyncEngine sync) async {
    final cur = TextEditingController();
    final next = TextEditingController();
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            left: 16, right: 16, top: 16,
            bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('修改密码', style: Theme.of(ctx).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('成功后其他设备需重新登录。',
                style: TextStyle(
                    fontSize: 13,
                    color: appColors(
                        ctx, Theme.of(ctx).brightness)
                        .muted)),
            const SizedBox(height: 12),
            TextField(
                controller: cur,
                obscureText: true,
                decoration: const InputDecoration(labelText: '当前密码')),
            const SizedBox(height: 8),
            TextField(
                controller: next,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: '新密码', hintText: '至少 12 个字符')),
            const SizedBox(height: 12),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('修改')),
          ],
        ),
      ),
    );
    final c = cur.text, n = next.text;
    cur.dispose();
    next.dispose();
    if (ok != true) return;
    final err = await sync.changePassword(c, n);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err ?? '密码修改成功')));
    }
  }

  String _lastSeen(api.Device d) {
    final t = d.lastSeenAt ?? d.lastLoginAt ?? d.createdAt;
    return '最近活动 ${t.toLocal().toString().substring(0, 16)}';
  }

  Widget _logCard(BuildContext context, AppColors a, SyncEngine sync) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('本机同步日志',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('仅记录时间、方向、数量与结果，不记录内容。',
                style: TextStyle(fontSize: 12, color: a.muted)),
            const SizedBox(height: 8),
            if (sync.state.logs.isEmpty)
              Text('暂无记录', style: TextStyle(fontSize: 13, color: a.muted)),
            for (final l in sync.state.logs.take(30))
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${l.at.toLocal().toString().substring(5, 16)}  ${_dirLabel(l.direction)}  '
                  '${l.count}  ${l.result == 'ok' ? '成功' : l.result == 'conflict' ? '冲突' : l.result == 'rejected' ? '被拒绝' : '失败'}'
                  '${l.errorCode != null ? ' (${l.errorCode})' : ''}',
                  style: TextStyle(
                      fontSize: 12,
                      color: l.result == 'ok' ? a.muted : a.danger),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _dirLabel(String d) => switch (d) {
        'upload' => '↑ 上传',
        'download' => '↓ 下载',
        'login' => '登录',
        'bootstrap' => '初始同步',
        _ => d,
      };
}

/// 高级区：快照与恢复。恢复会影响项目内所有设备；恢复成功后服务端
/// generation+1，下一轮同步自动走既有“重新 bootstrap → 预览确认”链路。
class _SnapshotRestoreSection extends StatefulWidget {
  final AppModel model;
  const _SnapshotRestoreSection({required this.model});

  @override
  State<_SnapshotRestoreSection> createState() =>
      _SnapshotRestoreSectionState();
}

class _SnapshotRestoreSectionState extends State<_SnapshotRestoreSection> {
  Future<List<api.Snapshot>>? _snapshotsFuture;
  api.RestoreJob? _job;
  bool _polling = false;

  SyncEngine? get _sync => widget.model.sync;

  @override
  void dispose() {
    _polling = false;
    super.dispose();
  }

  bool _terminal(api.RestoreJob j) =>
      j.status == api.RestoreJobStatusEnum.succeeded ||
      j.status == api.RestoreJobStatusEnum.failed ||
      j.status == api.RestoreJobStatusEnum.cancelled;

  Future<void> _poll(String restoreId) async {
    _polling = true;
    while (_polling && mounted) {
      await Future.delayed(const Duration(seconds: 3));
      if (!_polling || !mounted) return;
      try {
        final j = await _sync!.fetchRestore(restoreId);
        if (j == null || !mounted) return;
        setState(() => _job = j);
        if (_terminal(j)) {
          _polling = false;
          return;
        }
      } catch (_) {
        return; // 网络失败停止轮询，用户可手动刷新
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = appColors(context, Theme.of(context).brightness);
    final sync = _sync;
    if (sync == null) return const SizedBox.shrink();
    return Card(
      child: ExpansionTile(
        title: const Text('高级：快照与恢复'),
        subtitle: Text('恢复会影响项目内所有设备',
            style: TextStyle(fontSize: 12, color: a.warn)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('快照'),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final err = await sync.createSnapshot();
                        if (!mounted) return;
                        if (err != null) {
                          messenger.showSnackBar(
                              SnackBar(content: Text(err)));
                        } else {
                          setState(
                              () => _snapshotsFuture = sync.listSnapshots());
                        }
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('立即创建快照'),
                    ),
                  ],
                ),
                FutureBuilder<List<api.Snapshot>>(
                  future: _snapshotsFuture ??= sync.listSnapshots(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(8),
                        child: SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2)),
                      );
                    }
                    if (snap.hasError) {
                      return Row(
                        children: [
                          const Expanded(child: Text('快照列表加载失败')),
                          TextButton(
                            onPressed: () => setState(() =>
                                _snapshotsFuture = sync.listSnapshots()),
                            child: const Text('重试'),
                          ),
                        ],
                      );
                    }
                    final list = snap.data ?? [];
                    if (list.isEmpty) {
                      return Text('暂无快照',
                          style:
                              TextStyle(fontSize: 13, color: a.muted));
                    }
                    return Column(
                      children: [
                        for (final s in list)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            title: Text(
                                'generation ${s.generation} · seq ${s.changeSequence}'),
                            subtitle: Text(
                                '${s.status.name} · ${s.createdAt.toLocal().toString().substring(0, 16)}',
                                style: TextStyle(
                                    fontSize: 12, color: a.muted)),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _restoreSheet(context, sync),
                  icon: const Icon(Icons.restore, size: 16),
                  label: const Text('从快照/时间点恢复'),
                ),
                if (_job != null) ...[
                  const SizedBox(height: 8),
                  _jobCard(context, a, sync, _job!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _jobCard(
      BuildContext context, AppColors a, SyncEngine sync, api.RestoreJob j) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: a.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('恢复任务 ${j.status.name}',
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
              '已恢复 ${j.restoredObjects} 对象 / ${j.restoredTombstones} 墓碑'
              '${j.errorCode != null ? '（${j.errorCode}）' : ''}',
              style: TextStyle(fontSize: 12, color: a.muted)),
          if (j.status == api.RestoreJobStatusEnum.succeeded)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('恢复成功：下一轮同步将自动重新拉取并进入预览确认。',
                  style: TextStyle(fontSize: 12, color: a.brandInk)),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton(
                onPressed: () async {
                  final updated = await sync.fetchRestore(j.id);
                  if (updated != null && mounted) {
                    setState(() => _job = updated);
                  }
                },
                child: const Text('刷新状态'),
              ),
              if (!_terminal(j))
                TextButton(
                  onPressed: () => _cancelSheet(context, sync, j.id),
                  child: Text('取消恢复',
                      style: TextStyle(color: a.danger)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _restoreSheet(BuildContext context, SyncEngine sync) async {
    final seqCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();
    String? snapshotId;
    bool bySnapshot = true;
    final snapshots = await sync.listSnapshots().catchError((_) => <api.Snapshot>[]);
    if (!context.mounted) return;
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
              left: 16, right: 16, top: 16,
              bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('发起恢复', style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text('恢复会影响项目内所有设备，原因将写入永久审计。',
                  style: TextStyle(
                      fontSize: 13,
                      color:
                          appColors(ctx, Theme.of(ctx).brightness).warn)),
              const SizedBox(height: 12),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('按快照')),
                  ButtonSegment(value: false, label: Text('按时间点')),
                ],
                selected: {bySnapshot},
                onSelectionChanged: (s) =>
                    setSheet(() => bySnapshot = s.first),
              ),
              const SizedBox(height: 12),
              if (bySnapshot)
                DropdownButton<String>(
                  isExpanded: true,
                  value: snapshotId,
                  hint: const Text('选择快照'),
                  items: [
                    for (final s in snapshots)
                      DropdownMenuItem(
                        value: s.id,
                        child: Text(
                            'generation ${s.generation} · ${s.createdAt.toLocal().toString().substring(0, 16)}'),
                      ),
                  ],
                  onChanged: (v) => setSheet(() => snapshotId = v),
                )
              else
                TextField(
                  controller: seqCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: '目标 changeSequence', hintText: '整数'),
                ),
              const SizedBox(height: 8),
              TextField(
                controller: reasonCtrl,
                maxLength: 512,
                decoration: const InputDecoration(
                    labelText: '恢复原因（必填，1-512 个字符）'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('发起恢复'),
              ),
            ],
          ),
        ),
      ),
    );
    final reason = reasonCtrl.text;
    final seq = int.tryParse(seqCtrl.text.trim());
    seqCtrl.dispose();
    reasonCtrl.dispose();
    if (ok != true) return;
    final (job, err) = await sync.createRestore(
      snapshotId: bySnapshot ? snapshotId : null,
      targetChangeSequence: bySnapshot ? null : seq,
      reason: reason,
    );
    if (!context.mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    if (!mounted) return;
    setState(() => _job = job);
    if (job != null) _poll(job.id);
  }

  Future<void> _cancelSheet(
      BuildContext context, SyncEngine sync, String restoreId) async {
    final reasonCtrl = TextEditingController();
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            left: 16, right: 16, top: 16,
            bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('取消恢复', style: Theme.of(ctx).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              maxLength: 512,
              decoration:
                  const InputDecoration(labelText: '取消原因（必填）'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('确认取消'),
            ),
          ],
        ),
      ),
    );
    final reason = reasonCtrl.text;
    reasonCtrl.dispose();
    if (ok != true) return;
    final err = await sync.cancelRestore(restoreId, reason);
    if (!context.mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    } else {
      final updated = await sync.fetchRestore(restoreId);
      if (updated != null && mounted) setState(() => _job = updated);
    }
  }
}
