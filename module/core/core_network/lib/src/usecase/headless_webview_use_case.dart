import 'package:html/dom.dart';

abstract class HeadlessWebviewUseCase {
  Future<Document> open(
    String url, {
    List<String> scripts = const [],
    bool useCache = true,
    bool forceLoad = false,
  });

  Future<String> image(
    String url, {
    bool useCache = true,
    bool forceLoad = false,
    Map<String, String>? headers,
  });
}
