// Tests for the moved-source predicate and exception (issue #206):
// `SourceMoved.movedHostOf` returns the stored URL's normalised host when the
// resolved source no longer lists it (baseUrl host + header `hosts`), and
// null otherwise — built-in sources and host-less URLs are never moved.
// `SourceMovedException.toString` carries the pinned user-facing copy.
//
// Usage: run with `fvm flutter test test/extension/source_moved_extension_test.dart`
// from module/domain/domain_manga.
import 'dart:convert';

import 'package:domain_manga/src/exception/source_moved_exception.dart';
import 'package:domain_manga/src/extension/source_moved_extension.dart';
import 'package:domain_manga/src/sources/manga_dex_source_external.dart';
import 'package:domain_manga/src/sources/script_source_external.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock/mock_sources.dart';

/// A real [ScriptSourceExternal] named [name] whose header lists [hosts]
/// (baseUrl stays `https://<id>.example`). Like `scriptSource` from the
/// shared mocks, but with hosts configurable so tests can model a source
/// before and after a domain move.
ScriptSourceExternal scriptWithHosts({
  required String name,
  required List<String> hosts,
}) {
  final id = name.toLowerCase().replaceAll(' ', '-');
  final code =
      '// ==MangaStashSource==\n'
      '// {"id": "$id", "name": "$name", "baseUrl": "https://$id.example", '
      '"version": 1, "contract": 1, "hosts": ${jsonEncode(hosts)}}\n'
      '// ==/MangaStashSource==\n'
      'const source = {};\n';
  return ScriptSourceExternal(
    script: SourceScript.parse(code),
    runner: mockRunner(),
  );
}

void main() {
  group('movedHostOf', () {
    test('url on the current baseUrl host is not moved', () {
      final source = scriptSource(
        name: 'A Scans',
        body: 'v1',
        runner: mockRunner(),
      );

      expect(source.movedHostOf('https://a-scans.example/t'), isNull);
    });

    test('www./uppercase variant of the baseUrl host is not moved', () {
      final source = scriptSource(
        name: 'A Scans',
        body: 'v1',
        runner: mockRunner(),
      );

      expect(source.movedHostOf('https://WWW.A-Scans.Example/t'), isNull);
    });

    test('url on a host listed in hosts is not moved', () {
      final source = scriptWithHosts(
        name: 'X Scans',
        hosts: ['x.example', 'cdn.x.example'],
      );

      expect(source.movedHostOf('https://cdn.x.example/t'), isNull);
    });

    test('url on an unknown host returns the normalised stored host', () {
      final source = scriptSource(
        name: 'A Scans',
        body: 'v1',
        runner: mockRunner(),
      );

      expect(source.movedHostOf('https://old.example/t'), equals('old.example'));
    });

    test('null and blank urls are not moved', () {
      final source = scriptSource(
        name: 'A Scans',
        body: 'v1',
        runner: mockRunner(),
      );

      expect(source.movedHostOf(null), isNull);
      expect(source.movedHostOf(''), isNull);
    });

    test('the built-in MangaDex source is never moved', () {
      expect(
        MangaDexSourceExternal().movedHostOf('https://elsewhere.org/x'),
        isNull,
      );
    });

    test('restoring the old host in hosts clears the mark', () {
      final restored = scriptWithHosts(
        name: 'A Scans',
        hosts: ['a-scans.example', 'old.example'],
      );

      expect(restored.movedHostOf('https://old.example/t'), isNull);
    });
  });

  group('SourceMovedException', () {
    test('toString carries the source name and host', () {
      expect(
        const SourceMovedException(
          sourceName: 'A',
          host: 'old.example',
        ).toString(),
        equals('Source moved: A no longer serves old.example.'),
      );
    });
  });
}
