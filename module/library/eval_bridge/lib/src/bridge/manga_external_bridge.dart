import 'package:dart_eval/dart_eval.dart';
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:entity_manga_external/entity_manga_external.dart';

class $MangaScrapped implements $Instance {
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
      case 'coverUrl':
        return $value.coverUrl == null ? const $null() : $String($value.coverUrl!);
      case 'status':
        return $value.status == null ? const $null() : $String($value.status!);
      case 'author':
        return $value.author == null ? const $null() : $String($value.author!);
      case 'description':
        return $value.description == null ? const $null() : $String($value.description!);
      case 'tags':
        return $value.tags == null ? const $null() : $List.wrap($value.tags!.map((e) => $String(e)).toList());
    }
    return null;
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

class $ChapterScrapped implements $Instance {
  static const $type = BridgeTypeRef(BridgeTypeSpec('package:entity_manga_external/entity_manga_external.dart', 'ChapterScrapped'));
  static const $declaration = BridgeClassDef(
    BridgeClassType($type),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          params: [],
          namedParams: [
            BridgeParameter('title', BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)), true),
            BridgeParameter('chapter', BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)), true),
            BridgeParameter('readableAt', BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)), true),
            BridgeParameter('webUrl', BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)), true),
            BridgeParameter('scanlationGroup', BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)), true),
          ],
        ),
      ),
    },
    wrap: true,
  );

  $ChapterScrapped.wrap(this.$value) : super();

  @override
  final ChapterScrapped $value;

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'title':
        return $value.title == null ? const $null() : $String($value.title!);
      case 'chapter':
        return $value.chapter == null ? const $null() : $String($value.chapter!);
      case 'readableAt':
        return $value.readableAt == null ? const $null() : $String($value.readableAt!);
      case 'webUrl':
        return $value.webUrl == null ? const $null() : $String($value.webUrl!);
      case 'scanlationGroup':
        return $value.scanlationGroup == null ? const $null() : $String($value.scanlationGroup!);
    }
    return null;
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
    return $ChapterScrapped.wrap(ChapterScrapped(
      title: args[0]?.$value as String?,
      chapter: args[1]?.$value as String?,
      readableAt: args[2]?.$value as String?,
      webUrl: args[3]?.$value as String?,
      scanlationGroup: args[4]?.$value as String?,
    ));
  }
}
