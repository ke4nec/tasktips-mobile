import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import '../../app/app_model.dart';
import '../../domain/todo.dart';
import '../../infra/store.dart';
import '../app.dart';
import '../theme.dart';
import '../widgets.dart';
import 'history_page.dart';

/// Todo 编辑页：编辑/预览切换、400ms 防抖自动保存 + 2s 周期快照、
/// 元数据（优先级/日期/目录/标签）、格式工具栏随键盘、移入回收站。
class DetailPage extends StatefulWidget {
  final AppModel model;
  final String todoId;
  const DetailPage({super.key, required this.model, required this.todoId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

enum _SaveState { none, pending, saving, saved, failed }

class _DetailPageState extends State<DetailPage> {
  final _bodyCtrl = TextEditingController();
  final _bodyFocus = FocusNode();
  Timer? _debounce;
  Timer? _periodic;
  DateTime? _lastInputAt;
  bool _preview = false;
  bool _closing = false;
  _SaveState _saveState = _SaveState.saved;
  bool _imeComposing = false; // 输入法组合期：不落盘、不派生标题
  // 正在把远端/外部写入同步进输入框：此时 text 变更不算本地编辑
  bool _applyingExternal = false;
  int _cbCounter = 0;
  // 待保存的最新快照（比已提交保存更新的内容在此排队）
  Todo? _pendingSnapshot;
  bool _saving = false;

  String get _id => widget.todoId;
  AppModel get m => widget.model;

  @override
  void initState() {
    super.initState();
    _bodyCtrl.text = m.byId(_id)?.body ?? '';
    _bodyCtrl.addListener(_onBodyChanged);
    // 完成按钮、元数据写入与后台同步 pull 都会 notifyListeners：
    // 监听 model 使页面随外部写入刷新（设计 §2 统一写入契约的 UI 面）
    m.addListener(_onModelChanged);
    _bodyFocus.addListener(() {
      if (_bodyFocus.hasFocus) setState(() {});
    });
    // 连续输入期间至多 2s 安排一次快照保存
    _periodic = Timer.periodic(const Duration(seconds: 2), (_) => _flushIfNeeded());
  }

  @override
  void dispose() {
    // 先移除监听再触发落盘写，避免写通知打到已销毁的 State
    m.removeListener(_onModelChanged);
    // 离开页面立即刷新待保存内容（进程终止可能收不到回调，故不能只依赖此处）
    _flushSync();
    _debounce?.cancel();
    _periodic?.cancel();
    _bodyCtrl.dispose();
    _bodyFocus.dispose();
    super.dispose();
  }

  /// 外部写入（完成/元数据/后台同步）后的页面刷新。
  /// 仅在本机无待保存编辑且不在输入法组合期时同步正文到输入框；
  /// 有待保存内容时只刷新元数据，禁止替换正在输入的正文（设计 §4.3）。
  void _onModelChanged() {
    if (!mounted || _closing) return;
    final t = m.byId(_id);
    final noPendingEdits =
        _saveState == _SaveState.saved || _saveState == _SaveState.none;
    if (t != null && noPendingEdits && !_imeComposing && t.body != _bodyCtrl.text) {
      _applyingExternal = true;
      _bodyCtrl.text = t.body;
      _applyingExternal = false;
    }
    setState(() {});
  }

  void _onBodyChanged() {
    if (_closing || _applyingExternal) return;
    // 输入法组合期间不重设内容/不触发保存；组合结束会再次回调
    final range = _bodyCtrl.value.composing;
    _imeComposing = range.isValid && range != TextRange.empty;
    setState(() {
      _lastInputAt = DateTime.now();
      if (_saveState != _SaveState.failed) _saveState = _SaveState.pending;
    });
    _debounce?.cancel();
    if (_imeComposing) return;
    _debounce = Timer(const Duration(milliseconds: 400), () => _saveSnapshot());
  }

  void _flushIfNeeded() {
    // 有待保存内容且防抖迟迟未触发（持续输入）时兜底落盘
    if (_saveState == _SaveState.pending &&
        _lastInputAt != null &&
        DateTime.now().difference(_lastInputAt!) >= const Duration(milliseconds: 1200) &&
        !_saving) {
      _saveSnapshot();
    } else if (_saveState == _SaveState.pending && _pendingSnapshot == null && !_saving) {
      _saveSnapshot();
    }
  }

  Future<void> _saveSnapshot() async {
    if (_saving || _closing) {
      return;
    }
    final t = m.byId(_id);
    if (t == null) return;
    final snapshot = t.copyWith(body: _bodyCtrl.text);
    _pendingSnapshot = snapshot;
    await _drainSaves();
  }

  /// 串行执行保存；较旧回执不得清除较新修改的待保存状态。
  Future<void> _drainSaves() async {
    if (_saving) return;
    _saving = true;
    try {
      while (_pendingSnapshot != null) {
        final snap = _pendingSnapshot!;
        _pendingSnapshot = null;
        setState(() => _saveState = _SaveState.saving);
        try {
          await m.writeTodo(snap);
          if (!mounted) return;
          // 只有当输入框内容与已落盘版本一致时才显示“已保存”
          if (_bodyCtrl.text == snap.body) {
            setState(() {
              _saveState = _SaveState.saved;
            });
          }
        } catch (e) {
          if (!mounted) return;
          // 恢复待保存状态并允许重试
          _pendingSnapshot = snap;
          setState(() {
            _saveState = _SaveState.failed;
          });
          return; // 串行：失败后停止，等待重试
        }
      }
    } finally {
      _saving = false;
    }
  }

  void _flushSync() {
    if (_saveState == _SaveState.pending ||
        _pendingSnapshot != null ||
        _saveState == _SaveState.failed) {
      final t = m.byId(_id);
      if (t != null && t.body != _bodyCtrl.text && !_imeComposing) {
        // dispose 里不能 await：入队后交给串行保存队列异步完成，
        // 与在飞保存保序（避免两笔直写竞争完成顺序）
        _pendingSnapshot = t.copyWith(body: _bodyCtrl.text);
      }
    }
    if (_pendingSnapshot != null) {
      unawaited(_drainSaves());
    }
  }

  Future<bool> _onWillPop() async {
    // 系统返回顺序：先收起键盘，再退出编辑页（设计 §2 交互补充）
    if (_bodyFocus.hasFocus) {
      _bodyFocus.unfocus();
      return false;
    }
    // 保存失败时不能丢弃正文返回（设计 §2：失败停留编辑页并提供重试）
    if (_saveState == _SaveState.failed) {
      final retry = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('尚未保存'),
          content: const Text('正文保存失败。返回前会再次尝试保存；仍失败时将停留在本页，正文不会丢弃。'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('留在本页')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('尝试保存并返回')),
          ],
        ),
      );
      if (retry != true) return false;
      final t = m.byId(_id);
      if (t != null && t.body != _bodyCtrl.text && !_imeComposing) {
        _pendingSnapshot = t.copyWith(body: _bodyCtrl.text);
      }
      await _drainSaves();
      if (_saveState == _SaveState.failed) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('仍未保存成功，已停留在编辑页，内容已保留待重试')));
        }
        return false;
      }
      return true;
    }
    _closing = true;
    _debounce?.cancel();
    await _drainSaves();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final a = appColors(context, Theme.of(context).brightness);
    final t = m.byId(_id);
    if (t == null) {
      return const Scaffold(body: Center(child: Text('Todo 不存在')));
    }
    _cbCounter = 0;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _onWillPop()) {
          if (context.mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: Text(
            t.title.isEmpty ? '未命名 Todo' : t.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 17),
          ),
          actions: [
            _saveIndicator(a),
            // 设计稿 detail 页无 FAB；预览切换入口放在 AppBar
            IconButton(
              tooltip: _preview ? '编辑' : '预览',
              onPressed: _togglePreview,
              icon: Icon(_preview
                  ? Icons.edit_outlined
                  : Icons.visibility_outlined),
            ),
            IconButton(
              tooltip: t.isCompleted ? '取消完成' : '完成',
              onPressed: () => m.setCompleted(_id, !t.isCompleted),
              icon: Icon(t.isCompleted
                  ? Icons.task_alt
                  : Icons.task_alt_outlined),
            ),
            PopupMenuButton<String>(
              onSelected: (v) async {
                if (v == 'history') {
                  openSecondaryPage(context,
                      HistoryPage(model: m, kind: 'todo', objectId: _id));
                } else if (v == 'trash') {
                  final title = t.title.isEmpty ? '未命名 Todo' : t.title;
                  final ok = await confirmDialog(context,
                      title: '移入回收站',
                      message: '将“$title”移入回收站？30 天后自动删除。',
                      confirmText: '移入',
                      destructive: true);
                  if (ok) {
                    _closing = true;
                    await _drainSaves();
                    await m.trashTodo(_id);
                    if (context.mounted) Navigator.of(context).pop();
                  }
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'history', child: Text('查看历史')),
                PopupMenuItem(value: 'trash', child: Text('移入回收站')),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              // 编辑器用 Offstage 保活：预览切换不销毁 TextField，
              // 保留撤销历史、选区与输入法会话（设计 §3）
              child: Stack(
                children: [
                  Offstage(
                    offstage: _preview,
                    child: TextField(
                      controller: _bodyCtrl,
                      focusNode: _bodyFocus,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      keyboardType: TextInputType.multiline,
                      onEditingComplete: () {},
                      style: TextStyle(color: a.text, fontSize: 15, height: 1.5),
                      decoration: InputDecoration(
                        hintText: '记录内容…首行会成为标题',
                        border: InputBorder.none,
                        filled: true,
                        fillColor: a.bg,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  if (_preview)
                    Markdown(
                      data: _bodyCtrl.text,
                      selectable: false,
                      // 本地图片真实渲染，网络图仍占位（设计：不自动加载网络图片）
                      sizedImageBuilder: (config) => _PreviewImage(
                          model: m,
                          uri: config.uri,
                          alt: config.alt ?? config.title ?? '图片',
                          a: a),
                      checkboxBuilder: (checked) {
                        final idx = _cbCounter++;
                        return Semantics(
                          checked: checked,
                          label: checked ? '已完成任务' : '未完成任务',
                          button: true,
                          child: InkWell(
                            onTap: () => _toggleTask(idx),
                            child: Icon(
                              checked
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              size: 18,
                              color: checked ? a.brand : a.muted,
                            ),
                          ),
                        );
                      },
                      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                          .copyWith(p: TextStyle(color: a.text)),
                    ),
                ],
              ),
            ),
            _metadataBar(context, a, t),
          ],
        ),
        bottomNavigationBar: _preview
            ? null
            : AnimatedPadding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                // 尊重系统“减弱动效”设置（设计稿 prefers-reduced-motion）
                duration: MediaQuery.of(context).disableAnimations
                    ? Duration.zero
                    : const Duration(milliseconds: 150),
                child: _formatToolbar(a),
              ),
      ),
    );
  }

  Widget _saveIndicator(AppColors a) {
    late Widget w;
    switch (_saveState) {
      case _SaveState.pending:
      case _SaveState.saving:
        w = const SizedBox(
            width: 12, height: 12,
            child: CircularProgressIndicator(strokeWidth: 2));
      case _SaveState.saved:
        w = Tooltip(
            message: '已保存到本机',
            child: Icon(Icons.check_circle, size: 18, color: a.brand));
      case _SaveState.failed:
        w = TextButton.icon(
            onPressed: _drainSaves,
            icon: Icon(Icons.error_outline, size: 18, color: a.danger),
            label: Text('重试', style: TextStyle(color: a.danger, fontSize: 13)));
      case _SaveState.none:
        w = const SizedBox(width: 12);
    }
    return Padding(padding: const EdgeInsets.only(right: 4), child: w);
  }

  void _togglePreview() {
    _saveSnapshot();
    setState(() => _preview = !_preview);
  }

  // ---------- 元数据栏 ----------

  Widget _metadataBar(BuildContext context, AppColors a, Todo t) {
    final catName = t.categoryId == null
        ? null
        : m.classification.categoryPath(t.categoryId);
    // 设计稿 .meta-group/.setting-row：leading 图标 + 标签 + trailing 当前值 + chevron，
    // 窄屏横向滚动排布，触控区 48dp
    Widget row(IconData icon, String label, String value, VoidCallback onTap) {
      return InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: a.muted),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(fontSize: 13, color: a.muted)),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 13,
                      color: a.text,
                      fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, size: 16, color: a.muted),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.only(
          left: 4, right: 4, top: 4,
          bottom: 4 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: a.panel,
        border: Border(top: BorderSide(color: a.line)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            row(Icons.flag_outlined, '优先级', priorityLabel(t.priority),
                _pickPriority),
            row(
                Icons.event_outlined,
                '截止日期',
                t.dueDate == null
                    ? '未设置'
                    : friendlyDate(m.today, t.dueDate),
                _pickDueDate),
            row(Icons.folder_outlined, '目录', catName ?? '未分类', _pickCategory),
            row(Icons.tag, '标签',
                t.tags.isEmpty ? '未设置' : t.tags.join('、'), _pickTags),
          ],
        ),
      ),
    );
  }

  Future<void> _pickPriority() async {
    final t = m.byId(_id);
    if (t == null || !mounted) return;
    final p = await showModalBottomSheet<int>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final v in kPriorities)
              ListTile(
                title: Text('优先级：${priorityLabel(v)}'),
                trailing: t.priority == v
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.pop(ctx, v),
              ),
          ],
        ),
      ),
    );
    // 弹层期间对象可能被后台同步删除/清理：重取最新再写
    final cur = m.byId(_id);
    if (p == null || cur == null || !mounted) return;
    await m.writeTodo(cur.copyWith(priority: p));
  }

  Future<void> _pickDueDate() async {
    final t = m.byId(_id);
    if (t == null || !mounted) return;
    // 设计稿日期 sheet：清除 / 完成 两个显式入口（替代“选同日清空”的隐式逻辑）
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.event_outlined),
              title: Text(t.dueDate == null
                  ? '选择日期'
                  : '选择日期（当前：${friendlyDate(m.today, t.dueDate)}）'),
              onTap: () => Navigator.pop(ctx, 'pick'),
            ),
            ListTile(
              leading: const Icon(Icons.event_busy),
              title: const Text('清除日期'),
              enabled: t.dueDate != null,
              onTap: () => Navigator.pop(ctx, 'clear'),
            ),
          ],
        ),
      ),
    );
    if (action == 'clear') {
      final cur = m.byId(_id);
      if (cur == null || !mounted) return;
      await m.writeTodo(cur.copyWith(clearDueDate: true));
      return;
    }
    if (action != 'pick') return;
    if (!mounted) return;
    final initial = t.dueDate == null
        ? null
        : DateTime.tryParse(t.dueDate!);
    final d = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: '选择截止日期',
    );
    if (d == null) return;
    final s = '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
    final cur = m.byId(_id);
    if (cur == null || !mounted) return;
    await m.writeTodo(cur.copyWith(dueDate: s));
  }

  Future<void> _pickCategory() async {
    final t = m.byId(_id);
    if (t == null || !mounted) return;
    final id = await showModalBottomSheet<String?>(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: const Text('未分类'),
              trailing: t.categoryId == null ? const Icon(Icons.check) : null,
              onTap: () => Navigator.pop(ctx, ''),
            ),
            for (final c in _flattenedCategories())
              ListTile(
                title: Text('${'　' * (c.$2)}${c.$1.name}'),
                trailing: t.categoryId == c.$1.id
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.pop(ctx, c.$1.id),
              ),
          ],
        ),
      ),
    );
    if (id != null) {
      final cur = m.byId(_id);
      if (cur == null || !mounted) return;
      await m.writeTodo(id.isEmpty
          ? cur.copyWith(clearCategoryId: true)
          : cur.copyWith(categoryId: id));
    }
  }

  List<(dynamic, int)> _flattenedCategories() {
    final out = <(dynamic, int)>[];
    void walk(String? parentId, int depth) {
      for (final c in m.childCategories(parentId ?? '')) {
        out.add((c, depth));
        walk(c.id, depth + 1);
      }
    }

    walk(null, 0);
    return out;
  }

  Future<void> _pickTags() async {
    final t = m.byId(_id);
    if (t == null || !mounted) return;
    final selected = List.of(t.tags);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final tags = m.visibleTags;
        return StatefulBuilder(
          builder: (ctx, setSheet) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('标签', style: Theme.of(ctx).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (tags.isEmpty)
                    const Text('暂无标签，可在“分类”页创建'),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final tag in tags)
                        FilterChip(
                          label: Text('#${tag.name}'),
                          selected: selected.contains(tag.name),
                          onSelected: (sel) => setSheet(() => sel
                              ? selected.add(tag.name)
                              : selected.remove(tag.name)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      TextButton(
                        onPressed: selected.isEmpty
                            ? null
                            : () {
                                selected.clear();
                                setSheet(() {});
                              },
                        child: const Text('清除'),
                      ),
                      const Spacer(),
                      SizedBox(
                        child: FilledButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('完成'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    final cur = m.byId(_id);
    if (cur == null || !mounted) return;
    await m.writeTodo(cur.copyWith(tags: selected));
    if (mounted) setState(() {});
  }

  // ---------- 格式工具栏 ----------

  Widget _formatToolbar(AppColors a) {
    Widget btn(IconData icon, String label, VoidCallback onTap) => Tooltip(
          message: label,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              child: Icon(icon, size: 20, color: a.text),
            ),
          ),
        );
    return Container(
      color: a.panel,
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              btn(Icons.title, '标题', () => _wrapLine('# ')),
              btn(Icons.format_bold, '粗体', () => _wrapSel('**', '**')),
              btn(Icons.format_italic, '斜体', () => _wrapSel('*', '*')),
              btn(Icons.format_strikethrough, '删除线', () => _wrapSel('~~', '~~')),
              btn(Icons.format_list_bulleted, '无序列表', () => _wrapLine('- ')),
              btn(Icons.format_list_numbered, '有序列表', () => _wrapLine('1. ')),
              btn(Icons.checklist, '任务清单', () => _wrapLine('- [ ] ')),
              btn(Icons.format_quote, '引用', () => _wrapLine('> ')),
              btn(Icons.code, '行内代码', () => _wrapSel('`', '`')),
              btn(Icons.link, '链接', () => _wrapSel('[', '](https://)')),
              btn(Icons.image_outlined, '插入本地图片', _importImage),
            ],
          ),
        ),
      ),
    );
  }

  void _wrapSel(String before, String after) {
    final sel = _bodyCtrl.selection;
    final text = _bodyCtrl.text;
    if (!sel.isValid) return;
    final s = sel.start, e = sel.end;
    final inner = text.substring(s, e);
    _bodyCtrl.value = _bodyCtrl.value.copyWith(
      text: '${text.substring(0, s)}$before$inner$after${text.substring(e)}',
      selection: TextSelection.collapsed(offset: s + before.length + inner.length),
    );
    _bodyFocus.requestFocus();
  }

  void _wrapLine(String prefix) {
    final sel = _bodyCtrl.selection;
    final text = _bodyCtrl.text;
    if (!sel.isValid) return;
    var lineStart = sel.start;
    while (lineStart > 0 && text[lineStart - 1] != '\n') {
      lineStart--;
    }
    _bodyCtrl.value = _bodyCtrl.value.copyWith(
      text: '${text.substring(0, lineStart)}$prefix${text.substring(lineStart)}',
      selection: TextSelection.collapsed(offset: sel.start + prefix.length),
    );
    _bodyFocus.requestFocus();
  }

  void _insertAtCursor(String s) {
    final sel = _bodyCtrl.selection;
    final text = _bodyCtrl.text;
    final pos = sel.isValid ? sel.start : text.length;
    _bodyCtrl.value = _bodyCtrl.value.copyWith(
      text: '${text.substring(0, pos)}$s${text.substring(pos)}',
      selection: TextSelection.collapsed(offset: pos + s.length),
    );
    _bodyFocus.requestFocus();
  }

  /// 系统图片选择器导入：魔数白名单 + ≤10MiB；落盘 `images/<ULID>.<ext>`
  /// 后在光标处插入引用。校验失败保留编辑内容并提示原因，禁止截断。
  Future<void> _importImage() async {
    final xfile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      requestFullMetadata: false,
    );
    if (xfile == null) return;
    if (!mounted) return;
    final rawName = xfile.name;
    try {
      final bytes = await xfile.readAsBytes();
      final rel = await m.store.saveImage(bytes);
      if (!mounted) return;
      // alt：原始文件名去扩展名、折叠空白、限 60 字符
      var alt = rawName.replaceFirst(RegExp(r'\.[^.]+$'), '');
      alt = alt.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (alt.runes.length > 60) {
        alt =
            '${String.fromCharCodes(alt.runes.take(59))}…';
      }
      _insertAtCursor('![${alt.isEmpty ? '图片' : alt}]($rel)');
    } on ImageRejectException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('图片读取失败')));
      }
    }
  }

  /// 预览勾选：直接修改原文 Markdown 中第 index 个任务复选框。
  void _toggleTask(int index) {
    final re = RegExp(r'- \[([ xX])\]');
    var i = 0;
    final buf = StringBuffer();
    var last = 0;
    for (final m1 in re.allMatches(_bodyCtrl.text)) {
      if (i++ == index) {
        buf.write(_bodyCtrl.text.substring(last, m1.start));
        final cur = m1.group(1)!;
        buf.write(cur == ' ' ? '- [x]' : '- [ ]');
        last = m1.end;
        break;
      }
    }
    if (last == 0) return;
    buf.write(_bodyCtrl.text.substring(last));
    _bodyCtrl.text = buf.toString();
    setState(() {});
    _onBodyChanged();
  }
}

/// 预览本地图片：仅渲染 images/ 下的本机文件；网络图、非法引用与缺失文件
/// 沿用占位（设计：预览不自动加载网络图片）。
/// 路径规范化后必须仍在 imagesDir 内，防 `../` 穿越到应用目录外。
/// 文件解析在 initState/didUpdateWidget 做一次，不在 build 中查文件系统。
class _PreviewImage extends StatefulWidget {
  final AppModel model;
  final Uri uri;
  final String alt;
  final AppColors a;
  const _PreviewImage(
      {required this.model,
      required this.uri,
      required this.alt,
      required this.a});

  @override
  State<_PreviewImage> createState() => _PreviewImageState();
}

class _PreviewImageState extends State<_PreviewImage> {
  File? _file;

  @override
  void initState() {
    super.initState();
    _file = _resolve();
  }

  @override
  void didUpdateWidget(covariant _PreviewImage old) {
    super.didUpdateWidget(old);
    if (old.uri != widget.uri || old.model != widget.model) {
      _file = _resolve();
    }
  }

  File? _resolve() {
    try {
      if (widget.uri.hasScheme) return null; // http/https/data 等一律不加载
      var path = Uri.decodeComponent(widget.uri.path);
      if (path.startsWith('/')) path = path.substring(1);
      if (!path.startsWith('images/')) return null;
      final base = p.normalize(widget.model.store.imagesDir.path);
      final abs =
          p.normalize(p.join(widget.model.store.tipsDir.path, path));
      if (abs != base && !abs.startsWith('$base${p.separator}')) {
        return null;
      }
      final f = File(abs);
      return f.existsSync() ? f : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final f = _file;
    if (f == null) return _ImagePlaceholder(a: widget.a, alt: widget.alt);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          f,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) =>
              _ImagePlaceholder(a: widget.a, alt: widget.alt),
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {  final AppColors a;
  final String alt;
  const _ImagePlaceholder({required this.a, required this.alt});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: a.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: a.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_outlined, size: 18, color: a.muted),
          const SizedBox(width: 8),
          Flexible(child: Text(alt, style: TextStyle(fontSize: 13, color: a.muted))),
        ],
      ),
    );
  }
}
