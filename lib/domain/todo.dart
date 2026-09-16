/// 领域模型：与桌面端 tasktips-design.md §10.1 保持一致。
library domain;

/// 无时区本地日历日期 YYYY-MM-DD。
typedef LocalDate = String;

String todayLocal() {
  final n = DateTime.now();
  return '${n.year.toString().padLeft(4, '0')}-'
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

  /// 正文纯文本摘要（供搜索与列表两行摘要）。
  String get plainBody {
    final buf = StringBuffer();
    var inFence = false;
    for (final line in body.split('\n')) {
      if (line.trimLeft().startsWith('```')) {
        inFence = !inFence;
        buf.writeln(line);
        continue;
      }
      buf.writeln(line);
    }
    return buf.toString();
  }

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

/// 标题派生：取首个非空、且并非只由 Markdown 标记构成的行，
/// 剥离标记后按 Unicode 码点截断到 80（超出取 79 码点 + …）。
String deriveTitle(String body) {
  for (final rawLine in body.split('\n')) {
    final line = rawLine.trim();
    if (line.isEmpty) continue;
    var t = line;
    // 剥离常见行首标记
    t = t.replaceFirst(RegExp(r'^#{1,6}\s+'), '');
    t = t.replaceFirst(RegExp(r'^[-*+]\s+\[[ xX]\]\s*'), '');
    t = t.replaceFirst(RegExp(r'^[-*+]\s+'), '');
    t = t.replaceFirst(RegExp(r'^\d+[.)]\s+'), '');
    t = t.replaceFirst(RegExp(r'^>\s*'), '');
    if (t.trim().replaceAll(RegExp(r'[*_`~#>\[\]()!-]'), '').isEmpty) continue;
    String stripMarks(String input, RegExp re) => input
        .replaceAllMapped(re, (m) => m.group(1) ?? '');
    t = stripMarks(t, RegExp(r'\*\*(.+?)\*\*'));
    t = stripMarks(t, RegExp(r'__(.+?)__'));
    t = stripMarks(t, RegExp(r'(?<!\*)\*(?<!\*\*)([^*]+?)\*(?!\*)'));
    t = stripMarks(t, RegExp(r'(?<!_)_([^_]+?)_(?!_)'));
    t = stripMarks(t, RegExp(r'~~(.+?)~~'));
    t = t.replaceAll('`', '');
    t = t.trim();
    if (t.isEmpty) continue;
    final runes = t.runes.toList();
    if (runes.length <= 80) return t;
    return String.fromCharCodes(runes.take(79)) + '…';
  }
  return '';
}
