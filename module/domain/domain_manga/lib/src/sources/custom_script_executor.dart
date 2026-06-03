/// A custom executor for running Dart scripts in a sandboxed environment.
///
/// **Business/Technical Purpose:**
/// This class uses `dart_eval` to execute dynamically loaded Dart scripts (e.g.,
/// for scraping manga sources). It bridges standard HTML parsing classes (`Document`,
/// `Element`) so that the sandboxed scripts can interact with DOM elements.
///
/// **Usage Instructions:**
/// 1. Instantiate `CustomScriptExecutor` with a valid Dart script string.
/// 2. Call `invoke('functionName', [args])` to execute a function defined in
///    the sandboxed script.
import 'package:dart_eval/dart_eval.dart';
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

/// Evaluates and executes Dart scripts with HTML bridging capabilities.
class CustomScriptExecutor {
  /// The sandboxed runtime environment.
  final Runtime runtime;

  /// Creates a new executor and builds its runtime with the given [scriptCode].
  CustomScriptExecutor(String scriptCode) : runtime = _buildRuntime(scriptCode);

  /// Compiles the script and sets up bridge classes and functions.
  static Runtime _buildRuntime(String scriptCode) {
    final compiler = Compiler();
    compiler.defineBridgeClasses([
      $Document.$declaration,
      $Element.$declaration,
    ]);
    compiler.defineBridgeTopLevelFunction(
      BridgeFunctionDeclaration(
        'package:html/parser.dart',
        'parse',
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dynamic)),
          params: [
            BridgeParameter(
              'html',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)),
              false,
            ),
          ],
        ),
      ),
    );

    final program = compiler.compile({
      'scraper': {
        'main.dart': scriptCode,
      },
    });

    final runtime = Runtime.ofProgram(program);
    runtime.registerBridgeFunc('package:html/parser.dart', 'parse', (rt, target, args) {
      final doc = html_parser.parse(args[0]?.$value as String);
      return $Document.wrap(doc);
    });
    runtime.setup();
    return runtime;
  }

  /// Invokes a function inside the evaluated script.
  dynamic invoke(String functionName, List<dynamic> positionalArgs) {
    return runtime.executeLib('package:scraper/main.dart', functionName, positionalArgs);
  }
}

/// Bridge class for [Document] from the `html` package.
class $Document implements $Instance {
  /// Type reference for the [Document] class.
  static const $type = BridgeTypeRef(BridgeTypeSpec('package:html/dom.dart', 'Document'));

  /// Declaration of the [Document] class for `dart_eval`.
  static const $declaration = BridgeClassDef(
    BridgeClassType($type),
    constructors: {},
    methods: {
      'querySelector': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dynamic)),
          params: [
            BridgeParameter(
              'selector',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)),
              false,
            ),
          ],
        ),
      ),
      'querySelectorAll': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dynamic)),
          params: [
            BridgeParameter(
              'selector',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)),
              false,
            ),
          ],
        ),
      ),
    },
    getters: {},
    setters: {},
    fields: {},
    wrap: true,
  );

  /// The wrapped [Document] instance.
  final Document $value;

  /// Wraps an existing [Document] instance.
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

/// Bridge class for [Element] from the `html` package.
class $Element implements $Instance {
  /// Type reference for the [Element] class.
  static const $type = BridgeTypeRef(BridgeTypeSpec('package:html/dom.dart', 'Element'));

  /// Declaration of the [Element] class for `dart_eval`.
  static const $declaration = BridgeClassDef(
    BridgeClassType($type),
    constructors: {},
    methods: {
      'querySelector': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dynamic)),
          params: [
            BridgeParameter(
              'selector',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)),
              false,
            ),
          ],
        ),
      ),
    },
    getters: {
      'text': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)),
        ),
      ),
      'attributes': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dynamic)),
        ),
      ),
    },
    setters: {},
    fields: {},
    wrap: true,
  );

  /// The wrapped [Element] instance.
  final Element $value;

  /// Wraps an existing [Element] instance.
  $Element.wrap(this.$value);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'text':
        return $String($value.text);
      case 'attributes':
        return $Map.wrap(
          $value.attributes.map(
            (k, v) => MapEntry($String(k.toString()), $String(v)),
          ),
        );
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

/// Helper function to create an evaluated function value.
$Value __evalFunction(Function(Runtime rt, $Value? target, List<$Value?> args) func) {
  return $Function((rt, target, args) => func(rt, target, args));
}
