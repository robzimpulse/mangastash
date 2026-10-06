// Tests for Relationship.from's include dispatch (issue #131): artist
// relationships were silently dropped (TODO break), discarding co-artist
// credits. Artists carry the same attribute shape as authors, so they parse
// as Relationship<AuthorDataAttributes>.
//
// Run with: fvm flutter test test/model/common/relationship_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

void main() {
  test('from keeps artist relationships with their attributes (#131)', () {
    final relationships = Relationship.from([
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
    ]);

    // Previously the artist entry hit a TODO break and was discarded.
    expect(relationships.length, 2);

    final artist = relationships[1];
    expect(artist.id, 'art-1');
    expect(artist.type, 'artist');
    expect(
      (artist as Relationship<AuthorDataAttributes>).attributes?.name,
      'Artist One',
    );
  });
}
