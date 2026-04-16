import 'package:dart_eval/dart_eval.dart';
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:html/dom.dart' as dom;

class $Document implements $Instance {
  static const $type = BridgeTypeRef(BridgeTypeSpec('package:html/dom.dart', 'Document'));
  static const $declaration = BridgeClassDef(
    BridgeClassType($type),
    constructors: {},
    methods: {
      'querySelector': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(BridgeTypeSpec('package:html/dom.dart', 'Element')), nullable: true),
          params: [BridgeParameter('selector', BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)), false)],
        ),
      ),
      'querySelectorAll': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.list, [BridgeTypeRef(BridgeTypeSpec('package:html/dom.dart', 'Element'))])),
          params: [BridgeParameter('selector', BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)), false)],
        ),
      ),
    },
    wrap: true,
  );

  $Document.wrap(this.$value) : super();

  @override
  final dom.Document $value;

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'querySelector':
        return $Function((runtime, target, args) {
          final selector = args[0]!.$value as String;
          final result = $value.querySelector(selector);
          return result == null ? const $null() : $Element.wrap(result);
        });
      case 'querySelectorAll':
        return $Function((runtime, target, args) {
          final selector = args[0]!.$value as String;
          final results = $value.querySelectorAll(selector);
          return $List.wrap(results.map((e) => $Element.wrap(e)).toList());
        });
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
}

class $Element implements $Instance {
  static const $type = BridgeTypeRef(BridgeTypeSpec('package:html/dom.dart', 'Element'));
  static const $declaration = BridgeClassDef(
    BridgeClassType($type),
    constructors: {},
    methods: {
      'querySelector': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(BridgeTypeSpec('package:html/dom.dart', 'Element')), nullable: true),
          params: [BridgeParameter('selector', BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)), false)],
        ),
      ),
      'querySelectorAll': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.list, [BridgeTypeRef(BridgeTypeSpec('package:html/dom.dart', 'Element'))])),
          params: [BridgeParameter('selector', BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)), false)],
        ),
      ),
    },
    getters: {
      'text': BridgeMethodDef(BridgeFunctionDef(returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)))),
      'attributes': BridgeMethodDef(BridgeFunctionDef(returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.map, [BridgeTypeRef(CoreTypes.string), BridgeTypeRef(CoreTypes.string)])))),
      'children': BridgeMethodDef(BridgeFunctionDef(returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.list, [BridgeTypeRef(BridgeTypeSpec('package:html/dom.dart', 'Element'))])))),
    },
    wrap: true,
  );

  $Element.wrap(this.$value) : super();

  @override
  final dom.Element $value;

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'text':
        return $String($value.text);
      case 'attributes':
        return $Map.wrap($value.attributes.map((key, value) => MapEntry($String(key as String), $String(value))));
      case 'children':
        return $List.wrap($value.children.map((e) => $Element.wrap(e)).toList());
      case 'querySelector':
        return $Function((runtime, target, args) {
          final selector = args[0]!.$value as String;
          final result = $value.querySelector(selector);
          return result == null ? const $null() : $Element.wrap(result);
        });
      case 'querySelectorAll':
        return $Function((runtime, target, args) {
          final selector = args[0]!.$value as String;
          final results = $value.querySelectorAll(selector);
          return $List.wrap(results.map((e) => $Element.wrap(e)).toList());
        });
      case '==':
        return $Function((runtime, target, args) {
          final other = args[0];
          return $bool($value == other?.$value);
        });
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
}
