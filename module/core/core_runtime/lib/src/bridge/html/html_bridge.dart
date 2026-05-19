import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:html/dom.dart' as dom;

class $Document extends $Value implements $Instance {
  static const $type = BridgeTypeRef(
    BridgeTypeSpec('package:html/dom.dart', 'Document'),
  );

  static const $declaration = BridgeClassDef(
    BridgeClassType($type),
    constructors: {},
    methods: {
      'querySelector': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(BridgeTypeSpec('package:html/dom.dart', 'Element')),
            nullable: true,
          ),
          params: [
            BridgeParameter(
              'selector',
              BridgeTypeAnnotation(
                BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')),
              ),
              false,
            ),
          ],
        ),
      ),
      'querySelectorAll': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.list, [
              BridgeTypeRef(BridgeTypeSpec('package:html/dom.dart', 'Element')),
            ]),
          ),
          params: [
            BridgeParameter(
              'selector',
              BridgeTypeAnnotation(
                BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')),
              ),
              false,
            ),
          ],
        ),
      ),
    },
    wrap: true,
  );

  $Document.wrap(this.value) : _superclass = $Object(value);

  final dom.Document value;

  final $Instance _superclass;

  @override
  dom.Document get $value => value;

  @override
  dom.Document get $reified => value;

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'querySelector':
        return $Function((runtime, thisValue, args) {
          final selector = args[0]!.$value as String;
          final element = value.querySelector(selector);
          return element == null ? runtime.wrap(null) : $Element.wrap(element);
        });
      case 'querySelectorAll':
        return $Function((runtime, thisValue, args) {
          final selector = args[0]!.$value as String;
          final elements = value.querySelectorAll(selector);
          return runtime.wrap(elements.map((e) => $Element.wrap(e)).toList());
        });
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

class $Element extends $Value implements $Instance {
  static const $type = BridgeTypeRef(
    BridgeTypeSpec('package:html/dom.dart', 'Element'),
  );

  static const $declaration = BridgeClassDef(
    BridgeClassType($type),
    constructors: {},
    fields: {
      'text': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')),
        ),
      ),
      'innerHtml': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')),
        ),
      ),
      'outerHtml': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')),
        ),
      ),
      'attributes': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(BridgeTypeSpec('dart:core', 'Map'))),
      ),
    },
    methods: {
      'querySelector': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type, nullable: true),
          params: [
            BridgeParameter(
              'selector',
              BridgeTypeAnnotation(
                BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')),
              ),
              false,
            ),
          ],
        ),
      ),
      'querySelectorAll': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.list, [$type]),
          ),
          params: [
            BridgeParameter(
              'selector',
              BridgeTypeAnnotation(
                BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')),
              ),
              false,
            ),
          ],
        ),
      ),
    },
    wrap: true,
  );

  $Element.wrap(this.value) : _superclass = $Object(value);

  final dom.Element value;

  final $Instance _superclass;

  @override
  dom.Element get $value => value;

  @override
  dom.Element get $reified => value;

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'text':
        return runtime.wrap(value.text);
      case 'innerHtml':
        return runtime.wrap(value.innerHtml);
      case 'outerHtml':
        return runtime.wrap(value.outerHtml);
      case 'attributes':
        return runtime.wrap(value.attributes);
      case 'querySelector':
        return $Function((runtime, thisValue, args) {
          final selector = args[0]!.$value as String;
          final element = value.querySelector(selector);
          return element == null ? runtime.wrap(null) : $Element.wrap(element);
        });
      case 'querySelectorAll':
        return $Function((runtime, thisValue, args) {
          final selector = args[0]!.$value as String;
          final elements = value.querySelectorAll(selector);
          return runtime.wrap(elements.map((e) => $Element.wrap(e)).toList());
        });
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

class HtmlParserBridge {
  static const $type = BridgeTypeRef(
    BridgeTypeSpec('package:html/parser.dart', 'parser'),
  );

  static const $declaration = BridgeClassDef(
    BridgeClassType($type),
    wrap: true,
    constructors: {},
    methods: {
      'parse': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(BridgeTypeSpec('package:html/dom.dart', 'Document')),
          ),
          params: [
            BridgeParameter(
              'html',
              BridgeTypeAnnotation(
                BridgeTypeRef(BridgeTypeSpec('dart:core', 'String')),
              ),
              false,
            ),
          ],
        ),
      ),
    },
  );
}
