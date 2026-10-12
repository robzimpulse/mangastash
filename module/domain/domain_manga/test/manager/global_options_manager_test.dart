// Tests for GlobalOptionsManager's enabled-sources option (issue #115 Task 10):
// it persists enabled source NAMES under 'sources' and resolves them against
// the SourceRegistry, so an edited script is picked up without touching the
// stored names (Review Focus 5) and names of removed sources resolve to
// nothing. Uses a real SourceRegistry over an in-memory AppDatabase and a
// mocktail SharedPreferencesAsync.
// Run: fvm flutter test test/manager/global_options_manager_test.dart
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/src/manager/global_options_manager.dart';
import 'package:domain_manga/src/manager/source_registry.dart';
import 'package:domain_manga/src/sources/script_source_external.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_service_drift/src/database/memory_executor.dart';
import 'package:mocktail/mocktail.dart';

class MockRunSourceScriptUseCase extends Mock
    implements RunSourceScriptUseCase {}

class MockSharedPreferencesAsync extends Mock
    implements SharedPreferencesAsync {}

String script({required String id, required String name, String body = ''}) {
  return '// ==MangaStashSource==\n'
      '// {"id": "$id", "name": "$name", "baseUrl": "https://$id.com", '
      '"version": 1, "contract": 1, "hosts": ["$id.com"]}\n'
      '// ==/MangaStashSource==\n'
      '$body\n';
}

const names = {
  'asura-scans': 'Asura Scans',
  'weeb-central': 'Weeb Central',
  'manga-katana': 'Manga Katana',
  'manhua-plus': 'Manhua Plus',
};

void main() {
  late AppDatabase db;
  late SourceRegistry registry;
  late MockSharedPreferencesAsync storage;

  setUp(() async {
    db = AppDatabase(executor: MemoryExecutor());
    registry = await SourceRegistry.create(
      dao: SourceScriptDao(db),
      runner: MockRunSourceScriptUseCase(),
      loadAsset: (path) async {
        final id = path.split('/').last.replaceAll('.js', '');
        return script(id: id, name: names[id]!, body: '// shipped');
      },
    );
    storage = MockSharedPreferencesAsync();
    when(() => storage.getBool(any())).thenAnswer((_) async => null);
    when(() => storage.getString(any())).thenAnswer((_) async => null);
    when(() => storage.getInt(any())).thenAnswer((_) async => null);
    when(() => storage.getStringList(any())).thenAnswer((_) async => null);
    when(() => storage.setStringList(any(), any())).thenAnswer((_) async {});
  });

  tearDown(() async {
    await registry.close();
    await db.close();
  });

  Future<GlobalOptionsManager> create() {
    return GlobalOptionsManager.create(storage: storage, registry: registry);
  }

  test('defaults to every source when the key is absent', () async {
    final manager = await create();

    expect(manager.sourceStateStream.value.map((e) => e.name), [
      'Manga Dex',
      ...names.values,
    ]);
    await manager.dispose();
  });

  test('stored names that no longer exist resolve to nothing', () async {
    when(
      () => storage.getStringList('sources'),
    ).thenAnswer((_) async => ['Asura Scans', 'Gone Source']);

    final manager = await create();

    expect(manager.sourceStateStream.value.map((e) => e.name), ['Asura Scans']);
    await manager.dispose();
  });

  test('updateSources persists names and emits in registry order', () async {
    final manager = await create();

    await manager.updateSources(
      sources: [
        registry.fromName('Manhua Plus')!,
        registry.fromName('Manga Dex')!,
      ],
    );

    verify(
      () => storage.setStringList('sources', ['Manhua Plus', 'Manga Dex']),
    ).called(1);
    expect(manager.sourceStateStream.value.map((e) => e.name), [
      'Manga Dex',
      'Manhua Plus',
    ]);
    await manager.dispose();
  });

  test('a registry save re-resolves the adapters (Review Focus 5)', () async {
    when(
      () => storage.getStringList('sources'),
    ).thenAnswer((_) async => ['Asura Scans']);
    final manager = await create();
    final emissions = <List<SourceExternal>>[];
    final sub = manager.sourceStateStream.listen(emissions.add);
    await pumpEventQueue();

    final edited = script(
      id: 'asura-scans',
      name: 'Asura Scans',
      body: '// edited',
    );
    await registry.save(edited);
    await pumpEventQueue();

    final latest = emissions.last.single as ScriptSourceExternal;
    expect(latest.name, 'Asura Scans');
    expect(latest.script.code, edited);
    verifyNever(() => storage.setStringList(any(), any()));

    await sub.cancel();
    await manager.dispose();
  });
}
