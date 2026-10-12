// Tests for wrapScript (the error-reporting wrapper of injected page
// scripts) and ScriptEvaluationException. The readiness beacon helpers
// were removed with the Dart scrapers (issue #115).
// Run: fvm flutter test test/manager/script_wrapper_test.dart
import 'package:core_network/src/exception/script_evaluation_exception.dart';
import 'package:core_network/src/manager/script_wrapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('wrapScript', () {
    test('wraps the body in a try/catch reporting through the bridge', () {
      final wrapped = wrapScript('document.title = "x";', index: 0);

      expect(wrapped, contains('try'));
      expect(wrapped, contains('catch'));
      expect(wrapped, contains("callHandler('scriptError'"));
      expect(wrapped, contains('document.title = "x";'));
    });

    test('carries the script index for diagnostics', () {
      final wrapped = wrapScript('a();', index: 3);

      expect(wrapped, contains('3'));
    });

    test('produces a syntactically self-contained expression', () {
      final wrapped = wrapScript('a();', index: 0);

      expect(wrapped.startsWith('(async function(){'), isTrue);
      expect(wrapped.endsWith('})()'), isTrue);
    });
  });

  group('ScriptEvaluationException', () {
    test('carries script index, error and url', () {
      final exception = ScriptEvaluationException(
        scriptIndex: 2,
        error: 'TypeError: null is not an object',
        url: 'https://x.com/page',
      );

      expect(exception.scriptIndex, 2);
      expect(exception.error, 'TypeError: null is not an object');
      expect(exception.url, 'https://x.com/page');
      expect(exception.toString(), contains('script #2'));
      expect(exception.toString(), contains('TypeError'));
    });
  });
}
