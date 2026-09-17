/// 系统分享去重与挂起顺序测试（不触碰平台通道，只走纯 Dart 路径）。
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:tasktips/app/share_service.dart';

void main() {
  group('分享去重与挂起', () {
    test('挂起分享按到达顺序补建（FIFO）', () {
      final svc = ShareService();
      final got = <String>[];
      svc.enqueueForTest('第一条');
      svc.enqueueForTest('第二条');
      expect(svc.pendingForTest, ['第一条', '第二条']);
      svc.setHandler(got.add);
      expect(got, ['第一条', '第二条']);
    });

    test('同一文本 3 秒内重投递只建一条', () {
      final svc = ShareService();
      final got = <String>[];
      svc.setHandler(got.add);
      svc.enqueueForTest('相同内容');
      svc.enqueueForTest('相同内容');
      expect(got, ['相同内容']);
    });

    test('不同文本各自建一条；引导期挂起不吞掉', () {
      final svc = ShareService();
      svc.queuePending('引导期分享');
      expect(svc.pendingForTest, ['引导期分享']);
      final got = <String>[];
      svc.setHandler(got.add);
      expect(got, ['引导期分享']);
      svc.enqueueForTest('另一条不同内容');
      expect(got, ['引导期分享', '另一条不同内容']);
    });
  });
}
