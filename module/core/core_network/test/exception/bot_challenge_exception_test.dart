/// Unit tests for [BotChallengeException] and [isBotChallengeUri].
///
/// Validates predicate logic detecting MangaDex edge bot challenge URLs
/// and verifies string formatting of the exception.
///
/// Usage:
/// Run via `fvm flutter test test/exception/bot_challenge_exception_test.dart`.
import 'package:core_network/core_network.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isBotChallengeUri', () {
    test('detects challenge URI on mangadex.org/edge/challenge', () {
      expect(
        isBotChallengeUri(
          Uri.parse('https://mangadex.org/edge/challenge?src=abc'),
        ),
        isTrue,
      );
    });

    test('returns false for other paths or hosts', () {
      expect(
        isBotChallengeUri(Uri.parse('https://mangadex.org/title/x')),
        isFalse,
      );
      expect(
        isBotChallengeUri(Uri.parse('https://api.mangadex.org/edge/challenge')),
        isFalse,
      );
      expect(
        isBotChallengeUri(Uri.parse('https://evil.com/edge/challenge')),
        isFalse,
      );
    });
  });

  group('BotChallengeException', () {
    test('toString contains url and bot challenge message', () {
      final exception = BotChallengeException('https://api.mangadex.org/manga');
      expect(exception.toString(), contains('https://api.mangadex.org/manga'));
      expect(exception.toString(), contains('bot challenge'));
    });
  });
}
