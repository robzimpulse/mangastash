// Tests for [normalizedHostOf] — the shared URL-host normaliser used by the
// moved-source predicate (domain_manga) and MangaDao's title+source fallback
// (issue #206). Hosts compare lowercase with one leading `www.` stripped;
// anything without a parseable host normalises to null.
//
// Usage: run with `fvm flutter test test/util/normalized_host_test.dart`
// from module/library/manga_service_drift.
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_service_drift/manga_service_drift.dart';

void main() {
  group('normalizedHostOf', () {
    test('lowercases the host and strips the port', () {
      expect(normalizedHostOf('https://WWW.Old.com:443/x'), equals('old.com'));
    });

    test('keeps subdomains other than www.', () {
      expect(normalizedHostOf('https://cdn.old.com/a'), equals('cdn.old.com'));
    });

    test('null url normalises to null', () {
      expect(normalizedHostOf(null), isNull);
    });

    test('blank url normalises to null', () {
      expect(normalizedHostOf(''), isNull);
    });

    test('unparseable url normalises to null', () {
      expect(normalizedHostOf('not a url'), isNull);
    });

    test('strips only one leading www.', () {
      expect(normalizedHostOf('https://www.www.x.com'), equals('www.x.com'));
    });
  });
}
