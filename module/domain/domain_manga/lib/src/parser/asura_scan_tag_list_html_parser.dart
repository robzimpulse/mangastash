import 'package:core_environment/core_environment.dart';
import 'package:entity_manga/src/tag.dart';

import 'base/tag_list_html_parser.dart';

class AsuraScanTagListHtmlParser extends TagListHtmlParser {
  @override
  Future<List<Tag>> get tags async {
    final region = root.querySelector('form#hook-form');

    final elements = region?.querySelectorAll(
      'div.flex.flex-row.items-start.space-x-1.space-y-0',
    );

    final tags = [
      for (final (index, element) in [...?elements].indexed)
        Tag(
          id: (index + 1).toString(),
          // TODO: move to intermediary object like [ChapterScrapped]
          name: toBeginningOfSentenceCase(
            element.querySelector('label')?.text.trim(),
          ),
        ),
    ];

    return tags;
  }

  AsuraScanTagListHtmlParser({required super.root});
}
