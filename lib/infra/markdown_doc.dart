/// Markdown + YAML front matter 文档解析/序列化。
/// 未知 front matter 字段原样保留；读取兼容 CRLF，保存统一 LF（真实编辑时）。
library;

import 'package:yaml/yaml.dart';
import 'package:yaml_writer/yaml_writer.dart';

import '../domain/todo.dart';

class TodoDoc {
  final Todo todo;
  final String rawBody;
  final String rawFrontMatter; // 原始文本（含未知字段排版）

  TodoDoc(this.todo, this.rawBody, this.rawFrontMatter);
}

class FrontMatterException implements Exception {
  final String message;
  FrontMatterException(this.message);
  @override
  String toString() => message;
}

class ParsedDoc {
  final Map<String, Object?> fields;
  final String body;
  ParsedDoc(this.fields, this.body);
}

/// 解析 `---\n...\n---\n` front matter。解析失败抛 [FrontMatterException]。
ParsedDoc parseTodoDoc(String text) {
  // 读取兼容 CRLF 与孤立 \r（与桌面端 markdown.rs 归一规则一致），保存统一 LF
  final normalized =
      text.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  if (!normalized.startsWith('---\n')) {
    throw FrontMatterException('缺少 front matter 起始标记');
  }
  // 结束标记按行判定（整行 trim 后为 ---），避免 `---xyz` 等前缀误判
  // 切错 YAML 切片（与桌面端 markdown.rs 按行判定一致）
  final lines = normalized.split('\n');
  var endLine = -1;
  for (var i = 1; i < lines.length; i++) {
    if (lines[i].trim() == '---') {
      endLine = i;
      break;
    }
  }
  if (endLine < 0) throw FrontMatterException('缺少 front matter 结束标记');
  final fmText = lines.sublist(1, endLine).join('\n');
  var body =
      lines.sublist(endLine + 1).join('\n').replaceFirst(RegExp('^\n*'), '');
  final YamlMap y;
  try {
    y = loadYaml(fmText) as YamlMap;
  } catch (e) {
    throw FrontMatterException('YAML 解析失败: $e');
  }
  final fields = <String, Object?>{};
  y.forEach((k, v) {
    fields[k as String] = _yamlToDart(v);
  });
  return ParsedDoc(fields, body);
}

Object? _yamlToDart(Object? v) {
  if (v is YamlMap) {
    final m = <String, Object?>{};
    v.forEach((k, val) => m[k.toString()] = _yamlToDart(val));
    return m;
  }
  if (v is YamlList) return v.map(_yamlToDart).toList();
  return v;
}

DateTime _parseDate(Object? v) {
  if (v == null) throw FrontMatterException('时间字段缺失');
  return DateTime.parse(v as String);
}

/// 从解析结果构建 Todo。schemaVersion 不识别时抛异常（调用方按损坏处理）。
Todo todoFromFields(Map<String, Object?> f, String body) {
  final sv = f['schemaVersion'];
  if (sv is! int || sv != 1) {
    throw FrontMatterException('不支持的 schemaVersion: $sv');
  }
  final status = f['status'];
  if (status != 'open' && status != 'completed') {
    throw FrontMatterException('非法 status: $status');
  }
  final priorityRaw = f['priority'];
  // 非 int（如字符串 "2" / 浮点）显式拒绝为 FrontMatterException，
  // 避免 as 强转抛 TypeError 导致错误分类失真（调用方按损坏隔离）。
  final priority = switch (priorityRaw) {
    null => 0,
    int p => p,
    _ => throw FrontMatterException('非法 priority: $priorityRaw'),
  };
  if (priority < 0 || priority > 3) {
    // 与桌面端 TodoTip::validate 一致：优先级只允许 0-3
    throw FrontMatterException('非法 priority: $priority');
  }
  final known = {
    'schemaVersion', 'id', 'title', 'status', 'priority', 'tags',
    'dueDate', 'categoryId', 'deletedAt', 'createdAt', 'updatedAt',
    'completedAt', 'revision', 'deviceId',
  };
  final extra = <String, Object?>{};
  f.forEach((k, v) {
    if (!known.contains(k)) extra[k] = v;
  });
  return Todo(
    id: f['id'] as String,
    title: (f['title'] as String?) ?? '',
    body: body,
    status: status == 'completed' ? TodoStatus.completed : TodoStatus.open,
    priority: priority,
    tags: ((f['tags'] as List?) ?? []).map((e) => e.toString()).toList(),
    dueDate: _optStr(f['dueDate']),
    categoryId: _optStr(f['categoryId']),
    deletedAt: f['deletedAt'] == null ? null : _parseDate(f['deletedAt']),
    createdAt: _parseDate(f['createdAt']),
    updatedAt: _parseDate(f['updatedAt']),
    completedAt: f['completedAt'] == null ? null : _parseDate(f['completedAt']),
    revision: (f['revision'] as int?) ?? 1,
    deviceId: (f['deviceId'] as String?) ?? '',
    extraFrontMatter: extra,
  );
}

String? _optStr(Object? v) {
  if (v == null) return null;
  final s = v.toString();
  return s.isEmpty || s == 'null' ? null : s;
}

String _fmtDate(DateTime t) =>
    t.toUtc().toIso8601String().replaceFirst(RegExp(r'\.000'), '');

/// 序列化为完整 Markdown 文档（UTF-8 / LF）。
String serializeTodoDoc(Todo t) {
  final fm = <String, Object?>{
    'schemaVersion': 1,
    'id': t.id,
    'title': t.title,
    'status': t.status == TodoStatus.completed ? 'completed' : 'open',
    'priority': t.priority,
    if (t.tags.isNotEmpty) 'tags': t.tags,
    if (t.dueDate != null) 'dueDate': t.dueDate,
    'categoryId': t.categoryId,
    'deletedAt': t.deletedAt == null ? null : _fmtDate(t.deletedAt!),
    'createdAt': _fmtDate(t.createdAt),
    'updatedAt': _fmtDate(t.updatedAt),
    'completedAt': t.completedAt == null ? null : _fmtDate(t.completedAt!),
    'revision': t.revision,
    'deviceId': t.deviceId,
    ...t.extraFrontMatter,
  };
  final yamlText = YamlWriter().write(fm);
  return '---\n$yamlText---\n\n${t.body}';
}
