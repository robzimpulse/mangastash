import 'package:dart_eval/dart_eval.dart';
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:entity_manga_external/entity_manga_external.dart';

class $TagScrapped extends $Value implements $Instance {
  static const $type = BridgeTypeRef(
    BridgeTypeSpec('package:entity_manga_external/src/tag_scrapped.dart', 'TagScrapped'),
  );

  static const $declaration = BridgeClassDef(
    BridgeClassType($type),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [
            BridgeParameter('id', BridgeTypeAnnotation(BridgeTypeRef(BridgeTypeSpec('dart:core', 'String'))), true),
            BridgeParameter('name', BridgeTypeAnnotation(BridgeTypeRef(BridgeTypeSpec('dart:core', 'String'))), true),
          ],
        ),
      ),
    },
    fields: {
      'id': BridgeFieldDef(BridgeTypeAnnotation(BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')), nullable: true)),
      'name': BridgeFieldDef(BridgeTypeAnnotation(BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')), nullable: true)),
    },
    wrap: true,
  );

  $TagScrapped.wrap(this.value) : _superclass = $Object(value);

  @override
  final TagScrapped value;

  final $Instance _superclass;

  @override
  TagScrapped get $value => value;

  @override
  TagScrapped get $reified => value;

  static $Value $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $TagScrapped.wrap(TagScrapped(
      id: args[0]?.$value,
      name: args[1]?.$value,
    ));
  }

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'id':
        return runtime.wrap(value.id);
      case 'name':
        return runtime.wrap(value.name);
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
