import 'package:url_launcher/src/types.dart';

abstract class LaunchUrlUseCase {
  Future<bool> launch({
    required String url,
    LaunchMode mode = LaunchMode.platformDefault,
    WebViewConfiguration webViewConfiguration = const WebViewConfiguration(),
    String? webOnlyWindowName,
  });
}