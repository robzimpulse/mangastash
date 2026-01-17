import 'package:dart_eval/dart_eval_bridge.dart';
import 'src/html_document.eval.dart';
import 'src/chapter_scrapped.eval.dart';
import 'src/manga_scrapped.eval.dart';

/// [EvalPlugin] for entity_manga_external
class EntityMangaExternalPlugin implements EvalPlugin {
  @override
  String get identifier => 'package:entity_manga_external';

  @override
  void configureForCompile(BridgeDeclarationRegistry registry) {
    registry.defineBridgeClass($HtmlDocument.$declaration);
    registry.defineBridgeClass($ChapterScrapped.$declaration);
    registry.defineBridgeClass($MangaScrapped.$declaration);
  }

  @override
  void configureForRuntime(Runtime runtime) {
    $HtmlDocument.configureForRuntime(runtime);
    $ChapterScrapped.configureForRuntime(runtime);
    $MangaScrapped.configureForRuntime(runtime);
  }
}
