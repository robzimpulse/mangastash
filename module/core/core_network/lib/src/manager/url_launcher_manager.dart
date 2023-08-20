import 'package:url_launcher/url_launcher.dart';

import '../use_case/launch_url_use_case.dart';

class UrlLauncherManager implements LaunchUrlUseCase {
  @override
  void launch({
    required String url,
    LaunchMode mode = LaunchMode.platformDefault,
    WebViewConfiguration webViewConfiguration = const WebViewConfiguration(),
    String? webOnlyWindowName,
    Function(bool)? onSuccess,
  }) async {
    final result = await launchUrl(
      Uri.parse(url),
      mode: mode,
      webViewConfiguration: webViewConfiguration,
      webOnlyWindowName: webOnlyWindowName,
    );

    onSuccess?.call(result);
  }
}
