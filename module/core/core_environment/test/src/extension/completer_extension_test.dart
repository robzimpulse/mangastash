import 'dart:async';

import 'package:core_environment/core_environment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SafeCompleter Extension', () {
    test('safeComplete completes when not completed', () {
      final completer = Completer<String>();
      completer.safeComplete('value');
      
      expect(completer.isCompleted, isTrue);
      expect(completer.future, completion(equals('value')));
    });

    test('safeComplete does nothing if already completed', () async {
      final completer = Completer<String>();
      completer.complete('first');
      
      completer.safeComplete('second'); // Should not throw StateError
      
      expect(completer.isCompleted, isTrue);
      expect(await completer.future, equals('first'));
    });

    test('safeCompleteError completes with error when not completed', () {
      final completer = Completer<String>();
      final exception = Exception('test error');
      
      completer.safeCompleteError(exception);
      
      expect(completer.isCompleted, isTrue);
      expect(completer.future, throwsA(equals(exception)));
    });

    test('safeCompleteError does nothing if already completed', () async {
      final completer = Completer<String>();
      completer.complete('first');
      
      final exception = Exception('test error');
      completer.safeCompleteError(exception); // Should not throw StateError
      
      expect(completer.isCompleted, isTrue);
      expect(await completer.future, equals('first'));
    });
  });
}
