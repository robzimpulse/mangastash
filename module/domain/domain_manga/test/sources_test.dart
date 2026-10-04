// Registry tests for the Sources list. Dead sources must not be
// registered: their parsers can never succeed, and every browse/search
// against them just burns a webview fetch and surfaces errors.
import 'package:domain_manga/src/sources/sources.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dead sources are not registered (#166)', () {
    final names = Sources.values.map((e) => e.name).toSet();

    // flamecomics.xyz (and every sibling domain) redirects to a Discord
    // invite — the Next.js site no longer exists; isekaiscans.org returns
    // HTTP 522 (origin down). Verified live 2026-10-04.
    expect(names, isNot(contains('Flame Comics')));
    expect(names, isNot(contains('Isekai Scans')));
  });

  test('the registry is exactly the five live-verified sources (review on #170)', () {
    // Positive pin alongside the negatives above: catches a dropped live
    // source and forces any addition to be a deliberate act (update this
    // set together with the live-site verification).
    // NB: the name getters use spaced display names.
    expect(
      Sources.values.map((e) => e.name).toSet(),
      unorderedEquals({
        'Manga Dex',
        'Asura Scans',
        'Weeb Central',
        'Manga Katana',
        'Manhua Plus',
      }),
    );
  });
}
