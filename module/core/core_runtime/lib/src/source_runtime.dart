import 'dart:async';
import 'dart:typed_data';

import 'package:dart_eval/dart_eval.dart';
import 'package:dart_eval/dart_eval_bridge.dart';
import 'bridge/runtime_bridge.dart';

class SourceRuntime {
  final Map<String, Uint8List> _bytecodeCache = {};

  Uint8List getOrCreateBytecode(String id, String sourceCode) {
    if (_bytecodeCache.containsKey(id)) {
      return _bytecodeCache[id]!;
    }
    
    final compiler = Compiler();
    RuntimeBridge.register(compiler);
    
    final program = compiler.compile({
      'dynamic_source': {
        'main.dart': sourceCode,
      }
    });
    
    final bytecode = program.write();
    _bytecodeCache[id] = bytecode;
    return bytecode;
  }

  Future<dynamic> execute({
    required Uint8List bytecode,
    required String functionName,
    List<dynamic> args = const [],
  }) async {
    // TODO: Implement Isolate-based execution for safety and performance
    final runtime = Runtime(bytecode.buffer.asByteData());
    RuntimeBridge.configure(runtime);
    
    final wrappedArgs = args.map((e) => runtime.wrap(e)).toList();
    final result = runtime.executeLib('package:dynamic_source/main.dart', functionName, wrappedArgs);
    
    return _unwrap(result);
  }

  dynamic _unwrap(dynamic value) {
    if (value is $Value) {
      return value.$value;
    }
    if (value is List) {
      return value.map(_unwrap).toList();
    }
    return value;
  }
}
