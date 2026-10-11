// Tests for SourceScript header parsing (see lib/src/source_script.dart).
// Run with `fvm flutter test test/source_script_test.dart` from this module.
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:flutter_test/flutter_test.dart';

const header = '''// ==MangaStashSource==
// { "id": "asura-scans", "name": "Asura Scans", "baseUrl": "https://asurascans.com",
//   "iconUrl": "https://asurascans.com/images/logo.webp", "version": 3, "contract": 1,
//   "hosts": ["asurascans.com", "cdn.asurascans.com"], "timeouts": { "images": 30000 } }
// ==/MangaStashSource==
const source = {};''';

/// Builds a script whose header JSON is [json] on a single line.
String withJson(String json) {
  return '// ==MangaStashSource==\n'
      '// $json\n'
      '// ==/MangaStashSource==\n'
      'const source = {};';
}

/// Valid header JSON with [overrides] applied; null values remove the key.
String jsonWith(Map<String, String?> overrides) {
  final fields = <String, String?>{
    'id': '"asura-scans"',
    'name': '"Asura Scans"',
    'baseUrl': '"https://asurascans.com"',
    'version': '3',
    'contract': '1',
    'hosts': '["asurascans.com"]',
    ...overrides,
  };
  final entries = [
    for (final e in fields.entries)
      if (e.value != null) '"${e.key}": ${e.value}',
  ];
  return '{ ${entries.join(', ')} }';
}

void main() {
  test('parses header fields', () {
    final s = SourceScript.parse(header);
    expect(s.id, 'asura-scans');
    expect(s.name, 'Asura Scans');
    expect(s.baseUrl, 'https://asurascans.com');
    expect(s.iconUrl, 'https://asurascans.com/images/logo.webp');
    expect(s.version, 3);
    expect(s.contract, 1);
    expect(s.hosts, ['asurascans.com', 'cdn.asurascans.com']);
    expect(s.timeoutFor('images'), const Duration(seconds: 30));
    expect(s.timeoutFor('search'), const Duration(seconds: 15));
    expect(s.code, header);
  });

  test('kSupportedSourceContract is 1', () {
    expect(kSupportedSourceContract, 1);
  });

  test('CRLF header parses the same as LF', () {
    final crlf = header.replaceAll('\n', '\r\n');
    final s = SourceScript.parse(crlf);
    expect(s.id, 'asura-scans');
    expect(s.hosts, ['asurascans.com', 'cdn.asurascans.com']);
    expect(s.timeoutFor('images'), const Duration(seconds: 30));
    expect(s.code, crlf);
  });

  test('BOM and leading whitespace are tolerated', () {
    final s = SourceScript.parse('﻿  \n$header');
    expect(s.id, 'asura-scans');
  });

  test('equality includes code', () {
    expect(SourceScript.parse(header), SourceScript.parse(header));
    expect(
      SourceScript.parse(header),
      isNot(SourceScript.parse('$header\n// changed')),
    );
  });

  test('iconUrl and timeouts are optional', () {
    final s = SourceScript.parse(withJson(jsonWith({})));
    expect(s.iconUrl, '');
    expect(s.timeouts, isEmpty);
  });

  group('rejects', () {
    void rejects(String name, String code) {
      test(name, () {
        expect(
          () => SourceScript.parse(code),
          throwsA(isA<SourceScriptFormatException>()),
        );
      });
    }

    rejects('no header', 'const source = {};');
    rejects('header not at top', 'const a = 1;\n$header');
    rejects('missing closing marker', '// ==MangaStashSource==\n// {}\n');
    rejects(
      'non-comment line inside header',
      '// ==MangaStashSource==\n{ }\n// ==/MangaStashSource==',
    );
    rejects('invalid JSON', withJson('{ not json'));
    rejects('JSON not an object', withJson('[1, 2]'));
    for (final key in [
      'id',
      'name',
      'baseUrl',
      'version',
      'contract',
      'hosts',
    ]) {
      rejects('missing $key', withJson(jsonWith({key: null})));
    }
    rejects('id not a slug', withJson(jsonWith({'id': '"Asura Scans"'})));
    rejects(
      'baseUrl not absolute',
      withJson(jsonWith({'baseUrl': '"asurascans.com"'})),
    );
    rejects(
      'baseUrl not http(s)',
      withJson(jsonWith({'baseUrl': '"ftp://asurascans.com"'})),
    );
    rejects('empty hosts', withJson(jsonWith({'hosts': '[]'})));
    rejects(
      'host with scheme',
      withJson(jsonWith({'hosts': '["https://asurascans.com"]'})),
    );
    rejects('version 0', withJson(jsonWith({'version': '0'})));
    rejects('version wrong type', withJson(jsonWith({'version': '"3"'})));
    rejects(
      'negative timeout',
      withJson(jsonWith({'timeouts': '{"images": -1}'})),
    );
    rejects(
      'unknown timeout key',
      withJson(jsonWith({'timeouts': '{"bogus": 1000}'})),
    );
  });

  group('timeout upper bound', () {
    test('120000 ms is the largest accepted timeout', () {
      final s = SourceScript.parse(
        withJson(jsonWith({'timeouts': '{"images": 120000}'})),
      );

      expect(s.timeoutFor('images'), const Duration(milliseconds: 120000));
    });

    test('a timeout above 120000 ms is rejected naming the limit', () {
      // A script cannot hold the shared webview (and, on Android, the
      // renderer other calls wait on) for longer than two minutes.
      expect(
        () => SourceScript.parse(
          withJson(jsonWith({'timeouts': '{"images": 120001}'})),
        ),
        throwsA(
          isA<SourceScriptFormatException>().having(
            (e) => e.message,
            'message',
            allOf(contains('images'), contains('120000')),
          ),
        ),
      );
    });
  });
}
