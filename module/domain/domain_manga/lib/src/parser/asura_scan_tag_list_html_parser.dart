import 'package:entity_manga/src/tag.dart';

import 'base/tag_list_html_parser.dart';

class AsuraScanTagListHtmlParser extends TagListHtmlParser {

  @override
  List<Tag> get tags {
    final region = root.querySelectorAll('form#hook-form');
    
    
    // TODO: implement tags
    return [];
  }

  AsuraScanTagListHtmlParser({required super.root});

}