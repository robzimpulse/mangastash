// Tests for SourceCacheVersion / stripCacheVersion (issue #115, Review Focus
// 5): scripted sources get a stable per-code version, MangaDex gets none, and
// the version suffix can be stripped from a cache key again.
//
// Run with: fvm flutter test test/extension/source_cache_version_extension_test.dart
import 'package:domain_manga/src/extension/source_cache_version_extension.dart';
import 'package:domain_manga/src/sources/manga_dex_source_external.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock/mock_sources.dart';

void main() {
  final runner = mockRunner();

  test('MangaDex has no version', () {
    expect(MangaDexSourceExternal().cacheVersion, '');
  });

  test('the version is stable for equal code and differs for edited code', () {
    final a1 = scriptSource(name: 'Asura Scans', body: 'v1', runner: runner);
    final a2 = scriptSource(name: 'Asura Scans', body: 'v1', runner: runner);
    final b = scriptSource(name: 'Asura Scans', body: 'v2', runner: runner);

    expect(a1.cacheVersion, startsWith('@'));
    expect(a1.cacheVersion, a2.cacheVersion);
    expect(a1.cacheVersion, isNot(b.cacheVersion));
  });

  test('stripCacheVersion returns the parameter JSON', () {
    expect(stripCacheVersion('{"a":{"b":1}}@abc123'), '{"a":{"b":1}}');
    expect(stripCacheVersion('{"a":{"b":1}}'), '{"a":{"b":1}}');
  });
}
