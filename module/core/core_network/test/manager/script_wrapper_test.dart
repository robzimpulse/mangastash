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

  group('readinessBeaconScript', () {
    test('waits for all selectors then reports over the bridge', () {
      final script = readinessBeaconScript(const ['img[data-page-index]']);

      expect(script, contains('img[data-page-index]'));
      expect(script, contains('document.querySelectorAll'));
      expect(script, contains('selectors.every'));
      expect(script, contains("callHandler('scriptReady', ready)"));
    });

    test('reports failure after a bounded number of tries', () {
      final script = readinessBeaconScript(const ['img']);

      // The timeout path reports the same call with ready === false; the
      // bound is what stops it from polling forever.
      expect(script, contains('++tries >= maxTries'));
      expect(script, contains('maxTries = 40'));
    });

    test('escapes single quotes in selectors', () {
      final script = readinessBeaconScript(const ["img[alt='page']"]);

      expect(script, contains(r"img[alt=\'page\']"));
    });
  });

  group('readinessSatisfied', () {
    test('empty selectors are always satisfied', () {
      expect(readinessSatisfied('<html></html>', const []), isTrue);
    });

    test('all selectors must match at least one element', () {
      final html = '<div><img data-page-index="0"></div>';

      expect(readinessSatisfied(html, const ['img[data-page-index]']), isTrue);
      expect(
        readinessSatisfied(html, const [
          'img[data-page-index]',
          'section#chapter-images',
        ]),
        isFalse,
      );
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
