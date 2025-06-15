import 'package:core_environment/core_environment.dart';
import 'package:entity_manga/src/tag.dart';

import 'base/tag_list_html_parser.dart';

class MangaClashTagListHtmlParser extends TagListHtmlParser {
  @override
  List<Tag> get tags {
    final region = root.querySelector('div.form-group.checkbox-group.row');

    return [
      for (final child in [...?region?.children])
        Tag(
          id: child.querySelector('input')?.attributes['value'],
          name: toBeginningOfSentenceCase(child.text.trim()),
        ),
    ];
  }

  MangaClashTagListHtmlParser({required super.root});
}
