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

    test('the over-budget cut snaps back to the last complete tag', () {
      // A raw offset cut can split a tag or entity; the fixer must never see
      // one (review on #194). 100 chars in, the offset lands inside
      // `<div class="grid">`; the cut snaps back to the `>` of `</p>`.
      final html = '<p>${'a' * 90}</p><div class="grid">${'b' * 40}';
      final trimmed = trimPageHtml(html, maxChars: 100);

      expect(trimmed, '<p>${'a' * 90}</p>\n<!-- truncated 58 chars -->');
    });

    test('leaves input at exactly maxChars untouched', () {
      expect(trimPageHtml('a' * 10, maxChars: 10), 'a' * 10);
    });

    test('defaults to a 60000 character cap', () {
      final trimmed = trimPageHtml('a' * 60005);

      expect(trimmed, '${'a' * 60000}\n<!-- truncated 5 chars -->');
    });

    test('keeps the cards of a real-shaped page inside the cap (bug H)', () {
      // The head (meta/link/scripts) and a huge astro-island props attribute
      // used to eat the whole budget so the cards were cut off.
      final head = StringBuffer('<!DOCTYPE html><html><head>')
        ..write('<title>Browse - Asura</title>');
      for (var i = 0; i < 400; i++) {
        head.write('<meta property="og:x$i" content="${'m' * 150}">');
        head.write('<link rel="preload" href="/a$i.js" as="script">');
      }
      head.write('<script>var big = "${'s' * 80000}";</script></head>');
      final body =
          StringBuffer('<body>')
            ..write('<astro-island props="${'{&quot;k&quot;:1}' * 20000}">')
            ..write('<div class="grid">');
      for (var i = 0; i < 50; i++) {
        body.write(
          '<div class="series-card rounded-md"><a href="/comics/s$i">'
          '<img src="/c$i.jpg"><h3>Series $i</h3></a></div>',
        );
      }
      body.write('</div></astro-island></body></html>');

      final trimmed = trimPageHtml('$head$body');

      expect('series-card'.allMatches(trimmed), hasLength(50));
      expect(trimmed, contains('<title>Browse - Asura</title>'));
      expect(trimmed, isNot(contains('og:x')));
      expect(trimmed, isNot(contains('<link')));
      expect(trimmed, isNot(contains('truncated')));
      expect(trimmed.length, lessThan(60000));
    });

    test('drops the head except the title', () {
      expect(
        trimPageHtml(
          '<html><head><meta charset="utf-8"><TITLE>My Page</TITLE>'
          '<link rel="x"></head><body><p>a</p></body></html>',
        ),
        '<html><title>My Page</title><body><p>a</p></body></html>',
      );
      expect(
        trimPageHtml('<head><meta charset="utf-8"></head><p>a</p>'),
        '<p>a</p>',
      );
    });

    test('does not mistake header for head', () {
      expect(
        trimPageHtml('<header><p>a</p></header>'),
        '<header><p>a</p></header>',
      );
    });

    test('removes comments and noscript blocks', () {
      expect(
        trimPageHtml(
          '<p>a</p><!-- hidden <p>x</p> --><noscript><img src="t.gif">'
          '</noscript><p>b</p>',
        ),
        '<p>a</p><p>b</p>',
      );
    });

    test('truncates attribute values longer than 200 characters', () {
      final long = 'x' * 201;
      expect(
        trimPageHtml('<div data-a="$long" data-b=\'$long\' class="ok">t</div>'),
        '<div data-a="${'x' * 200}…" data-b=\'${'x' * 200}…\' class="ok">'
        't</div>',
      );
      // Exactly 200 stays untouched.
      final edge = '<a href="${'y' * 200}">t</a>';
      expect(trimPageHtml(edge), edge);
    });

    test('a > or < inside an attribute value does not end the tag', () {
      expect(
        trimPageHtml('<a title="1 > 0 <b>" href="/x">t</a>'),
        '<a title="1 > 0 <b>" href="/x">t</a>',
      );
    });

    test('stray less-than signs in text are kept', () {
      expect(
        trimPageHtml('<p>1 < 2 and 3 <= 4</p>'),
        '<p>1 < 2 and 3 <= 4</p>',
      );
    });

    test('many empty heads stay linear', () {
      final watch = Stopwatch()..start();

      expect(trimPageHtml('<head></head>' * 100000), '');
      expect(trimPageHtml('<head></head><p>a</p>' * 3), '<p>a</p>' * 3);

      expect(watch.elapsed, lessThan(const Duration(seconds: 5)));
    });

    test('unterminated blocks and comments drop the rest without hanging', () {
      final watch = Stopwatch()..start();

      expect(trimPageHtml('<p>a</p><script>never closed'), '<p>a</p>');
      expect(trimPageHtml('<p>a</p><!-- never closed'), '<p>a</p>');
      // Many unterminated openers must stay linear, not quadratic.
      expect(trimPageHtml('<svg ' * 200000), '');
      expect(trimPageHtml('<!-- ' * 200000), '');
      expect(trimPageHtml('<a href="' * 100000), isNotEmpty);

      expect(watch.elapsed, lessThan(const Duration(seconds: 5)));
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

    test('no fence but the header: the reply from the marker on', () {
      expect(
        extractScriptFromReply('\n  $_header\nconst source = {};\n\n'),
        '$_header\nconst source = {};',
      );
      // Leading prose would make SourceScript.parse reject the paste ("must
      // start with header"), so it is cut off (review on #194).
      expect(
        extractScriptFromReply('Here is the fixed script:\n$_header\nx\n'),
        '$_header\nx',
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

    test('an empty js fence does not shadow a later valid block', () {
      // ```js\n``` used to win the first pass and return '', hiding a later
      // valid block (review on #194).
      expect(
        extractScriptFromReply('```js\n```\n```js\n$_header\n```'),
        _header,
      );
      // A lone empty js fence yields null, not ''.
      expect(extractScriptFromReply('```js\n```'), isNull);
      expect(extractScriptFromReply('```js\n\n```'), isNull);
    });

    test('info string variants name JavaScript', () {
      expect(extractScriptFromReply('```js run\nA\n```'), 'A');
      expect(extractScriptFromReply('```javascript:file\nA\n```'), 'A');
      expect(extractScriptFromReply('~~~js\nA\n~~~'), 'A');
      // jsx/ts do not name our script; the header pass still finds them.
      expect(extractScriptFromReply('```jsx\n$_header\n```'), _header);
      expect(extractScriptFromReply('```ts\nA\n```'), isNull);
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
        '{{stack}}',
        '{{html}}',
      ]) {
        expect(prompt, isNot(contains(placeholder)));
      }
      // No stack in this run: the section stays empty instead of naming a
      // frame that does not exist.
      expect(prompt, contains('<stack>\n\n</stack>'));
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
        'iOS 13.4',
        '{{script}}',
        '{{function}}',
        '{{url}}',
        '{{error}}',
        '{{stack}}',
        '{{html}}',
      ]) {
        expect(template, contains(needle), reason: needle);
      }
    });

    test('the stack lands in its own section', () async {
      final builder = FixPromptBuilder(
        loadAsset: (_) async => '<stack>\n{{stack}}\n</stack>',
      );

      final prompt = await builder.build(
        code: 'c',
        function: 'search',
        url: 'u',
        errorMessage: 'e',
        html: 'h',
        stack: 'search@source.js:3:7',
      );

      expect(prompt, '<stack>\nsearch@source.js:3:7\n</stack>');
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
