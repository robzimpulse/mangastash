// Tests for isRecrawlableError / recrawlUrlOf (issue #115 review): besides
// parse failures and Cloudflare challenges, a source script failure on a
// loaded page (SourceScriptException with a url — e.g. a ctx.waitFor timeout
// on an interstitial) must offer the "Open Debug Browser" recrawl, while a
// URL-builder failure on the blank page (no url) must not.
//
// Run with: fvm flutter test test/exception/recrawlable_error_test.dart
import 'package:core_network/src/exception/cloudflare_challenge_exception.dart';
import 'package:core_network/src/exception/failed_parsing_html_exception.dart';
import 'package:core_network/src/script/source_script_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a page script failure is recrawlable at its url', () {
    const error = SourceScriptException(
      function: 'images',
      message: 'waitFor timed out: img[data-page-index]',
      url: 'https://asurascans.com/comics/x/chapter/1',
      source: 'Asura Scans',
    );

    expect(isRecrawlableError(error), isTrue);
    expect(recrawlUrlOf(error), 'https://asurascans.com/comics/x/chapter/1');
  });

  test('a page script timeout is recrawlable', () {
    const error = SourceScriptException(
      function: 'search',
      message: 'search timed out after 15s',
      url: 'https://asurascans.com/browse?page=1',
      timedOut: true,
    );

    expect(isRecrawlableError(error), isTrue);
    expect(recrawlUrlOf(error), 'https://asurascans.com/browse?page=1');
  });

  test('a URL-builder failure without a url is not recrawlable', () {
    const error = SourceScriptException(function: 'searchUrl', message: 'x');

    expect(isRecrawlableError(error), isFalse);
    expect(recrawlUrlOf(error), isNull);
  });

  test('parse failures and Cloudflare challenges stay recrawlable', () {
    final parse = FailedParsingHtmlException('https://a.com/p');
    final challenge = CloudflareChallengeException('https://b.com/p');

    expect(isRecrawlableError(parse), isTrue);
    expect(recrawlUrlOf(parse), 'https://a.com/p');
    expect(isRecrawlableError(challenge), isTrue);
    expect(recrawlUrlOf(challenge), 'https://b.com/p');
    expect(isRecrawlableError(Exception('other')), isFalse);
    expect(recrawlUrlOf(null), isNull);
  });
}
