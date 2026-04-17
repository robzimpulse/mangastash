import 'package:dart_eval/dart_eval.dart';
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:html/dom.dart';
import 'model/source_metadata.dart';
import 'bridge/html_bridge.dart';
import 'bridge/manga_external_bridge.dart';

class DynamicSourceExternal implements SourceExternal {
  final Runtime runtime;
  final SourceMetadata metadata;

  DynamicSourceExternal(this.runtime, this.metadata);

  @override
  String get baseUrl => metadata.baseUrl;

  @override
  String get iconUrl => metadata.iconUrl;

  @override
  String get name => metadata.name;

  @override
  bool get builtIn => false;

  @override
  SearchMangaSourceExternalUseCase get searchMangaUseCase =>
      _DynamicSearchMangaUseCase(runtime);

  @override
  GetChapterImageSourceExternalUseCase get getChapterImageUseCase => _DynamicGetChapterImageUseCase(runtime);

  @override
  GetMangaSourceExternalUseCase get getMangaUseCase => _DynamicGetMangaUseCase(runtime);

  @override
  ListChapterSourceExternalUseCase get listChapterUseCase => _DynamicListChapterUseCase(runtime);

  @override
  ListTagSourceExternalUseCase get listTagUseCase => throw UnimplementedError();
}

class _DynamicGetMangaUseCase implements GetMangaSourceExternalUseCase {
  final Runtime runtime;

  _DynamicGetMangaUseCase(this.runtime);

  @override
  Duration? get timeout => const Duration(seconds: 20);

  @override
  List<String> get scripts {
    final result = runtime.executeLib('package:provider/main.dart', 'getMangaScripts');
    return (result.$value as List).cast<String>();
  }

  @override
  Future<MangaScrapped> parse({required Document root}) async {
    final result = runtime.executeLib('package:provider/main.dart', 'parseManga', [$Document.wrap(root)]);
    return (result as $MangaScrapped).$value;
  }
}

class _DynamicGetChapterImageUseCase implements GetChapterImageSourceExternalUseCase {
  final Runtime runtime;

  _DynamicGetChapterImageUseCase(this.runtime);

  @override
  Duration? get timeout => const Duration(seconds: 30);

  @override
  List<String> get scripts {
    final result = runtime.executeLib('package:provider/main.dart', 'getChapterImageScripts');
    return (result.$value as List).cast<String>();
  }

  @override
  Future<List<String>> parse({required Document root}) async {
    final result = runtime.executeLib('package:provider/main.dart', 'parseChapterImages', [$Document.wrap(root)]);
    return (result as Iterable).cast<String>().toList();
  }
}

class _DynamicListChapterUseCase implements ListChapterSourceExternalUseCase {
  final Runtime runtime;

  _DynamicListChapterUseCase(this.runtime);

  @override
  Duration? get timeout => const Duration(seconds: 15);

  @override
  List<String> get scripts => [];

  @override
  Future<List<ChapterScrapped>> parse({required Document root}) async {
    final result = runtime.executeLib('package:provider/main.dart', 'parseChapters', [$Document.wrap(root)]);
    final list = result as Iterable;
    return list.map((e) => (e as $ChapterScrapped).$value).toList();
  }
}

class _DynamicSearchMangaUseCase implements SearchMangaSourceExternalUseCase {
  final Runtime runtime;

  _DynamicSearchMangaUseCase(this.runtime);

  @override
  Duration? get timeout => const Duration(seconds: 15);

  @override
  List<String> get scripts {
    final result = runtime.executeLib('package:provider/main.dart', 'getSearchScripts');
    return (result.$value as List).cast<String>();
  }

  @override
  String url({required SearchMangaParameter parameter}) {
    final result = runtime.executeLib('package:provider/main.dart', 'getSearchUrl', [$Map.wrap({
      'title': $String(parameter.title ?? ''),
      'page': $int(parameter.page),
    })]);
    return result is $Value ? result.$value as String : result as String;
  }

  @override
  Future<List<MangaScrapped>> parse({required Document root}) async {
    final result = runtime.executeLib('package:provider/main.dart', 'parseSearch', [$Document.wrap(root)]);
    final list = result as Iterable;
    return list.map((e) => (e as $MangaScrapped).$value).toList();
  }

  @override
  Future<bool?> haveNextPage({required Document root}) async {
    final result = runtime.executeLib('package:provider/main.dart', 'haveNextSearchPage', [$Document.wrap(root)]);
    return result is $Value ? result.$value as bool? : result as bool?;
  }
}
