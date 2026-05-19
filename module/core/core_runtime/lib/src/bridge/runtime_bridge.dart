import 'package:dart_eval/dart_eval.dart';
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as parser;
import 'package:manga_dex_api/manga_dex_api.dart';
import 'entities/chapter_scrapped_bridge.dart';
import 'entities/manga_scrapped_bridge.dart';
import 'entities/tag_scrapped_bridge.dart';
import 'html/html_bridge.dart';
import 'manga_dex_api/enums_bridge.dart';
import 'manga_dex_api/search_manga_parameter_bridge.dart';

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

    registry.defineBridgeEnum($MangaStatus.$declaration);
    registry.defineBridgeEnum($ContentRating.$declaration);
    registry.defineBridgeEnum($LanguageCodes.$declaration);
    registry.defineBridgeEnum($PublicDemographic.$declaration);
    registry.defineBridgeEnum($TagsMode.$declaration);
    registry.defineBridgeEnum($SearchOrders.$declaration);
    registry.defineBridgeEnum($OrderDirections.$declaration);
    registry.defineBridgeEnum($Include.$declaration);
    registry.defineBridgeClass($SearchMangaParameter.$declaration);

    registry.defineBridgeTopLevelFunction(
      BridgeFunctionDeclaration(
        'package:html/parser.dart',
        'parse',
        const BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(BridgeTypeSpec('package:html/dom.dart', 'Document')),
          ),
          params: [
            BridgeParameter(
              'html',
              BridgeTypeAnnotation(
                BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')),
              ),
              false,
            ),
          ],
        ),
      ),
    );
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

    // MangaDex API Enums
    for (final v in MangaStatus.values) {
      runtime.registerBridgeFunc(
        'package:manga_dex_api/manga_dex_api.dart',
        'MangaStatus.${v.name}',
        (runtime, target, args) => $MangaStatus.wrap(v),
      );
    }
    for (final v in ContentRating.values) {
      runtime.registerBridgeFunc(
        'package:manga_dex_api/manga_dex_api.dart',
        'ContentRating.${v.name}',
        (runtime, target, args) => $ContentRating.wrap(v),
      );
    }
    for (final v in LanguageCodes.values) {
      runtime.registerBridgeFunc(
        'package:manga_dex_api/manga_dex_api.dart',
        'LanguageCodes.${v.name}',
        (runtime, target, args) => $LanguageCodes.wrap(v),
      );
    }
    for (final v in PublicDemographic.values) {
      runtime.registerBridgeFunc(
        'package:manga_dex_api/manga_dex_api.dart',
        'PublicDemographic.${v.name}',
        (runtime, target, args) => $PublicDemographic.wrap(v),
      );
    }
    for (final v in TagsMode.values) {
      runtime.registerBridgeFunc(
        'package:manga_dex_api/manga_dex_api.dart',
        'TagsMode.${v.name}',
        (runtime, target, args) => $TagsMode.wrap(v),
      );
    }
    for (final v in SearchOrders.values) {
      runtime.registerBridgeFunc(
        'package:manga_dex_api/manga_dex_api.dart',
        'SearchOrders.${v.name}',
        (runtime, target, args) => $SearchOrders.wrap(v),
      );
    }
    for (final v in OrderDirections.values) {
      runtime.registerBridgeFunc(
        'package:manga_dex_api/manga_dex_api.dart',
        'OrderDirections.${v.name}',
        (runtime, target, args) => $OrderDirections.wrap(v),
      );
    }
    for (final v in Include.values) {
      runtime.registerBridgeFunc(
        'package:manga_dex_api/manga_dex_api.dart',
        'Include.${v.name}',
        (runtime, target, args) => $Include.wrap(v),
      );
    }

    runtime.registerBridgeFunc('package:html/parser.dart', 'parse', (
      runtime,
      target,
      args,
    ) {
      final html = args[0]!.$value as String;
      return $Document.wrap(parser.parse(html));
    });
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

  static $Value wrap(Runtime runtime, dynamic e) {
    if (e == null) return runtime.wrap(null);
    if (e is MangaScrapped) return $MangaScrapped.wrap(e);
    if (e is ChapterScrapped) return $ChapterScrapped.wrap(e);
    if (e is TagScrapped) return $TagScrapped.wrap(e);
    if (e is Document) return $Document.wrap(e);
    if (e is Element) return $Element.wrap(e);
    if (e is SearchMangaParameter) return $SearchMangaParameter.wrap(e);
    if (e is MangaStatus) return $MangaStatus.wrap(e);
    if (e is ContentRating) return $ContentRating.wrap(e);
    if (e is LanguageCodes) return $LanguageCodes.wrap(e);
    if (e is PublicDemographic) return $PublicDemographic.wrap(e);
    if (e is TagsMode) return $TagsMode.wrap(e);
    if (e is SearchOrders) return $SearchOrders.wrap(e);
    if (e is OrderDirections) return $OrderDirections.wrap(e);
    if (e is Include) return $Include.wrap(e);
    return runtime.wrap(e);
  }
}
