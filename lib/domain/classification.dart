/// 目录与标签实体，格式对齐桌面端 content/classification.json（schemaVersion 3）。
///
/// 桌面契约（../tasktips/src-tauri/src/domain/classification.rs）：
/// - 时间戳必填；color 必填（hex 色板，默认 #8a8a8a）；
/// - icon/description/orderIndex/isSystem 始终写出；
/// - parentId 始终写出（可 null）；deletedAt 为 null 时省略；
/// - 未知字段必须原样保留（对齐 Todo 的 extraFrontMatter 做法）。
///
/// 时间戳以 RFC 3339 原文字符串保存，避免 Dart DateTime 毫秒截断
/// 破坏与桌面端 serde(chrono) 序列化的逐字节一致性。
library;

import '../core/ulid.dart';

const kClassificationSchemaVersion = 3;
const kDefaultColor = '#8a8a8a';
const kDefaultTagGroup = '其他';

/// 桌面端 32 色 hex 色板（COLOR_PALETTE）。
const kColorPalette = [
  '#8a8a8a', '#f97066', '#fb923c', '#fbbf24', '#6ccb5f', '#6ee7b7', '#4a9eff', '#a78bfa',
  '#e05299', '#ff8fab', '#c084fc', '#818cf8', '#38bdf8', '#22d3ee', '#34d399', '#a3e635',
  '#f97316', '#ef4444', '#dc2626', '#b91c1c', '#d97706', '#ca8a04', '#65a30d', '#15803d',
  '#0284c7', '#1d4ed8', '#4338ca', '#7c3aed', '#9d174d', '#be123c', '#0f766e', '#475569',
];

/// 旧移动端语义色键 → 色板 hex（v1 文件迁移用）。
const _legacySemanticColors = {
  'blue': '#4a9eff',
  'green': '#6ccb5f',
  'orange': '#fb923c',
  'purple': '#a78bfa',
  'red': '#f97066',
  'gray': '#8a8a8a',
};

/// chrono 兼容 RFC3339：整秒无小数位，否则毫秒 3 位。
String rfc3339Utc(DateTime t) {
  final utc = t.toUtc();
  var s = utc.toIso8601String(); // ...T..:..:..(.mmm)?Z
  if (s.endsWith('.000Z')) s = '${s.substring(0, s.length - 5)}Z';
  return s;
}

DateTime? tryParseRfc3339(String? s) =>
    s == null || s.isEmpty ? null : DateTime.tryParse(s);

class Category {
  final String id;
  String name;
  String? parentId;
  String color; // hex，始终写出
  String icon;
  String description;
  int orderIndex;
  String createdAt; // RFC 3339 原文
  String updatedAt;
  String? deletedAt; // 原文；null 省略
  final Map<String, Object?> extra; // 未知字段原样保留

  Category({
    required this.id,
    required this.name,
    this.parentId,
    String? color,
    this.icon = '',
    this.description = '',
    this.orderIndex = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? deletedAt,
    Map<String, Object?>? extra,
  })  : color = _normalizeColor(color),
        createdAt = rfc3339Utc(createdAt ?? DateTime.now().toUtc()),
        updatedAt = rfc3339Utc(updatedAt ?? DateTime.now().toUtc()),
        deletedAt = (deletedAt == null || deletedAt.isEmpty) ? null : deletedAt,
        extra = extra ?? {};

  bool get isDeleted => deletedAt != null;

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'parentId': parentId,
        'color': color,
        'icon': icon,
        'description': description,
        'orderIndex': orderIndex,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        if (deletedAt != null) 'deletedAt': deletedAt,
        ...extra,
      };

  static Category fromJson(Map<String, Object?> j) {
    final c = Category(
      id: j['id'] as String,
      name: j['name'] as String,
      parentId: (j['parentId'] as String?)?.nullIfEmpty,
      color: _normalizeColor(j['color'] as String?),
      icon: (j['icon'] as String?) ?? '',
      description: (j['description'] as String?) ?? '',
      orderIndex: (j['orderIndex'] as num?)?.toInt() ?? 0,
      extra: _extras(j, const {
        'id', 'name', 'parentId', 'color', 'icon', 'description',
        'orderIndex', 'createdAt', 'updatedAt', 'deletedAt',
      }),
    )
      // 时间戳保留原文（缺失时已是当前时刻），避免毫秒格式漂移
      ..createdAt = _parseTs(j['createdAt'])
      ..updatedAt = _parseTs(j['updatedAt'])
      ..deletedAt = (j['deletedAt'] as String?)?.nullIfEmpty;
    return c;
  }
}

class Tag {
  final String id;
  String name;
  String color;
  String icon;
  String description;
  bool isSystem;
  String group; // 空串表示默认组；序列化归一为“其他”
  String createdAt;
  String updatedAt;
  String? deletedAt;
  final Map<String, Object?> extra;

  Tag({
    required this.id,
    required this.name,
    String? color,
    this.icon = '',
    this.description = '',
    this.isSystem = false,
    this.group = '',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
    Map<String, Object?>? extra,
  })  : color = _normalizeColor(color),
        createdAt = rfc3339Utc(createdAt ?? DateTime.now().toUtc()),
        updatedAt = rfc3339Utc(updatedAt ?? DateTime.now().toUtc()),
        extra = extra ?? {};

  bool get isDeleted => deletedAt != null;

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'color': color,
        'icon': icon,
        'description': description,
        'isSystem': isSystem,
        'group': group.trim().isEmpty ? kDefaultTagGroup : group.trim(),
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        if (deletedAt != null) 'deletedAt': deletedAt,
        ...extra,
      };

  static Tag fromJson(Map<String, Object?> j) {
    final t = Tag(
      id: j['id'] as String,
      name: j['name'] as String,
      color: _normalizeColor(j['color'] as String?),
      icon: (j['icon'] as String?) ?? '',
      description: (j['description'] as String?) ?? '',
      isSystem: j['isSystem'] == true,
      group: (j['group'] as String?) ?? '',
      extra: _extras(j, const {
        'id', 'name', 'color', 'icon', 'description', 'isSystem',
        'group', 'createdAt', 'updatedAt', 'deletedAt',
      }),
    )
      ..createdAt = _parseTs(j['createdAt'])
      ..updatedAt = _parseTs(j['updatedAt'])
      ..deletedAt = (j['deletedAt'] as String?)?.nullIfEmpty;
    return t;
  }
}

/// 分类集合：目录树（最多三级）+ 标签。
class Classification {
  List<Category> categories;
  List<Tag> tags;
  int schemaVersion; // 读入原值；写出固定为当前版本
  final Map<String, Object?> fileExtra; // 文件级未知字段

  /// 只读保存的逐字节保障：未修改时按原文写回。
  String? rawJson;
  bool dirty = true;

  Classification(this.categories, this.tags,
      {this.schemaVersion = kClassificationSchemaVersion, this.fileExtra = const {}});

  Map<String, Object?> toJson() => {
        'schemaVersion': kClassificationSchemaVersion,
        'categories': categories.map((c) => c.toJson()).toList(),
        'tags': tags.map((t) => t.toJson()).toList(),
        ...fileExtra,
      };

  static Classification fromJson(Map<String, Object?> j, {String? raw}) {
    final sv = (j['schemaVersion'] as num?)?.toInt() ?? 1;
    if (sv > kClassificationSchemaVersion) {
      throw FormatException('不支持的 classification schemaVersion: $sv');
    }
    final c = Classification(
      ((j['categories'] as List?) ?? [])
          .map((e) => Category.fromJson((e as Map).cast<String, Object?>()))
          .toList(),
      ((j['tags'] as List?) ?? [])
          .map((e) => Tag.fromJson((e as Map).cast<String, Object?>()))
          .toList(),
      schemaVersion: sv,
      fileExtra: _extras(j, const {'schemaVersion', 'categories', 'tags'}),
    )..rawJson = raw;
    if (sv < kClassificationSchemaVersion) {
      _migrateLegacy(c);
    }
    // 迁移不改用户语义，仍视为与原文等价（旧版本文件由本端首次写回时升级）
    c.dirty = sv < kClassificationSchemaVersion;
    return c;
  }

  /// v1/v2 → v3：时间戳/未知字段默认值已在 fromJson 完成；
  /// v1 默认灰标签按桌面 v1→v2 迁移回填未占用色（语义色键已在 _normalizeColor 映射）。
  static void _migrateLegacy(Classification c) {
    final used = c.tags.map((t) => t.color).toSet();
    final unused = kColorPalette.where((p) => !used.contains(p)).toList();
    var i = 0;
    for (final t in c.tags) {
      if (t.color == kDefaultColor && i < unused.length) {
        t.color = unused[i++];
      }
    }
  }

  Set<String> subtreeOf(String rootId) {
    final out = <String>{rootId};
    var grew = true;
    while (grew) {
      grew = false;
      for (final c in categories) {
        if (c.parentId != null && out.contains(c.parentId) && out.add(c.id)) {
          grew = true;
        }
      }
    }
    return out;
  }

  /// 同批次（deletedAt == cohort）软删除的子目录集合：从 rootId 沿
  /// deletedAt == cohort 的链向下收集；更早/更晚单独删除的子目录不连带
  ///（todo-classification-design.md §5.2 按原样恢复）。
  Set<String> trashedCohortOf(String rootId, String cohort) {
    final out = <String>{rootId};
    var grew = true;
    while (grew) {
      grew = false;
      for (final c in categories) {
        if (c.parentId != null &&
            out.contains(c.parentId) &&
            c.deletedAt == cohort &&
            out.add(c.id)) {
          grew = true;
        }
      }
    }
    return out;
  }

  /// Todo 的目录是否为"未分类"：无目录、目录不存在或已进回收站。
  bool isUncategorized(String? categoryId) {
    if (categoryId == null || categoryId.isEmpty) return true;
    final c = byId(categoryId);
    return c == null || c.isDeleted;
  }

  int depthOf(String id) {
    var depth = 1;
    var cur = byId(id);
    while (cur?.parentId != null) {
      cur = byId(cur!.parentId!);
      depth++;
    }
    return depth;
  }

  /// 被移动子树的最大深度（根为 1）。
  int subtreeHeight(String id) {
    var max = 1;
    for (final child in categories.where((c) => c.parentId == id)) {
      final h = subtreeHeight(child.id);
      if (h + 1 > max) max = h + 1;
    }
    return max;
  }

  Category? byId(String id) {
    for (final c in categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  Tag? tagById(String id) {
    for (final t in tags) {
      if (t.id == id) return t;
    }
    return null;
  }

  Tag? tagByName(String name) {
    final lower = name.toLowerCase();
    for (final t in tags) {
      if (t.name.toLowerCase() == lower) return t;
    }
    return null;
  }

  String categoryPath(String? id) {
    if (id == null || id.isEmpty) return '未分类';
    final parts = <String>[];
    Category? cur = byId(id);
    var guard = 0;
    while (cur != null && guard++ < 8) {
      parts.insert(0, cur.isDeleted ? '${cur.name}（已删除）' : cur.name);
      cur = cur.parentId == null ? null : byId(cur.parentId!);
    }
    return parts.isEmpty ? '未分类' : parts.join(' / ');
  }
}

String _parseTs(Object? v) {
  final s = v as String?;
  if (s != null && s.isNotEmpty) return s;
  return rfc3339Utc(DateTime.now().toUtc());
}

/// 颜色规范化（对齐桌面端 validate_color）：null/空 → 默认灰；
/// 旧语义键 → hex；色板成员（大小写不敏感）→ 小写标准形；
/// 非色板值 → 默认灰，永不写出桌面编辑路径拒绝的颜色。
String canonicalizeColor(String? c) {
  if (c == null || c.isEmpty) return kDefaultColor;
  final lower = c.toLowerCase();
  final legacy = _legacySemanticColors[lower];
  if (legacy != null) return legacy;
  if (kColorPalette.contains(lower)) return lower;
  return kDefaultColor;
}

String _normalizeColor(String? c) => canonicalizeColor(c);

Map<String, Object?> _extras(Map<String, Object?> j, Set<String> known) {
  final out = <String, Object?>{};
  j.forEach((k, v) {
    if (!known.contains(k)) out[k] = v;
  });
  return out;
}

extension on String? {
  String? get nullIfEmpty => (this == null || this!.isEmpty) ? null : this;
}

/// 桌面端 new_entity_id 为 26 字符 Crockford ULID，与本端一致。
String newClassificationEntityId() => newUlid();
