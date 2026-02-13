// ignore_for_file: unused_import, unnecessary_import
// ignore_for_file: always_specify_types, avoid_redundant_argument_values
// ignore_for_file: sort_constructors_first
// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:dart_eval/dart_eval.dart';
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:html/dom.dart';

import 'html_document.dart';

/// dart_eval wrapper binding for [HtmlDocument]
class $HtmlDocument implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:entity_manga_external/src/html_document.dart',
      'HtmlDocument.',
      $HtmlDocument.$new,
    );
  }

  /// Compile-time type specification of [$HtmlDocument]
  static const $spec = BridgeTypeSpec(
    'package:entity_manga_external/src/html_document.dart',
    'HtmlDocument',
  );

  /// Compile-time type declaration of [$HtmlDocument]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$HtmlDocument]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [],
          params: [],
        ),
        isFactory: false,
      ),
    },

    methods: {
      'clone': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(BridgeTypeSpec('package:html/dom.dart', 'Node'), []),
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'deep',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              false,
            ),
          ],
        ),
      ),

      'createElement': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec('package:html/dom.dart', 'Element'),
              [],
            ),
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'tag',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),
          ],
        ),
      ),

      'createElementNS': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec('package:html/dom.dart', 'Element'),
              [],
            ),
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'namespaceUri',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              false,
            ),

            BridgeParameter(
              'tag',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              false,
            ),
          ],
        ),
      ),

      'createDocumentFragment': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec('package:html/dom.dart', 'DocumentFragment'),
              [],
            ),
          ),
          namedParams: [],
          params: [],
        ),
      ),

      'append': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [],
          params: [
            BridgeParameter(
              'node',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec('package:html/dom.dart', 'Node'),
                  [],
                ),
              ),
              false,
            ),
          ],
        ),
      ),

      'remove': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(BridgeTypeSpec('package:html/dom.dart', 'Node'), []),
          ),
          namedParams: [],
          params: [],
        ),
      ),

      'insertBefore': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [],
          params: [
            BridgeParameter(
              'node',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec('package:html/dom.dart', 'Node'),
                  [],
                ),
              ),
              false,
            ),

            BridgeParameter(
              'refNode',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec('package:html/dom.dart', 'Node'),
                  [],
                ),
                nullable: true,
              ),
              false,
            ),
          ],
        ),
      ),

      'replaceWith': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(BridgeTypeSpec('package:html/dom.dart', 'Node'), []),
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'otherNode',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec('package:html/dom.dart', 'Node'),
                  [],
                ),
              ),
              false,
            ),
          ],
        ),
      ),

      'hasContent': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [],
        ),
      ),

      'reparentChildren': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [],
          params: [
            BridgeParameter(
              'newParent',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec('package:html/dom.dart', 'Node'),
                  [],
                ),
              ),
              false,
            ),
          ],
        ),
      ),

      'hasChildNodes': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [],
        ),
      ),

      'contains': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
          namedParams: [],
          params: [
            BridgeParameter(
              'node',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec('package:html/dom.dart', 'Node'),
                  [],
                ),
              ),
              false,
            ),
          ],
        ),
      ),

      'querySelector': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec('package:html/dom.dart', 'Element'),
              [],
            ),
            nullable: true,
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'selector',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),
          ],
        ),
      ),

      'querySelectorAll': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.list, [
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec('package:html/dom.dart', 'Element'),
                  [],
                ),
              ),
            ]),
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'selector',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),
          ],
        ),
      ),

      'getElementById': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec('package:html/dom.dart', 'Element'),
              [],
            ),
            nullable: true,
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'id',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),
          ],
        ),
      ),

      'getElementsByTagName': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.list, [
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec('package:html/dom.dart', 'Element'),
                  [],
                ),
              ),
            ]),
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'localName',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),
          ],
        ),
      ),

      'getElementsByClassName': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.list, [
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec('package:html/dom.dart', 'Element'),
                  [],
                ),
              ),
            ]),
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'classNames',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),
          ],
        ),
      ),
    },
    getters: {
      'nodeType': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.int, [])),
          namedParams: [],
          params: [],
        ),
      ),

      'documentElement': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec('package:html/dom.dart', 'Element'),
              [],
            ),
            nullable: true,
          ),
          namedParams: [],
          params: [],
        ),
      ),

      'head': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec('package:html/dom.dart', 'Element'),
              [],
            ),
            nullable: true,
          ),
          namedParams: [],
          params: [],
        ),
      ),

      'body': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec('package:html/dom.dart', 'Element'),
              [],
            ),
            nullable: true,
          ),
          namedParams: [],
          params: [],
        ),
      ),

      'outerHtml': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
          namedParams: [],
          params: [],
        ),
      ),

      'parent': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec('package:html/dom.dart', 'Element'),
              [],
            ),
            nullable: true,
          ),
          namedParams: [],
          params: [],
        ),
      ),

      'attributeSpans': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CollectionTypes.linkedHashMap, [
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.object, [])),
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:source_span/src/file.dart',
                    'FileSpan',
                  ),
                  [],
                ),
              ),
            ]),
            nullable: true,
          ),
          namedParams: [],
          params: [],
        ),
      ),

      'attributeValueSpans': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CollectionTypes.linkedHashMap, [
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.object, [])),
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:source_span/src/file.dart',
                    'FileSpan',
                  ),
                  [],
                ),
              ),
            ]),
            nullable: true,
          ),
          namedParams: [],
          params: [],
        ),
      ),

      'text': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.string, []),
            nullable: true,
          ),
          namedParams: [],
          params: [],
        ),
      ),

      'firstChild': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(BridgeTypeSpec('package:html/dom.dart', 'Node'), []),
            nullable: true,
          ),
          namedParams: [],
          params: [],
        ),
      ),
    },
    setters: {
      'text': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
          namedParams: [],
          params: [
            BridgeParameter(
              'value',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              false,
            ),
          ],
        ),
      ),
    },
    fields: {},
    wrap: true,
    bridge: false,
  );

  /// Wrapper for the [HtmlDocument.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $HtmlDocument.wrap(HtmlDocument());
  }

  final $Instance _superclass;

  @override
  final HtmlDocument $value;

  @override
  HtmlDocument get $reified => $value;

  /// Wrap a [HtmlDocument] in a [$HtmlDocument]
  $HtmlDocument.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'clone':
        return __clone;

      case 'createElement':
        return __createElement;

      case 'createElementNS':
        return __createElementNS;

      case 'createDocumentFragment':
        return __createDocumentFragment;

      case 'append':
        return __append;

      case 'remove':
        return __remove;

      case 'insertBefore':
        return __insertBefore;

      case 'replaceWith':
        return __replaceWith;

      case 'hasContent':
        return __hasContent;

      case 'reparentChildren':
        return __reparentChildren;

      case 'hasChildNodes':
        return __hasChildNodes;

      case 'contains':
        return __contains;

      case 'querySelector':
        return __querySelector;

      case 'querySelectorAll':
        return __querySelectorAll;

      case 'getElementById':
        return __getElementById;

      case 'getElementsByTagName':
        return __getElementsByTagName;

      case 'getElementsByClassName':
        return __getElementsByClassName;
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static const $Function __clone = $Function(_clone);
  static $Value? _clone(Runtime runtime, $Value? target, List<$Value?> args) {
    final self = target! as $HtmlDocument;
    final result = self.$value.clone(args[0]!.$value);
    return runtime.wrapAlways(result);
  }

  static const $Function __createElement = $Function(_createElement);
  static $Value? _createElement(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $HtmlDocument;
    final result = self.$value.createElement(args[0]!.$value);
    return runtime.wrapAlways(result);
  }

  static const $Function __createElementNS = $Function(_createElementNS);
  static $Value? _createElementNS(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $HtmlDocument;
    final result = self.$value.createElementNS(
      args[0]!.$value,
      args[1]!.$value,
    );
    return runtime.wrapAlways(result);
  }

  static const $Function __createDocumentFragment = $Function(
    _createDocumentFragment,
  );
  static $Value? _createDocumentFragment(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $HtmlDocument;
    final result = self.$value.createDocumentFragment();
    return runtime.wrapAlways(result);
  }

  static const $Function __append = $Function(_append);
  static $Value? _append(Runtime runtime, $Value? target, List<$Value?> args) {
    final self = target! as $HtmlDocument;
    self.$value.append(args[0]!.$value);
    return null;
  }

  static const $Function __remove = $Function(_remove);
  static $Value? _remove(Runtime runtime, $Value? target, List<$Value?> args) {
    final self = target! as $HtmlDocument;
    final result = self.$value.remove();
    return runtime.wrapAlways(result);
  }

  static const $Function __insertBefore = $Function(_insertBefore);
  static $Value? _insertBefore(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $HtmlDocument;
    self.$value.insertBefore(args[0]!.$value, args[1]!.$value);
    return null;
  }

  static const $Function __replaceWith = $Function(_replaceWith);
  static $Value? _replaceWith(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $HtmlDocument;
    final result = self.$value.replaceWith(args[0]!.$value);
    return runtime.wrapAlways(result);
  }

  static const $Function __hasContent = $Function(_hasContent);
  static $Value? _hasContent(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $HtmlDocument;
    final result = self.$value.hasContent();
    return $bool(result);
  }

  static const $Function __reparentChildren = $Function(_reparentChildren);
  static $Value? _reparentChildren(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $HtmlDocument;
    self.$value.reparentChildren(args[0]!.$value);
    return null;
  }

  static const $Function __hasChildNodes = $Function(_hasChildNodes);
  static $Value? _hasChildNodes(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $HtmlDocument;
    final result = self.$value.hasChildNodes();
    return $bool(result);
  }

  static const $Function __contains = $Function(_contains);
  static $Value? _contains(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $HtmlDocument;
    final result = self.$value.contains(args[0]!.$value);
    return $bool(result);
  }

  static const $Function __querySelector = $Function(_querySelector);
  static $Value? _querySelector(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $HtmlDocument;
    final result = self.$value.querySelector(args[0]!.$value);
    return result == null ? const $null() : runtime.wrapAlways(result);
  }

  static const $Function __querySelectorAll = $Function(_querySelectorAll);
  static $Value? _querySelectorAll(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $HtmlDocument;
    final result = self.$value.querySelectorAll(args[0]!.$value);
    return $List.view(result, (e) => runtime.wrapAlways(e));
  }

  static const $Function __getElementById = $Function(_getElementById);
  static $Value? _getElementById(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $HtmlDocument;
    final result = self.$value.getElementById(args[0]!.$value);
    return result == null ? const $null() : runtime.wrapAlways(result);
  }

  static const $Function __getElementsByTagName = $Function(
    _getElementsByTagName,
  );
  static $Value? _getElementsByTagName(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $HtmlDocument;
    final result = self.$value.getElementsByTagName(args[0]!.$value);
    return $List.view(result, (e) => runtime.wrapAlways(e));
  }

  static const $Function __getElementsByClassName = $Function(
    _getElementsByClassName,
  );
  static $Value? _getElementsByClassName(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $HtmlDocument;
    final result = self.$value.getElementsByClassName(args[0]!.$value);
    return $List.view(result, (e) => runtime.wrapAlways(e));
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}
