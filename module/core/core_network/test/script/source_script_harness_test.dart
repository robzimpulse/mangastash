/// Tests for the source script harness builder, the stack-location parser and
/// [SourceScriptException].
///
/// Purpose: pins the exact JS contract the headless runner relies on (indirect
/// eval of the JSON-encoded script, sourceURL, result/error handler names,
/// missing-function error) and the WebKit/Chromium stack parsing. The
/// "harness under Node" group executes the generated JS with a stubbed
/// `window.flutter_inappwebview` bridge, so success-path failures
/// (JSON.stringify of circular/BigInt values, a throwing post) are proven to
/// surface as `sourceError` rather than a silent timeout. That group is
/// skipped when `node` is not on PATH (CI installs Node 22 before tests).
/// Usage: `fvm flutter test test/script/source_script_harness_test.dart`
/// from module/core/core_network.
library;

import 'dart:convert';
import 'dart:io';

import 'package:core_network/core_network.dart';
import 'package:flutter_test/flutter_test.dart';

/// Whether a `node` binary is runnable; the Node-backed group is skipped
/// otherwise.
bool _hasNode() {
  try {
    return Process.runSync('node', ['--version']).exitCode == 0;
  } on ProcessException {
    return false;
  }
}

/// Runs the harness for [code] (calling `source.run()`) under Node with a
/// stubbed bridge and returns every `{name, payload}` the harness posted.
/// When [throwOn] names a handler, the stubbed `callHandler` throws for it;
/// [prelude] is JS run before the harness (e.g. to stub Error properties).
Future<List<dynamic>> _runHarness(
  String code, {
  String? throwOn,
  String prelude = '',
}) async {
  final harness = buildSourceHarness(
    ctxJs: File('assets/source_ctx.js').readAsStringSync(),
    code: code,
    function: 'run',
    argsJson: '[]',
    callId: 'c1',
    baseUrl: 'https://x.y',
    pageFunction: false,
  );
  final dir = await Directory.systemTemp.createTemp('harness_test');
  try {
    final file = File('${dir.path}/run.js');
    await file.writeAsString('''
var posts = [];
var throwOn = ${jsonEncode(throwOn)};
globalThis.window = {
  flutter_inappwebview: {
    callHandler: function (name, payload) {
      if (name === throwOn) throw new Error('post failed');
      posts.push({ name: name, payload: payload });
    },
  },
};
globalThis.document = {};
$prelude
$harness
setTimeout(function () { console.log(JSON.stringify(posts)); }, 50);
''');
    final result = await Process.run('node', [file.path]);
    expect(result.exitCode, 0, reason: '${result.stderr}');
    return jsonDecode((result.stdout as String).trim()) as List<dynamic>;
  } finally {
    await dir.delete(recursive: true);
  }
}

void main() {
  group(
    'harness under Node',
    skip: _hasNode() ? false : 'node not on PATH',
    () {
      test('posts the JSON-encoded value on success', () async {
        final posts = await _runHarness(
          'const source = { run: function () { return { a: 1 }; } };',
        );
        expect(posts, [
          {
            'name': 'sourceResult',
            'payload': {'callId': 'c1', 'value': '{"a":1}'},
          },
        ]);
      });

      test('undefined, function and symbol results post "null"', () async {
        for (final value in ['undefined', 'function () {}', 'Symbol("s")']) {
          final posts = await _runHarness(
            'const source = { run: function () { return $value; } };',
          );
          expect(posts, [
            {
              'name': 'sourceResult',
              'payload': {'callId': 'c1', 'value': 'null'},
            },
          ], reason: value);
        }
      });

      test('a circular result posts sourceError, not silence', () async {
        final posts = await _runHarness(
          'const source = { run: function () '
          '{ var a = {}; a.self = a; return a; } };',
        );
        expect(posts, hasLength(1));
        expect(posts.single['name'], 'sourceError');
        expect(posts.single['payload']['callId'], 'c1');
        expect(posts.single['payload']['message'], contains('circular'));
      });

      test('a BigInt result posts sourceError', () async {
        final posts = await _runHarness(
          'const source = { run: function () { return BigInt(1); } };',
        );
        expect(posts.single['name'], 'sourceError');
        expect(posts.single['payload']['message'], contains('BigInt'));
      });

      test('a throwing sourceResult post is reported as sourceError', () async {
        final posts = await _runHarness(
          'const source = { run: function () { return 1; } };',
          throwOn: 'sourceResult',
        );
        expect(posts, [
          {
            'name': 'sourceError',
            'payload': {
              'callId': 'c1',
              'message': 'post failed',
              'stack': isA<String>(),
            },
          },
        ]);
      });

      test('a throwing function reports its message and script line', () async {
        final posts = await _runHarness(
          'const source = {\n  run: function () {\n'
          "    throw new Error('boom');\n  },\n};",
        );
        expect(posts.single['name'], 'sourceError');
        expect(posts.single['payload']['message'], 'boom');
        expect(
          parseScriptLocation(posts.single['payload']['stack'] as String)?.line,
          3,
        );
      });

      test('posts the error line and column JavaScriptCore exposes', () async {
        // JavaScriptCore (iOS) leaves no file/line in the stack of eval'd
        // code but sets numeric `line`/`column` on the thrown Error, counted
        // from the eval'd text, i.e. the script's own line 1.
        final posts = await _runHarness(
          'const source = {\n  run: function () {\n'
          "    throw Object.assign(new Error('boom'), { line: 3, column: 11 });\n"
          '  },\n};',
        );
        expect(posts.single['name'], 'sourceError');
        expect(posts.single['payload']['line'], 3);
        expect(posts.single['payload']['column'], 11);
      });

      test('an error without line and column posts neither key', () async {
        final posts = await _runHarness(
          "const source = { run: function () { throw new Error('boom'); } };",
        );
        final payload = posts.single['payload'] as Map<String, dynamic>;
        expect(payload.containsKey('line'), isFalse);
        expect(payload.containsKey('column'), isFalse);
      });

      test('a line beyond the script is not posted', () async {
        // Errors raised by the harness or ctx helpers carry positions of the
        // harness text, never of the script.
        final posts = await _runHarness(
          'const source = { run: function () '
          "{ throw Object.assign(new Error('x'), { line: 900, column: 2 }); } };",
        );
        final payload = posts.single['payload'] as Map<String, dynamic>;
        expect(payload.containsKey('line'), isFalse);
        expect(payload.containsKey('column'), isFalse);
      });

      test('a script SyntaxError never carries a line', () async {
        // JavaScriptCore offsets a SyntaxError of eval'd code by the line of
        // the eval call (a harness line), so it must not be reported.
        final posts = await _runHarness(
          'const source = { run: function () { return 1 +; } };',
          prelude:
              'Object.defineProperty(SyntaxError.prototype, "line", '
              '{ value: 3 });',
        );
        final payload = posts.single['payload'] as Map<String, dynamic>;
        expect(payload['message'], isNotEmpty);
        expect(payload.containsKey('line'), isFalse);
      });

      group('ctx helper errors (real source_ctx.js)', () {
        // Every Error gets line 1 / column 1, as JavaScriptCore would set a
        // harness-file position on a ctx helper's error. Line 1 is inside
        // the script, so only the fromHarness flag can keep it out.
        const prelude =
            'Error.prototype.line = 1; Error.prototype.column = 1;'
            'document.querySelector = function () { return null; };';

        for (final (name, body) in [
          ('a waitFor timeout', "await ctx.waitFor('.never', 0);"),
          ('an absUrl failure', "ctx.absUrl('http://');"),
        ]) {
          test('$name posts no line or column', () async {
            final posts = await _runHarness(
              'const source = {\n  run: async function (ctx) {\n'
              '    $body\n  },\n};',
              prelude: prelude,
            );
            final payload = posts.single['payload'] as Map<String, dynamic>;
            expect(posts.single['name'], 'sourceError');
            expect(payload['message'], isNotEmpty);
            expect(payload.containsKey('line'), isFalse);
            expect(payload.containsKey('column'), isFalse);
          });
        }

        test('a throw in user code on line 3 still posts line 3', () async {
          final posts = await _runHarness(
            'const source = {\n  run: async function (ctx) {\n'
            "    throw Object.assign(new Error('mine'), { line: 3, column: 5 });\n"
            '  },\n};',
            prelude: prelude,
          );
          final payload = posts.single['payload'] as Map<String, dynamic>;
          expect(payload['line'], 3);
          expect(payload['column'], 5);
        });
      });

      test('the missing-function rejection never carries a line', () async {
        // ScriptSourceExternal tells "function not defined" from a script bug
        // by the absence of a line; the harness throws it at a harness line.
        final posts = await _runHarness(
          'Error.prototype.line = 2; Error.prototype.column = 1;\n'
          'const source = {};',
        );
        final payload = posts.single['payload'] as Map<String, dynamic>;
        expect(payload['message'], 'source.run is not a function');
        expect(payload.containsKey('line'), isFalse);
        expect(payload.containsKey('column'), isFalse);
      });

      test('U+2028/U+2029 in the script survive as escapes', () async {
        final posts = await _runHarness(
          "const source = { run: function () { return 'a\u2028b\u2029c'; } };",
        );
        expect(
          jsonDecode(posts.single['payload']['value'] as String),
          'a\u2028b\u2029c',
        );
      });
    },
  );

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

    test('escapes U+2028/U+2029 so literals stay valid on pre-ES2019 JS', () {
      final js = buildSourceHarness(
        ctxJs: '',
        code: 'a\u2028b\u2029c',
        function: 'f',
        argsJson: '[]',
        callId: 'c',
        baseUrl: 'https://x.y',
        pageFunction: false,
      );
      expect(js, isNot(contains('\u2028')));
      expect(js, isNot(contains('\u2029')));
      expect(js, contains(r'"a\u2028b\u2029c"'));
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
