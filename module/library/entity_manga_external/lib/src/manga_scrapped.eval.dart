// ignore_for_file: unused_import, unnecessary_import
// ignore_for_file: always_specify_types, avoid_redundant_argument_values
// ignore_for_file: sort_constructors_first
// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:dart_eval/dart_eval.dart';
import 'package:dart_eval/dart_eval_bridge.dart';
import 'manga_scrapped.dart';
import 'package:equatable/equatable.dart';
import 'package:dart_eval/stdlib/core.dart';

/// dart_eval wrapper binding for [MangaScrapped]
class $MangaScrapped implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:entity_manga_external/src/manga_scrapped.dart',
      'MangaScrapped.',
      $MangaScrapped.$new,
    );
  }

  /// Compile-time type specification of [$MangaScrapped]
  static const $spec = BridgeTypeSpec(
    'package:entity_manga_external/src/manga_scrapped.dart',
    'MangaScrapped',
  );

  /// Compile-time type declaration of [$MangaScrapped]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$MangaScrapped]
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
              'coverUrl',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'author',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'status',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'description',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              true,
            ),

            BridgeParameter(
              'tags',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.list, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                ]),
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

      'stringify': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.bool, []),
            nullable: true,
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

      'title': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.string, []),
          nullable: true,
        ),
        isStatic: false,
      ),

      'coverUrl': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.string, []),
          nullable: true,
        ),
        isStatic: false,
      ),

      'author': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.string, []),
          nullable: true,
        ),
        isStatic: false,
      ),

      'status': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.string, []),
          nullable: true,
        ),
        isStatic: false,
      ),

      'description': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.string, []),
          nullable: true,
        ),
        isStatic: false,
      ),

      'tags': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.list, [
            BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
          ]),
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

  /// Wrapper for the [MangaScrapped.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $MangaScrapped.wrap(
      MangaScrapped(
        id: args[0]?.$value,
        title: args[1]?.$value,
        coverUrl: args[2]?.$value,
        author: args[3]?.$value,
        status: args[4]?.$value,
        description: args[5]?.$value,
        tags: (args[6]?.$reified as List?)?.cast(),
        webUrl: args[7]?.$value,
        createdAt: args[8]?.$value,
        updatedAt: args[9]?.$value,
      ),
    );
  }

  final $Instance _superclass;

  @override
  final MangaScrapped $value;

  @override
  MangaScrapped get $reified => $value;

  /// Wrap a [MangaScrapped] in a [$MangaScrapped]
  $MangaScrapped.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'id':
        final _id = $value.id;
        return _id == null ? const $null() : $String(_id);

      case 'title':
        final _title = $value.title;
        return _title == null ? const $null() : $String(_title);

      case 'coverUrl':
        final _coverUrl = $value.coverUrl;
        return _coverUrl == null ? const $null() : $String(_coverUrl);

      case 'author':
        final _author = $value.author;
        return _author == null ? const $null() : $String(_author);

      case 'status':
        final _status = $value.status;
        return _status == null ? const $null() : $String(_status);

      case 'description':
        final _description = $value.description;
        return _description == null ? const $null() : $String(_description);

      case 'tags':
        final _tags = $value.tags;
        return _tags == null
            ? const $null()
            : $List.view(_tags, (e) => $String(e));

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
