/// 应用用例层：统一写入流程、回收站、分类操作与主题状态。
/// 所有 UI 只通过该模型读写数据，保证失败时恢复原显示状态。
library;

import 'dart:async';

import 'package:flutter/foundation.dart' hide Category;

import '../core/ulid.dart';
import '../domain/classification.dart';
import '../domain/query.dart';
import '../domain/todo.dart';
import '../infra/store.dart';
import '../sync/sync_engine.dart';

enum ThemeModeSetting { system, light, dark }

class AppModel extends ChangeNotifier {
  final TodoStore store;
  late final String deviceId;

  /// 同步引擎；由 main 在 load() 后接入。
  SyncEngine? sync;

  List<Todo> todos = [];
  Classification classification = Classification([], []);
  IndexData index = IndexData.empty();
  List<CorruptTip> corrupt = [];

  ThemeModeSetting themeMode = ThemeModeSetting.system;
  bool onboardingDone = false;
  DateTime _lastTodayRefresh = DateTime.now();
  String _today = '';

  /// classification/index 的本地内容版本号：任何变更（本地写入或同步落盘）+1。
  /// SyncEngine 用它跳过未变更内容的重复序列化+哈希。
  int classificationVersion = 0;
  int indexVersion = 0;

  // 派生数据缓存：notifyListeners 时统一失效
  Map<String, Todo>? _byIdCache;
  Map<String, int>? _countByCategory;
  Map<String, Set<String>>? _subtreeCache;
  Set<String>? _activeCategoryIdsCache;

  @override
  void notifyListeners() {
    _byIdCache = null;
    _countByCategory = null;
    _subtreeCache = null;
    _activeCategoryIdsCache = null;
    super.notifyListeners();
  }

  AppModel(this.store);

  String get today {
    // 跨午夜/时区恢复前台时由调用方调用 refreshToday()
    final now = DateTime.now();
    if (_today.isEmpty || now.difference(_lastTodayRefresh).inMinutes >= 1) {
      _today = todayLocal();
      _lastTodayRefresh = now;
    }
    return _today;
  }

  void refreshToday() {
    _lastTodayRefresh = DateTime.fromMillisecondsSinceEpoch(0);
    _today = todayLocal();
    notifyListeners();
  }

  Future<void> load() async {
    await store.init();
    // 四路加载互不依赖，并行执行缩短启动关键路径
    final deviceIdF = store.loadOrCreateDeviceId();
    final scanF = store.scanTodos();
    final classificationF = store.loadClassification();
    final indexF = store.loadIndex();
    final settingsF = store.loadSettings();
    deviceId = await deviceIdF;
    final scan = await scanF;
    todos = scan.todos;
    corrupt = scan.corrupt;
    classification = await classificationF;
    index = await indexF;
    final s = await settingsF;
    themeMode = ThemeModeSetting.values
        .firstWhere((m) => m.name == s['theme'], orElse: () => ThemeModeSetting.system);
    onboardingDone = s['onboardingDone'] == true;
    _today = todayLocal();
    await purgeExpiredTrash();
    notifyListeners();
  }

  /// 本地修改保存后触发自动同步（如已开启）。
  void scheduleAutoSync() {
    final s = sync;
    if (s != null &&
        s.state.autoSync &&
        s.status != SyncStatus.syncing &&
        s.state.serverUrl != null &&
        s.state.projectId != null) {
      Future.microtask(() => s.syncNow());
    }
  }

  Future<void> _saveSettings() =>
      store.saveSettings({
        'schemaVersion': 1,
        'theme': themeMode.name,
        'onboardingDone': onboardingDone,
      });

  Future<void> setThemeMode(ThemeModeSetting m) async {
    themeMode = m;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    onboardingDone = true;
    notifyListeners();
    await _saveSettings();
  }

  // ---------- Todo 用例 ----------

  Todo? byId(String id) => (_byIdCache ??= {for (final t in todos) t.id: t})[id];

  /// 新建；fromToday 预填今天截止，category/tag 继承来源页。
  Future<Todo> createTodo({LocalDate? dueDate, String? categoryId, String? tagName}) async {
    final now = DateTime.now().toUtc();
    final t = Todo(
      id: newUlid(),
      title: '',
      body: '',
      dueDate: dueDate,
      categoryId: (categoryId != null && categoryId.isNotEmpty) ? categoryId : null,
      tags: tagName == null ? [] : [tagName],
      createdAt: now,
      updatedAt: now,
      deviceId: deviceId,
    );
    await store.saveTodo(t);
    todos.add(t);
    notifyListeners();
    return t;
  }

  /// 统一写入流程：先落盘成功再更新内存并广播；失败抛错且内存保持原状。
  Future<void> writeTodo(Todo updated) async {
    updated.updatedAt = DateTime.now().toUtc();
    updated.revision += 1;
    updated.title = deriveTitle(updated.body);
    await store.saveTodo(updated);
    final i = todos.indexWhere((t) => t.id == updated.id);
    if (i >= 0) todos[i] = updated;
    notifyListeners();
    scheduleAutoSync();
  }

  Future<void> setCompleted(String id, bool completed) async {
    final t = byId(id);
    if (t == null) return;
    await writeTodo(t.copyWith(
      status: completed ? TodoStatus.completed : TodoStatus.open,
      completedAt: completed ? DateTime.now().toUtc() : null,
      clearCompletedAt: !completed,
    ));
  }

  /// 软删除移入回收站（确认由 UI 层负责）。
  Future<void> trashTodo(String id) async {
    final t = byId(id);
    if (t == null) return;
    await writeTodo(t.copyWith(deletedAt: DateTime.now().toUtc()));
  }

  /// 恢复 Todo：保留原 ID、目录和标签；清空 deletedAt。
  Future<void> restoreTodo(String id) async {
    final t = byId(id);
    if (t == null) return;
    await writeTodo(t.copyWith(clearDeletedAt: true));
  }

  /// 物理删除：先写墓碑，墓碑持久化成功后才移除文件。
  Future<void> purgeTodo(String id) async {
    final t = byId(id);
    if (t == null) return;
    final ts = Tombstone(id, 'todo', DateTime.now().toUtc(), t.revision, deviceId);
    index.tombstones.add(ts);
    indexVersion++;
    await store.saveIndex(index); // 墓碑先落盘
    await store.deleteTodoFile(id);
    todos.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  // ---------- 回收站 ----------

  List<Todo> get trashedTodos =>
      todos.where((t) => t.isDeleted).toList()
        ..sort((a, b) => b.deletedAt!.compareTo(a.deletedAt!));

  List<Category> get trashedCategories =>
      classification.categories.where((c) => c.isDeleted).toList();

  List<Tag> get trashedTags =>
      classification.tags.where((t) => t.isDeleted).toList();

  static String _normalizeColorValue(String c) =>
      const {'blue': '#4a9eff', 'green': '#6ccb5f', 'orange': '#fb923c',
            'purple': '#a78bfa', 'red': '#f97066', 'gray': '#8a8a8a'}[c.toLowerCase()] ?? c;

  static bool _isBefore(String? rfc3339, DateTime cutoff) =>
      (tryParseRfc3339(rfc3339) ?? DateTime.now()).isBefore(cutoff);

  /// deletedAt 接受 RFC3339 字符串（分类实体）或 DateTime（Todo）。
  int remainingDays(Object deletedAt) {
    final d = (deletedAt is DateTime
            ? deletedAt
            : DateTime.tryParse(deletedAt as String))!
        .toLocal();
    final expiry = d.add(const Duration(days: TodoStore.retentionDays));
    final left = expiry.difference(DateTime.now()).inDays + 1;
    return left.clamp(0, TodoStore.retentionDays);
  }

  /// 到期清理：应用启动 / 前台恢复时调用。
  Future<void> purgeExpiredTrash() async {
    final cutoff =
        DateTime.now().subtract(const Duration(days: TodoStore.retentionDays));
    var changed = false;
    final expiredTodos = todos
        .where((t) => t.isDeleted && t.deletedAt!.isBefore(cutoff))
        .toList();
    for (final t in expiredTodos) {
      final ts =
          Tombstone(t.id, 'todo', DateTime.now().toUtc(), t.revision, deviceId);
      index.tombstones.add(ts);
      indexVersion++;
      await store.deleteTodoFile(t.id);
      todos.remove(t);
      changed = true;
    }
    // index.json 只在批量墓碑写完后落盘一次，避免逐条全量重写
    if (expiredTodos.isNotEmpty) await store.saveIndex(index);
    final expiredCats = classification.categories
        .where((c) => c.isDeleted && _isBefore(c.deletedAt, cutoff))
        .toList();
    final expiredTags = classification.tags
        .where((t) => t.isDeleted && _isBefore(t.deletedAt, cutoff))
        .toList();
    if (expiredCats.isNotEmpty || expiredTags.isNotEmpty) {
      classification.categories.removeWhere(expiredCats.contains);
      classification.tags.removeWhere(expiredTags.contains);
      for (final c in expiredCats) {
        index.tombstones.add(
            Tombstone(c.id, 'category', DateTime.now().toUtc(), 1, deviceId));
      }
      for (final tg in expiredTags) {
        index.tombstones
            .add(Tombstone(tg.id, 'tag', DateTime.now().toUtc(), 1, deviceId));
      }
      await store.saveClassification(classification);
      await store.saveIndex(index);
      // 同步哈希缓存按版本失效：漏加会导致清理后的分类/索引被认为无变化而不上传
      classificationVersion++;
      indexVersion++;
      changed = true;
    }
    if (changed) notifyListeners();
  }

  Future<void> emptyTrash() async {
    for (final t in trashedTodos) {
      await purgeTodo(t.id);
    }
    for (final c in List.of(trashedCategories)) {
      await _purgeCategoryNow(c.id);
    }
    for (final t in List.of(trashedTags)) {
      await purgeTag(t.id);
    }
  }

  // ---------- 查询 ----------

  List<Todo> query(TodoQuery q) => runQuery(todos, q,
      today: today,
      activeCategoryIds: _activeCategoryIds(),
      customOrder: index.customOrder);

  /// 当前未删除目录 ID 集：categoryId 指向其外的 Todo 按未分类口径处理。
  Set<String> _activeCategoryIds() => _activeCategoryIdsCache ??=
      classification.categories.where((c) => !c.isDeleted).map((c) => c.id).toSet();

  /// 展开子目录后的目录筛选 ID 集。
  Set<String> expandCategoryIds(String rootId) =>
      classification.subtreeOf(rootId);

  // ---------- 分类用例 ----------

  Future<void> _saveClassification() async {
    await store.saveClassification(classification);
    classificationVersion++;
    notifyListeners();
  }

  String? validateCategoryName(String name, {String? parentId, String? excludeId}) {
    final n = name.trim();
    if (n.isEmpty) return '名称不能为空';
    if (n.length > 30) return '名称最多 30 字符';
    final sameLevel = classification.categories.where((c) =>
        c.parentId == parentId &&
        !c.isDeleted &&
        c.id != excludeId &&
        c.name.toLowerCase() == n.toLowerCase());
    if (sameLevel.isNotEmpty) return '同级已存在同名目录';
    if (parentId != null) {
      final depth = classification.depthOf(parentId) + 1;
      if (depth > 3) return '目录最多三级';
    }
    return null;
  }

  Future<String?> createCategory(String name, {String? parentId, String? color}) async {
    final err = validateCategoryName(name, parentId: parentId);
    if (err != null) return err;
    final c = Category(id: newUlid(), name: name.trim(), parentId: parentId, color: color);
    classification.categories.add(c);
    await _saveClassification();
    return null;
  }

  Future<String?> renameCategory(String id, String name) async {
    final c = classification.byId(id);
    if (c == null) return '目录不存在';
    final err = validateCategoryName(name,
        parentId: c.parentId, excludeId: id);
    if (err != null) return err;
    c.name = name.trim();
    await _saveClassification();
    return null;
  }

  Future<String?> moveCategory(String id, String? newParentId) async {
    final c = classification.byId(id);
    if (c == null) return '目录不存在';
    if (newParentId != null &&
        (id == newParentId || classification.subtreeOf(id).contains(newParentId))) {
      return '不能移动到自身或其子目录';
    }
    if (newParentId != null && classification.depthOf(id) + 1 > 3) {
      // 需要按最深子孙计算，此处按简化：目标深度+1 超限即拒绝
      return '目录最多三级';
    }
    c.parentId = newParentId;
    await _saveClassification();
    return null;
  }

  Future<void> setCategoryColor(String id, String? color) async {
    final c = classification.byId(id);
    if (c == null) return;
    c.color = (color == null || color.isEmpty) ? kDefaultColor : _normalizeColorValue(color);
    c.updatedAt = rfc3339Utc(DateTime.now().toUtc());
    await _saveClassification();
  }

  /// 软删除目录（整树），Todo 变为“未分类”语义（保留 categoryId 原值）。
  Future<void> trashCategory(String id) async {
    final tree = classification.subtreeOf(id);
    final now = DateTime.now().toUtc();
    for (final c in classification.categories) {
      if (tree.contains(c.id) && !c.isDeleted) {
        c.deletedAt = rfc3339Utc(now);
        c.updatedAt = rfc3339Utc(now);
      }
    }
    await _saveClassification();
  }

  Future<void> restoreCategory(String id) async {
    final c = classification.byId(id);
    if (c == null || !c.isDeleted) return;
    // 父目录已删除/不存在时提升为顶级
    if (c.parentId != null) {
      final parent = classification.byId(c.parentId!);
      if (parent == null || parent.isDeleted) c.parentId = null;
    }
    // 同名冲突：保留回收站条目并让调用方提示
    c.deletedAt = null;
    await _saveClassification();
  }

  Future<void> _purgeCategoryNow(String id) async {
    classification.categories.removeWhere((c) => c.id == id);
    index.tombstones
        .add(Tombstone(id, 'category', DateTime.now().toUtc(), 1, deviceId));
    indexVersion++;
    await store.saveIndex(index);
    await _saveClassification();
  }

  Future<void> purgeCategory(String id) => _purgeCategoryNow(id);

  String? validateTagName(String name, {String? excludeId}) {
    final n = name.trim();
    if (n.isEmpty) return '名称不能为空';
    if (n.length > 30) return '名称最多 30 字符';
    final dup = classification.tags.any((t) =>
        t.id != excludeId && !t.isDeleted && t.name.toLowerCase() == n.toLowerCase());
    if (dup) return '已存在同名标签';
    return null;
  }

  Future<String?> createTag(String name, {String? color}) async {
    final err = validateTagName(name);
    if (err != null) return err;
    classification.tags
        .add(Tag(id: newUlid(), name: name.trim(), color: color));
    await _saveClassification();
    return null;
  }

  Future<String?> renameTag(String id, String name) async {
    final t = classification.tagById(id);
    if (t == null) return '标签不存在';
    final err = validateTagName(name, excludeId: id);
    if (err != null) return err;
    final old = t.name;
    t.name = name.trim();
    // 同步更新关联 Todo（含回收站内容）
    for (final todo in todos) {
      if (todo.tags.contains(old)) {
        final i = todo.tags.indexOf(old);
        todo.tags[i] = t.name;
        await writeTodo(todo);
      }
    }
    await _saveClassification();
    return null;
  }

  Future<void> setTagColor(String id, String? color) async {
    final t = classification.tagById(id);
    if (t == null) return;
    t.color = (color == null || color.isEmpty) ? kDefaultColor : _normalizeColorValue(color);
    t.updatedAt = rfc3339Utc(DateTime.now().toUtc());
    await _saveClassification();
  }

  /// 软删除标签：保留关联，恢复后重新可见。
  Future<void> trashTag(String id) async {
    final t = classification.tagById(id);
    if (t == null) return;
    t.deletedAt = rfc3339Utc(DateTime.now().toUtc());
    t.updatedAt = t.deletedAt!;
    await _saveClassification();
  }

  Future<void> restoreTag(String id) async {
    final t = classification.tagById(id);
    if (t == null || !t.isDeleted) return;
    t.deletedAt = null;
    await _saveClassification();
  }

  /// 彻底删除：移除所有 Todo 中的标签名称。
  Future<void> purgeTag(String id) async {
    final t = classification.tagById(id);
    if (t == null) return;
    final name = t.name;
    classification.tags.removeWhere((e) => e.id == id);
    for (final todo in todos) {
      if (todo.tags.remove(name)) {
        await writeTodo(todo);
      }
    }
    index.tombstones
        .add(Tombstone(id, 'tag', DateTime.now().toUtc(), 1, deviceId));
    indexVersion++;
    await store.saveIndex(index);
    await _saveClassification();
  }

  List<Tag> get visibleTags => classification.tags.where((t) => !t.isDeleted).toList();

  Map<String, List<Tag>> get tagsByGroup {
    final map = <String, List<Tag>>{};
    for (final t in visibleTags) {
      map.putIfAbsent(t.group.isEmpty ? '其他' : t.group, () => []).add(t);
    }
    final keys = map.keys.toList()..sort();
    return {for (final k in keys) k: map[k]!};
  }

  List<Category> get rootCategories => classification.categories
      .where((c) => !c.isDeleted && (c.parentId == null ||
          classification.byId(c.parentId!)?.isDeleted == true))
      .toList()
    ..sort((a, b) => a.name.compareTo(b.name));

  List<Category> childCategories(String parentId) =>
      classification.categories
          .where((c) => !c.isDeleted && c.parentId == parentId)
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));

  int todoCountInCategory(String categoryId) {
    // 计数与子树展开均缓存；notifyListeners 时失效。
    // 一次遍历统计所有目录的精确计数，避免 目录数 × 全量 todos 扫描。
    _countByCategory ??= _buildCounts();
    final subtree = _subtreeCache ??= {};
    final ids =
        subtree.putIfAbsent(categoryId, () => expandCategoryIds(categoryId));
    final counts = _countByCategory!;
    var n = 0;
    for (final id in ids) {
      n += counts[id] ?? 0;
    }
    return n;
  }

  Map<String, int> _buildCounts() {
    final counts = <String, int>{};
    for (final t in todos) {
      if (t.isDeleted || t.categoryId == null) continue;
      counts[t.categoryId!] = (counts[t.categoryId!] ?? 0) + 1;
    }
    return counts;
  }
}
