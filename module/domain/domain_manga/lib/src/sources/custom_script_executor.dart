import 'package:dart_eval/dart_eval.dart';
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

class CustomScriptExecutor {
  final Runtime runtime;

  CustomScriptExecutor(String scriptCode) : runtime = _buildRuntime(scriptCode);

  static Runtime _buildRuntime(String scriptCode) {
    final compiler = Compiler();
    compiler.defineBridgeClasses([$Document.$declaration, $Element.$declaration]);
    compiler.defineBridgeTopLevelFunction(BridgeFunctionDeclaration(
      'package:html/parser.dart',
      'parse',
      BridgeFunctionDef(returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dynamic)), params: [
        BridgeParameter('html', BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)), false)
      ])
    ));

    final program = compiler.compile({
      'scraper': {'main.dart': scriptCode}
    });

    final runtime = Runtime.ofProgram(program);
    runtime.registerBridgeFunc('package:html/parser.dart', 'parse', (rt, target, args) {
      final doc = html_parser.parse(args[0]?.$value as String);
      return $Document.wrap(doc);
    });
    runtime.setup();
    return runtime;
  }

  dynamic invoke(String functionName, List<dynamic> positionalArgs) {
    return runtime.executeLib('package:scraper/main.dart', functionName, positionalArgs);
  }
}

class $Document implements $Instance {
  static const $type = BridgeTypeRef(BridgeTypeSpec('package:html/dom.dart', 'Document'));
  static const $declaration = BridgeClassDef(BridgeClassType($type),
      constructors: {},
      methods: {
        'querySelector': BridgeMethodDef(BridgeFunctionDef(returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dynamic)), params: [BridgeParameter('selector', BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)), false)])),
        'querySelectorAll': BridgeMethodDef(BridgeFunctionDef(returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dynamic)), params: [BridgeParameter('selector', BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)), false)])),
      },
      getters: {}, setters: {}, fields: {}, wrap: true);

  final Document $value;
  $Document.wrap(this.$value);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'querySelector':
        return __evalFunction((rt, target, args) {
          final el = $value.querySelector(args[0]?.$value as String);
          return el != null ? $Element.wrap(el) : const $null();
        });
      case 'querySelectorAll':
        return __evalFunction((rt, target, args) {
          final els = $value.querySelectorAll(args[0]?.$value as String);
          return $List.wrap(els.map((e) => $Element.wrap(e)).toList());
        });
    }
    return null;
  }
  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {}
  @override
  int get $runtimeType => runtimeType.hashCode;
}

class $Element implements $Instance {
  static const $type = BridgeTypeRef(BridgeTypeSpec('package:html/dom.dart', 'Element'));
  static const $declaration = BridgeClassDef(BridgeClassType($type),
      constructors: {},
      methods: {
        'querySelector': BridgeMethodDef(BridgeFunctionDef(returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dynamic)), params: [BridgeParameter('selector', BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)), false)])),
      },
      getters: {
        'text': BridgeMethodDef(BridgeFunctionDef(returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)))),
        'attributes': BridgeMethodDef(BridgeFunctionDef(returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dynamic)))),
      }, setters: {}, fields: {}, wrap: true);

  final Element $value;
  $Element.wrap(this.$value);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'text':
        return $String($value.text);
      case 'attributes':
        return $Map.wrap($value.attributes.map((k, v) => MapEntry($String(k.toString()), $String(v))));
      case 'querySelector':
        return __evalFunction((rt, target, args) {
          final el = $value.querySelector(args[0]?.$value as String);
          return el != null ? $Element.wrap(el) : const $null();
        });
    }
    return null;
  }
  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {}
  @override
  int get $runtimeType => runtimeType.hashCode;
}

$Value __evalFunction(Function(Runtime rt, $Value? target, List<$Value?> args) func) {
  return $Function((rt, target, args) => func(rt, target, args));
}
