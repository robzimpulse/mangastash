import 'package:url_launcher/url_launcher.dart';

import '../use_case/launch_url_use_case.dart';

class UrlLauncherManager implements LaunchUrlUseCase {
  @override
  Future<bool> launch({
    required String url,
    LaunchMode mode = LaunchMode.platformDefault,
    WebViewConfiguration webViewConfiguration = const WebViewConfiguration(),
    String? webOnlyWindowName,
  }) async {
    return launchUrl(
      Uri.parse(url),
      mode: mode,
      webViewConfiguration: webViewConfiguration,
      webOnlyWindowName: webOnlyWindowName,
    );
  }
}
