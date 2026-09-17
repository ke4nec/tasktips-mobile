/// 系统分享入口：接收其他应用分享的文字/链接，
/// 进入预填内容的新建编辑页。冷/热启动均处理，同一事件去重。
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class ShareService {
  StreamSubscription? _sub;
  void Function(String text)? _handler;
  // 待处理分享：首次引导或已有编辑会话期间不吞掉
  final List<String> _pending = [];
  // 重投递去重：同一文本在极短窗口内只创建一条
  String? _lastText;
  DateTime? _lastAt;

  /// 冷启动分享内容；读取一次后清空。结果同时作为热启动流的去重种子，
  /// 避免同一分享事件冷启动建一条、热重投递再建一条。
  Future<String?> initialSharedText() async {
    try {
      final list = await ReceiveSharingIntent.instance.getInitialMedia();
      if (list.isEmpty) return null;
      final text = list.map((m) => m.path).where((s) => s.isNotEmpty).join('\n');
      await ReceiveSharingIntent.instance.reset();
      if (text.isEmpty) return null;
      _lastText = text;
      _lastAt = DateTime.now();
      return text;
    } catch (_) {
      return null;
    }
  }

  void setHandler(void Function(String text)? handler) {
    _handler = handler;
    if (handler != null) drainPending();
  }

  void start() {
    _sub?.cancel();
    _sub = ReceiveSharingIntent.instance.getMediaStream().listen((list) {
      if (list.isEmpty) return;
      final text =
          list.map((m) => m.path).where((s) => s.isNotEmpty).join('\n');
      if (text.isEmpty) return;
      _enqueue(text);
    });
  }

  void _enqueue(String text) {
    final now = DateTime.now();
    if (_lastText == text &&
        _lastAt != null &&
        now.difference(_lastAt!) < const Duration(seconds: 3)) {
      return; // 同一分享事件重投递。
      // 已知取舍：插件不提供分享事件标识，只能按内容+时间窗判定；
      // 3 秒内两次正文完全相同的独立分享会被合并，属设计 §3 允许的边界。
    }
    _lastText = text;
    _lastAt = now;
    final h = _handler;
    if (h == null) {
      _pending.add(text); // 首次引导期间挂起，不吞掉
    } else {
      h(text);
    }
  }

  /// 按到达顺序补建挂起分享（FIFO），保证多次分享的创建时间序。
  void drainPending() {
    while (_pending.isNotEmpty) {
      final t = _pending.removeAt(0);
      _handler?.call(t);
    }
  }

  /// 挂起待处理分享（如首次引导期间）。
  void queuePending(String text) => _pending.add(text);

  @visibleForTesting
  void enqueueForTest(String text) => _enqueue(text);

  @visibleForTesting
  List<String> get pendingForTest => List.unmodifiable(_pending);

  void stop() {
    _sub?.cancel();
    _sub = null;
  }
}
