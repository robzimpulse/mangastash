import 'package:entity_manga/src/tag.dart';

import 'base/tag_list_html_parser.dart';

class AsuraScanTagListHtmlParser extends TagListHtmlParser {
  @override
  Future<List<Tag>> get tags async {
    final region = root.querySelector('form#hook-form');

    final elements = region?.querySelectorAll(
      'div.flex.flex-row.items-start.space-x-1.space-y-0',
    );

    return [
      for (final (index, element) in [...?elements].indexed)
        Tag(
          id: (index + 1).toString(),
          name: element.querySelector('label')?.text.trim(),
        ),
    ];
  }

  AsuraScanTagListHtmlParser({required super.root});
}
