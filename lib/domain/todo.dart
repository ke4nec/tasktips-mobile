/// 领域模型：与桌面端 tasktips-design.md §10.1 保持一致。
library;

/// 无时区本地日历日期 YYYY-MM-DD。
typedef LocalDate = String;

String _todayCache = '';
int _todayCacheY = -1, _todayCacheM = -1, _todayCacheD = -1;

String todayLocal() {
  final n = DateTime.now();
  // 当日本地日期缓存：列表逐项 isOverdue/isDueToday 等高频取值时
  // 避免重复格式化；本地年月日变化（含跨时区导致日期翻转）时重算。
  if (_todayCache.isNotEmpty &&
      n.year == _todayCacheY &&
      n.month == _todayCacheM &&
      n.day == _todayCacheD) {
    return _todayCache;
  }
  _todayCacheY = n.year;
  _todayCacheM = n.month;
  _todayCacheD = n.day;
  return _todayCache = '${n.year.toString().padLeft(4, '0')}-'
      '${n.month.toString().padLeft(2, '0')}-'
      '${n.day.toString().padLeft(2, '0')}';
}

enum TodoStatus { open, completed }

/// 优先级 0/1/2/3：无、低、中、高。
const List<int> kPriorities = [0, 1, 2, 3];

String priorityLabel(int p) => const ['无', '低', '中', '高'][p.clamp(0, 3)];

class Todo {
  final String id;
  String title; // 由正文首行派生，保存时写回
  String body;
  TodoStatus status;
  int priority;
  List<String> tags; // 标签名称，保留显示大小写
  LocalDate? dueDate;
  String? categoryId;
  DateTime? deletedAt;
  final DateTime createdAt;
  DateTime updatedAt;
  DateTime? completedAt;
  int revision;
  final String deviceId; // 创建设备
  final Map<String, Object?> extraFrontMatter; // 未知字段原样保留

  Todo({
    required this.id,
    required this.title,
    required this.body,
    this.status = TodoStatus.open,
    this.priority = 0,
    List<String>? tags,
    this.dueDate,
    this.categoryId,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.revision = 1,
    required this.deviceId,
    Map<String, Object?>? extraFrontMatter,
  })  : tags = tags ?? [],
        extraFrontMatter = extraFrontMatter ?? {};

  bool get isCompleted => status == TodoStatus.completed;
  bool get isDeleted => deletedAt != null;
  bool get isOverdue =>
      !isCompleted && dueDate != null && dueDate!.compareTo(todayLocal()) < 0;
  bool get isDueToday =>
      !isCompleted && dueDate == todayLocal();
  bool get isUpcoming =>
      !isCompleted && dueDate != null && dueDate!.compareTo(todayLocal()) > 0;

  Todo copyWith({
    DateTime? deletedAt,
    bool clearDeletedAt = false,
    TodoStatus? status,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    int? revision,
    DateTime? updatedAt,
    String? body,
    int? priority,
    String? dueDate,
    bool clearDueDate = false,
    String? categoryId,
    bool clearCategoryId = false,
    List<String>? tags,
  }) =>
      Todo(
        id: id,
        title: title,
        body: body ?? this.body,
        status: status ?? this.status,
        priority: priority ?? this.priority,
        tags: tags ?? List.of(this.tags),
        dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
        categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
        deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
        revision: revision ?? this.revision,
        deviceId: deviceId,
        extraFrontMatter: Map.of(extraFrontMatter),
      );
}

/// 派生标题的最大字符数（码点）：仅控制列表/标题栏展示宽度。
const int kDerivedTitleMaxChars = 80;

const int _maxLinesScanned = 50;

final _hrRe = RegExp(r'^ {0,3}(?:[-*_][ \t]*){3,}$');
final _brRe = RegExp(r'\\?<br\s*/?>', caseSensitive: false);
final _atxRe = RegExp(r'^#{1,6}\s+([^\s].*?)(?:\s+#{1,6})?\s*$');
final _quoteRe = RegExp(r'^>\s?');
final _taskBulletRe = RegExp(r'^[-*+]\s+\[[ xX]\]\s+');
final _bulletRe = RegExp(r'^[-*+]\s+');
final _taskOrderedRe = RegExp(r'^\d+[.)]\s+\[[ xX]\]\s+');
final _orderedRe = RegExp(r'^\d+[.)]\s+');
final _imgRe = RegExp(r'!\[([^\]]*)\]\([^)]*\)');
final _linkRe = RegExp(r'\[([^\]]*)\]\([^)]*\)');
final _boldItalicRe = RegExp(r'\*\*\*(.+?)\*\*\*');
final _boldRe = RegExp(r'\*\*(.+?)\*\*');
final _italicRe = RegExp(r'\*(.+?)\*');
final _strikeRe = RegExp(r'~~(.+?)~~');
final _codeRe = RegExp(r'`([^`]*)`');
// 下划线强调只在两侧不紧邻单词字符时视为标记（保留 snake_case）
final _underscoreRe = RegExp(r'(^|[^\w])_{1,3}([^_]+?)_{1,3}(?=[^\w]|$)');

/// 剥离单行 Markdown 标记，返回纯文本；规则与桌面端 markdown.ts 一致：
/// 分隔线/`<br>` 残留视为无文本；块级前缀（标题/引用/任务/列表，可叠加）
/// 循环剥离；行内强调/代码/链接与图片保留可见文本。
String stripMarkdown(String line) {
  var text = line.trim();
  if (_hrRe.hasMatch(text)) return '';
  text = text.replaceAll(_brRe, '');
  for (;;) {
    final next = text
        .replaceFirstMapped(_atxRe, (m) => m.group(1) ?? '')
        .replaceFirst(_quoteRe, '')
        .replaceFirst(_taskBulletRe, '')
        .replaceFirst(_bulletRe, '')
        .replaceFirst(_taskOrderedRe, '')
        .replaceFirst(_orderedRe, '');
    if (next == text) break;
    text = next;
  }
  text = text
      .replaceAllMapped(_imgRe, (m) => m.group(1) ?? '')
      .replaceAllMapped(_linkRe, (m) => m.group(1) ?? '')
      .replaceAllMapped(_boldItalicRe, (m) => m.group(1) ?? '')
      .replaceAllMapped(_boldRe, (m) => m.group(1) ?? '')
      .replaceAllMapped(_italicRe, (m) => m.group(1) ?? '')
      .replaceAllMapped(_strikeRe, (m) => m.group(1) ?? '')
      .replaceAllMapped(_codeRe, (m) => m.group(1) ?? '')
      .replaceAllMapped(
          _underscoreRe, (m) => '${m.group(1)}${m.group(2)}');
  return text.trim();
}

/// 标题派生（设计文档 4.2）：取正文首个非空行（至多扫描 50 行），
/// 剥离 Markdown 标记后按 Unicode 码点截断到 80（超出取 79 码点 + …）。
String deriveTitle(String body) {
  var count = 0;
  for (final line in body.split(RegExp(r'\r?\n'))) {
    if (count >= _maxLinesScanned) break;
    count += 1;
    if (line.trim().isEmpty) continue;
    final text = stripMarkdown(line);
    // 行内只有标记（分隔线、<br> 残留等）时继续向后找真正的文本行
    if (text.isEmpty) continue;
    final runes = text.runes.toList();
    if (runes.length <= kDerivedTitleMaxChars) return text;
    return '${String.fromCharCodes(runes.take(kDerivedTitleMaxChars - 1))}…';
  }
  return '';
}
