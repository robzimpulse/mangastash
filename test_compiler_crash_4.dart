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
  var i = 0;
  if (i < regions.length) {
     final e = regions[0] as Element;
     result.add(MangaScrapped(title: e.text));
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
