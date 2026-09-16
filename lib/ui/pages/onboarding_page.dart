import 'package:flutter/material.dart';

import '../../app/app_model.dart';
import '../theme.dart';

/// 首次启动引导：简短介绍本地保存与离线使用，无需登录即可开始。
class OnboardingPage extends StatelessWidget {
  final AppModel model;
  const OnboardingPage({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final a = appColors(context, Theme.of(context).brightness);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              Icon(Icons.edit_note, size: 64, color: a.brand),
              const SizedBox(height: 24),
              Text('随手记录，聚焦今日',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Text(
                'TaskTips 把待办保存为本机 Markdown 文件，离线也能使用。'
                '之后可以从设置连接服务端，与桌面端接续编辑。',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: a.muted, height: 1.6),
              ),
              const Spacer(flex: 3),
              FilledButton(
                onPressed: model.completeOnboarding,
                style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48)),
                child: const Text('开始使用'),
              ),
              const SizedBox(height: 8),
              Text(
                '无需登录，数据默认只保存在本机',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: a.muted),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
