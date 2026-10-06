// Tests for Manga.from's MangaDex mapping (issue #131): artist credits map
// to their own field instead of being dropped (or leaking into author).
//
// Run with: fvm flutter test test/src/manga_test.dart
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

void main() {
  test('Manga.from maps author and artist relationships separately (#131)', () {
    final data = MangaData.fromJson(<String, dynamic>{
      'id': 'm1',
      'type': 'manga',
      'attributes': <String, dynamic>{'chapterNumbersResetOnNewVolume': false},
      'relationships': <Map<String, dynamic>>[
        {
          'id': 'auth-1',
          'type': 'author',
          'attributes': {'name': 'Author One'},
        },
        {
          'id': 'art-1',
          'type': 'artist',
          'attributes': {'name': 'Artist One'},
        },
      ],
    });

    final manga = Manga.from(data: data);

    expect(manga.author, 'Author One');
    expect(manga.artist, 'Artist One');
  });

  // Review on #188: `.nonNulls.join(' | ')` yields '' — not null — when no
  // artist relationship exists. The empty string would persist into the
  // artist column (Value.absentIfNull('') is present) and render a trailing
  // separator in the detail credits, defeating the column's
  // nullable-for-absent intent.
  test('Manga.from maps a missing artist to null, not empty string (#188)', () {
    final data = MangaData.fromJson(<String, dynamic>{
      'id': 'm1',
      'type': 'manga',
      'attributes': <String, dynamic>{
        'chapterNumbersResetOnNewVolume': false,
      },
      'relationships': <Map<String, dynamic>>[
        {
          'id': 'auth-1',
          'type': 'author',
          'attributes': {'name': 'Author One'},
        },
      ],
    });

    final manga = Manga.from(data: data);

    expect(manga.artist, isNull);
  });
}
