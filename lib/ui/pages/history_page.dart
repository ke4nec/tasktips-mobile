import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tasktips_api/tasktips_api.dart' as api;

import '../../app/app_model.dart';
import '../app.dart';
import '../theme.dart';

/// 历史页：项目历史 / 单对象历史（信封列表）。
/// 仅展示时间、kind、id、revision、hash 前 8 位、device 等信封字段；
/// 正文按需单条 getPayload 查看（只读），不批量下载、不从历史恢复单对象
///（恢复一律走快照整项目流程，与桌面对齐）。
class HistoryPage extends StatefulWidget {
  final AppModel model;
  final String? kind; // null → 项目历史；非 null 需配 objectId
  final String? objectId;
  const HistoryPage({super.key, required this.model, this.kind, this.objectId});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _items = <api.SyncChange>[];
  bool _loading = false;
  bool _hasMore = true;
  int _after = 0;
  String? _error;
  String? _kindFilter; // 项目历史 kind 筛选

  bool get _isObject => widget.kind != null && widget.objectId != null;

  @override
  void initState() {
    super.initState();
    _loadMore();
  }

  Future<void> _loadMore({bool reset = false}) async {
    final sync = widget.model.sync;
    if (sync == null || _loading) return;
    setState(() {
      _loading = true;
      _error = null;
      if (reset) {
        _items.clear();
        _after = 0;
        _hasMore = true;
      }
    });
    try {
      final resp = _isObject
          ? await sync.fetchObjectHistory(widget.kind!, widget.objectId!,
              afterSequence: _after)
          : await sync.fetchProjectHistory(
              afterSequence: _after, kind: _kindFilter);
      if (!mounted) return;
      setState(() {
        _items.addAll(resp.items);
        _hasMore = resp.hasMore;
        if (resp.nextSequence != null) _after = resp.nextSequence!;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = appColors(context, Theme.of(context).brightness);
    return SecondaryScaffold(
      title: _isObject ? '对象历史' : '项目历史',
      body: Column(
        children: [
          if (!_isObject)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  const Text('类型筛选：'),
                  const SizedBox(width: 8),
                  DropdownButton<String?>(
                    value: _kindFilter,
                    hint: const Text('全部'),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('全部')),
                      DropdownMenuItem(value: 'todo', child: Text('Todo')),
                      DropdownMenuItem(
                          value: 'classification', child: Text('分类')),
                      DropdownMenuItem(value: 'index', child: Text('索引')),
                      DropdownMenuItem(value: 'image', child: Text('图片')),
                    ],
                    onChanged: (v) {
                      _kindFilter = v;
                      _loadMore(reset: true);
                    },
                  ),
                ],
              ),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(_error!,
                  style: TextStyle(fontSize: 13, color: a.danger)),
            ),
          Expanded(
            child: _items.isEmpty && !_loading
                ? Center(
                    child: Text('暂无历史记录',
                        style: TextStyle(fontSize: 13, color: a.muted)))
                : ListView.builder(
                    itemCount: _items.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i >= _items.length) {
                        if (!_loading) {
                          Future.microtask(() => _loadMore());
                        }
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child:
                              SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                        );
                      }
                      return _row(context, a, _items[i]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, AppColors a, api.SyncChange change) {
    final v = change.oneOf.value;
    final String kind;
    final String id;
    final int revision;
    final String? hash;
    final String device;
    final int seq;
    final bool tombstone;
    if (v is api.SyncTombstoneChange) {
      tombstone = true;
      kind = v.kind.name;
      id = v.id;
      revision = v.revision;
      hash = null;
      device = v.deviceId;
      seq = v.changeSequence;
    } else if (v is api.SyncObjectChange) {
      tombstone = false;
      kind = v.kind.name;
      id = v.id;
      revision = v.revision;
      hash = v.contentHash;
      device = v.deviceId;
      seq = v.changeSequence;
    } else {
      return const ListTile(title: Text('未知变更类型'));
    }
    final shortId = id.length > 10 ? id.substring(0, 10) : id;
    final h = hash;
    return ListTile(
      dense: true,
      title: Text('$kind $shortId  r$revision${tombstone ? '（此版本为删除）' : ''}',
          style: TextStyle(
              fontSize: 14,
              color: tombstone ? a.danger : a.text)),
      subtitle: Text(
          '#$seq · hash ${hash == null ? '-' : hash.substring(0, hash.length.clamp(0, 8))} · ${device.length > 8 ? device.substring(0, 8) : device}',
          style: TextStyle(fontSize: 12, color: a.muted)),
      trailing: h == null
          ? null
          : IconButton(
              tooltip: '查看正文',
              icon: const Icon(Icons.visibility_outlined, size: 20),
              onPressed: () => _showPayload(context, kind, h),
            ),
    );
  }

  Future<void> _showPayload(
      BuildContext context, String kind, String hash) async {
    final sync = widget.model.sync;
    if (sync == null) return;
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        content: SizedBox(
            height: 48,
            width: 48,
            child: Center(child: CircularProgressIndicator())),
      ),
    );
    final bytes = await sync.fetchHistoryPayload(hash);
    if (!context.mounted) return;
    Navigator.of(context).pop(); // 关闭 loading
    if (bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(sync.lastError ?? '正文加载失败')));
      return;
    }
    final text = kind == 'image'
        ? '二进制图片（${bytes.length} 字节），此处不直接展示。'
        : utf8.decode(bytes, allowMalformed: true);
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('历史正文（只读）'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(child: SelectableText(text)),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('关闭')),
        ],
      ),
    );
  }
}
