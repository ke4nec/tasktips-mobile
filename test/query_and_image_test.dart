/// 查询层 tagMode 三模式与图片导入校验（魔数白名单/限额/命名）测试。
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tasktips/domain/query.dart';
import 'package:tasktips/domain/todo.dart';
import 'package:tasktips/infra/store.dart';

Todo _todo(String id, List<String> tags) => Todo(
      id: id,
      title: id,
      body: id,
      tags: tags,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
      deviceId: 'dev',
    );

void main() {
  group('tagMode 三模式（桌面 TagFilterMode 语义）', () {
    final todos = [
      _todo('ab', ['甲', '乙']),
      _todo('a', ['甲']),
      _todo('none', ['丙']),
    ];
    final today = '2026-09-17';

    List<String> run(List<String> tags, TagFilterMode mode) => runQuery(todos,
            TodoQuery(
              view: TodoView.all,
              tagNames: tags,
              tagMode: mode,
            ),
            today: today)
        .map((t) => t.id)
        .toList();

    test('and=全部命中', () {
      expect(run(['甲', '乙'], TagFilterMode.and), ['ab']);
    });

    test('or=任一命中', () {
      expect(run(['甲', '乙'], TagFilterMode.or), ['ab', 'a']);
    });

    test('exclude=均不包含', () {
      expect(run(['甲', '乙'], TagFilterMode.exclude), ['none']);
    });

    test('标签为空时任何模式恒命中', () {
      for (final m in TagFilterMode.values) {
        expect(run([], m), ['ab', 'a', 'none']);
      }
      // tagNames 为 null 同样恒命中
      expect(
          runQuery(todos,
                  TodoQuery(view: TodoView.all, tagMode: TagFilterMode.exclude),
                  today: today)
              .map((t) => t.id)
              .toList(),
          ['ab', 'a', 'none']);
    });

    test('大小写折叠匹配', () {
      final latin = [_todo('w1', ['Work']), _todo('w2', ['personal'])];
      expect(
          runQuery(latin,
                  TodoQuery(
                      view: TodoView.all,
                      tagNames: ['work'],
                      tagMode: TagFilterMode.or),
                  today: today)
              .map((t) => t.id)
              .toList(),
          ['w1']);
    });
  });

  group('目录+未分类组合为并集（桌面 matches_categories 语义）', () {
    Todo cat(String id, String? categoryId) => Todo(
          id: id,
          title: id,
          body: id,
          categoryId: categoryId,
          createdAt: DateTime.utc(2026, 1, 1),
          updatedAt: DateTime.utc(2026, 1, 1),
          deviceId: 'dev',
        );
    const today = '2026-09-17';
    const active = {'c1'};

    test('仅目录：命中 ID 集', () {
      final todos = [cat('in', 'c1'), cat('out', 'c2'), cat('none', null)];
      final r = runQuery(
          todos, TodoQuery(view: TodoView.all, categoryIds: ['c1']),
          today: today, activeCategoryIds: active);
      expect(r.map((t) => t.id), ['in']);
    });

    test('仅未分类：含空目录与指向已删/不存在目录', () {
      final todos = [cat('in', 'c1'), cat('null', null), cat('gone', 'c9')];
      final r = runQuery(todos, TodoQuery(view: TodoView.all, uncategorized: true),
          today: today, activeCategoryIds: active);
      expect(r.map((t) => t.id).toSet(), {'null', 'gone'});
    });

    test('目录+未分类同时勾选：两者并集', () {
      final todos = [cat('in', 'c1'), cat('null', null), cat('other', 'c2')];
      final r = runQuery(
          todos,
          TodoQuery(
              view: TodoView.all, categoryIds: ['c1'], uncategorized: true),
          today: today, activeCategoryIds: active);
      // c2 不在 active 集 → 按未分类口径，同样命中
      expect(r.map((t) => t.id).toSet(), {'in', 'null', 'other'});
    });
  });

  group('搜索覆盖代码围栏内容', () {
    test('围栏内代码可搜，围栏标记行不干扰', () {
      final todos = [
        Todo(
          id: 'code',
          title: '笔记',
          body: '说明文字\n```dart\nflutterSecureStorage\n```\n尾部',
          createdAt: DateTime.utc(2026, 1, 1),
          updatedAt: DateTime.utc(2026, 1, 1),
          deviceId: 'dev',
        ),
        Todo(
          id: 'other',
          title: '其他',
          body: '毫不相关的内容',
          createdAt: DateTime.utc(2026, 1, 1),
          updatedAt: DateTime.utc(2026, 1, 1),
          deviceId: 'dev',
        ),
      ];
      final r = runQuery(todos, TodoQuery(view: TodoView.all, search: 'fluttersecurestorage'),
          today: '2026-09-17');
      expect(r.map((t) => t.id), ['code']);
    });
  });

  group('显式标题排序等标题时按 id 稳定决胜', () {
    test('升序/降序下等标题顺序一致', () {
      Todo titled(String id) => Todo(
            id: id,
            title: '相同标题',
            body: id,
            createdAt: DateTime.utc(2026, 1, 1),
            updatedAt: DateTime.utc(2026, 1, 1),
            deviceId: 'dev',
          );
      final todos = [titled('b-id'), titled('a-id'), titled('c-id')];
      for (final order in [SortOrder.asc, SortOrder.desc]) {
        final r = runQuery(
            todos,
            TodoQuery(
                view: TodoView.all,
                defaultSort: false,
                sortKey: SortKey.title,
                sortOrder: order),
            today: '2026-09-17');
        expect(r.map((t) => t.id), ['a-id', 'b-id', 'c-id']);
      }
    });
  });

  group('图片导入校验', () {
    late Directory dir;
    late TodoStore store;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('tt_img');
      store = TodoStore(dir);
      await store.init();
    });

    tearDown(() async {
      await dir.delete(recursive: true);
    });

    test('魔数白名单：PNG/JPEG/GIF/WebP/BMP 识别，SVG 拒绝', () {
      expect(TodoStore.sniffImageExtension(Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])), 'png');
      expect(TodoStore.sniffImageExtension(Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0])), 'jpg');
      expect(TodoStore.sniffImageExtension(Uint8List.fromList([0x47, 0x49, 0x46, 0x38, 0x39, 0x61])), 'gif');
      expect(
          TodoStore.sniffImageExtension(Uint8List.fromList([
            0x52, 0x49, 0x46, 0x46, 0x00, 0x00, 0x00, 0x00,
            0x57, 0x45, 0x42, 0x50,
          ])),
          'webp');
      expect(TodoStore.sniffImageExtension(Uint8List.fromList([0x42, 0x4D])), 'bmp');
      // SVG（XML 文本）不在白名单
      expect(
          TodoStore.sniffImageExtension(
              Uint8List.fromList('<svg xmlns'.codeUnits)),
          isNull);
    });

    test('saveImage：PNG 落盘为 images/<ULID>.png 并返回相对路径', () async {
      final png = Uint8List.fromList([
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0, 0, 0, 0x0D,
      ]);
      final rel = await store.saveImage(png);
      expect(rel, matches(r'^images/[0-9A-HJKMNP-TV-Z]{26}\.png$'));
      expect(await File('${store.tipsDir.path}/$rel').exists(), isTrue);
      // 绝不使用用户原始文件名：引用只含生成的 ULID
      expect(rel.contains('photo'), isFalse);
    });

    test('saveImage：不支持格式抛异常且不产生半写文件', () async {
      final before = store.imagesDir.listSync().length;
      expect(
          () => store.saveImage(
              Uint8List.fromList('<svg xmlns="x"></svg>'.codeUnits)),
          throwsA(isA<ImageRejectException>()));
      expect(
          () => store.saveImage(Uint8List.fromList([])),
          throwsA(isA<ImageRejectException>()));
      expect(store.imagesDir.listSync().length, before);
    });

    test('saveImage：超 10MiB 拒绝（按原始字节计，禁止截断）', () async {
      final big = Uint8List(TodoStore.maxImageBytes + 1);
      big[0] = 0x89;
      big[1] = 0x50;
      big[2] = 0x4E;
      big[3] = 0x47;
      expect(() => store.saveImage(big), throwsA(isA<ImageRejectException>()));
    });

    test('sniff 越界守卫：8-11 字节 RIFF 头不抛异常且返回 null', () {
      // 长度守卫不足时 b[8..11] 会抛 RangeError；应安全返回 null
      expect(
          TodoStore.sniffImageExtension(
              Uint8List.fromList([0x52, 0x49, 0x46, 0x46, 0, 0, 0, 0])),
          isNull);
      expect(TodoStore.sniffImageExtension(Uint8List.fromList([0x89])), isNull);
      expect(TodoStore.sniffImageExtension(Uint8List(0)), isNull);
    });

    test('sniff GIF 仅接受 GIF87a/GIF89a 全 6 字节', () {
      expect(
          TodoStore.sniffImageExtension(
              Uint8List.fromList([0x47, 0x49, 0x46, 0x38, 0x37, 0x61])),
          'gif');
      expect(
          TodoStore.sniffImageExtension(
              Uint8List.fromList([0x47, 0x49, 0x46, 0x38, 0x39, 0x61])),
          'gif');
      // GIF80a 等非标准头拒绝
      expect(
          TodoStore.sniffImageExtension(
              Uint8List.fromList([0x47, 0x49, 0x46, 0x38, 0x30, 0x61])),
          isNull);
    });
  });
}
