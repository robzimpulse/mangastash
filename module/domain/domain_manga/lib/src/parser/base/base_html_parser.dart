import 'package:core_storage/core_storage.dart';
import 'package:html/dom.dart';

class BaseHtmlParser {
  final Document root;
  final ConverterCacheManager converterCacheManager;
  BaseHtmlParser({required this.root, required this.converterCacheManager});
}
