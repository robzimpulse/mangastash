import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:entity_manga_external/entity_manga_external.dart';

class $MangaScrapped extends $Value implements $Instance {
  static const $type = BridgeTypeRef(
    BridgeTypeSpec('package:entity_manga_external/src/manga_scrapped.dart', 'MangaScrapped'),
  );

  static const $declaration = BridgeClassDef(
    BridgeClassType($type),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [
            BridgeParameter('id', BridgeTypeAnnotation(BridgeTypeRef(BridgeTypeSpec('dart:core', 'String'))), true),
            BridgeParameter('title', BridgeTypeAnnotation(BridgeTypeRef(BridgeTypeSpec('dart:core', 'String'))), true),
            BridgeParameter('coverUrl', BridgeTypeAnnotation(BridgeTypeRef(BridgeTypeSpec('dart:core', 'String'))), true),
            BridgeParameter('author', BridgeTypeAnnotation(BridgeTypeRef(BridgeTypeSpec('dart:core', 'String'))), true),
            BridgeParameter('status', BridgeTypeAnnotation(BridgeTypeRef(BridgeTypeSpec('dart:core', 'String'))), true),
            BridgeParameter('description', BridgeTypeAnnotation(BridgeTypeRef(BridgeTypeSpec('dart:core', 'String'))), true),
            BridgeParameter('tags', BridgeTypeAnnotation(BridgeTypeRef(BridgeTypeSpec('dart:core', 'List'))), true),
            BridgeParameter('webUrl', BridgeTypeAnnotation(BridgeTypeRef(BridgeTypeSpec('dart:core', 'String'))), true),
            BridgeParameter('createdAt', BridgeTypeAnnotation(BridgeTypeRef(BridgeTypeSpec('dart:core', 'String'))), true),
            BridgeParameter('updatedAt', BridgeTypeAnnotation(BridgeTypeRef(BridgeTypeSpec('dart:core', 'String'))), true),
          ],
        ),
      ),
    },
    fields: {
      'id': BridgeFieldDef(BridgeTypeAnnotation(BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')), nullable: true)),
      'title': BridgeFieldDef(BridgeTypeAnnotation(BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')), nullable: true)),
      'coverUrl': BridgeFieldDef(BridgeTypeAnnotation(BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')), nullable: true)),
      'author': BridgeFieldDef(BridgeTypeAnnotation(BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')), nullable: true)),
      'status': BridgeFieldDef(BridgeTypeAnnotation(BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')), nullable: true)),
      'description': BridgeFieldDef(BridgeTypeAnnotation(BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')), nullable: true)),
      'tags': BridgeFieldDef(BridgeTypeAnnotation(BridgeTypeRef(BridgeTypeSpec('dart:core', 'List')), nullable: true)),
      'webUrl': BridgeFieldDef(BridgeTypeAnnotation(BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')), nullable: true)),
      'createdAt': BridgeFieldDef(BridgeTypeAnnotation(BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')), nullable: true)),
      'updatedAt': BridgeFieldDef(BridgeTypeAnnotation(BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')), nullable: true)),
    },
    wrap: true,
  );

  $MangaScrapped.wrap(this.value) : _superclass = $Object(value);

  final MangaScrapped value;

  final $Instance _superclass;

  @override
  MangaScrapped get $value => value;

  @override
  MangaScrapped get $reified => value;

  static $Value $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $MangaScrapped.wrap(MangaScrapped(
      id: args[0]?.$value,
      title: args[1]?.$value,
      coverUrl: args[2]?.$value,
      author: args[3]?.$value,
      status: args[4]?.$value,
      description: args[5]?.$value,
      tags: (args[6]?.$value as List?)?.cast<String>(),
      webUrl: args[7]?.$value,
      createdAt: args[8]?.$value,
      updatedAt: args[9]?.$value,
    ));
  }

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'id':
        return runtime.wrap(value.id);
      case 'title':
        return runtime.wrap(value.title);
      case 'coverUrl':
        return runtime.wrap(value.coverUrl);
      case 'author':
        return runtime.wrap(value.author);
      case 'status':
        return runtime.wrap(value.status);
      case 'description':
        return runtime.wrap(value.description);
      case 'tags':
        return runtime.wrap(value.tags);
      case 'webUrl':
        return runtime.wrap(value.webUrl);
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
