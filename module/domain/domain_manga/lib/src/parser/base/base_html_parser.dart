import 'package:core_storage/core_storage.dart';
import 'package:html/dom.dart';

class BaseHtmlParser {
  final Document root;
  final StorageManager storageManager;
  BaseHtmlParser({required this.root, required this.storageManager});
}
