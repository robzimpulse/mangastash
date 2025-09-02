import 'package:faro/faro.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:universal_io/io.dart';

mixin FaroMixin {
  /// faro only support ios and android only
  Faro? get faro => Platform.isAndroid || Platform.isIOS ? Faro() : null;

  static void runner(Widget app) async {
    if (!(Platform.isAndroid || Platform.isIOS)) {
      runApp(app);
      return;
    }

    const faroApiKey = String.fromEnvironment('FARO_API_KEY');
    const faroCollectorUrl = String.fromEnvironment('FARO_COLLECTOR_URL');

    if (faroApiKey.isEmpty || faroCollectorUrl.isEmpty) {
      runApp(app);
      return;
    }

    HttpOverrides.global = FaroHttpOverrides(HttpOverrides.current);

    final info = await PackageInfo.fromPlatform();

    Faro().runApp(
      optionsConfiguration: FaroConfig(
        appName: info.appName,
        appVersion: info.version,
        appEnv: kDebugMode ? 'debug' : 'release',
        apiKey: faroApiKey,
        collectorUrl: faroCollectorUrl,
        enableCrashReporting: true,
        anrTracking: true,
        refreshRateVitals: true,
        namespace: 'flutter',
      ),
      appRunner: () {
        return runApp(
          DefaultAssetBundle(
            bundle: FaroAssetBundle(),
            child: FaroUserInteractionWidget(child: app),
          ),
        );
      },
    );
  }
}
