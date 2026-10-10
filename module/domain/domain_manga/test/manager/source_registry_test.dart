// Tests for SourceRegistry (issue #115, spec §8): resolution of shipped assets
// vs DB rows, status computation, ordering, save validation, reset/delete and
// stream emissions, plus the SourceExternal adapters it exposes (values,
// fromName, fromHost; issue #115 Task 10). Uses a real in-memory AppDatabase
// (MemoryExecutor) with the real SourceScriptDao, a map-backed loadAsset
// standing in for rootBundle, and a mocktail RunSourceScriptUseCase.
// Run: fvm flutter test test/manager/source_registry_test.dart
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/src/manager/source_registry.dart';
import 'package:domain_manga/src/model/source_entry.dart';
import 'package:domain_manga/src/sources/manga_dex_source_external.dart';
import 'package:domain_manga/src/sources/script_source_external.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_service_drift/src/database/memory_executor.dart';
import 'package:mocktail/mocktail.dart';

class MockRunSourceScriptUseCase extends Mock
    implements RunSourceScriptUseCase {}

String script({
  required String id,
  required String name,
  int version = 1,
  int contract = 1,
  String body = '',
}) {
  return '// ==MangaStashSource==\n'
      '// {"id": "$id", "name": "$name", "baseUrl": "https://$id.com", '
      '"version": $version, "contract": $contract, "hosts": ["$id.com"]}\n'
      '// ==/MangaStashSource==\n'
      '$body\n';
}

const names = {
  'asura-scans': 'Asura Scans',
  'weeb-central': 'Weeb Central',
  'manga-katana': 'Manga Katana',
  'manhua-plus': 'Manhua Plus',
};

Map<String, String> assets({int asuraVersion = 2}) {
  return {
    for (final id in shippedSourceIds)
      'packages/domain_manga/assets/sources/$id.js': script(
        id: id,
        name: names[id]!,
        version: id == 'asura-scans' ? asuraVersion : 1,
        body: '// shipped',
      ),
  };
}

void main() {
  late AppDatabase db;
  late SourceScriptDao dao;
  late Map<String, String> assetMap;
  final registries = <SourceRegistry>[];

  Future<SourceRegistry> create() async {
    final registry = await SourceRegistry.create(
      dao: dao,
      runner: MockRunSourceScriptUseCase(),
      loadAsset: (path) async {
        final asset = assetMap[path];
        if (asset == null) throw StateError('missing asset $path');
        return asset;
      },
    );
    registries.add(registry);
    return registry;
  }

  setUp(() {
    db = AppDatabase(executor: MemoryExecutor());
    dao = SourceScriptDao(db);
    assetMap = assets();
  });

  tearDown(() async {
    for (final registry in registries) {
      await registry.close();
    }
    registries.clear();
    await db.close();
  });

  group('create', () {
    test('with no rows exposes the 4 shipped ids in order', () async {
      final registry = await create();

      final entries = registry.entries.value;
      expect(entries.map((e) => e.script.id), shippedSourceIds);
      expect(entries.map((e) => e.status), everyElement(SourceStatus.shipped));
      expect(entries.map((e) => e.script.name), names.values);
    });

    test(
      'skips a shipped asset with a broken header without throwing',
      () async {
        assetMap['packages/domain_manga/assets/sources/weeb-central.js'] =
            'not a header';

        final registry = await create();

        expect(registry.entries.value.map((e) => e.script.id), [
          'asura-scans',
          'manga-katana',
          'manhua-plus',
        ]);
      },
    );

    test('skips a shipped asset that cannot be loaded', () async {
      assetMap.remove('packages/domain_manga/assets/sources/manhua-plus.js');

      final registry = await create();

      expect(registry.entries.value, hasLength(3));
    });

    test('custom entries come after shipped ones, sorted by name', () async {
      final registry = await create();
      await registry.save(script(id: 'zeta', name: 'Zeta'));
      await registry.save(script(id: 'alpha', name: 'Alpha'));

      expect(registry.entries.value.map((e) => e.script.id), [
        ...shippedSourceIds,
        'alpha',
        'zeta',
      ]);
    });
  });

  group('save', () {
    test('shipped edit becomes modified with baseVersion = shipped', () async {
      final registry = await create();

      final saved = await registry.save(
        script(id: 'asura-scans', name: 'Asura Scans', version: 5),
      );

      expect(saved.status, SourceStatus.modified);
      expect(saved.script.version, 5);
      expect(saved.shipped?.version, 2);
      final row = await dao.get('asura-scans');
      expect(row?.baseVersion, 2);
      expect(row?.origin, SourceScriptOrigin.shippedEdited);
      expect(registry.entries.value.first, saved);
    });

    test(
      'shipped edit with lower or equal version is still modified',
      () async {
        final registry = await create();

        final lower = await registry.save(
          script(id: 'asura-scans', name: 'Asura Scans', version: 1),
        );
        expect(lower.status, SourceStatus.modified);
        expect((await dao.get('asura-scans'))?.baseVersion, 2);

        final equal = await registry.save(
          script(
            id: 'asura-scans',
            name: 'Asura Scans',
            version: 2,
            body: '//x',
          ),
        );
        expect(equal.status, SourceStatus.modified);
      },
    );

    test(
      'shipped bump after an edit gives updateAvailable; reset restores',
      () async {
        var registry = await create();
        await registry.save(
          script(id: 'asura-scans', name: 'Asura Scans', version: 5),
        );

        assetMap = assets(asuraVersion: 3);
        registry = await create();

        expect(
          registry.entries.value.first.status,
          SourceStatus.updateAvailable,
        );

        await registry.reset('asura-scans');

        final first = registry.entries.value.first;
        expect(first.status, SourceStatus.shipped);
        expect(
          first.script.code,
          assetMap['packages/domain_manga/assets/sources/asura-scans.js'],
        );
        expect(await dao.get('asura-scans'), null);
      },
    );

    test(
      'rejects a renamed existing id and leaves the DAO untouched',
      () async {
        final registry = await create();

        await expectLater(
          registry.save(script(id: 'asura-scans', name: 'Asura', version: 5)),
          throwsA(
            isA<SourceScriptRejected>().having(
              (e) => e.message,
              'message',
              'Name is locked: expected "Asura Scans"',
            ),
          ),
        );
        expect(await dao.getAll(), isEmpty);
      },
    );

    test('rejects a new id reusing a shipped name or Manga Dex', () async {
      final registry = await create();

      await expectLater(
        registry.save(script(id: 'my-site', name: 'Weeb Central')),
        throwsA(
          isA<SourceScriptRejected>().having(
            (e) => e.message,
            'message',
            'Name "Weeb Central" is already used by another source',
          ),
        ),
      );
      await expectLater(
        registry.save(script(id: 'my-site', name: 'Manga Dex')),
        throwsA(
          isA<SourceScriptRejected>().having(
            (e) => e.message,
            'message',
            contains('already used'),
          ),
        ),
      );
      expect(await dao.getAll(), isEmpty);
    });

    test('accepts a new id as custom with null baseVersion', () async {
      final registry = await create();

      final saved = await registry.save(
        script(id: 'my-site', name: 'Flame Comics'),
      );

      expect(saved.status, SourceStatus.custom);
      expect(saved.shipped, null);
      final row = await dao.get('my-site');
      expect(row?.origin, SourceScriptOrigin.custom);
      expect(row?.baseVersion, null);
    });

    test('rejects the name of another custom entry; allows own name', () async {
      final registry = await create();
      await registry.save(script(id: 'one', name: 'One'));

      await expectLater(
        registry.save(script(id: 'two', name: 'One')),
        throwsA(isA<SourceScriptRejected>()),
      );
      final again = await registry.save(
        script(id: 'one', name: 'One', version: 4),
      );
      expect(again.script.version, 4);
      expect(again.status, SourceStatus.custom);
    });

    test(
      'overwriting a custom id keeps origin custom and baseVersion null',
      () async {
        final registry = await create();
        await registry.save(script(id: 'one', name: 'One'));

        await registry.save(script(id: 'one', name: 'One', version: 3));

        final row = await dao.get('one');
        expect(row?.origin, SourceScriptOrigin.custom);
        expect(row?.baseVersion, null);
        expect(row?.version, 3);
      },
    );

    test('name of a deleted source may be reused', () async {
      final registry = await create();
      await registry.save(script(id: 'one', name: 'One'));
      await registry.delete('one');

      final saved = await registry.save(script(id: 'two', name: 'One'));

      expect(saved.status, SourceStatus.custom);
    });

    test('rejects an unsupported contract before any write', () async {
      final registry = await create();

      await expectLater(
        registry.save(script(id: 'my-site', name: 'My Site', contract: 2)),
        throwsA(
          isA<SourceScriptRejected>().having(
            (e) => e.message,
            'message',
            'Unsupported contract 2; this app supports 1',
          ),
        ),
      );
      expect(await dao.getAll(), isEmpty);
    });

    test(
      'rethrows a malformed header as SourceScriptFormatException',
      () async {
        final registry = await create();

        await expectLater(
          registry.save('// nothing here'),
          throwsA(isA<SourceScriptFormatException>()),
        );
        expect(await dao.getAll(), isEmpty);
      },
    );

    test('concurrent saves with the same new name: exactly one wins', () async {
      final registry = await create();

      final results = await Future.wait([
        registry
            .save(script(id: 'one', name: 'Same'))
            .then<Object>((e) => e)
            .catchError((Object e) => e),
        registry
            .save(script(id: 'two', name: 'Same'))
            .then<Object>((e) => e)
            .catchError((Object e) => e),
      ]);

      expect(results.whereType<SourceEntry>(), hasLength(1));
      expect(results.whereType<SourceScriptRejected>(), hasLength(1));
      expect(await dao.getAll(), hasLength(1));
    });
  });

  group('classify', () {
    test(
      'ReplacesSource for an existing id, NewSource for a new one',
      () async {
        final registry = await create();

        final existing = registry.classify(
          script(id: 'asura-scans', name: 'Whatever'),
        );
        final fresh = registry.classify(script(id: 'my-site', name: 'My Site'));

        expect(existing, isA<ReplacesSource>());
        expect((existing as ReplacesSource).entry.script.id, 'asura-scans');
        expect(fresh, isA<NewSource>());
      },
    );

    test('throws SourceScriptFormatException on unparseable code', () async {
      final registry = await create();

      expect(
        () => registry.classify('garbage'),
        throwsA(isA<SourceScriptFormatException>()),
      );
    });
  });

  group('reset and delete', () {
    test('delete of a shipped id throws StateError', () async {
      final registry = await create();

      expect(() => registry.delete('asura-scans'), throwsStateError);
    });

    test('reset of a custom id throws StateError', () async {
      final registry = await create();
      await registry.save(script(id: 'one', name: 'One'));

      expect(() => registry.reset('one'), throwsStateError);
    });

    test('delete removes a custom row', () async {
      final registry = await create();
      await registry.save(script(id: 'one', name: 'One'));

      await registry.delete('one');

      expect(await dao.get('one'), null);
      expect(registry.entries.value, hasLength(4));
    });
  });

  group('entries stream', () {
    test('emits after each save, reset and delete', () async {
      final registry = await create();
      final emissions = <List<SourceEntry>>[];
      final sub = registry.entries.skip(1).listen(emissions.add);

      await registry.save(
        script(id: 'asura-scans', name: 'Asura Scans', version: 5),
      );
      await pumpEventQueue();
      final afterSave = emissions.length;
      expect(afterSave, greaterThanOrEqualTo(1));
      expect(emissions.last.first.status, SourceStatus.modified);

      await registry.reset('asura-scans');
      await pumpEventQueue();
      expect(emissions.length, greaterThan(afterSave));
      expect(emissions.last.first.status, SourceStatus.shipped);

      await registry.save(script(id: 'one', name: 'One'));
      await pumpEventQueue();
      expect(emissions.last, hasLength(5));

      await registry.delete('one');
      await pumpEventQueue();
      expect(emissions.last, hasLength(4));

      await sub.cancel();
    });

    test('reflects direct dao changes', () async {
      final registry = await create();

      await dao.upsert(
        SourceScriptTablesCompanion.insert(
          id: 'outside',
          name: 'Outside',
          code: script(id: 'outside', name: 'Outside'),
          version: 1,
          origin: SourceScriptOrigin.custom,
        ),
      );
      await pumpEventQueue();

      expect(
        registry.entries.value.map((e) => e.script.id),
        contains('outside'),
      );
    });
  });

  group('adapters', () {
    test('values lists Manga Dex first, then one adapter per entry', () async {
      final registry = await create();

      expect(registry.values.first, isA<MangaDexSourceExternal>());
      expect(
        registry.values.skip(1),
        everyElement(isA<ScriptSourceExternal>()),
      );
      expect(registry.values.map((e) => e.name), [
        'Manga Dex',
        ...names.values,
      ]);
    });

    test(
      'fromName returns the adapter; after save it has the edited code',
      () async {
        final registry = await create();

        final before = registry.fromName('Asura Scans');
        expect(before, isA<ScriptSourceExternal>());
        expect(
          (before as ScriptSourceExternal).script.code,
          contains('shipped'),
        );

        final edited = script(
          id: 'asura-scans',
          name: 'Asura Scans',
          body: '// edited',
        );
        await registry.save(edited);

        final after = registry.fromName('Asura Scans') as ScriptSourceExternal?;
        expect(after?.script.code, edited);
        expect(registry.fromName('Manga Dex'), isA<MangaDexSourceExternal>());
        expect(registry.fromName('Gone Source'), isNull);
      },
    );

    test('fromHost matches the base url host', () async {
      final registry = await create();

      expect(registry.fromHost('asura-scans.com')?.name, 'Asura Scans');
      expect(registry.fromHost('www.mangadex.org')?.name, 'Manga Dex');
      expect(registry.fromHost('unknown.com'), isNull);
    });

    test('values are fresh before entries emits', () async {
      final registry = await create();
      final seen = <String?>[];
      final sub = registry.entries.listen((_) {
        final asura = registry.fromName('Asura Scans') as ScriptSourceExternal?;
        seen.add(asura?.script.code);
      });
      await pumpEventQueue();

      final edited = script(
        id: 'asura-scans',
        name: 'Asura Scans',
        body: '//e',
      );
      await registry.save(edited);
      await pumpEventQueue();

      expect(seen.last, edited);
      await sub.cancel();
    });
  });
}
