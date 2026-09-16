import 'package:flutter/material.dart';

import '../../app/app_model.dart';
import '../theme.dart';

/// 首次启动引导（设计稿 onboardingPage）：欢迎语 + 三条特性 + 开始记录，
/// 支持“跳过”（与开始等效完成引导）。
class OnboardingPage extends StatelessWidget {
  final AppModel model;
  const OnboardingPage({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final a = appColors(context, Theme.of(context).brightness);
    Widget feature(IconData icon, String text) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: a.brandInk),
            const SizedBox(width: 12),
            Text(text, style: TextStyle(fontSize: 15, color: a.text)),
          ],
        );
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: model.completeOnboarding,
            child: const Text('跳过'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // 设计稿 .app-symbol：brand-container 圆形图标
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: a.brandContainer,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Icon(Icons.checklist, size: 40, color: a.brandInk),
                ),
              ),
              const SizedBox(height: 24),
              const Text('把想法记下来，\n把事情做好。',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 24,
                      height: 1.5,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Text('一个轻巧的待办空间，\n装下工作、生活和随手的灵感。',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: a.muted, height: 1.6)),
              const SizedBox(height: 28),
              feature(Icons.edit_outlined, '直接写下内容，自动保存'),
              const SizedBox(height: 12),
              feature(Icons.folder_outlined, '用目录和标签整理'),
              const SizedBox(height: 12),
              feature(Icons.lock_outline, '离线可用，数据保存在本机'),
              const Spacer(),
              FilledButton(
                onPressed: model.completeOnboarding,
                style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48)),
                child: const Text('开始记录'),
              ),
              const SizedBox(height: 8),
              Text('无需登录 · 可稍后在设置中连接同步',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: a.muted)),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
