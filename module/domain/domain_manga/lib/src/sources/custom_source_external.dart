/// A custom external source implementation that delegates parsing and URL generation
/// to a dynamically evaluated Dart script.
///
/// **Business/Technical Purpose:**
/// This class acts as an adapter between the app's standard `SourceExternal` interface
/// and user-provided custom scraper scripts. It allows users to side-load their own
/// scraper logic without rebuilding the app.
///
/// **Usage Instructions:**
/// 1. Use [CustomSourceExternal.fromScript] to instantiate this class with the
///    script's raw source code.
/// 2. Use this source like any other `SourceExternal` implementation.
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:html/dom.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import 'custom_script_executor.dart';

/// Implements [SourceExternal] by delegating to [CustomScriptExecutor].
class CustomSourceExternal extends SourceExternal {
  /// The underlying script executor.
  final CustomScriptExecutor _executor;
  final String _name;
  final String _baseUrl;
  final String _iconUrl;

  /// Creates a new [CustomSourceExternal] with the given parameters.
  CustomSourceExternal({
    required CustomScriptExecutor executor,
    required String name,
    required String baseUrl,
    required String iconUrl,
  }) : _executor = executor,
       _name = name,
       _baseUrl = baseUrl,
       _iconUrl = iconUrl;

  /// Creates a [CustomSourceExternal] by evaluating the given script code to
  /// extract metadata.
  static CustomSourceExternal fromScript(String scriptCode) {
    final executor = CustomScriptExecutor(scriptCode);
    final metaValue = executor.invoke('getMetadata', []) as Map;
    final meta = metaValue.map((k, v) => MapEntry(k.toString(), v.toString()));
    return CustomSourceExternal(
      executor: executor,
      name: meta['name'] ?? 'Unknown',
      baseUrl: meta['baseUrl'] ?? '',
      iconUrl: meta['iconUrl'] ?? '',
    );
  }

  @override
  String get name => _name;

  @override
  String get baseUrl => _baseUrl;

  @override
  String get iconUrl => _iconUrl;

  @override
  GetMangaSourceExternalUseCase get getMangaUseCase => _GetManga(_executor);

  @override
  GetChapterImageSourceExternalUseCase get getChapterImageUseCase =>
      _GetChapterImage(_executor);

  @override
  SearchMangaSourceExternalUseCase get searchMangaUseCase =>
      _SearchManga(_executor);

  @override
  ListChapterSourceExternalUseCase get listChapterUseCase =>
      _ListChapter(_executor);

  @override
  ListTagSourceExternalUseCase get listTagUseCase => _ListTag(_executor);
}

class _GetManga implements GetMangaSourceExternalUseCase {
  final CustomScriptExecutor _executor;

  _GetManga(this._executor);

  @override
  Duration? get timeout => const Duration(seconds: 15);

  @override
  List<String> get scripts => [];

  @override
  Future<MangaScrapped> parse({required Document root}) async {
    final res = _executor.invoke('parseManga', [$Document.wrap(root)]) as Map;
    return MangaScrapped(
      title: res['title']?.toString(),
      author: res['author']?.toString(),
      coverUrl: res['coverUrl']?.toString(),
      description: res['description']?.toString(),
      tags: (res['tags'] as List?)?.map((e) => e.toString()).toList(),
    );
  }
}

class _GetChapterImage implements GetChapterImageSourceExternalUseCase {
  final CustomScriptExecutor _executor;

  _GetChapterImage(this._executor);

  @override
  Duration? get timeout => const Duration(seconds: 15);

  @override
  List<String> get scripts => [];

  @override
  Future<List<String>> parse({required Document root}) async {
    final res =
        _executor.invoke('parseChapterImages', [$Document.wrap(root)]) as List;
    return res.map((e) => e.toString()).toList();
  }
}

class _SearchManga implements SearchMangaSourceExternalUseCase {
  final CustomScriptExecutor _executor;

  _SearchManga(this._executor);

  @override
  Duration? get timeout => const Duration(seconds: 15);

  @override
  List<String> get scripts => [];

  @override
  Future<bool?> haveNextPage({required Document root}) async {
    return _executor.invoke('haveNextPage', [$Document.wrap(root)]) as bool?;
  }

  @override
  Future<List<MangaScrapped>> parse({required Document root}) async {
    final res =
        _executor.invoke('parseSearchManga', [$Document.wrap(root)]) as List;
    return res.map((item) {
      final map = item as Map;
      return MangaScrapped(
        title: map['title']?.toString(),
        coverUrl: map['coverUrl']?.toString(),
        webUrl: map['webUrl']?.toString(),
        status: map['status']?.toString(),
        tags: (map['tags'] as List?)?.map((e) => e.toString()).toList(),
      );
    }).toList();
  }

  @override
  String url({required SearchMangaParameter parameter}) {
    return _executor.invoke('searchMangaUrl', [
          parameter.page,
          parameter.title ?? '',
          parameter.status?.map((e) => e.name).toList() ?? [],
          parameter.includedTags ?? [],
          parameter.includedTagsMode.name,
        ])
        as String;
  }
}

class _ListChapter implements ListChapterSourceExternalUseCase {
  final CustomScriptExecutor _executor;

  _ListChapter(this._executor);

  @override
  Duration? get timeout => const Duration(seconds: 15);

  @override
  List<String> get scripts => [];

  @override
  Future<List<ChapterScrapped>> parse({required Document root}) async {
    final res =
        _executor.invoke('parseChapters', [$Document.wrap(root)]) as List;
    return res.map((item) {
      final map = item as Map;
      return ChapterScrapped(
        title: map['title']?.toString(),
        chapter: map['chapter']?.toString(),
        readableAt: map['readableAt']?.toString(),
        webUrl: map['webUrl']?.toString(),
      );
    }).toList();
  }
}

class _ListTag implements ListTagSourceExternalUseCase {
  final CustomScriptExecutor _executor;

  _ListTag(this._executor);

  @override
  Duration? get timeout => const Duration(seconds: 15);

  @override
  List<String> get scripts => [];

  @override
  Future<List<TagScrapped>> parse({required Document root}) async {
    final res = _executor.invoke('parseTags', [$Document.wrap(root)]) as List;
    return res.map((item) {
      final map = item as Map;
      return TagScrapped(
        id: map['id']?.toString(),
        name: map['name']?.toString(),
      );
    }).toList();
  }
}
