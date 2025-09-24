import 'package:faro/faro.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:universal_io/io.dart';

mixin FaroMixin {
  Faro get faro => Faro();

  static void runner(Widget app) async {
    const faroApiKey = String.fromEnvironment('FARO_API_KEY');
    const faroCollectorUrl = String.fromEnvironment('FARO_COLLECTOR_URL');

    if (faroApiKey.isEmpty || faroCollectorUrl.isEmpty) {
      runApp(app);
      return;
    }

    await Faro().init(
      optionsConfiguration: FaroConfig(
        appName: (await PackageInfo.fromPlatform()).appName.toLowerCase(),
        appEnv: kDebugMode ? 'debug' : 'release',
        apiKey: faroApiKey,
        collectorUrl: faroCollectorUrl,
        enableCrashReporting: true,
        anrTracking: true,
        refreshRateVitals: true,
        namespace: 'flutter',
      ),
    );

    /// for tracking flutter error
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      Faro().pushError(
        type: 'flutter_error',
        value: details.exception.toString(),
        stacktrace: details.stack,
      );
      originalOnError?.call(details);
    };

    /// for tracking platform error
    final platformOriginalOnError = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (e, st) {
      Faro().pushError(
        type: 'platform_error',
        value: e.toString(),
        stacktrace: st,
      );
      return platformOriginalOnError?.call(e, st) ?? false;
    };

    /// for tracking http activity
    HttpOverrides.global = FaroHttpOverrides(HttpOverrides.current);

    runApp(
      DefaultAssetBundle(
        /// for tracking asset load time
        bundle: FaroAssetBundle(),

        /// for tracking user interaction
        child: FaroUserInteractionWidget(child: app),
      ),
    );
  }
}
