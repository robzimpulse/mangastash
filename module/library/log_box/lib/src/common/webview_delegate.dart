import 'package:uuid/uuid.dart';

import 'enum.dart';
import 'storage.dart';

class WebviewDelegate {
  final Storage _storage;

  final String _id;

  WebviewDelegate({required Storage storage})
    : _storage = storage,
      _id = const Uuid().v4();

  void onWebViewCreated() {}

  void onLoadStart(Uri? uri) {}

  void onLoadStop(Uri? uri) {}

  void onProgressChanged(Uri? uri, int progress) {}

  void onReceivedError(Uri? uri, String message) {}

  void onConsoleMessage(Uri? uri, String message) {}

  void onNavigationResponse(Uri? uri) {}

  void shouldOverrideUrlLoading(Uri? uri, WebviewNavigationAction action) {}
}
