import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:dart_eval/dart_eval.dart';
import 'package:dart_eval/dart_eval_bridge.dart';
import 'bridge/runtime_bridge.dart';

class SourceRuntime {
  final Map<String, Uint8List> _bytecodeCache = {};

  Uint8List getOrCreateBytecode(
    String id,
    String sourceCode, {
    bool useCache = true,
  }) {
    if (useCache && _bytecodeCache.containsKey(id)) {
      return _bytecodeCache[id]!;
    }

    try {
      final compiler = Compiler();
      RuntimeBridge.register(compiler);

      final program = compiler.compile({
        'dynamic_source': {'main.dart': sourceCode},
      });

      final bytecode = program.write();
      if (useCache) {
        _bytecodeCache[id] = bytecode;
      }
      return bytecode;
    } catch (e) {
      throw Exception('Compilation failed: $e');
    }
  }

  dynamic executeSync({
    required Uint8List bytecode,
    required String functionName,
    List<dynamic> args = const [],
  }) {
    final runtime = Runtime(bytecode.buffer.asByteData());
    RuntimeBridge.configure(runtime);

    final wrappedArgs = args.map((e) => RuntimeBridge.wrap(runtime, e)).toList();
    final result = runtime.executeLib(
      'package:dynamic_source/main.dart',
      functionName,
      wrappedArgs,
    );

    return _unwrap(result);
  }

  Future<dynamic> execute({
    required Uint8List bytecode,
    required String functionName,
    List<dynamic> args = const [],
  }) async {
    // If args contains non-sendable objects, we must run on main thread
    // For now, we assume simple args for editor testing.
    try {
      return await Isolate.run(() {
        final runtime = Runtime(bytecode.buffer.asByteData());
        RuntimeBridge.configure(runtime);

        final wrappedArgs =
            args.map((e) => RuntimeBridge.wrap(runtime, e)).toList();
        final result = runtime.executeLib(
          'package:dynamic_source/main.dart',
          functionName,
          wrappedArgs,
        );

        return _unwrap(result);
      });
    } catch (e) {
      // Fallback to sync execution if isolate fails or for debugging
      return executeSync(
        bytecode: bytecode,
        functionName: functionName,
        args: args,
      );
    }
  }

  static dynamic _unwrap(dynamic value) {
    if (value is $Value) {
      return value.$value;
    }
    if (value is List) {
      return value.map(_unwrap).toList();
    }
    return value;
  }
}
