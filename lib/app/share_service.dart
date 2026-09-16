/// 系统分享入口：接收其他应用分享的文字/链接，
/// 进入预填内容的新建编辑页。冷/热启动均处理，同一事件去重。
library;

import 'dart:async';

import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class ShareService {
  StreamSubscription? _sub;
  void Function(String text)? _handler;
  // 待处理分享：首次引导或已有编辑会话期间不吞掉
  final List<String> _pending = [];
  // 重投递去重：同一文本在极短窗口内只创建一条
  String? _lastText;
  DateTime? _lastAt;

  /// 冷启动分享内容；读取一次后清空。
  Future<String?> initialSharedText() async {
    try {
      final list = await ReceiveSharingIntent.instance.getInitialMedia();
      if (list.isEmpty) return null;
      final text = list.map((m) => m.path).where((s) => s.isNotEmpty).join('\n');
      await ReceiveSharingIntent.instance.reset();
      return text.isEmpty ? null : text;
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
      return; // 同一分享事件重投递
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

  void drainPending() {
    while (_pending.isNotEmpty) {
      final t = _pending.removeLast();
      _handler?.call(t);
    }
  }

  /// 挂起待处理分享（如首次引导期间）。
  void queuePending(String text) => _pending.add(text);

  void stop() {
    _sub?.cancel();
    _sub = null;
  }
}
