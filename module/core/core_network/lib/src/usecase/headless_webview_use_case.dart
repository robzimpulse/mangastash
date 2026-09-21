import 'package:html/dom.dart';

abstract class HeadlessWebviewUseCase {
  Future<Document> open(
    String url, {
    List<String> scripts = const [],
    bool useCache = true,
    Duration? timeout,
  });

  Future<String> image(
    String url, {
    bool useCache = true,
    Map<String, String>? headers,
    Duration? timeout,
  });
}
