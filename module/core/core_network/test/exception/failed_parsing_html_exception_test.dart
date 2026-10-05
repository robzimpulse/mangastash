// Tests for FailedParsingHtmlException's parse-failure context (issue
// #114): scrapers attach the source, parser, and missing fields so a
// silent selector drift surfaces as a diagnostic parse error at scrape
// time instead of a DataNotFoundException at reader time.
//
// Run with: fvm flutter test test/exception/failed_parsing_html_exception_test.dart
import 'package:core_network/src/exception/cloudflare_challenge_exception.dart';
import 'package:core_network/src/exception/failed_parsing_html_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('carries url, source, parser and missing fields', () {
    final error = FailedParsingHtmlException(
      'https://asurascans.com/comics/solo-leveling',
      source: 'Asura Scans',
      parser: 'getManga',
      missingFields: const ['title'],
    );

    expect(error.url, 'https://asurascans.com/comics/solo-leveling');
    expect(error.source, 'Asura Scans');
    expect(error.parser, 'getManga');
    expect(error.missingFields, ['title']);
  });

  test('toString lists the context when attached', () {
    final error = FailedParsingHtmlException(
      'https://asurascans.com/comics/solo-leveling',
      source: 'Asura Scans',
      parser: 'getManga',
      missingFields: const ['title'],
    );

    expect(
      error.toString(),
      'FailedParsingHtmlException : Failed parsing html from '
      'https://asurascans.com/comics/solo-leveling '
      '(source Asura Scans; parser getManga; missing title)',
    );
  });

  test('toString keeps the legacy message when no context is attached', () {
    // HeadlessWebviewManager throws the bare form — its message must not
    // change shape under this enrichment.
    final error = FailedParsingHtmlException('https://x.com/page');

    expect(
      error.toString(),
      'FailedParsingHtmlException : Failed parsing html from https://x.com/page',
    );
  });

  test('stays recrawlable with context attached', () {
    // The recrawl/"open debug browser" flow keys off these helpers — a
    // scrape-time parse failure must still offer the recrawl action.
    final error = FailedParsingHtmlException(
      'https://weebcentral.com/series/x',
      source: 'Weeb Central',
      parser: 'listChapter',
      missingFields: const ['chapter rows'],
    );

    expect(isRecrawlableError(error), isTrue);
    expect(recrawlUrlOf(error), 'https://weebcentral.com/series/x');
  });
}
