// ScriptSourceExternal (issue #115, spec §7): the single SourceExternal
// adapter for JavaScript sources. Each hook runs the matching function of
// [ScriptSourceExternal.script] through [RunSourceScriptUseCase] — page
// functions (search, manga, chapters, images, tags) inside the loaded page via
// `runOnPage`, URL builders (searchUrl, chaptersUrl, tagsUrl) in the warm blank
// webview via `runOnBlank` — with the script's per-function timeout, and maps
// the JSON result to the *Scrapped models.
//
// Errors: a runner `SourceScriptException` is rethrown with `source` set to the
// script's name; a result of the wrong shape (fromJson `FormatException`, a
// non-object/non-list/non-string value) becomes
// `SourceScriptException(function: <fn>, message: 'Invalid result: <why>')`;
// for page functions it also carries the page `url` and the runner's cached
// result for that url is evicted first (the runner caches before this check,
// so a half-loaded page's bad JSON would otherwise be served for 30 minutes).
// Domain validation (missing titles, zero chapters/images) stays in the use
// cases, which evict the runner's cached result when it fails.
//
// Optional functions: `chaptersUrl` defaults to the series webUrl and
// `tagsUrl` (also when it returns null) to `searchUrl({page: 1})`. "Not
// defined" is detected from the harness's own rejection
// `source.<fn> is not a function`, which never carries a script line — a
// TypeError raised inside a defined function points at a script line and is
// rethrown, so a bug in the script is never mistaken for an absent function.
//
// Usage:
//   final source = ScriptSourceExternal(script: script, runner: runner);
//   final url = await source.searchUrl(parameter: parameter);
//   final page = await source.search(url: url, searchTerm: parameter.title);
// Instances are equal when their scripts are equal (`props: [script]`).
import 'package:core_network/core_network.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:equatable/equatable.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

class ScriptSourceExternal extends Equatable implements SourceExternal {
  const ScriptSourceExternal({
    required this.script,
    required RunSourceScriptUseCase runner,
  }) : _runner = runner;

  final SourceScript script;
  final RunSourceScriptUseCase _runner;

  @override
  String get name => script.name;

  @override
  String get iconUrl => script.iconUrl;

  @override
  String get baseUrl => script.baseUrl;

  @override
  bool get builtIn => false;

  @override
  Future<String> searchUrl({required SearchMangaParameter parameter}) async {
    const function = 'searchUrl';
    final value = await _blank(function, args: [parameter.toJson()]);
    return _map(function, () => _string(value));
  }

  @override
  Future<SearchResultScrapped> search({
    required String url,
    String? searchTerm,
    bool useCache = true,
  }) async {
    const function = 'search';
    final value = await _page(
      function,
      url: url,
      searchTerm: searchTerm,
      useCache: useCache,
    );
    return _mapPage(function, url, () {
      return SearchResultScrapped.fromJson(_object(value));
    });
  }

  @override
  Future<MangaScrapped> manga({
    required String url,
    bool useCache = true,
  }) async {
    const function = 'manga';
    final value = await _page(function, url: url, useCache: useCache);
    return _mapPage(
      function,
      url,
      () => MangaScrapped.fromJson(_object(value)),
    );
  }

  @override
  Future<String> chaptersUrl({required String webUrl}) async {
    const function = 'chaptersUrl';
    final value = await _optionalBlank(function, args: [webUrl]);
    if (value == null) return webUrl;
    return _map(function, () => _string(value));
  }

  @override
  Future<List<ChapterScrapped>> chapters({
    required String url,
    bool useCache = true,
  }) async {
    const function = 'chapters';
    final value = await _page(function, url: url, useCache: useCache);
    return _mapPage(function, url, () {
      return [
        for (final row in _list(value)) ChapterScrapped.fromJson(_object(row)),
      ];
    });
  }

  @override
  Future<List<String>> images({
    required String url,
    bool useCache = true,
  }) async {
    const function = 'images';
    final value = await _page(function, url: url, useCache: useCache);
    return _mapPage(function, url, () {
      return [for (final e in _list(value)) _string(e)];
    });
  }

  @override
  Future<String> tagsUrl() async {
    const function = 'tagsUrl';
    final value = await _optionalBlank(function);
    if (value == null) {
      return searchUrl(parameter: const SearchMangaParameter(page: 1));
    }
    return _map(function, () => _string(value));
  }

  @override
  Future<List<TagScrapped>> tags({
    required String url,
    bool useCache = true,
  }) async {
    const function = 'tags';
    final value = await _page(function, url: url, useCache: useCache);
    return _mapPage(function, url, () {
      return [
        for (final tag in _list(value)) TagScrapped.fromJson(_object(tag)),
      ];
    });
  }

  Future<Object?> _page(
    String function, {
    required String url,
    String? searchTerm,
    required bool useCache,
  }) async {
    try {
      final result = await _runner.runOnPage(
        url: url,
        code: script.code,
        function: function,
        baseUrl: script.baseUrl,
        searchTerm: searchTerm,
        timeout: script.timeoutFor(function),
        useCache: useCache,
      );
      return result.value;
    } on SourceScriptException catch (e) {
      throw e.copyWith(source: name);
    }
  }

  Future<Object?> _blank(
    String function, {
    List<Object?> args = const [],
  }) async {
    try {
      return await _runner.runOnBlank(
        code: script.code,
        function: function,
        baseUrl: script.baseUrl,
        args: args,
        timeout: script.timeoutFor(function),
      );
    } on SourceScriptException catch (e) {
      throw e.copyWith(source: name);
    }
  }

  /// Runs an optional URL builder; null when the script does not define it.
  Future<Object?> _optionalBlank(
    String function, {
    List<Object?> args = const [],
  }) async {
    try {
      return await _blank(function, args: args);
    } on SourceScriptException catch (e) {
      final missing =
          e.line == null && e.message == 'source.$function is not a function';
      if (missing) return null;
      rethrow;
    }
  }

  /// Runs [convert], turning a malformed result into a SourceScriptException.
  T _map<T>(String function, T Function() convert) {
    try {
      return convert();
    } on FormatException catch (e) {
      throw SourceScriptException(
        function: function,
        message: 'Invalid result: ${e.message}',
        source: name,
      );
    }
  }

  /// [_map] for a page function's result fetched from [url]: a malformed
  /// result first evicts the runner's cached results for [url], and the
  /// exception carries [url] (the page to recrawl or fix against).
  Future<T> _mapPage<T>(
    String function,
    String url,
    T Function() convert,
  ) async {
    try {
      return convert();
    } on FormatException catch (e) {
      await _runner.evict(url: url);
      throw SourceScriptException(
        function: function,
        message: 'Invalid result: ${e.message}',
        url: url,
        source: name,
      );
    }
  }

  static Map<String, dynamic> _object(Object? value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    throw FormatException('expected an object, got ${_type(value)}');
  }

  static List<Object?> _list(Object? value) {
    if (value is List) return value;
    throw FormatException('expected a list, got ${_type(value)}');
  }

  static String _string(Object? value) {
    if (value is String) return value;
    throw FormatException('expected a string, got ${_type(value)}');
  }

  static String _type(Object? value) {
    return value == null ? 'null' : value.runtimeType.toString();
  }

  @override
  List<Object?> get props => [script];
}
