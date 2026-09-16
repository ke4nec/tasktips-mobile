import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:tasktips/app/app_model.dart';
import 'package:tasktips/domain/classification.dart';
import 'package:tasktips/infra/store.dart';

/// 桌面端（schemaVersion 3）生成的 classification.json 夹具：
/// 含 icon/description/orderIndex/isSystem 全字段、未知字段、
/// 无小数秒时间戳、hex 色板与“其他”分组。
const desktopFixture = '''{
  "schemaVersion": 3,
  "categories": [
    {
      "id": "01J5MZ6K6AC2F4Y17D8Q1T8PXP",
      "name": "工作",
      "parentId": null,
      "color": "#4a9eff",
      "icon": "",
      "description": "",
      "orderIndex": 0,
      "createdAt": "2026-08-18T01:00:00Z",
      "updatedAt": "2026-08-18T01:10:00.123456789Z",
      "customCategoryField": true
    }
  ],
  "tags": [
    {
      "id": "01J5MZ6K6AC2F4Y17D8Q1T8PXA",
      "name": "设计",
      "color": "#a78bfa",
      "icon": "",
      "description": "桌面创建",
      "isSystem": false,
      "group": "其他",
      "createdAt": "2026-08-18T01:00:00Z",
      "updatedAt": "2026-08-18T01:00:00Z"
    }
  ],
  "futureTopLevel": {"x": 1}
}''';

void main() {
  test('桌面夹具读入后只读保存：逐字节等价', () async {
    final dir = await Directory.systemTemp.createTemp('cls_compat');
    addTearDown(() => dir.delete(recursive: true));
    final store = TodoStore(dir);
    await store.init();
    await File('${store.contentDir.path}/classification.json')
        .writeAsString(desktopFixture);

    final model = AppModel(store);
    await model.load();
    // 只读：不做任何修改，重新保存
    await store.saveClassification(model.classification);
    final after = await File('${store.contentDir.path}/classification.json')
        .readAsString();
    expect(after, desktopFixture);
  });

  test('解析保留未知字段与非毫秒时间戳', () {
    final c = Classification.fromJson(
        (jsonDecode(desktopFixture) as Map).cast<String, Object?>(),
        raw: desktopFixture);
    expect(c.schemaVersion, 3);
    expect(c.categories.single.extra['customCategoryField'], true);
    expect(c.fileExtra['futureTopLevel'], isNotNull);
    expect(c.categories.single.updatedAt, '2026-08-18T01:10:00.123456789Z');
    expect(c.tags.single.group, '其他');
    expect(c.tags.single.color, '#a78bfa');
  });

  test('移动端新建实体序列化含桌面必填字段', () {
    final c = Classification([Category(id: 'x', name: '工作')], []);
    final j = (c.toJson()['categories'] as List).single as Map<String, Object?>;
    expect(j.keys.toList(), [
      'id', 'name', 'parentId', 'color', 'icon', 'description',
      'orderIndex', 'createdAt', 'updatedAt',
    ]);
    expect(j['color'], kDefaultColor);
    expect(j['orderIndex'], 0);
    expect((j['createdAt'] as String).endsWith('Z'), isTrue);
    // deletedAt null 时省略（对齐桌面 skip_serializing_if）
    expect(j.containsKey('deletedAt'), isFalse);
    final t = (Classification([], [Tag(id: 't', name: '甲')]).toJson()['tags']
        as List).single as Map<String, Object?>;
    expect(t['isSystem'], false);
    expect(t['group'], '其他'); // 空串归一
    expect(t.containsKey('deletedAt'), isFalse);
  });

  test('旧 v1 文件（语义色键、缺时间戳）迁移不视为损坏', () {
    const v1 = '''{
  "schemaVersion": 1,
  "categories": [
    {"id": "c1", "name": "工作", "parentId": null, "color": "blue"}
  ],
  "tags": [
    {"id": "t1", "name": "甲", "color": "purple", "group": ""}
  ]
}''';
    final c = Classification.fromJson(
        (jsonDecode(v1) as Map).cast<String, Object?>());
    expect(c.schemaVersion, 1);
    expect(c.categories.single.color, '#4a9eff'); // 语义键 → 色板 hex
    expect(c.tags.single.color, '#a78bfa');
    expect(c.categories.single.createdAt, isNotEmpty); // 补默认时间戳
    // 序列化升级为 schemaVersion 3
    expect((c.toJson()['schemaVersion'] as int), 3);
  });

  test('超出支持的 schemaVersion 拒绝解析', () {
    expect(
        () => Classification.fromJson({
              'schemaVersion': 4,
              'categories': [],
              'tags': [],
            }),
        throwsFormatException);
  });

  test('修改后保存产生新字节并清除 dirty', () async {
    final dir = await Directory.systemTemp.createTemp('cls_dirty');
    addTearDown(() => dir.delete(recursive: true));
    final store = TodoStore(dir);
    await store.init();
    final model = AppModel(store);
    await model.load();
    await model.createCategory('新目录');
    final raw =
        await File('${store.contentDir.path}/classification.json').readAsString();
    expect(raw.contains('"新目录"'), isTrue);
    expect(raw.contains('"schemaVersion": 3'), isTrue);
    expect(model.classification.dirty, isFalse); // 保存后清除
  });
}
