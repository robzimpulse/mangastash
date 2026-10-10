// Tests for the fix-source prompt helpers (issue #115, spec §10.1):
// trimPageHtml, extractScriptFromReply and FixPromptBuilder.
//
// Usage: `fvm flutter test test/prompt` from module/domain/domain_manga. The
// builder tests read the real template from assets/prompt/ through an injected
// loadAsset, so no Flutter binding is needed.
import 'dart:io';

import 'package:domain_manga/src/prompt/fix_prompt_builder.dart';
import 'package:flutter_test/flutter_test.dart';

const _header =
    '// ==MangaStashSource==\n'
    '// { "id": "x", "name": "X" }\n'
    '// ==/MangaStashSource==';

void main() {
  group('trimPageHtml', () {
    test('removes script, style and svg and collapses whitespace', () {
      expect(
        trimPageHtml(
          '<p>a</p><script>x()</script><STYLE>b{}</STYLE><svg><g/></svg>  '
          '<p>b</p>',
        ),
        '<p>a</p> <p>b</p>',
      );
    });

    test('removes multiline blocks and tags with attributes', () {
      expect(
        trimPageHtml(
          '<p>a</p>\n<SCRIPT type="x">\n  var a = 1;\n</SCRIPT>\n'
          '<svg viewBox="0 0 1 1">\n<path/>\n</svg>\n<p>b</p>',
        ),
        '<p>a</p> <p>b</p>',
      );
    });

    test('appends a marker with the number of dropped characters', () {
      final trimmed = trimPageHtml('a' * 100001, maxChars: 100000);

      expect(trimmed.endsWith('<!-- truncated 1 chars -->'), isTrue);
      expect(trimmed, '${'a' * 100000}\n<!-- truncated 1 chars -->');
    });

    test('leaves input at exactly maxChars untouched', () {
      expect(trimPageHtml('a' * 10, maxChars: 10), 'a' * 10);
    });

    test('defaults to a 60000 character cap', () {
      final trimmed = trimPageHtml('a' * 60005);

      expect(trimmed, '${'a' * 60000}\n<!-- truncated 5 chars -->');
    });
  });

  group('extractScriptFromReply', () {
    test('first js/javascript fence wins over later ones', () {
      expect(
        extractScriptFromReply(
          'Here you go:\n```javascript\nA\n```\nand also\n```js\nB\n```\n',
        ),
        'A',
      );
    });

    test('js fence wins even when an earlier fence has another info string '
        'and the header', () {
      expect(
        extractScriptFromReply('```text\n$_header\nold\n```\n```js\nnew\n```'),
        'new',
      );
    });

    test('info string is case-insensitive', () {
      expect(extractScriptFromReply('```JS\nA\n```'), 'A');
      expect(extractScriptFromReply('```JavaScript\nA\n```'), 'A');
    });

    test('ignores prose around the fence', () {
      expect(
        extractScriptFromReply('Sure!\n\n```js\nconst a = 1;\n```\n\nEnjoy.'),
        'const a = 1;',
      );
    });

    test('normalizes CRLF to LF', () {
      expect(
        extractScriptFromReply('x\r\n```js\r\nline1\r\nline2\r\n```\r\n'),
        'line1\nline2',
      );
    });

    test('no fence but the header: the trimmed whole reply', () {
      expect(
        extractScriptFromReply('\n  $_header\nconst source = {};\n\n'),
        '$_header\nconst source = {};',
      );
    });

    test('fence without info string containing the header: its content', () {
      expect(
        extractScriptFromReply('```\n$_header\nconst source = {};\n```'),
        '$_header\nconst source = {};',
      );
    });

    test('other info string containing the header: its content', () {
      expect(extractScriptFromReply('```text\n$_header\n```'), _header);
    });

    test('skips fences without the header, takes the first with it', () {
      expect(
        extractScriptFromReply('```json\n{}\n```\n```\n$_header\n```'),
        _header,
      );
    });

    test('fence without header and prose-only reply: null', () {
      expect(extractScriptFromReply('```json\n{}\n```'), isNull);
      expect(extractScriptFromReply('sorry, cannot help'), isNull);
      expect(extractScriptFromReply(''), isNull);
    });

    test('an empty js fence yields an empty string', () {
      expect(extractScriptFromReply('```js\n```'), '');
      expect(extractScriptFromReply('```js\n\n```'), '');
    });

    test('an unterminated js fence yields null', () {
      expect(extractScriptFromReply('```js\nconst a = 1;'), isNull);
    });

    test('a template literal inside the code does not end the fence', () {
      expect(
        extractScriptFromReply('```js\nconst a = `x`;\n```\ntail'),
        'const a = `x`;',
      );
    });
  });

  group('FixPromptBuilder', () {
    late String template;

    setUp(() {
      template = File('assets/prompt/fix_source_prompt.md').readAsStringSync();
    });

    test('loads the template from the packaged asset path', () async {
      String? requested;
      final builder = FixPromptBuilder(
        loadAsset: (path) async {
          requested = path;
          return template;
        },
      );

      await builder.build(
        code: 'c',
        function: 'search',
        url: 'u',
        errorMessage: 'e',
        html: 'h',
      );

      expect(
        requested,
        'packages/domain_manga/assets/prompt/fix_source_prompt.md',
      );
    });

    test('fills every section of the real template', () async {
      final builder = FixPromptBuilder(loadAsset: (_) async => template);

      final prompt = await builder.build(
        code: 'const source = { marker: 1 };',
        function: 'search',
        url: 'https://example.com/browse?page=1',
        errorMessage: 'search returned 0 items',
        html: '<p>a</p><script>x()</script>${'z' * 70000}',
      );

      expect(prompt, contains('const source = { marker: 1 };'));
      expect(prompt, contains('search'));
      expect(prompt, contains('https://example.com/browse?page=1'));
      expect(prompt, contains('search returned 0 items'));
      expect(prompt, contains('<!-- truncated'));
      expect(prompt, isNot(contains('x()')));
      expect(prompt, contains('```js'));
      for (final placeholder in const [
        '{{script}}',
        '{{function}}',
        '{{url}}',
        '{{error}}',
        '{{html}}',
      ]) {
        expect(prompt, isNot(contains(placeholder)));
      }
    });

    test('real template states the contract and the rules', () {
      for (final needle in const [
        '==MangaStashSource==',
        'contract',
        'hosts',
        'timeouts',
        'searchUrl',
        'chaptersUrl',
        'tagsUrl',
        'hasNextPage',
        'coverUrl',
        'readableAt',
        'scanlationGroup',
        'ctx.waitFor',
        'ctx.sleep',
        'ctx.absUrl',
        'ctx.searchTerm',
        'version',
        'iOS 13',
        '{{script}}',
        '{{function}}',
        '{{url}}',
        '{{error}}',
        '{{html}}',
      ]) {
        expect(template, contains(needle), reason: needle);
      }
    });

    test(
      'substitutes in a single pass: values are never re-expanded',
      () async {
        final builder = FixPromptBuilder(
          loadAsset:
              (_) async =>
                  '[{{script}}][{{function}}][{{url}}][{{error}}][{{html}}]',
        );

        final prompt = await builder.build(
          code: 'code {{html}} {{error}}',
          function: '{{script}}',
          url: '{{function}}',
          errorMessage: '{{url}}',
          html: '<p>{{script}}</p>',
        );

        expect(
          prompt,
          '[code {{html}} {{error}}][{{script}}][{{function}}]'
          '[{{url}}][<p>{{script}}</p>]',
        );
      },
    );

    test('unknown placeholders in the template are left as they are', () async {
      final builder = FixPromptBuilder(
        loadAsset: (_) async => '{{other}} {{script}}',
      );

      expect(
        await builder.build(
          code: 'c',
          function: 'f',
          url: 'u',
          errorMessage: 'e',
          html: 'h',
        ),
        '{{other}} c',
      );
    });
  });
}
