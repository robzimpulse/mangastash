// Tests for the hand-written fromJson factories of the *Scrapped models.
// Run with `fvm flutter test test/scrapped_from_json_test.dart` from this module.
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:flutter_test/flutter_test.dart';

/// Matcher: a FormatException whose message mentions [field].
Matcher formatErrorNaming(String field) {
  return isA<FormatException>().having(
    (e) => e.message,
    'message',
    contains(field),
  );
}

void main() {
  test('MangaScrapped.fromJson ignores unknown keys', () {
    expect(
      MangaScrapped.fromJson({
        'title': 'T',
        'webUrl': 'u',
        'tags': ['a'],
        'extra': 1,
      }),
      const MangaScrapped(title: 'T', webUrl: 'u', tags: ['a']),
    );
  });

  test('MangaScrapped.fromJson wrong type names the field', () {
    expect(
      () => MangaScrapped.fromJson({'title': 3}),
      throwsA(formatErrorNaming('title')),
    );
  });

  test('MangaScrapped.fromJson wrong tag element type names the field', () {
    expect(
      () => MangaScrapped.fromJson({
        'tags': ['a', 2],
      }),
      throwsA(formatErrorNaming('tags')),
    );
  });

  test('ChapterScrapped.fromJson maps fields', () {
    expect(
      ChapterScrapped.fromJson({
        'title': 'Ch 1',
        'chapter': '1',
        'webUrl': 'u',
        'images': ['i1', 'i2'],
        'unknown': true,
      }),
      const ChapterScrapped(
        title: 'Ch 1',
        chapter: '1',
        webUrl: 'u',
        images: ['i1', 'i2'],
      ),
    );
  });

  test('ChapterScrapped.fromJson wrong type names the field', () {
    expect(
      () => ChapterScrapped.fromJson({'images': 'x'}),
      throwsA(formatErrorNaming('images')),
    );
  });

  test('TagScrapped.fromJson maps fields and ignores unknown keys', () {
    expect(
      TagScrapped.fromJson({'id': 'action', 'name': 'Action', 'x': 1}),
      const TagScrapped(id: 'action', name: 'Action'),
    );
    expect(
      () => TagScrapped.fromJson({'name': 1}),
      throwsA(formatErrorNaming('name')),
    );
  });

  test('SearchResultScrapped.fromJson with empty items, null hasNextPage', () {
    final r = SearchResultScrapped.fromJson({'items': [], 'hasNextPage': null});
    expect(r.items, isEmpty);
    expect(r.hasNextPage, isNull);
  });

  test('SearchResultScrapped.fromJson maps items', () {
    final r = SearchResultScrapped.fromJson({
      'items': [
        {'title': 'A'},
      ],
      'hasNextPage': true,
    });
    expect(r.items, [const MangaScrapped(title: 'A')]);
    expect(r.hasNextPage, true);
  });

  test('SearchResultScrapped.fromJson bad shapes throw FormatException', () {
    expect(
      () => SearchResultScrapped.fromJson({'items': 'x'}),
      throwsA(formatErrorNaming('items')),
    );
    expect(
      () => SearchResultScrapped.fromJson({'items': [], 'hasNextPage': 'yes'}),
      throwsA(formatErrorNaming('hasNextPage')),
    );
  });
}
