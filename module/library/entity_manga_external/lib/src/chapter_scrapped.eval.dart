// ignore_for_file: unused_import, unnecessary_import
// ignore_for_file: always_specify_types, avoid_redundant_argument_values
// ignore_for_file: sort_constructors_first
// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:dart_eval/dart_eval.dart';
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:equatable/equatable.dart';

import 'chapter_scrapped.dart';

/// dart_eval wrapper binding for [ChapterScrapped]
class $ChapterScrapped implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:entity_manga_external/src/chapter_scrapped.dart',
      'ChapterScrapped.',
      $ChapterScrapped.$new,
    );
  }

  /// Compile-time type specification of [$ChapterScrapped]
  static const $spec = BridgeTypeSpec(
    'package:entity_manga_external/src/chapter_scrapped.dart',
    'ChapterScrapped',
  );

  /// Compile-time type declaration of [$ChapterScrapped]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$ChapterScrapped]
  static const $declaration = BridgeClassDef(
    BridgeClassType(
      $type,

      $extends: BridgeTypeRef(
        BridgeTypeSpec('package:equatable/src/equatable.dart', 'Equatable'),
        [],
      ),
    ),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [
            BridgeParameter(
              'id',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'mangaId',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'title',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'volume',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'chapter',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'readableAt',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'publishAt',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'images',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.list, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                ]),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'translatedLanguage',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'scanlationGroup',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'webUrl',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'lastReadAt',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'createdAt',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'updatedAt',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              true,
            ),
          ],
          params: [],
        ),
        isFactory: false,
      ),
    },

    methods: {},
    getters: {
      'props': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.list, [
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.object, []),
                nullable: true,
              ),
            ]),
          ),
          namedParams: [],
          params: [],
        ),
      ),
    },
    setters: {},
    fields: {
      'id': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.string, []),
          nullable: true,
        ),
        isStatic: false,
      ),

      'mangaId': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.string, []),
          nullable: true,
        ),
        isStatic: false,
      ),

      'title': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.string, []),
          nullable: true,
        ),
        isStatic: false,
      ),

      'volume': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.string, []),
          nullable: true,
        ),
        isStatic: false,
      ),

      'chapter': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.string, []),
          nullable: true,
        ),
        isStatic: false,
      ),

      'readableAt': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.string, []),
          nullable: true,
        ),
        isStatic: false,
      ),

      'publishAt': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.string, []),
          nullable: true,
        ),
        isStatic: false,
      ),

      'lastReadAt': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.string, []),
          nullable: true,
        ),
        isStatic: false,
      ),

      'images': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.list, [
            BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
          ]),
          nullable: true,
        ),
        isStatic: false,
      ),

      'translatedLanguage': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.string, []),
          nullable: true,
        ),
        isStatic: false,
      ),

      'scanlationGroup': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.string, []),
          nullable: true,
        ),
        isStatic: false,
      ),

      'webUrl': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.string, []),
          nullable: true,
        ),
        isStatic: false,
      ),

      'createdAt': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.string, []),
          nullable: true,
        ),
        isStatic: false,
      ),

      'updatedAt': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.string, []),
          nullable: true,
        ),
        isStatic: false,
      ),
    },
    wrap: true,
    bridge: false,
  );

  /// Wrapper for the [ChapterScrapped.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $ChapterScrapped.wrap(
      ChapterScrapped(
        id: args[0]?.$value,
        mangaId: args[1]?.$value,
        title: args[2]?.$value,
        volume: args[3]?.$value,
        chapter: args[4]?.$value,
        readableAt: args[5]?.$value,
        publishAt: args[6]?.$value,
        images: (args[7]?.$reified as List?)?.cast(),
        translatedLanguage: args[8]?.$value,
        scanlationGroup: args[9]?.$value,
        webUrl: args[10]?.$value,
        lastReadAt: args[11]?.$value,
        createdAt: args[12]?.$value,
        updatedAt: args[13]?.$value,
      ),
    );
  }

  final $Instance _superclass;

  @override
  final ChapterScrapped $value;

  @override
  ChapterScrapped get $reified => $value;

  /// Wrap a [ChapterScrapped] in a [$ChapterScrapped]
  $ChapterScrapped.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'id':
        final _id = $value.id;
        return _id == null ? const $null() : $String(_id);

      case 'mangaId':
        final _mangaId = $value.mangaId;
        return _mangaId == null ? const $null() : $String(_mangaId);

      case 'title':
        final _title = $value.title;
        return _title == null ? const $null() : $String(_title);

      case 'volume':
        final _volume = $value.volume;
        return _volume == null ? const $null() : $String(_volume);

      case 'chapter':
        final _chapter = $value.chapter;
        return _chapter == null ? const $null() : $String(_chapter);

      case 'readableAt':
        final _readableAt = $value.readableAt;
        return _readableAt == null ? const $null() : $String(_readableAt);

      case 'publishAt':
        final _publishAt = $value.publishAt;
        return _publishAt == null ? const $null() : $String(_publishAt);

      case 'lastReadAt':
        final _lastReadAt = $value.lastReadAt;
        return _lastReadAt == null ? const $null() : $String(_lastReadAt);

      case 'images':
        final _images = $value.images;
        return _images == null
            ? const $null()
            : $List.view(_images, (e) => $String(e));

      case 'translatedLanguage':
        final _translatedLanguage = $value.translatedLanguage;
        return _translatedLanguage == null
            ? const $null()
            : $String(_translatedLanguage);

      case 'scanlationGroup':
        final _scanlationGroup = $value.scanlationGroup;
        return _scanlationGroup == null
            ? const $null()
            : $String(_scanlationGroup);

      case 'webUrl':
        final _webUrl = $value.webUrl;
        return _webUrl == null ? const $null() : $String(_webUrl);

      case 'createdAt':
        final _createdAt = $value.createdAt;
        return _createdAt == null ? const $null() : $String(_createdAt);

      case 'updatedAt':
        final _updatedAt = $value.updatedAt;
        return _updatedAt == null ? const $null() : $String(_updatedAt);

      case 'props':
        final _props = $value.props;
        return $List.view(
          _props,
          (e) => e == null ? const $null() : $Object(e),
        );
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}
