import 'package:core_analytics/src/extension/stack_trace_extension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Stack Trace Extension', () {
    group('callerFunctionName', () {
      test('returns the caller function name', () {
        expect(
          testCallerFunctionName().callerFunctionName,
          equals('testCallerFunctionName'),
        );
      });

      test('returns the class.method name when called from a class', () {
        final result = _TestClass().getCallerTrace();
        expect(
          result.callerFunctionName,
          equals('TestClass.getCallerTrace'),
        );
      });

      test('returns null when StackTrace has only one frame', () {
        // Create a StackTrace with only a single frame (no second line)
        final singleFrameTrace = StackTrace.fromString(
          '#0      main (file:///test.dart:1:1)',
        );
        expect(singleFrameTrace.callerFunctionName, isNull);
      });

      test('returns null when StackTrace is empty', () {
        final emptyTrace = StackTrace.fromString('');
        expect(emptyTrace.callerFunctionName, isNull);
      });

      test('handles StackTrace with multiple frames', () {
        final multiFrameTrace = StackTrace.fromString(
          '#0      producerFunctionName (file:///test.dart:1:1)\n'
          '#1      myCallerFunction (file:///test.dart:2:1)\n'
          '#2      main (file:///test.dart:3:1)',
        );
        expect(multiFrameTrace.callerFunctionName, equals('myCallerFunction'));
      });

      test('returns function name from current StackTrace', () {
        final trace = StackTrace.current;
        // The caller is the anonymous test closure, which the test framework
        // wraps - just verify it returns a non-null string
        expect(trace.callerFunctionName, isNotNull);
        expect(trace.callerFunctionName, isA<String>());
      });
    });
  });
}

StackTrace testCallerFunctionName() {
  return producerFunctionName();
}

StackTrace producerFunctionName() {
  return StackTrace.current;
}

class _TestClass {
  StackTrace getCallerTrace() {
    return producerFunctionName();
  }
}
