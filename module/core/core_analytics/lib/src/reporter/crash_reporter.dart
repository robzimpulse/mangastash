/// The seam for crash reporting services, e.g. Firebase Crashlytics.
///
/// Consume it via `locator<CrashReporter>()` and report anything that should
/// reach the crash dashboard. Implementations must never throw: every method
/// guards internally and logs its own failures to LogBox instead of
/// propagating them to the caller.
abstract class CrashReporter {
  /// Reports [error] as a fatal crash, i.e. one that terminated the app.
  Future<void> reportFatal(Object error, StackTrace stack, {String? reason});

  /// Reports [error] as a non-fatal exception, i.e. one the app recovered from.
  Future<void> reportNonFatal(Object error, StackTrace stack, {String? reason});

  /// Records [message] as a breadcrumb attached to the next crash report.
  Future<void> logBreadcrumb(String message);

  /// Associates [value] with [key] on every subsequent crash report.
  Future<void> setKey(String key, String value);

  /// Enables or disables crash data collection at runtime.
  Future<void> setCollectionEnabled(bool enabled);
}
