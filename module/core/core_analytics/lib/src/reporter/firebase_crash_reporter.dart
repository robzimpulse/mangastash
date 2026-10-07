import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:log_box/log_box.dart';

import 'crash_reporter.dart';

/// A [CrashReporter] backed by Firebase Crashlytics.
///
/// It delegates every [CrashReporter] call to the injected
/// [FirebaseCrashlytics] backend and never throws: each method is guarded so
/// that a backend failure (missing platform channel, offline SDK, …) is logged
/// to the injected [LogBox] and swallowed instead of propagating to the caller
/// — crash reporting must never crash the app.
///
/// Usage: construct it with the real backend in the registrar
/// (`FirebaseCrashReporter(FirebaseCrashlytics.instance, logBox: locator<LogBox>())`)
/// and register it as the `CrashReporter` alias. The backend and LogBox are
/// injected so unit tests never touch the Firebase singleton, platform
/// channels, or the service locator.
class FirebaseCrashReporter implements CrashReporter {
  FirebaseCrashReporter(this._crashlytics, {required LogBox logBox})
    : _logBox = logBox;

  /// The Firebase Crashlytics instance every call delegates to.
  final FirebaseCrashlytics _crashlytics;

  /// Where guard failures are logged to.
  final LogBox _logBox;

  @override
  Future<void> reportFatal(Object error, StackTrace stack, {String? reason}) {
    return _guard(
      'report fatal error',
      () => _crashlytics.recordError(error, stack, reason: reason, fatal: true),
    );
  }

  @override
  Future<void> reportNonFatal(
    Object error,
    StackTrace stack, {
    String? reason,
  }) {
    return _guard(
      'report non-fatal error',
      () =>
          _crashlytics.recordError(error, stack, reason: reason, fatal: false),
    );
  }

  @override
  Future<void> logBreadcrumb(String message) {
    return _guard('log breadcrumb', () => _crashlytics.log(message));
  }

  @override
  Future<void> setKey(String key, String value) {
    return _guard(
      'set custom key',
      () => _crashlytics.setCustomKey(key, value),
    );
  }

  @override
  Future<void> setCollectionEnabled(bool enabled) {
    return _guard(
      'set collection enabled',
      () => _crashlytics.setCrashlyticsCollectionEnabled(enabled),
    );
  }

  /// Runs [run], logging any failure to LogBox instead of propagating it.
  ///
  /// [action] names the guarded operation so the log entry says which crash
  /// report was dropped.
  Future<void> _guard(String action, Future<void> Function() run) async {
    try {
      await run();
    } catch (error, stackTrace) {
      _logBox.log(
        'Failed to $action via Firebase Crashlytics',
        name: 'FirebaseCrashReporter',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
