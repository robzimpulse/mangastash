import 'package:core_network/src/exception/cloudflare_challenge_exception.dart';
import 'package:core_network/src/exception/failed_parsing_html_exception.dart';
import 'package:core_network/src/manager/cloudflare_detector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isCloudflareChallenge', () {
    test('matches the exact interstitial title', () {
      expect(isCloudflareChallenge(title: 'Just a moment...', html: ''), isTrue);
    });

    test('matches title case-insensitively and ignores surrounding blanks', () {
      expect(
        isCloudflareChallenge(title: '  just a moment... ', html: ''),
        isTrue,
      );
    });

    test('matches other Cloudflare block titles', () {
      expect(
        isCloudflareChallenge(title: 'Attention Required! | Cloudflare'),
        isTrue,
      );
      expect(isCloudflareChallenge(title: 'Access denied'), isTrue);
    });

    test('matches challenge-platform markers in the html', () {
      expect(
        isCloudflareChallenge(
          title: 'Some Title',
          html: '<script src="/cdn-cgi/challenge-platform/h/g/orchestrate/'
              'jsch/v1"></script>',
        ),
        isTrue,
      );
    });

    test('matches the checking-your-browser marker in the html', () {
      expect(
        isCloudflareChallenge(
          title: null,
          html: '<title>Checking your browser before accessing the site</title>',
        ),
        isTrue,
      );
    });

    test('does not match an ordinary page', () {
      expect(
        isCloudflareChallenge(
          title: 'Solo Leveling - Chapter 1',
          html: '<html><body><h1>Solo Leveling</h1></body></html>',
        ),
        isFalse,
      );
    });

    test('does not match a page that merely mentions Cloudflare CDN', () {
      expect(
        isCloudflareChallenge(
          title: 'Manga List',
          html: '<a href="https://cloudflare.com">hosted by Cloudflare</a>',
        ),
        isFalse,
      );
    });
  });

  group('CloudflareChallengeException', () {
    test('carries the url and an actionable message', () {
      final exception = CloudflareChallengeException('https://x.com/page');

      expect(exception.url, 'https://x.com/page');
      expect(exception.toString(), contains('CloudflareChallengeException'));
      expect(exception.toString(), contains('https://x.com/page'));
    });
  });

  group('isRecrawlableError', () {
    test('is true for FailedParsingHtmlException', () {
      expect(
        isRecrawlableError(FailedParsingHtmlException('https://x.com/page')),
        isTrue,
      );
    });

    test('is true for CloudflareChallengeException', () {
      expect(
        isRecrawlableError(CloudflareChallengeException('https://x.com/page')),
        isTrue,
      );
    });

    test('is false for any other error', () {
      expect(isRecrawlableError(Exception('boom')), isFalse);
    });

    test('recrawlUrlOf returns the url for both recrawlable types', () {
      expect(
        recrawlUrlOf(FailedParsingHtmlException('https://x.com/a')),
        'https://x.com/a',
      );
      expect(
        recrawlUrlOf(CloudflareChallengeException('https://x.com/b')),
        'https://x.com/b',
      );
      expect(recrawlUrlOf(Exception('boom')), isNull);
    });
  });

  group('fetchWithCloudflareRetry', () {
    test('returns the first attempt when it is not a challenge', () async {
      final delays = <Duration>[];

      final result = await fetchWithCloudflareRetry(
        url: 'https://x.com/page',
        attemptCount: 2,
        delay: (d) async => delays.add(d),
        attempt: () async => ('<html>ok</html>', 'Fine Title'),
      );

      expect(result, ('<html>ok</html>', 'Fine Title'));
      expect(delays, isEmpty);
    });

    test('retries once when the first attempt is a challenge', () async {
      final delays = <Duration>[];
      var calls = 0;

      final result = await fetchWithCloudflareRetry(
        url: 'https://x.com/page',
        attemptCount: 2,
        delay: (d) async => delays.add(d),
        attempt: () async {
          calls++;
          return calls == 1
              ? ('<html>challenge</html>', 'Just a moment...')
              : ('<html>ok</html>', 'Fine Title');
        },
      );

      expect(result, ('<html>ok</html>', 'Fine Title'));
      expect(calls, 2);
      expect(delays, hasLength(1));
    });

    test('throws CloudflareChallengeException after exhausting attempts', () async {
      var calls = 0;

      await expectLater(
        fetchWithCloudflareRetry(
        url: 'https://x.com/page',
          attemptCount: 2,
          delay: (_) async {},
          attempt: () async {
            calls++;
            return ('<html>challenge</html>', 'Just a moment...');
          },
        ),
        throwsA(isA<CloudflareChallengeException>()),
      );

      expect(calls, 2);
    });

    test('does not swallow non-challenge failures', () async {
      await expectLater(
        fetchWithCloudflareRetry(
        url: 'https://x.com/page',
          attemptCount: 2,
          delay: (_) async {},
          attempt: () async => throw FailedParsingHtmlException('https://x.com'),
        ),
        throwsA(isA<FailedParsingHtmlException>()),
      );
    });
  });
}
