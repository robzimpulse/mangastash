// Shared mocktail doubles for domain_manga tests that need sources (issue
// #115): a scraped SourceExternal whose hooks each test stubs, the script
// runner (evictions are stubbed to succeed) and the SourceRegistry.
//
// Usage:
//   final source = mockScrapedSource(name: 'Manga Katana');
//   when(() => source.manga(url: url, useCache: any(named: 'useCache')))
//       .thenAnswer((_) async => const MangaScrapped());
//   final runner = mockRunner();   // verify(() => runner.evict(url: url))
//   final registry = mockRegistry([source]);  // fromName by source.name
//   final sources = shippedSources();  // MangaDex + 4 named scraped doubles
//   final real = scriptSource(name: 'X', body: 'v1', runner: runner);
import 'package:collection/collection.dart';
import 'package:core_network/core_network.dart';
import 'package:domain_manga/src/manager/source_registry.dart';
import 'package:domain_manga/src/sources/manga_dex_source_external.dart';
import 'package:domain_manga/src/sources/script_source_external.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:mocktail/mocktail.dart';

class MockSourceExternal extends Mock implements SourceExternal {}

class MockRunSourceScriptUseCase extends Mock
    implements RunSourceScriptUseCase {}

class MockSourceRegistry extends Mock implements SourceRegistry {}

/// A scraped (non built-in) source named [name] with base URL [baseUrl].
MockSourceExternal mockScrapedSource({
  required String name,
  String baseUrl = 'https://scraped.example.com',
}) {
  final source = MockSourceExternal();
  when(() => source.name).thenReturn(name);
  when(() => source.baseUrl).thenReturn(baseUrl);
  when(() => source.iconUrl).thenReturn('$baseUrl/favicon.ico');
  when(() => source.builtIn).thenReturn(false);
  return source;
}

/// A runner whose [RunSourceScriptUseCase.evict] completes.
MockRunSourceScriptUseCase mockRunner() {
  final runner = MockRunSourceScriptUseCase();
  when(() => runner.evict(url: any(named: 'url'))).thenAnswer((_) async {});
  return runner;
}

/// A registry resolving MangaDex plus [sources] by name.
MockSourceRegistry mockRegistry(List<SourceExternal> sources) {
  final registry = MockSourceRegistry();
  final values = [MangaDexSourceExternal(), ...sources];
  when(() => registry.values).thenReturn(values);
  when(() => registry.fromName(any())).thenAnswer((invocation) {
    final name = invocation.positionalArguments.first as String;
    return values.firstWhereOrNull((e) => e.name == name);
  });
  return registry;
}

/// MangaDex plus scraped doubles named like the four shipped sources, for
/// tests that only filter sources by name.
List<SourceExternal> shippedSources() {
  return [
    MangaDexSourceExternal(),
    for (final name in const [
      'Asura Scans',
      'Weeb Central',
      'Manga Katana',
      'Manhua Plus',
    ])
      mockScrapedSource(name: name),
  ];
}

/// A real ScriptSourceExternal named [name] whose script body is [body], run
/// by [runner]. Two sources with different [body]s model a script before and
/// after a user edit (different code, same name).
ScriptSourceExternal scriptSource({
  required String name,
  required String body,
  required RunSourceScriptUseCase runner,
}) {
  final id = name.toLowerCase().replaceAll(' ', '-');
  final code =
      '// ==MangaStashSource==\n'
      '// {"id": "$id", "name": "$name", "baseUrl": "https://$id.example", '
      '"version": 1, "contract": 1, "hosts": ["$id.example"]}\n'
      '// ==/MangaStashSource==\n'
      'const source = {}; // $body\n';
  return ScriptSourceExternal(script: SourceScript.parse(code), runner: runner);
}
