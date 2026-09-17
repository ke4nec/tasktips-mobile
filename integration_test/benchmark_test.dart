/// Release 基准（真机，1000 条数据集）：冷启动加载 / 搜索查询 / 首帧与滚动。
///
/// 运行（连接真机）：
///
/// ```sh
/// flutter run integration_test/benchmark_test.dart -d <device-id> --release
/// adb logcat | grep BENCH
/// ```
///
/// 判定：只认 release 真机数值（debug/模拟器结论无效），实际值记入
/// docs/manual-test-matrix.md §0。跑完后卸载 App，避免种子数据污染日常使用。
/// 本文件只读写真机应用目录，不改 lib/ 生产代码。
library;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tasktips/app/app_model.dart';
import 'package:tasktips/domain/query.dart';
import 'package:tasktips/domain/todo.dart';
import 'package:tasktips/infra/store.dart';
import 'package:tasktips/ui/app.dart';

const _targetCount = 1000;

Future<void> _seed(TodoStore store, int missing) async {
  final rnd = Random(42);
  const words = ['需求', '评审', '联调', '回归', '发布', '复盘', '周报', '修障', '设计', '走查'];
  const tags = ['工作', '生活', '灵感', '待办'];
  for (var i = 0; i < missing; i++) {
    final now = DateTime.now().toUtc().subtract(Duration(minutes: i));
    final dueRoll = rnd.nextInt(5);
    final due = dueRoll == 0
        ? null
        : '2026-09-${(10 + rnd.nextInt(20)).toString().padLeft(2, '0')}';
    final body = dueRoll == 4
        ? '# ${words[i % words.length]}-$i\n```dart\nfinal x = $i;\n```\n正文 $i'
        : '# ${words[i % words.length]}-$i\n正文第 $i 条，含关键词回归测试';
    final t = Todo(
      id: 'BENCH${i.toString().padLeft(6, '0')}',
      title: '',
      body: body,
      priority: i % 4,
      tags: rnd.nextBool() ? [tags[i % tags.length]] : [],
      dueDate: due,
      createdAt: now,
      updatedAt: now,
      revision: 1 + (i % 3),
      deviceId: 'bench',
    );
    t.title = deriveTitle(t.body);
    await store.saveTodo(t);
  }
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('release 基准：1000 条冷启动/搜索/首帧滚动', (tester) async {
    binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

    final dir = await getApplicationSupportDirectory();
    final store = TodoStore(dir);
    await store.init();
    final scan = await store.scanTodos();
    if (scan.todos.length < _targetCount) {
      await _seed(store, _targetCount - scan.todos.length);
    }

    // 1. 冷启动加载（含全量扫描解析）
    var sw = Stopwatch()..start();
    final model = AppModel(store);
    await model.load();
    sw.stop();
    final loadMs = sw.elapsedMilliseconds;
    debugPrint('BENCH load_ms=$loadMs todos=${model.todos.length}');
    expect(model.todos.length, greaterThanOrEqualTo(_targetCount));
    expect(loadMs, lessThan(5000), reason: '冷启动加载回归');

    // 2. 搜索查询（100 次平均，含围栏内容剥离路径）
    const rounds = 100;
    sw = Stopwatch()..start();
    for (var i = 0; i < rounds; i++) {
      runQuery(model.todos, TodoQuery(view: TodoView.all, search: '回归'),
          today: model.today);
    }
    sw.stop();
    final queryAvgMs = sw.elapsedMilliseconds / rounds;
    debugPrint('BENCH query_avg_ms=$queryAvgMs');
    expect(queryAvgMs, lessThan(100), reason: '搜索查询回归');

    // 3. 首帧 + 列表滚动
    sw = Stopwatch()..start();
    await tester.pumpWidget(TaskTipsApp(model: model));
    await tester.pumpAndSettle();
    sw.stop();
    final pumpMs = sw.elapsedMilliseconds;
    debugPrint('BENCH first_frame_ms=$pumpMs');
    expect(pumpMs, lessThan(5000), reason: '首帧回归');

    final scrollable = find.byType(Scrollable).first;
    sw = Stopwatch()..start();
    await tester.drag(scrollable, const Offset(0, -3000));
    await tester.pumpAndSettle();
    sw.stop();
    debugPrint('BENCH scroll_settle_ms=${sw.elapsedMilliseconds}');
  });
}
