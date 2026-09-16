import 'package:flutter_test/flutter_test.dart';
import 'package:tasktips/domain/todo.dart';

void main() {
  testWidgets('deriveTitle 剥离 Markdown 标记', (tester) async {
    expect(deriveTitle('# 标题行\n正文'), '标题行');
    expect(deriveTitle('- [ ] 任务项\n其他'), '任务项');
    expect(deriveTitle('---\n\n**强调**正文'), '强调正文');
    expect(deriveTitle('\n\n   \n唯一'), '唯一');
    expect(deriveTitle(''), '');
  });

  testWidgets('deriveTitle 按码点截断', (tester) async {
    final t = deriveTitle('a' * 100);
    expect(t.runes.length, 80);
    expect(t.endsWith('…'), isTrue);
  });

  testWidgets('空正文返回空标题', (tester) async {
    expect(deriveTitle('#\n##\n'), '');
  });
}
