import 'dart:typed_data';

import 'package:core_runtime/core_runtime.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:html/dom.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

class DynamicSourceExternal implements SourceExternal {
  @override
  final String name;
  @override
  final String baseUrl;
  @override
  final String iconUrl;
  @override
  bool get builtIn => false;

  final Uint8List bytecode;
  final SourceRuntime _runtime;

  DynamicSourceExternal({
    required this.name,
    required this.baseUrl,
    required this.iconUrl,
    required this.bytecode,
    required SourceRuntime runtime,
  }) : _runtime = runtime;

  @override
  GetMangaSourceExternalUseCase get getMangaUseCase => _DynamicGetMangaUseCase(bytecode, _runtime);

  @override
  GetChapterImageSourceExternalUseCase get getChapterImageUseCase =>
      _DynamicGetChapterImageUseCase(bytecode, _runtime);

  @override
  SearchMangaSourceExternalUseCase get searchMangaUseCase => _DynamicSearchMangaUseCase(bytecode, _runtime);

  @override
  ListChapterSourceExternalUseCase get listChapterUseCase => _DynamicListChapterUseCase(bytecode, _runtime);

  @override
  ListTagSourceExternalUseCase get listTagUseCase => _DynamicListTagUseCase(bytecode, _runtime);
}

class _DynamicGetMangaUseCase implements GetMangaSourceExternalUseCase {
  final Uint8List bytecode;
  final SourceRuntime runtime;

  _DynamicGetMangaUseCase(this.bytecode, this.runtime);

  @override
  Duration? get timeout => null;
  @override
  List<String> get scripts => [];

  @override
  Future<MangaScrapped> parse({required Document root}) async {
    return await runtime.execute(
      bytecode: bytecode,
      functionName: 'getManga',
      args: [root],
    );
  }
}

class _DynamicGetChapterImageUseCase implements GetChapterImageSourceExternalUseCase {
  final Uint8List bytecode;
  final SourceRuntime runtime;

  _DynamicGetChapterImageUseCase(this.bytecode, this.runtime);

  @override
  Duration? get timeout => null;
  @override
  List<String> get scripts => [];

  @override
  Future<List<String>> parse({required Document root}) async {
    return (await runtime.execute(
      bytecode: bytecode,
      functionName: 'getChapterImages',
      args: [root],
    ) as List).cast<String>();
  }
}

class _DynamicSearchMangaUseCase implements SearchMangaSourceExternalUseCase {
  final Uint8List bytecode;
  final SourceRuntime runtime;

  _DynamicSearchMangaUseCase(this.bytecode, this.runtime);

  @override
  Duration? get timeout => null;
  @override
  List<String> get scripts => [];

  @override
  String url({required SearchMangaParameter parameter}) {
    // This might need a separate bridge or just handle it if it doesn't need HTML
    // For now, we'll assume the script has a 'searchUrl' function
    // But wait, SearchMangaParameter is from manga_dex_api. We might need a bridge for it too.
    // Or just pass its JSON.
    return ''; 
  }

  @override
  Future<List<MangaScrapped>> parse({required Document root}) async {
    return (await runtime.execute(
      bytecode: bytecode,
      functionName: 'searchManga',
      args: [root],
    ) as List).cast<MangaScrapped>();
  }

  @override
  Future<bool?> haveNextPage({required Document root}) async {
    return await runtime.execute(
      bytecode: bytecode,
      functionName: 'searchHaveNextPage',
      args: [root],
    );
  }
}

class _DynamicListChapterUseCase implements ListChapterSourceExternalUseCase {
  final Uint8List bytecode;
  final SourceRuntime runtime;

  _DynamicListChapterUseCase(this.bytecode, this.runtime);

  @override
  Duration? get timeout => null;
  @override
  List<String> get scripts => [];

  @override
  Future<List<ChapterScrapped>> parse({required Document root}) async {
    return (await runtime.execute(
      bytecode: bytecode,
      functionName: 'listChapters',
      args: [root],
    ) as List).cast<ChapterScrapped>();
  }
}

class _DynamicListTagUseCase implements ListTagSourceExternalUseCase {
  final Uint8List bytecode;
  final SourceRuntime runtime;

  _DynamicListTagUseCase(this.bytecode, this.runtime);

  @override
  Duration? get timeout => null;
  @override
  List<String> get scripts => [];

  @override
  Future<List<TagScrapped>> parse({required Document root}) async {
    return (await runtime.execute(
      bytecode: bytecode,
      functionName: 'listTags',
      args: [root],
    ) as List).cast<TagScrapped>();
  }
}
