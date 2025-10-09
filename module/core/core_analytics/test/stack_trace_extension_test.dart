import 'package:core_analytics/src/extension/stack_trace_extension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Stack Trace Extension', () {
    test('callerFunctionName', () {
      expect(
        testCallerFunctionName().callerFunctionName,
        equals('testCallerFunctionName'),
      );
    });
  });
}

StackTrace testCallerFunctionName() {
  return producerFunctionName();
}

StackTrace producerFunctionName() {
  return StackTrace.current;
}
