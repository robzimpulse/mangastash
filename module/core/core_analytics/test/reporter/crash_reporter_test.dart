import 'package:core_analytics/core_analytics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NoOpCrashReporter', () {
    test('NoOpCrashReporter records calls and never throws', () async {
      final reporter = NoOpCrashReporter();
      await reporter.reportFatal(Exception('boom'), StackTrace.empty);
      await reporter.reportNonFatal(Exception('oops'), StackTrace.empty);
      await reporter.logBreadcrumb('nav');
      await reporter.setKey('source', 'mangadex');
      await reporter.setCollectionEnabled(false);
      expect(reporter.calls, hasLength(5));
    });

    test('recorded calls carry their method name and arguments', () async {
      final reporter = NoOpCrashReporter();
      final error = Exception('boom');
      const reason = 'chapter-reader';
      await reporter.reportFatal(error, StackTrace.empty, reason: reason);
      await reporter.logBreadcrumb('nav');
      await reporter.setKey('source', 'mangadex');
      await reporter.setCollectionEnabled(false);

      expect(reporter.calls, hasLength(4));
      expect(reporter.calls[0].method, 'reportFatal');
      expect(
        reporter.calls[0].arguments,
        [error, StackTrace.empty, reason],
      );
      expect(reporter.calls[1].method, 'logBreadcrumb');
      expect(reporter.calls[1].arguments, ['nav']);
      expect(reporter.calls[2].method, 'setKey');
      expect(reporter.calls[2].arguments, ['source', 'mangadex']);
      expect(reporter.calls[3].method, 'setCollectionEnabled');
      expect(reporter.calls[3].arguments, [false]);
    });
  });
}
