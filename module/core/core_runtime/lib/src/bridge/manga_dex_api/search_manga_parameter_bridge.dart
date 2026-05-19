import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

class $SearchMangaParameter extends $Value implements $Instance {
  static const $type = BridgeTypeRef(
    BridgeTypeSpec(
      'package:manga_dex_api/manga_dex_api.dart',
      'SearchMangaParameter',
    ),
  );

  static const $declaration = BridgeClassDef(
    BridgeClassType($type),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [],
        ),
      ),
    },
    fields: {
      'title': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')),
          nullable: true,
        ),
      ),
      'limit': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(BridgeTypeSpec('dart:core', 'int')),
          nullable: true,
        ),
      ),
      'offset': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(BridgeTypeSpec('dart:core', 'int')),
          nullable: true,
        ),
      ),
      'page': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(BridgeTypeSpec('dart:core', 'int')),
          nullable: true,
        ),
      ),
      'includedTags': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.list, [
            BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')),
          ]),
          nullable: true,
        ),
      ),
      'status': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.list, [
            BridgeTypeRef(
              BridgeTypeSpec('package:manga_dex_api/manga_dex_api.dart', 'MangaStatus'),
            ),
          ]),
          nullable: true,
        ),
      ),
      'contentRating': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.list, [
            BridgeTypeRef(
              BridgeTypeSpec('package:manga_dex_api/manga_dex_api.dart', 'ContentRating'),
            ),
          ]),
          nullable: true,
        ),
      ),
      'publicationDemographic': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.list, [
            BridgeTypeRef(
              BridgeTypeSpec('package:manga_dex_api/manga_dex_api.dart', 'PublicDemographic'),
            ),
          ]),
          nullable: true,
        ),
      ),
      'orders': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.map, [
            BridgeTypeRef(
              BridgeTypeSpec('package:manga_dex_api/manga_dex_api.dart', 'SearchOrders'),
            ),
            BridgeTypeRef(
              BridgeTypeSpec('package:manga_dex_api/manga_dex_api.dart', 'OrderDirections'),
            ),
          ]),
          nullable: true,
        ),
      ),
      'includedTagsMode': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(
            BridgeTypeSpec(
              'package:manga_dex_api/manga_dex_api.dart',
              'TagsMode',
            ),
          ),
        ),
      ),
      'authors': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.list, [
            BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')),
          ]),
          nullable: true,
        ),
      ),
      'artists': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.list, [
            BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')),
          ]),
          nullable: true,
        ),
      ),
      'year': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(BridgeTypeSpec('dart:core', 'int')),
          nullable: true,
        ),
      ),
    },
    wrap: true,
  );

  $SearchMangaParameter.wrap(this.value) : _superclass = $Object(value);

  final SearchMangaParameter value;

  final $Instance _superclass;

  @override
  SearchMangaParameter get $value => value;

  @override
  SearchMangaParameter get $reified => value;

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'title':
        return runtime.wrap(value.title);
      case 'limit':
        return runtime.wrap(value.limit);
      case 'offset':
        return runtime.wrap(value.offset);
      case 'page':
        return runtime.wrap(value.page);
      case 'includedTags':
        return runtime.wrap(value.includedTags);
      case 'status':
        return runtime.wrap(value.status);
      case 'contentRating':
        return runtime.wrap(value.contentRating);
      case 'publicationDemographic':
        return runtime.wrap(value.publicationDemographic);
      case 'orders':
        return runtime.wrap(value.orders);
      case 'includedTagsMode':
        return runtime.wrap(value.includedTagsMode);
      case 'authors':
        return runtime.wrap(value.authors);
      case 'artists':
        return runtime.wrap(value.artists);
      case 'year':
        return runtime.wrap(value.year);
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    _superclass.$setProperty(runtime, identifier, value);
  }

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($type.spec!);
}
