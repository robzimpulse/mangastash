import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:entity_manga_external/entity_manga_external.dart';

class $ChapterScrapped extends $Value implements $Instance {
  static const $type = BridgeTypeRef(
    BridgeTypeSpec(
      'package:entity_manga_external/src/chapter_scrapped.dart',
      'ChapterScrapped',
    ),
  );

  static const $declaration = BridgeClassDef(
    BridgeClassType($type),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [
            BridgeParameter(
              'id',
              BridgeTypeAnnotation(
                BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')),
              ),
              true,
            ),
            BridgeParameter(
              'mangaId',
              BridgeTypeAnnotation(
                BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')),
              ),
              true,
            ),
            BridgeParameter(
              'title',
              BridgeTypeAnnotation(
                BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')),
              ),
              true,
            ),
            BridgeParameter(
              'volume',
              BridgeTypeAnnotation(
                BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')),
              ),
              true,
            ),
            BridgeParameter(
              'chapter',
              BridgeTypeAnnotation(
                BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')),
              ),
              true,
            ),
            BridgeParameter(
              'readableAt',
              BridgeTypeAnnotation(
                BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')),
              ),
              true,
            ),
            BridgeParameter(
              'publishAt',
              BridgeTypeAnnotation(
                BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')),
              ),
              true,
            ),
            BridgeParameter(
              'images',
              BridgeTypeAnnotation(
                BridgeTypeRef(BridgeTypeSpec('dart:core', 'List')),
              ),
              true,
            ),
            BridgeParameter(
              'translatedLanguage',
              BridgeTypeAnnotation(
                BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')),
              ),
              true,
            ),
            BridgeParameter(
              'scanlationGroup',
              BridgeTypeAnnotation(
                BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')),
              ),
              true,
            ),
            BridgeParameter(
              'webUrl',
              BridgeTypeAnnotation(
                BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')),
              ),
              true,
            ),
            BridgeParameter(
              'lastReadAt',
              BridgeTypeAnnotation(
                BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')),
              ),
              true,
            ),
            BridgeParameter(
              'createdAt',
              BridgeTypeAnnotation(
                BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')),
              ),
              true,
            ),
            BridgeParameter(
              'updatedAt',
              BridgeTypeAnnotation(
                BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')),
              ),
              true,
            ),
          ],
        ),
      ),
    },
    fields: {
      'id': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')),
          nullable: true,
        ),
      ),
      'mangaId': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')),
          nullable: true,
        ),
      ),
      'title': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')),
          nullable: true,
        ),
      ),
      'volume': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')),
          nullable: true,
        ),
      ),
      'chapter': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')),
          nullable: true,
        ),
      ),
      'readableAt': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')),
          nullable: true,
        ),
      ),
      'publishAt': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')),
          nullable: true,
        ),
      ),
      'images': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(BridgeTypeSpec('dart:core', 'List')),
          nullable: true,
        ),
      ),
      'translatedLanguage': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')),
          nullable: true,
        ),
      ),
      'scanlationGroup': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')),
          nullable: true,
        ),
      ),
      'webUrl': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')),
          nullable: true,
        ),
      ),
      'lastReadAt': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')),
          nullable: true,
        ),
      ),
      'createdAt': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')),
          nullable: true,
        ),
      ),
      'updatedAt': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')),
          nullable: true,
        ),
      ),
    },
    wrap: true,
  );

  $ChapterScrapped.wrap(this.value) : _superclass = $Object(value);

  final ChapterScrapped value;

  final $Instance _superclass;

  @override
  ChapterScrapped get $value => value;

  @override
  ChapterScrapped get $reified => value;

  static $Value $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $ChapterScrapped.wrap(
      ChapterScrapped(
        id: args[0]?.$value,
        mangaId: args[1]?.$value,
        title: args[2]?.$value,
        volume: args[3]?.$value,
        chapter: args[4]?.$value,
        readableAt: args[5]?.$value,
        publishAt: args[6]?.$value,
        images: (args[7]?.$value as List?)?.cast<String>(),
        translatedLanguage: args[8]?.$value,
        scanlationGroup: args[9]?.$value,
        webUrl: args[10]?.$value,
        lastReadAt: args[11]?.$value,
        createdAt: args[12]?.$value,
        updatedAt: args[13]?.$value,
      ),
    );
  }

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'id':
        return runtime.wrap(value.id);
      case 'mangaId':
        return runtime.wrap(value.mangaId);
      case 'title':
        return runtime.wrap(value.title);
      case 'volume':
        return runtime.wrap(value.volume);
      case 'chapter':
        return runtime.wrap(value.chapter);
      case 'readableAt':
        return runtime.wrap(value.readableAt);
      case 'publishAt':
        return runtime.wrap(value.publishAt);
      case 'images':
        return runtime.wrap(value.images);
      case 'translatedLanguage':
        return runtime.wrap(value.translatedLanguage);
      case 'scanlationGroup':
        return runtime.wrap(value.scanlationGroup);
      case 'webUrl':
        return runtime.wrap(value.webUrl);
      case 'lastReadAt':
        return runtime.wrap(value.lastReadAt);
      case 'createdAt':
        return runtime.wrap(value.createdAt);
      case 'updatedAt':
        return runtime.wrap(value.updatedAt);
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
