/// Tests for [SourceScriptException]'s `loadFailed` flag (issue #115):
/// a page or runner that never loaded is not a script fault, the flag must
/// survive [SourceScriptException.copyWith], and [isTransientLoadError]
/// recognises exactly those failures.
///
/// Usage: `fvm flutter test test/script/source_script_exception_test.dart`
/// from module/core/core_network.
library;

import 'package:core_network/core_network.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loadFailed defaults to false', () {
    const e = SourceScriptException(function: 'search', message: 'm');
    expect(e.loadFailed, isFalse);
  });

  test('isTransientLoadError is true only for load failures', () {
    expect(
      isTransientLoadError(
        const SourceScriptException(
          function: 'chapters',
          message: 'm',
          loadFailed: true,
        ),
      ),
      isTrue,
    );
    expect(
      isTransientLoadError(
        const SourceScriptException(
          function: 'search',
          message: 'search timed out after 15s',
          timedOut: true,
        ),
      ),
      isFalse,
    );
    expect(isTransientLoadError(Exception('x')), isFalse);
    expect(isTransientLoadError(null), isFalse);
  });

  test('copyWith keeps loadFailed', () {
    const e = SourceScriptException(
      function: 'chapters',
      message: 'm',
      timedOut: true,
      loadFailed: true,
    );
    final copy = e.copyWith(source: 'Weeb Central', html: '<p>');
    expect(copy.loadFailed, isTrue);
    expect(copy.timedOut, isTrue);
    expect(copy.source, 'Weeb Central');
  });
}
