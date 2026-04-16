library;

import 'package:dart_eval/dart_eval.dart';

import 'src/bridge/html_bridge.dart';
import 'src/bridge/manga_external_bridge.dart';
import 'src/dynamic_source_external.dart';
import 'src/model/source_metadata.dart';

export 'src/dynamic_source_external.dart';
export 'src/model/source_metadata.dart';

class EvalBridge {
  static Runtime compile(String source) {
    final compiler = Compiler();
    
    compiler.defineBridgeClasses([
      $Document.$declaration,
      $Element.$declaration,
      $MangaScrapped.$declaration,
    ]);

    final program = compiler.compile({
      'provider': {
        'main.dart': source,
      }
    });

    final runtime = Runtime.ofProgram(program);
    
    runtime.registerBridgeFunc('package:html/dom.dart', 'Document.querySelector', (runtime, target, args) => (target as $Document).$getProperty(runtime, 'querySelector')!);
    runtime.registerBridgeFunc('package:html/dom.dart', 'Document.querySelectorAll', (runtime, target, args) => (target as $Document).$getProperty(runtime, 'querySelectorAll')!);
    runtime.registerBridgeFunc('package:html/dom.dart', 'Element.querySelector', (runtime, target, args) => (target as $Element).$getProperty(runtime, 'querySelector')!);
    runtime.registerBridgeFunc('package:html/dom.dart', 'Element.querySelectorAll', (runtime, target, args) => (target as $Element).$getProperty(runtime, 'querySelectorAll')!);
    runtime.registerBridgeFunc('package:entity_manga_external/entity_manga_external.dart', 'MangaScrapped.', $MangaScrapped.$new);

    return runtime;
  }

  static DynamicSourceExternal loadSource(String source) {
    final runtime = compile(source);
    
    // Extract metadata using static getter as requested
    final result = runtime.executeLib('package:provider/main.dart', 'MangaProvider.metadata');
    final metadataMap = result.$value as Map;
    final metadata = SourceMetadata.fromMap(metadataMap.map((k, v) => MapEntry(k.$value as String, v.$value)));
    
    return DynamicSourceExternal(runtime, metadata);
  }
}
