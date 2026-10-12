// Tests for fixSourceLocation (issue #115): a "Fix source" request resolves
// to the source editor route with the script id, failing function and page
// URL as query parameters - and to null for sources with no script
// (MangaDex) or unknown names.
//
// Run with: fvm flutter test test/src/fix_source_location_test.dart
import 'package:feature_browse/src/fix_source_location.dart';
import 'package:feature_common/feature_common.dart';
import 'package:feature_more/feature_more.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String? scriptIdOf(String name) => name == 'My Site' ? 'my-site' : null;

  test('builds the editor location with id, function and url', () {
    final location = fixSourceLocation(
      const FixSourceTarget(
        sourceName: 'My Site',
        function: 'chapters',
        url: 'https://my-site.com/manga/a?x=1&y=2',
      ),
      scriptIdOf: scriptIdOf,
    );

    final uri = Uri.parse(location!);
    expect(uri.path, MoreRoutePath.sourceEditor);
    expect(uri.queryParameters, {
      'id': 'my-site',
      'function': 'chapters',
      'url': 'https://my-site.com/manga/a?x=1&y=2',
    });
  });

  test('omits the url parameter when the target has none', () {
    final location = fixSourceLocation(
      const FixSourceTarget(sourceName: 'My Site', function: 'search'),
      scriptIdOf: scriptIdOf,
    );

    expect(Uri.parse(location!).queryParameters, {
      'id': 'my-site',
      'function': 'search',
    });
  });

  test('is null for an unknown source name', () {
    expect(
      fixSourceLocation(
        const FixSourceTarget(sourceName: 'Gone', function: 'search'),
        scriptIdOf: scriptIdOf,
      ),
      null,
    );
  });

  test('is null for MangaDex, which has no script (default registry)', () {
    expect(
      fixSourceLocation(
        const FixSourceTarget(sourceName: 'Manga Dex', function: 'search'),
      ),
      null,
    );
  });
}
