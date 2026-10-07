import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:log_box/log_box.dart';
import 'package:log_box_persistent_storage_drift/log_box_persistent_storage_drift.dart';
import 'package:service_locator/service_locator.dart';

import 'reporter/crash_reporter.dart';
import 'reporter/firebase_crash_reporter.dart';
import 'reporter/log_box_bridge.dart';
import 'reporter/noop_crash_reporter.dart';

/// Registers the analytics services: [LogBox], a [CrashReporter], and the
/// [LogBoxBridge] forwarding LogBox entries to that reporter (errors as
/// non-fatals, the rest as breadcrumbs).
///
/// The crash reporter prefers Firebase Crashlytics. Platforms that cannot run
/// it (web, Windows, Linux) and any Firebase initialization failure fall back
/// to [NoOpCrashReporter] instead of blocking startup.
class CoreAnalyticsRegistrar extends Registrar {
  /// Creates a registrar with overridable seams for tests.
  ///
  /// - [isSupportedPlatform] decides whether Firebase Crashlytics can run on
  ///   the current platform. Defaults to the real check: not web and not
  ///   Windows/Linux.
  /// - [firebaseInit] initializes the default [FirebaseApp]. Defaults to
  ///   [Firebase.initializeApp].
  /// - [enableCollectionInDebug] keeps crash collection enabled in debug/test
  ///   builds, where it is disabled by default so local crashes never reach
  ///   the dashboard.
  CoreAnalyticsRegistrar({
    bool Function()? isSupportedPlatform,
    Future<FirebaseApp> Function()? firebaseInit,
    bool enableCollectionInDebug = false,
  }) : _isSupportedPlatform =
           isSupportedPlatform ?? _defaultIsSupportedPlatform,
       _firebaseInit = firebaseInit ?? Firebase.initializeApp,
       _enableCollectionInDebug = enableCollectionInDebug;

  /// Seam for the platform support check, replaceable in tests.
  final bool Function() _isSupportedPlatform;

  /// Seam for the Firebase app initialization, replaceable in tests.
  final Future<FirebaseApp> Function() _firebaseInit;

  /// Whether crash collection stays enabled in debug/test builds.
  final bool _enableCollectionInDebug;

  /// Whether the current platform can run Firebase Crashlytics: everywhere
  /// except web, Windows, and Linux.
  static bool _defaultIsSupportedPlatform() {
    if (kIsWeb) {
      return false;
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.windows || TargetPlatform.linux => false,
      _ => true,
    };
  }

  @override
  Future<void> register(ServiceLocator locator) async {
    final start = DateTime.timestamp();
    locator.registerSingleton(
      LogBox(
        storage: Storage(
          liveDataStorage: MemoryStorage(capacity: 10000),
        ),
      ),
      dispose: (e) => e.dispose(),
    );
    locator.registerFactory(() => locator<LogBox>().queryInterceptor);
    locator.registerSingleton<CrashReporter>(
      await _buildCrashReporter(locator<LogBox>()),
    );
    if (kDebugMode && !_enableCollectionInDebug) {
      await locator<CrashReporter>().setCollectionEnabled(false);
    }
    final bridge = LogBoxBridge(
      logBox: locator<LogBox>(),
      reporter: locator<CrashReporter>(),
    );
    await bridge.start();
    locator.registerSingleton<LogBoxBridge>(
      bridge,
      dispose: (bridge) => bridge.close(),
    );
    final end = DateTime.timestamp();
    locator<LogBox>().log(
      'Register ${runtimeType.toString()}',
      id: runtimeType.toString(),
      name: 'Services',
      extra: {
        'start': start.toIso8601String(),
        'finish': end.toIso8601String(),
        'duration': end.difference(start).toString(),
      },
    );
  }

  /// Resolves the crash reporter: [FirebaseCrashReporter] when the platform is
  /// supported and Firebase initializes, [NoOpCrashReporter] otherwise. Every
  /// failure is logged to [logBox] and swallowed so registration never throws.
  Future<CrashReporter> _buildCrashReporter(LogBox logBox) async {
    if (!_isSupportedPlatform()) {
      return NoOpCrashReporter();
    }
    try {
      await _firebaseInit();
      return FirebaseCrashReporter(
        FirebaseCrashlytics.instance,
        logBox: logBox,
      );
    } catch (error, stackTrace) {
      logBox.log(
        'Failed to initialize Firebase Crashlytics, '
        'falling back to NoOpCrashReporter',
        name: 'CrashReporter',
        error: error,
        stackTrace: stackTrace,
      );
      return NoOpCrashReporter();
    }
  }
}
