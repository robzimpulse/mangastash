import 'dart:io';
import 'package:eval_bridge/eval_bridge.dart';
import 'package:html/dom.dart';

void main() {
  final source = '''
import 'package:html/dom.dart';
import 'package:entity_manga_external/entity_manga_external.dart';

List<MangaScrapped> parseSearch(Document root) {
  final List regions = root.querySelectorAll('div.series-card');
  final List<MangaScrapped> result = [];
  for (var i = 0, len = regions.length; i < len; i++) {
    result.add(MangaScrapped(title: 'item'));
  }
  return result;
}
''';

  try {
    print('Compiling...');
    EvalBridge.compile(source);
    print('Compilation successful!');
  } catch (e, stack) {
    print('Compilation failed: $e');
    print(stack);
  }
}
