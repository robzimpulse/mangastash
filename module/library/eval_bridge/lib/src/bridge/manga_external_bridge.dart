import 'package:dart_eval/dart_eval.dart';
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:entity_manga_external/entity_manga_external.dart';

class $MangaScrapped implements $Value {
  static const $type = BridgeTypeRef(BridgeTypeSpec('package:entity_manga_external/entity_manga_external.dart', 'MangaScrapped'));
  static const $declaration = BridgeClassDef(
    BridgeClassType($type),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          params: [],
          namedParams: [
            BridgeParameter('title', BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)), true),
            BridgeParameter('author', BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)), true),
            BridgeParameter('description', BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)), true),
            BridgeParameter('coverUrl', BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)), true),
            BridgeParameter('webUrl', BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)), true),
            BridgeParameter('status', BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)), true),
            BridgeParameter('tags', BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.list, [BridgeTypeRef(CoreTypes.string)])), true),
          ],
        ),
      ),
    },
    wrap: true,
  );

  $MangaScrapped.wrap(this.$value) : super();

  @override
  final MangaScrapped $value;

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'title':
        return $value.title == null ? const $null() : $String($value.title!);
      case 'webUrl':
        return $value.webUrl == null ? const $null() : $String($value.webUrl!);
    }
    throw UnimplementedError();
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    throw UnimplementedError();
  }

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($type.spec!);

  @override
  get $reified => $value;

  static $Value? $new(Runtime runtime, $Value? target, List<$Value?> args) {
    return $MangaScrapped.wrap(MangaScrapped(
      title: args[0]?.$value as String?,
      author: args[1]?.$value as String?,
      description: args[2]?.$value as String?,
      coverUrl: args[3]?.$value as String?,
      webUrl: args[4]?.$value as String?,
      status: args[5]?.$value as String?,
      tags: (args[6]?.$value as List?)?.cast<String>(),
    ));
  }
}
