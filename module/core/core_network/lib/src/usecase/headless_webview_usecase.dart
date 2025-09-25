import 'package:html/dom.dart';

abstract class HeadlessWebviewUseCase {
  Future<Document?> open(
    String url, {
    List<String> scripts = const [],
    bool useCache = true,
  });
}
