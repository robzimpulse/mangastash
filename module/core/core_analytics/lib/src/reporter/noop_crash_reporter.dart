import 'crash_reporter.dart';

/// A single [CrashReporter] invocation recorded by [NoOpCrashReporter].
///
/// Use it in tests to assert which method was called ([method]) and with which
/// arguments ([arguments], in declaration order, named arguments last).
class CrashReporterCall {
  const CrashReporterCall(this.method, this.arguments);

  /// The name of the invoked method, e.g. `'reportFatal'`.
  final String method;

  /// The arguments the method was invoked with, in declaration order.
  final List<Object?> arguments;
}

/// A [CrashReporter] that does nothing except record every call.
///
/// Use it as the default registration when no crash service is wired, and as
/// the stand-in for [CrashReporter] in tests — inspect [calls] to assert what
/// was reported.
class NoOpCrashReporter implements CrashReporter {
  /// Every invocation so far, one entry per method call.
  final List<CrashReporterCall> calls = [];

  @override
  Future<void> reportFatal(
    Object error,
    StackTrace stack, {
    String? reason,
  }) async {
    calls.add(CrashReporterCall('reportFatal', [error, stack, reason]));
  }

  @override
  Future<void> reportNonFatal(
    Object error,
    StackTrace stack, {
    String? reason,
  }) async {
    calls.add(CrashReporterCall('reportNonFatal', [error, stack, reason]));
  }

  @override
  Future<void> logBreadcrumb(String message) async {
    calls.add(CrashReporterCall('logBreadcrumb', [message]));
  }

  @override
  Future<void> setKey(String key, String value) async {
    calls.add(CrashReporterCall('setKey', [key, value]));
  }

  @override
  Future<void> setCollectionEnabled(bool enabled) async {
    calls.add(CrashReporterCall('setCollectionEnabled', [enabled]));
  }
}
