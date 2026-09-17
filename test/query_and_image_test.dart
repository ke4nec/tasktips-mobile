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
  });
}
