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
  GetChapterImageSourceExternalUseCase get getChapterImageUseCase => throw UnimplementedError();

  @override
  GetMangaSourceExternalUseCase get getMangaUseCase => throw UnimplementedError();

  @override
  ListChapterSourceExternalUseCase get listChapterUseCase => throw UnimplementedError();

  @override
  ListTagSourceExternalUseCase get listTagUseCase => throw UnimplementedError();
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
