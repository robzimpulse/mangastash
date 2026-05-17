import 'package:dart_eval/dart_eval.dart';
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:html/parser.dart' as parser;
import 'entities/chapter_scrapped_bridge.dart';
import 'entities/manga_scrapped_bridge.dart';
import 'entities/tag_scrapped_bridge.dart';
import 'html/html_bridge.dart';

class RuntimePlugin implements EvalPlugin {
  @override
  String get identifier => 'mangastash_runtime';

  @override
  void configureForCompile(BridgeDeclarationRegistry registry) {
    registry.defineBridgeClass($TagScrapped.$declaration);
    registry.defineBridgeClass($MangaScrapped.$declaration);
    registry.defineBridgeClass($ChapterScrapped.$declaration);
    registry.defineBridgeClass($Document.$declaration);
    registry.defineBridgeClass($Element.$declaration);

    registry.defineBridgeTopLevelFunction(BridgeFunctionDeclaration(
      'package:html/parser.dart',
      'parse',
      const BridgeFunctionDef(
        returns: BridgeTypeAnnotation(BridgeTypeRef(BridgeTypeSpec('package:html/dom.dart', 'Document'))),
        params: [
          BridgeParameter('html', BridgeTypeAnnotation(BridgeTypeRef(BridgeTypeSpec('dart:core', 'String'))), false),
        ],
      ),
    ));
  }

  @override
  void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:entity_manga_external/src/tag_scrapped.dart',
      'TagScrapped.',
      $TagScrapped.$new,
    );
    runtime.registerBridgeFunc(
      'package:entity_manga_external/src/manga_scrapped.dart',
      'MangaScrapped.',
      $MangaScrapped.$new,
    );
    runtime.registerBridgeFunc(
      'package:entity_manga_external/src/chapter_scrapped.dart',
      'ChapterScrapped.',
      $ChapterScrapped.$new,
    );

    runtime.registerBridgeFunc(
      'package:html/parser.dart',
      'parse',
      (runtime, target, args) {
        final html = args[0]!.$value as String;
        return $Document.wrap(parser.parse(html));
      },
    );
  }
}

class RuntimeBridge {
  static final plugin = RuntimePlugin();

  static void register(Compiler compiler) {
    compiler.addPlugin(plugin);
  }

  static void configure(Runtime runtime) {
    runtime.addPlugin(plugin);
  }
}
