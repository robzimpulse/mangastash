// Tests for ScriptSourceExternal (issue #115, spec §7): the SourceExternal
// adapter that runs a JS source script through RunSourceScriptUseCase and maps
// its JSON results to the *Scrapped models. The runner is a mocktail mock, so
// these tests pin the call shapes (function, args, searchTerm, timeout) and the
// error mapping (runner errors gain the source name; malformed results become
// SourceScriptException 'Invalid result: ...').
// Run: fvm flutter test test/sources/script_source_external_test.dart
import 'package:core_network/core_network.dart';
import 'package:domain_manga/src/sources/script_source_external.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:mocktail/mocktail.dart';

class MockRunSourceScriptUseCase extends Mock
    implements RunSourceScriptUseCase {}

String code({String body = '', String timeouts = '{"search": 20000}'}) {
  return '// ==MangaStashSource==\n'
      '// {"id": "my-site", "name": "My Site", '
      '"baseUrl": "https://my-site.com", "iconUrl": "https://my-site.com/i.png", '
      '"version": 1, "contract": 1, "hosts": ["my-site.com"], '
      '"timeouts": $timeouts}\n'
      '// ==/MangaStashSource==\n'
      'const source = {$body};\n';
}

void main() {
  late MockRunSourceScriptUseCase runner;
  late SourceScript script;
  late ScriptSourceExternal source;

  void stubPage(String function, Object? value) {
    when(
      () => runner.runOnPage(
        url: any(named: 'url'),
        code: any(named: 'code'),
        function: function,
        baseUrl: any(named: 'baseUrl'),
        searchTerm: any(named: 'searchTerm'),
        timeout: any(named: 'timeout'),
        useCache: any(named: 'useCache'),
      ),
    ).thenAnswer(
      (_) async => ScriptRunResult(value: value, elapsed: Duration.zero),
    );
  }

  void stubBlank(String function, Object? value) {
    when(
      () => runner.runOnBlank(
        code: any(named: 'code'),
        function: function,
        baseUrl: any(named: 'baseUrl'),
        args: any(named: 'args'),
        timeout: any(named: 'timeout'),
      ),
    ).thenAnswer((_) async => value);
  }

  void stubBlankThrows(String function, SourceScriptException error) {
    when(
      () => runner.runOnBlank(
        code: any(named: 'code'),
        function: function,
        baseUrl: any(named: 'baseUrl'),
        args: any(named: 'args'),
        timeout: any(named: 'timeout'),
      ),
    ).thenThrow(error);
  }

  setUp(() {
    runner = MockRunSourceScriptUseCase();
    script = SourceScript.parse(code());
    source = ScriptSourceExternal(script: script, runner: runner);
  });

  test('exposes the script header as source metadata', () {
    expect(source.name, 'My Site');
    expect(source.baseUrl, 'https://my-site.com');
    expect(source.iconUrl, 'https://my-site.com/i.png');
    expect(source.builtIn, isFalse);
  });

  test('equality follows the script', () {
    expect(
      ScriptSourceExternal(script: script, runner: runner),
      ScriptSourceExternal(
        script: script,
        runner: MockRunSourceScriptUseCase(),
      ),
    );
    expect(
      ScriptSourceExternal(
        script: SourceScript.parse(code(body: 'edited: 1')),
        runner: runner,
      ),
      isNot(source),
    );
  });

  group('search', () {
    test('runs search on the page with the search term and timeout', () async {
      stubPage('search', {
        'items': [
          {'title': 'A', 'webUrl': 'u'},
        ],
        'hasNextPage': true,
      });

      final result = await source.search(url: 'https://p', searchTerm: 'q');

      expect(
        result,
        const SearchResultScrapped(
          items: [MangaScrapped(title: 'A', webUrl: 'u')],
          hasNextPage: true,
        ),
      );
      verify(
        () => runner.runOnPage(
          url: 'https://p',
          code: script.code,
          function: 'search',
          baseUrl: 'https://my-site.com',
          searchTerm: 'q',
          timeout: script.timeoutFor('search'),
          useCache: true,
        ),
      ).called(1);
      expect(script.timeoutFor('search'), const Duration(seconds: 20));
    });

    test('a malformed result throws SourceScriptException Invalid result', () {
      stubPage('search', {'items': 'nope'});

      expect(
        source.search(url: 'https://p'),
        throwsA(
          isA<SourceScriptException>()
              .having((e) => e.function, 'function', 'search')
              .having((e) => e.source, 'source', 'My Site')
              .having(
                (e) => e.message,
                'message',
                startsWith('Invalid result'),
              ),
        ),
      );
    });

    test('a non-object result throws Invalid result', () {
      stubPage('search', ['not', 'a', 'map']);

      expect(
        source.search(url: 'https://p'),
        throwsA(
          isA<SourceScriptException>().having(
            (e) => e.message,
            'message',
            startsWith('Invalid result'),
          ),
        ),
      );
    });
  });

  test('a runner SourceScriptException surfaces with the source name', () {
    when(
      () => runner.runOnPage(
        url: any(named: 'url'),
        code: any(named: 'code'),
        function: 'manga',
        baseUrl: any(named: 'baseUrl'),
        searchTerm: any(named: 'searchTerm'),
        timeout: any(named: 'timeout'),
        useCache: any(named: 'useCache'),
      ),
    ).thenThrow(const SourceScriptException(function: 'manga', message: 'x'));

    expect(
      source.manga(url: 'https://p'),
      throwsA(
        isA<SourceScriptException>()
            .having((e) => e.source, 'source', 'My Site')
            .having((e) => e.message, 'message', 'x'),
      ),
    );
  });

  test('manga maps the result object', () async {
    stubPage('manga', {
      'title': 'T',
      'tags': ['a'],
    });

    final result = await source.manga(url: 'https://p', useCache: false);

    expect(result, const MangaScrapped(title: 'T', tags: ['a']));
    verify(
      () => runner.runOnPage(
        url: 'https://p',
        code: script.code,
        function: 'manga',
        baseUrl: 'https://my-site.com',
        timeout: script.timeoutFor('manga'),
        useCache: false,
      ),
    ).called(1);
  });

  test('chapters maps a list of objects', () async {
    stubPage('chapters', [
      {'webUrl': 'c1', 'chapter': '1'},
    ]);

    final result = await source.chapters(url: 'https://p');

    expect(result, const [ChapterScrapped(webUrl: 'c1', chapter: '1')]);
  });

  test('chapters rejects a non-list result', () {
    stubPage('chapters', {'webUrl': 'c1'});

    expect(
      source.chapters(url: 'https://p'),
      throwsA(
        isA<SourceScriptException>()
            .having((e) => e.function, 'function', 'chapters')
            .having((e) => e.message, 'message', startsWith('Invalid result')),
      ),
    );
  });

  test('images maps a list of strings and rejects other shapes', () async {
    stubPage('images', ['i1', 'i2']);
    expect(await source.images(url: 'https://p'), ['i1', 'i2']);

    stubPage('images', ['i1', 2]);
    await expectLater(
      source.images(url: 'https://p'),
      throwsA(
        isA<SourceScriptException>().having(
          (e) => e.message,
          'message',
          startsWith('Invalid result'),
        ),
      ),
    );
  });

  test('tags maps a list of objects', () async {
    stubPage('tags', [
      {'id': 'action', 'name': 'Action'},
    ]);

    expect(await source.tags(url: 'https://p'), const [
      TagScrapped(id: 'action', name: 'Action'),
    ]);
  });

  group('searchUrl', () {
    test('runs searchUrl on the blank page with the parameter json', () async {
      const parameter = SearchMangaParameter(title: 'x', page: 2);
      stubBlank('searchUrl', 'https://my-site.com/search?q=x&page=2');

      final url = await source.searchUrl(parameter: parameter);

      expect(url, 'https://my-site.com/search?q=x&page=2');
      verify(
        () => runner.runOnBlank(
          code: script.code,
          function: 'searchUrl',
          baseUrl: 'https://my-site.com',
          args: [parameter.toJson()],
          timeout: script.timeoutFor('searchUrl'),
        ),
      ).called(1);
    });

    test('a non-string result throws Invalid result', () {
      stubBlank('searchUrl', 42);

      expect(
        source.searchUrl(parameter: const SearchMangaParameter()),
        throwsA(
          isA<SourceScriptException>().having(
            (e) => e.message,
            'message',
            startsWith('Invalid result'),
          ),
        ),
      );
    });
  });

  group('chaptersUrl', () {
    test('returns webUrl when the script has no chaptersUrl', () async {
      stubBlankThrows(
        'chaptersUrl',
        const SourceScriptException(
          function: 'chaptersUrl',
          message: 'source.chaptersUrl is not a function',
        ),
      );

      expect(await source.chaptersUrl(webUrl: 'https://w'), 'https://w');
    });

    test('returns the script result when defined', () async {
      stubBlank('chaptersUrl', 'https://w/full');

      expect(await source.chaptersUrl(webUrl: 'https://w'), 'https://w/full');
      verify(
        () => runner.runOnBlank(
          code: script.code,
          function: 'chaptersUrl',
          baseUrl: 'https://my-site.com',
          args: ['https://w'],
          timeout: script.timeoutFor('chaptersUrl'),
        ),
      ).called(1);
    });

    test(
      'a script error that merely mentions "is not a function" surfaces',
      () {
        // A TypeError inside the user's own chaptersUrl must not be mistaken
        // for "function not defined": it carries a script line.
        stubBlankThrows(
          'chaptersUrl',
          const SourceScriptException(
            function: 'chaptersUrl',
            message: 'foo is not a function',
            line: 12,
          ),
        );

        expect(
          source.chaptersUrl(webUrl: 'https://w'),
          throwsA(
            isA<SourceScriptException>().having(
              (e) => e.source,
              'source',
              'My Site',
            ),
          ),
        );
      },
    );
  });

  group('tagsUrl', () {
    test('falls back to searchUrl(page: 1) when not defined', () async {
      stubBlankThrows(
        'tagsUrl',
        const SourceScriptException(
          function: 'tagsUrl',
          message: 'source.tagsUrl is not a function',
        ),
      );
      stubBlank('searchUrl', 'https://my-site.com/browse');

      expect(await source.tagsUrl(), 'https://my-site.com/browse');
      verify(
        () => runner.runOnBlank(
          code: script.code,
          function: 'searchUrl',
          baseUrl: 'https://my-site.com',
          args: [const SearchMangaParameter(page: 1).toJson()],
          timeout: script.timeoutFor('searchUrl'),
        ),
      ).called(1);
    });

    test('falls back to searchUrl(page: 1) when it returns null', () async {
      stubBlank('tagsUrl', null);
      stubBlank('searchUrl', 'https://my-site.com/browse');

      expect(await source.tagsUrl(), 'https://my-site.com/browse');
    });

    test('returns the script result when it is a string', () async {
      stubBlank('tagsUrl', 'https://my-site.com/genres');

      expect(await source.tagsUrl(), 'https://my-site.com/genres');
    });
  });
}
