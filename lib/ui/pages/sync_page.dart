import 'package:flutter/material.dart';
import 'package:tasktips_api/tasktips_api.dart' as api;

import '../../app/app_model.dart';
import '../../sync/sync_engine.dart';
import '../app.dart';
import '../theme.dart';

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

  SyncEngine? get _sync => widget.model.sync;

  @override
  void dispose() {
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
            onPressed: sync.busy ? null : () => sync.syncNow(),
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

  Widget _projectPicker(BuildContext context, AppColors a) {
    final sync = _sync!;
    return FutureBuilder<List<api.Project>>(
      future: sync.listProjects(),
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
                    onPressed: () => setState(() {}), child: const Text('重试')),
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
        if (!sync.state.bootstrapped) ...[
          const SizedBox(height: 8),
          _firstConnectCard(context, a, sync),
        ],
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('自动同步'),
          subtitle: const Text('启动、恢复前台、网络恢复与保存后触发；前台每 60 秒检查'),
          value: sync.state.autoSync,
          onChanged: sync.setAutoSync,
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
        TextButton(
            onPressed: () => sync.logout(),
            child: const Text('退出登录（保留本地内容）')),
        const SizedBox(height: 24),
      ],
    );
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
              future: sync.preview(),
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
                  return Text('概况读取失败：${snap.error}',
                      style: TextStyle(fontSize: 13, color: a.danger));
                }
                final p = snap.data!;
                return Text(
                  '本机待合入 ${p.localOnly} 项 · 远端待接收 ${p.remoteOnly} 项 · 潜在冲突 ${p.conflicts} 项',
                  style: const TextStyle(fontSize: 14),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusCard(BuildContext context, AppColors a, SyncEngine sync) {
    final (label, color) = switch (sync.status) {
      SyncStatus.disconnected => ('未连接', a.muted),
      SyncStatus.connected => ('已连接，未同步', a.warn),
      SyncStatus.syncing => ('同步中…', a.brand),
      SyncStatus.synced => ('已同步', const Color(0xFF107C10)),
      SyncStatus.partialFailed => ('部分失败', a.warn),
      SyncStatus.conflict => ('有冲突待处理', a.danger),
      SyncStatus.error => ('同步失败', a.danger),
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.circle, size: 10, color: color),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: color)),
              const Spacer(),
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
                  onPressed: sync.busy ? null : () => sync.syncNow(),
                  icon: const Icon(Icons.sync),
                  label: const Text('立即同步'),
                ),
              ),
            ]),
          ],
        ),
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
                subtitle: Text('本机 r${c.localRevision} / 远端 r${c.remoteRevision}'),
                trailing: Wrap(spacing: 4, children: [
                  TextButton(
                      onPressed: () => sync.resolveKeepLocal(c.kind, c.id),
                      child: const Text('保留本机')),
                  TextButton(
                      onPressed: () => sync.resolveUseRemote(c.kind, c.id),
                      child: const Text('采用远端')),
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
