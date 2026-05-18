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
  Duration? get timeout {
    try {
      final t = runtime.executeSync(
        bytecode: bytecode,
        functionName: 'getMangaTimeout',
      );
      if (t is int) return Duration(milliseconds: t);
    } catch (_) {}
    return null;
  }

  @override
  List<String> get scripts {
    try {
      final s = runtime.executeSync(
        bytecode: bytecode,
        functionName: 'getMangaScripts',
      );
      if (s is List) return s.cast<String>();
    } catch (_) {}
    return [];
  }

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
  Duration? get timeout {
    try {
      final t = runtime.executeSync(
        bytecode: bytecode,
        functionName: 'getChapterImageTimeout',
      );
      if (t is int) return Duration(milliseconds: t);
    } catch (_) {}
    return null;
  }

  @override
  List<String> get scripts {
    try {
      final s = runtime.executeSync(
        bytecode: bytecode,
        functionName: 'getChapterImageScripts',
      );
      if (s is List) return s.cast<String>();
    } catch (_) {}
    return [];
  }

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
  Duration? get timeout {
    try {
      final t = runtime.executeSync(
        bytecode: bytecode,
        functionName: 'searchMangaTimeout',
      );
      if (t is int) return Duration(milliseconds: t);
    } catch (_) {}
    return null;
  }

  @override
  List<String> get scripts {
    try {
      final s = runtime.executeSync(
        bytecode: bytecode,
        functionName: 'searchMangaScripts',
      );
      if (s is List) return s.cast<String>();
    } catch (_) {}
    return [];
  }

  @override
  String url({required SearchMangaParameter parameter}) {
    try {
      final result = runtime.executeSync(
        bytecode: bytecode,
        functionName: 'searchUrl',
        args: [parameter],
      );
      if (result is String) return result;
    } catch (_) {}
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
  Duration? get timeout {
    try {
      final t = runtime.executeSync(
        bytecode: bytecode,
        functionName: 'listChapterTimeout',
      );
      if (t is int) return Duration(milliseconds: t);
    } catch (_) {}
    return null;
  }

  @override
  List<String> get scripts {
    try {
      final s = runtime.executeSync(
        bytecode: bytecode,
        functionName: 'listChapterScripts',
      );
      if (s is List) return s.cast<String>();
    } catch (_) {}
    return [];
  }

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
  Duration? get timeout {
    try {
      final t = runtime.executeSync(
        bytecode: bytecode,
        functionName: 'listTagTimeout',
      );
      if (t is int) return Duration(milliseconds: t);
    } catch (_) {}
    return null;
  }

  @override
  List<String> get scripts {
    try {
      final s = runtime.executeSync(
        bytecode: bytecode,
        functionName: 'listTagScripts',
      );
      if (s is List) return s.cast<String>();
    } catch (_) {}
    return [];
  }

  @override
  Future<List<TagScrapped>> parse({required Document root}) async {
    return (await runtime.execute(
      bytecode: bytecode,
      functionName: 'listTags',
      args: [root],
    ) as List).cast<TagScrapped>();
  }
}
