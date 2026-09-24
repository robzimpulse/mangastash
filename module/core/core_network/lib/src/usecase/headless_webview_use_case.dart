import 'package:html/dom.dart';

abstract class HeadlessWebviewUseCase {
  /// [readyWhenSelectors] — CSS selectors that must each match at least one
  /// element before the HTML snapshot is taken; a fetch whose readiness is
  /// never met fails instead of caching a broken page. Empty means no
  /// readiness requirement.
  Future<Document> open(
    String url, {
    List<String> scripts = const [],
    List<String> readyWhenSelectors = const [],
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
