/// Tests for the source script harness builder, the stack-location parser and
/// [SourceScriptException].
///
/// Purpose: pins the exact JS contract the headless runner relies on (indirect
/// eval of the JSON-encoded script, sourceURL, result/error handler names,
/// missing-function error) and the WebKit/Chromium stack parsing.
/// Usage: `fvm flutter test test/script/source_script_harness_test.dart`
/// from module/core/core_network.
library;

import 'dart:convert';

import 'package:core_network/core_network.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseScriptLocation', () {
    test('WebKit stack', () {
      expect(
        parseScriptLocation(
          'boom@mangastash-source.js:12:9\nglobal code@about:blank:3:1',
        ),
        (line: 12, column: 9),
      );
    });

    test('Chromium stack', () {
      expect(
        parseScriptLocation(
          'Error: bad\n    at Object.boom (mangastash-source.js:7:15)\n'
          '    at <anonymous>:4:2',
        ),
        (line: 7, column: 15),
      );
    });

    test('no location', () {
      expect(parseScriptLocation('boom@about:blank:5:67'), isNull);
    });

    test('first match wins', () {
      expect(
        parseScriptLocation(
          'a@mangastash-source.js:1:2\nb@mangastash-source.js:3:4',
        ),
        (line: 1, column: 2),
      );
    });
  });

  group('buildSourceHarness', () {
    String build({bool pageFunction = true, String? searchTerm}) {
      return buildSourceHarness(
        ctxJs: '/*ctx*/',
        code: "const source = {a: '`\${x}`'};",
        function: 'search',
        argsJson: '[]',
        callId: 'c1',
        baseUrl: 'https://x.y',
        searchTerm: searchTerm,
        pageFunction: pageFunction,
      );
    }

    test('embeds code as a JSON string literal and the sourceURL', () {
      final js = build();
      expect(js, contains(jsonEncode("const source = {a: '`\${x}`'};")));
      expect(js, contains('//# sourceURL=mangastash-source.js'));
      expect(js, contains("'sourceResult'"));
      expect(js, contains("'sourceError'"));
      expect(js, contains('/*ctx*/'));
    });

    test('page function receives document, others receive args', () {
      expect(build(), contains('source[fn](document, ctx)'));
      expect(build(pageFunction: false), contains('source[fn](...args, ctx)'));
    });

    test('reports a missing function', () {
      expect(build(), contains("'source.' + fn + ' is not a function'"));
    });

    test('embeds search term, base url and call id as JSON literals', () {
      final js = build(searchTerm: 'a"b');
      expect(js, contains(jsonEncode('a"b')));
      expect(js, contains(jsonEncode('https://x.y')));
      expect(js, contains(jsonEncode('c1')));
    });
  });

  group('SourceScriptException', () {
    test('toString with every part', () {
      const e = SourceScriptException(
        function: 'search',
        message: 'boom',
        line: 12,
        source: 'asura-scans',
      );
      expect(
        e.toString(),
        'SourceScriptException: asura-scans search failed at line 12: boom',
      );
    });

    test('toString omits missing parts', () {
      const e = SourceScriptException(function: 'search', message: 'boom');
      expect(e.toString(), 'SourceScriptException: search failed: boom');
    });

    test('copyWith keeps everything else', () {
      const e = SourceScriptException(
        function: 'f',
        message: 'm',
        line: 1,
        column: 2,
        url: 'u',
        timedOut: true,
      );
      final c = e.copyWith(source: 's', html: '<p/>');
      expect(c.source, 's');
      expect(c.html, '<p/>');
      expect(c.function, 'f');
      expect(c.line, 1);
      expect(c.column, 2);
      expect(c.url, 'u');
      expect(c.timedOut, true);
    });
  });
}
