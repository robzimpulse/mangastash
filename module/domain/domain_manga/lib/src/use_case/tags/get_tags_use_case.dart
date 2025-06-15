import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:html/parser.dart';
import 'package:log_box/log_box.dart';

import '../../../domain_manga.dart';
import '../../extension/search_url_mixin.dart';
import '../../manager/headless_webview_manager.dart';
import '../../mixin/sync_tags_mixin.dart';
import '../../parser/base/tag_list_html_parser.dart';
import 'get_tags_on_mangadex_use_case.dart';

class GetTagsUseCase with SyncTagsMixin {
  final GetTagsOnMangaDexUseCase _getTagsOnMangaDexUseCase;
  final HeadlessWebviewManager _webview;
  final TagDao _tagDao;
  final LogBox _logBox;

  const GetTagsUseCase({
    required GetTagsOnMangaDexUseCase getTagsOnMangaDexUseCase,
    required HeadlessWebviewManager webview,
    required TagDao tagDao,
    required LogBox logBox,
  })  : _getTagsOnMangaDexUseCase = getTagsOnMangaDexUseCase,
        _tagDao = tagDao,
        _webview = webview,
        _logBox = logBox;

  Future<Result<List<Tag>>> execute({required String source}) async {
    if (source == Source.mangadex().name) {
      return _getTagsOnMangaDexUseCase.execute();
    }

    const parameter = SearchMangaParameter(page: 1);

    String url = '';
    if (source == Source.asurascan().name) {
      url = parameter.asurascan;
    } else if (source == Source.mangaclash().name) {
      url = parameter.mangaclash;
    }

    final document = await _webview.open(
      url,
      scripts: [
        if (source == Source.asurascan().name)
          'window.document.querySelectorAll(\'${[
            'button',
            'inline-flex',
            'items-center',
            'whitespace-nowrap',
            'px-4',
            'py-2',
            'w-full',
            'justify-center',
            'font-normal',
            'align-middle',
            'border-solid',
          ].join('.')}\')[0].click()',
      ],
    );

    if (document == null) {
      return Error(FailedParsingHtmlException(url));
    }

    final parser = TagListHtmlParser.forSource(
      root: document,
      source: source,
    );

    final data = await sync(
      dao: _tagDao,
      values: [...parser.tags.map((e) => e.copyWith(source: source))],
      logBox: _logBox,
    );

    return Success(data);
  }
}
