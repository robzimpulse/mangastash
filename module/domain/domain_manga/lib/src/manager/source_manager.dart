import 'package:entity_manga_external/entity_manga_external.dart';

import '../sources/built_in_source_provider.dart';

abstract class SourceManager {
  Stream<List<SourceExternal>> watchAllSources();
  List<SourceExternal> get currentSources;
  SourceExternal? getSource(String name);
  SourceExternal? getSourceByUri(Uri uri);
}

class SourceManagerImpl implements SourceManager {
  final BuiltInSourceProvider _builtInSourceProvider;

  SourceManagerImpl({
    required BuiltInSourceProvider builtInSourceProvider,
  }) : _builtInSourceProvider = builtInSourceProvider;

  @override
  Stream<List<SourceExternal>> watchAllSources() {
    // For now, it's just a static list from the built-in provider.
    // In Phase 3, this will combine with dynamic sources from the database.
    return Stream.value(_builtInSourceProvider.sources);
  }

  @override
  List<SourceExternal> get currentSources => _builtInSourceProvider.sources;

  @override
  SourceExternal? getSource(String name) {
    return _builtInSourceProvider.fromName(name);
  }

  @override
  SourceExternal? getSourceByUri(Uri uri) {
    for (final source in currentSources) {
      if (Uri.tryParse(source.baseUrl)?.host == uri.host) {
        return source;
      }
    }
    return null;
  }
}
