import 'package:core_environment/core_environment.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:html/dom.dart';

import 'base/chapter_list_html_parser.dart';

class AsuraScanChapterListHtmlParser extends ChapterListHtmlParser {
  AsuraScanChapterListHtmlParser({required super.root});

  @override
  Future<List<ChapterScrapped>> get chapters async {
    final region = root.querySelector(
      [
        'div',
        'pl-4',
        'pr-2',
        'pb-4',
        'overflow-y-auto',
        'scrollbar-thumb-themecolor',
        'scrollbar-track-transparent',
        'scrollbar-thin',
        'mr-3',
      ].join('.'),
    );

    final List<ChapterScrapped> data = [];
    for (final element in region?.children ?? <Element>[]) {
      final url = element.querySelector('a')?.attributes['href'];

      final container = element.querySelector(
        [
          'h3',
          'text-sm',
          'text-white',
          'font-medium',
          'flex',
          'flex-row',
        ].join('.'),
      );

      final spans = container?.querySelectorAll('span');
      final title = spans?.firstOrNull?.text.trim();
      final isNotPublished = spans?.lastOrNull?.hasChildNodes() == true;

      if (isNotPublished) continue;

      final chapterData = container?.nodes.firstOrNull?.text?.trim().split(' ');
      final chapter =
          chapterData?.map((text) {
            final value = double.tryParse(text);
            if (value != null) {
              final fraction = value - value.truncate();
              if (fraction > 0.0) return value;
            }
            return int.tryParse(text);
          }).lastOrNull;

      final releaseDate = element
          .querySelector('h3.text-xs')
          ?.text
          .trim()
          .replaceAll('st', '')
          .replaceAll('nd', '')
          .replaceAll('rd', '')
          .replaceAll('th', '');

      data.add(
        ChapterScrapped(
          title: title?.isNotEmpty == true ? title : null,
          chapter: '${chapter ?? url?.split('/').lastOrNull}',
          readableAtRaw: releaseDate,
          webUrl: ['https://asuracomic.net', 'series', url].join('/'),
          scanlationGroup: SourceEnum.asurascan.label,
        ),
      );
    }

    return data;
  }
}
