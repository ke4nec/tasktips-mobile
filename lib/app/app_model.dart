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

  /// 本地索引/分类文件损坏（原件已备份到 recovery/）：
  /// 同步引擎据此暂停自动推送，避免空对象反向覆盖远端（设计 §4.1）。
  bool classificationCorrupt = false;
  bool indexCorrupt = false;

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
  Map<String, int>? _openCountByCategory;
  Map<String, Set<String>>? _subtreeCache;
  Set<String>? _activeCategoryIdsCache;

  @override
  void notifyListeners() {
    _byIdCache = null;
    _countByCategory = null;
    _openCountByCategory = null;
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
    final clsResult = await classificationF;
    classification = clsResult.$1;
    classificationCorrupt = clsResult.$2;
    final idxResult = await indexF;
    index = idxResult.$1;
    indexCorrupt = idxResult.$2;
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
  /// [autosync] 供批量调用方关闭逐条触发，改由调用方在全部成功后触发一次。
  Future<void> writeTodo(Todo updated, {bool autosync = true}) async {
    updated.updatedAt = DateTime.now().toUtc();
    updated.revision += 1;
    // 内存态同样保证 0-3 不变量：非法值钳制，永不落盘脏数据
    updated.priority = updated.priority.clamp(0, 3);
    updated.title = deriveTitle(updated.body);
    await store.saveTodo(updated);
    final i = todos.indexWhere((t) => t.id == updated.id);
    if (i >= 0) todos[i] = updated;
    notifyListeners();
    if (autosync) scheduleAutoSync();
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

  static String _normalizeColorValue(String c) => canonicalizeColor(c);

  static bool _isBefore(String? rfc3339, DateTime cutoff) =>
      (tryParseRfc3339(rfc3339) ?? DateTime.now()).isBefore(cutoff);

  /// deletedAt 接受 RFC3339 字符串（分类实体）或 DateTime（Todo）。
  /// 语义：距到期时刻向上取整（最后一天显示 1，到期当天显示 0），
  /// 与 purgeExpiredTrash 的严格 30 天口径一致。
  int remainingDays(Object deletedAt) {
    final d = (deletedAt is DateTime
            ? deletedAt
            : DateTime.tryParse(deletedAt as String))!
        .toLocal();
    final expiry = d.add(const Duration(days: TodoStore.retentionDays));
    final left = expiry.difference(DateTime.now());
    return (left.inSeconds / Duration.secondsPerDay)
        .ceil()
        .clamp(0, TodoStore.retentionDays);
  }

  /// 到期清理：应用启动 / 前台恢复时调用。
  Future<void> purgeExpiredTrash() async {
    final cutoff =
        DateTime.now().subtract(const Duration(days: TodoStore.retentionDays));
    var changed = false;
    final expiredTodos = todos
        .where((t) => t.isDeleted && t.deletedAt!.isBefore(cutoff))
        .toList();
    // 墓碑先落盘再删文件：崩溃窗口内至多残留文件（下次清理重试），
    // 永不出现文件已删而墓碑丢失（他端重推时无法判定删除）。
    for (final t in expiredTodos) {
      final ts =
          Tombstone(t.id, 'todo', DateTime.now().toUtc(), t.revision, deviceId);
      index.tombstones.add(ts);
      indexVersion++;
    }
    // index.json 只在批量墓碑写完后落盘一次，避免逐条全量重写
    if (expiredTodos.isNotEmpty) await store.saveIndex(index);
    for (final t in expiredTodos) {
      await store.deleteTodoFile(t.id);
      todos.remove(t);
      changed = true;
    }
    final expiredCats = classification.categories
        .where((c) => c.isDeleted && _isBefore(c.deletedAt, cutoff))
        .toList();
    final expiredTags = classification.tags
        .where((t) => t.isDeleted && _isBefore(t.deletedAt, cutoff))
        .toList();
    if (expiredCats.isNotEmpty || expiredTags.isNotEmpty) {
      // 分类/标签删除经 classification 整对象传播，不写 category/tag 墓碑
      //（桌面端枚举只认 todo|classification|index|image）
      classification.categories.removeWhere(expiredCats.contains);
      classification.tags.removeWhere(expiredTags.contains);
      await store.saveClassification(classification);
      // 同步哈希缓存按版本失效：漏加会导致清理后的分类被认为无变化而不上传
      classificationVersion++;
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
    classification.dirty = true;
    await store.saveClassification(classification);
    classificationVersion++;
    notifyListeners();
  }

  /// 批量写入 Todo（目录整树删除/恢复的 cohort 连带）：调用方传入已 staged
  /// 的副本（copyWith），本方法逐条先落盘后更新内存——与 [writeTodo] 同一契约，
  /// 失败时内存列表保持原状，不出现内存已脏而磁盘未写的中间态。
  Future<void> _writeTodosBulk(List<Todo> updated) async {
    final now = DateTime.now().toUtc();
    for (final t in updated) {
      t.updatedAt = now;
      t.revision += 1;
      await store.saveTodo(t);
      final i = todos.indexWhere((e) => e.id == t.id);
      if (i >= 0) todos[i] = t;
    }
    notifyListeners();
    scheduleAutoSync();
  }

  /// 名称校验对齐桌面端（classification.rs）：
  /// 目录 2-50 字符且禁 `/\:*?"<>|`；标签 1-20 字符。
  static const _forbiddenCategoryChars = r'/\:*?"<>|';

  String? validateCategoryName(String name, {String? parentId, String? excludeId}) {
    final n = name.trim();
    final len = n.runes.length;
    if (len < 2 || len > 50) return '目录名称长度必须是 2-50 个字符';
    for (final ch in n.runes) {
      if (_forbiddenCategoryChars.contains(String.fromCharCode(ch))) {
        return '目录名称不允许包含特殊字符 ${String.fromCharCode(ch)}';
      }
    }
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

  /// 移动目录（对齐桌面端 move_category 六条校验）：
  /// 保留 ID 拦截 / 自移 / 移入子孙 / 父层级+子树高度≤3 /
  /// 目标同层重名 / 仅改 parentId+updatedAt。
  Future<String?> moveCategory(String id, String? newParentId) async {
    final c = classification.byId(id);
    if (c == null) return '目录不存在';
    if (id == 'uncategorized') return '不能移动系统保留目录';
    if (c.isDeleted) return '不能移动回收站中的目录';
    if (newParentId != null) {
      if (newParentId == id) return '不能把目录移动到自己下面';
      if (classification.subtreeOf(id).contains(newParentId)) {
        return '不能把目录移动到自己的子目录下';
      }
      final parent = classification.byId(newParentId);
      if (parent == null || parent.isDeleted) return '目标目录不存在或已删除';
      // 按被移动子树的最深子孙校验：目标深度 + 子树高度 - 1 ≤ 3
      final targetDepth = classification.depthOf(newParentId) + 1;
      final height = classification.subtreeHeight(id);
      if (targetDepth + height - 1 > 3) {
        return '目录最多三级';
      }
    }
    // 移动后同层重名校验（大小写折叠，排除自身；桌面 ensure_sibling_name_unique）
    final nameTaken = classification.categories.any((o) =>
        o.id != c.id &&
        !o.isDeleted &&
        o.parentId == newParentId &&
        o.name.toLowerCase() == c.name.toLowerCase());
    if (nameTaken) return '同级已存在同名目录';
    c.parentId = newParentId;
    c.updatedAt = rfc3339Utc(DateTime.now().toUtc());
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

  /// 软删除目录（整树，桌面端 §3.2.3 模式二）：子树内目录与 Todo 以同一
  /// cohort 时间戳一并软删除；父子引用原样保留（恢复时按原样回归）。
  Future<void> trashCategory(String id) async {
    final tree = classification.subtreeOf(id);
    final cohort = rfc3339Utc(DateTime.now().toUtc());
    // Todo 与目录使用同一解析值，保证恢复/清理时 cohort 精确匹配
    final cohortDt = DateTime.parse(cohort);
    for (final c in classification.categories) {
      if (tree.contains(c.id) && !c.isDeleted) {
        c.deletedAt = cohort;
        c.updatedAt = cohort;
      }
    }
    // 子树内未删除的 Todo 同批移入回收站（staged 为副本：落盘成功后才替换内存）
    final affected = todos
        .where((t) =>
            !t.isDeleted && t.categoryId != null && tree.contains(t.categoryId))
        .map((t) => t.copyWith(deletedAt: cohortDt))
        .toList();
    await _saveClassification();
    await _writeTodosBulk(affected);
  }

  /// 恢复目录（§5.2.2 按原样恢复）：清除本目录与仍处同批软删除状态的
  /// 子目录，并恢复同批进入回收站的 Todo。引用关系不动：
  /// 父目录已删/已清时按孤儿展示在根级（父目录之后恢复会自动归位）。
  /// 同名冲突（删除期间同级新建了同名目录）时保留回收站条目并返回原因。
  Future<String?> restoreCategory(String id) async {
    final c = classification.byId(id);
    if (c == null || !c.isDeleted) return null;
    final cohort = c.deletedAt!;
    final nameTaken = classification.categories.any((o) =>
        o.id != c.id &&
        !o.isDeleted &&
        o.parentId == c.parentId &&
        o.name.toLowerCase() == c.name.toLowerCase());
    if (nameTaken) {
      return '同级已存在同名目录“${c.name}”，请先重命名后再恢复';
    }
    final subtree = classification.trashedCohortOf(id, cohort);
    final now = rfc3339Utc(DateTime.now().toUtc());
    for (final sc in classification.categories) {
      if (subtree.contains(sc.id) && sc.deletedAt == cohort) {
        sc.deletedAt = null;
        sc.updatedAt = now;
      }
    }
    await _saveClassification();
    // 同批移入回收站的 Todo 一并恢复（此前单独删除的不动；精确匹配 cohort）
    final affected = todos
        .where((t) =>
            t.isDeleted &&
            t.categoryId != null &&
            subtree.contains(t.categoryId) &&
            t.deletedAt == tryParseRfc3339(cohort))
        .map((t) => t.copyWith(clearDeletedAt: true))
        .toList();
    await _writeTodosBulk(affected);
    return null;
  }

  /// 彻底删除目录（§5.2.3）：移除本目录与同批仍在回收站的子目录实体，
  /// 并物理删除其下同批仍在回收站的 Todo（写 todo 墓碑）。
  /// 分类/标签删除通过 classification 整对象传播，不写 category/tag 墓碑。
  Future<void> _purgeCategoryNow(String id) async {
    final c = classification.byId(id);
    if (c == null || !c.isDeleted) return;
    final cohort = c.deletedAt!;
    final subtree = classification.trashedCohortOf(id, cohort);
    classification.categories.removeWhere((e) => subtree.contains(e.id));
    final affected = todos
        .where((t) =>
            t.isDeleted &&
            t.categoryId != null &&
            subtree.contains(t.categoryId) &&
            t.deletedAt == tryParseRfc3339(cohort))
        .toList();
    for (final t in affected) {
      index.tombstones
          .add(Tombstone(t.id, 'todo', DateTime.now().toUtc(), t.revision, deviceId));
      indexVersion++;
    }
    // 墓碑先落盘再删文件（同 purgeExpiredTrash 语义）
    if (affected.isNotEmpty) await store.saveIndex(index);
    for (final t in affected) {
      await store.deleteTodoFile(t.id);
      todos.removeWhere((e) => e.id == t.id);
    }
    await _saveClassification();
  }

  Future<void> purgeCategory(String id) => _purgeCategoryNow(id);

  String? validateTagName(String name, {String? excludeId}) {
    final n = name.trim();
    final len = n.runes.length;
    if (len < 1 || len > 20) return '标签名称长度必须是 1-20 个字符';
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
    // 同步更新关联 Todo（含回收站内容）：标签名按 Unicode 小写折叠匹配
    //（桌面 name_key 语义），批量逐条落盘后只触发一次自动同步
    final oldLower = old.toLowerCase();
    var touched = false;
    for (final todo in todos) {
      var hit = false;
      for (var i = 0; i < todo.tags.length; i++) {
        if (todo.tags[i].toLowerCase() == oldLower) {
          todo.tags[i] = t.name;
          hit = true;
        }
      }
      if (hit) {
        await writeTodo(todo, autosync: false);
        touched = true;
      }
    }
    if (touched) scheduleAutoSync();
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

  /// 恢复标签（§5.2.2）：Todo 上的标签名在删除期间保留，恢复后关联自动还原。
  /// 删除期间出现同名活跃标签时保留回收站条目并返回原因。
  Future<String?> restoreTag(String id) async {
    final t = classification.tagById(id);
    if (t == null || !t.isDeleted) return null;
    final nameTaken = classification.tags.any((o) =>
        o.id != t.id &&
        !o.isDeleted &&
        o.name.toLowerCase() == t.name.toLowerCase());
    if (nameTaken) {
      return '已存在同名标签“${t.name}”，请先重命名后再恢复';
    }
    t.deletedAt = null;
    t.updatedAt = rfc3339Utc(DateTime.now().toUtc());
    await _saveClassification();
    return null;
  }

  /// 彻底删除：移除所有 Todo 中的标签名称。
  /// 标签删除经 classification 整对象传播，不写 tag 墓碑。
  Future<void> purgeTag(String id) async {
    final t = classification.tagById(id);
    if (t == null) return;
    final name = t.name;
    final lower = name.toLowerCase();
    classification.tags.removeWhere((e) => e.id == id);
    var touched = false;
    for (final todo in todos) {
      final before = todo.tags.length;
      todo.tags.removeWhere((e) => e.toLowerCase() == lower);
      if (todo.tags.length != before) {
        await writeTodo(todo, autosync: false);
        touched = true;
      }
    }
    if (touched) scheduleAutoSync();
    await _saveClassification();
  }

  List<Tag> get visibleTags => classification.tags.where((t) => !t.isDeleted).toList();

  /// 标签分组固定顺序（桌面 GROUP_ORDER）：约定分组在前，自定义组随后按名称。
  static const kTagGroupOrder = ['优先级', '状态', '属性', '其他'];

  /// 分组名归一：trim 后空白归默认组。
  static String normalizeTagGroup(String group) {
    final g = group.trim();
    return g.isEmpty ? kDefaultTagGroup : g;
  }

  /// 分组名校验：trim 后 1-20 字符（空白视为默认组，不报错）。
  static String? validateTagGroup(String group) {
    final g = group.trim();
    if (g.isEmpty) return null;
    if (g.runes.length > 20) return '分组名称长度不能超过 20 个字符';
    return null;
  }

  Map<String, List<Tag>> get tagsByGroup {
    final map = <String, List<Tag>>{};
    for (final t in visibleTags) {
      map.putIfAbsent(normalizeTagGroup(t.group), () => []).add(t);
    }
    // “其他”组空也保留标题
    map.putIfAbsent(kDefaultTagGroup, () => []);
    // 组内按使用次数降序，次数同则按名称升序（桌面 classification_service 语义）
    final usage = <String, int>{};
    for (final todo in todos) {
      if (todo.isDeleted) continue;
      for (final name in todo.tags) {
        usage[name] = (usage[name] ?? 0) + 1;
      }
    }
    for (final e in map.entries) {
      e.value.sort((a, b) {
        final ua = usage[a.name] ?? 0, ub = usage[b.name] ?? 0;
        if (ua != ub) return ub - ua;
        return a.name.compareTo(b.name);
      });
    }
    final keys = map.keys.toList()
      ..sort((a, b) {
        final ia = kTagGroupOrder.indexOf(a), ib = kTagGroupOrder.indexOf(b);
        if (ia != ib) {
          if (ia == -1) return 1;
          if (ib == -1) return -1;
          return ia - ib;
        }
        return a.compareTo(b);
      });
    return {for (final k in keys) k: map[k]!};
  }

  /// 隐式标签转正：Todo 上使用但未注册实体的标签名，先注册为实体。
  /// 已存在返回实体 id；名称非法返回 null。
  Future<String?> ensureTag(String name) async {
    final n = name.trim();
    if (n.isEmpty || n.runes.length > 20) return null;
    final existing = classification.tagByName(n);
    if (existing != null) return existing.id;
    final t = Tag(id: newUlid(), name: n);
    classification.tags.add(t);
    await _saveClassification();
    return t.id;
  }

  /// 设置单标签分组（桌面 set_tag_group 语义）。
  Future<String?> setTagGroup(String tagId, String group) async {
    final t = classification.tagById(tagId);
    if (t == null) return '标签不存在';
    final err = validateTagGroup(group);
    if (err != null) return err;
    t.group = normalizeTagGroup(group) == kDefaultTagGroup
        ? ''
        : group.trim();
    t.updatedAt = rfc3339Utc(DateTime.now().toUtc());
    await _saveClassification();
    return null;
  }

  /// 重命名分组：默认组不可改；改名到已存在组被拒绝；组内标签共用同一 updatedAt。
  Future<String?> renameTagGroup(String oldGroup, String newGroup) async {
    final old = oldGroup.trim(), neu = newGroup.trim();
    if (old == kDefaultTagGroup) return '默认分组不可重命名';
    if (neu.isEmpty || neu.runes.length > 20) return '分组名称长度必须是 1-20 个字符';
    final members = classification.tags
        .where((t) => !t.isDeleted && normalizeTagGroup(t.group) == old)
        .toList();
    if (members.isEmpty) return '分组不存在';
    if (classification.tags.any((t) =>
        !t.isDeleted && normalizeTagGroup(t.group) == neu)) {
      return '分组名称已存在：$neu；如需合并请删除原分组';
    }
    final now = rfc3339Utc(DateTime.now().toUtc());
    for (final t in members) {
      t.group = neu;
      t.updatedAt = now;
    }
    await _saveClassification();
    return null;
  }

  /// 删除分组：组内活跃标签回到“其他”，不删标签。
  Future<String?> deleteTagGroup(String group) async {
    final g = group.trim();
    if (g == kDefaultTagGroup) return '默认分组不可删除';
    final members = classification.tags
        .where((t) => !t.isDeleted && normalizeTagGroup(t.group) == g)
        .toList();
    if (members.isEmpty) return '分组不存在';
    final now = rfc3339Utc(DateTime.now().toUtc());
    for (final t in members) {
      t.group = '';
      t.updatedAt = now;
    }
    await _saveClassification();
    return null;
  }

  /// 保存 Inbox/All 自定义顺序（拖拽写回）：调用方传入当前视图可见 ID 顺序；
  /// 过滤不存在 ID，已存储但不在可见列表的 ID（含回收站）按原相对顺序保留在后。
  /// index 本身是同步对象，写回后走整对象冲突流程。
  Future<void> saveCustomOrder(String view, List<String> visibleIds) async {
    assert(view == 'inbox' || view == 'all');
    final existing = todos.map((t) => t.id).toSet();
    final visible = visibleIds.where(existing.contains).toList();
    final old = index.customOrder[view] ?? const [];
    final tail =
        old.where((id) => existing.contains(id) && !visible.contains(id));
    index.customOrder[view] = [...visible, ...tail];
    indexVersion++;
    await store.saveIndex(index);
    notifyListeners();
    scheduleAutoSync();
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

  /// 目录子树的未完成 Todo 数（设计稿分类行“N 项未完成”口径）。
  int openTodoCountInCategory(String categoryId) {
    _openCountByCategory ??= _buildCounts(openOnly: true);
    final subtree = _subtreeCache ??= {};
    final ids =
        subtree.putIfAbsent(categoryId, () => expandCategoryIds(categoryId));
    final counts = _openCountByCategory!;
    var n = 0;
    for (final id in ids) {
      n += counts[id] ?? 0;
    }
    return n;
  }

  Map<String, int> _buildCounts({bool openOnly = false}) {
    final counts = <String, int>{};
    for (final t in todos) {
      if (t.isDeleted || t.categoryId == null) continue;
      if (openOnly && t.isCompleted) continue;
      counts[t.categoryId!] = (counts[t.categoryId!] ?? 0) + 1;
    }
    return counts;
  }
}
