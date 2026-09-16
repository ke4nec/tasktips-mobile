/// 目录与标签实体，格式遵循桌面端 content/classification.json。
library;

class Category {
  final String id;
  String name;
  String? parentId;
  String? color; // 语义色键或 hex，可空
  DateTime? deletedAt;

  Category({
    required this.id,
    required this.name,
    this.parentId,
    this.color,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        if (parentId != null) 'parentId': parentId,
        if (color != null) 'color': color,
        if (deletedAt != null)
          'deletedAt': deletedAt!.toUtc().toIso8601String(),
      };

  static Category fromJson(Map<String, Object?> j) => Category(
        id: j['id'] as String,
        name: j['name'] as String,
        parentId: j['parentId'] as String?,
        color: j['color'] as String?,
        deletedAt: j['deletedAt'] == null
            ? null
            : DateTime.parse(j['deletedAt'] as String),
      );
}

class Tag {
  final String id;
  String name;
  String? color;
  String group; // 分组名，空为默认“其他”
  DateTime? deletedAt;

  Tag({
    required this.id,
    required this.name,
    this.color,
    this.group = '',
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        if (color != null) 'color': color,
        'group': group,
        if (deletedAt != null)
          'deletedAt': deletedAt!.toUtc().toIso8601String(),
      };

  static Tag fromJson(Map<String, Object?> j) => Tag(
        id: j['id'] as String,
        name: j['name'] as String,
        color: j['color'] as String?,
        group: (j['group'] as String?) ?? '',
        deletedAt: j['deletedAt'] == null
            ? null
            : DateTime.parse(j['deletedAt'] as String),
      );
}

/// 分类集合：目录树（最多三级）+ 标签。
class Classification {
  List<Category> categories;
  List<Tag> tags;

  Classification(this.categories, this.tags);

  Map<String, Object?> toJson() => {
        'schemaVersion': 1,
        'categories': categories.map((c) => c.toJson()).toList(),
        'tags': tags.map((t) => t.toJson()).toList(),
      };

  static Classification fromJson(Map<String, Object?> j) => Classification(
        ((j['categories'] as List?) ?? [])
            .map((e) => Category.fromJson((e as Map).cast()))
            .toList(),
        ((j['tags'] as List?) ?? [])
            .map((e) => Tag.fromJson((e as Map).cast()))
            .toList(),
      );

  /// 目录自身及其全部子孙 ID（软删除目录仍可包含，供回收站/级联判断）。
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

  int depthOf(String id) {
    var depth = 1;
    var cur = byId(id);
    while (cur?.parentId != null) {
      cur = byId(cur!.parentId!);
      depth++;
    }
    return depth;
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
