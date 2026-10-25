// Tests for fixSourceTargetOf (issue #115): which errors can open the source
// editor ("Fix source") and what they prefill.
//
// Run with: fvm flutter test test/util/fix_source_target_test.dart
import 'package:core_network/core_network.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_common/src/util/fix_source_target.dart';

void main() {
  group('fixSourceTargetOf', () {
    test('maps a SourceScriptException with a source directly', () {
      final target = fixSourceTargetOf(
        const SourceScriptException(
          function: 'search',
          message: 'm',
          source: 'Asura Scans',
          url: 'u',
        ),
      );

      expect(target?.sourceName, 'Asura Scans');
      expect(target?.function, 'search');
      expect(target?.url, 'u');
    });

    test('maps a FailedParsingHtmlException parser to the function', () {
      final target = fixSourceTargetOf(
        FailedParsingHtmlException(
          'u',
          source: 'Manga Katana',
          parser: 'chapters',
        ),
      );

      expect(target?.sourceName, 'Manga Katana');
      expect(target?.function, 'chapters');
      expect(target?.url, 'u');
    });

    test('is null for a page-load failure (the script never ran)', () {
      expect(
        fixSourceTargetOf(
          const SourceScriptException(
            function: 'chapters',
            message: 'chapters timed out loading the page after 15s',
            source: 'Weeb Central',
            url: 'u',
            timedOut: true,
            loadFailed: true,
          ),
        ),
        null,
      );
    });

    test('is null for a SourceScriptException without a source', () {
      expect(
        fixSourceTargetOf(
          const SourceScriptException(function: 'search', message: 'm'),
        ),
        null,
      );
    });

    test('is null for a FailedParsingHtmlException without source/parser', () {
      expect(fixSourceTargetOf(FailedParsingHtmlException('u')), null);
      expect(
        fixSourceTargetOf(FailedParsingHtmlException('u', parser: 'search')),
        null,
      );
      expect(
        fixSourceTargetOf(FailedParsingHtmlException('u', source: 'S')),
        null,
      );
    });

    test('is null for any other error', () {
      expect(fixSourceTargetOf(Exception()), null);
      expect(fixSourceTargetOf(null), null);
    });
  });
}
