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

  testWidgets('标记行跳过与空正文返回空标题', (tester) async {
    // 与桌面 markdown.ts 一致：裸 #（井号后无空格）不是 ATX 标题，保留为文本
    expect(deriveTitle('#\n##\n'), '#');
    expect(deriveTitle(''), '');
    expect(deriveTitle('---\n***\n'), '');
  });
}
