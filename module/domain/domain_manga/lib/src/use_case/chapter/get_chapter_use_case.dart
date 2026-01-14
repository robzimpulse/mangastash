import 'package:core_analytics/core_analytics.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import '../../mixin/sync_chapters_mixin.dart';
import '../../parser/base/chapter_image_html_parser.dart';

class GetChapterUseCase with SyncChaptersMixin {
  final ChapterRepository _chapterRepository;
  final AtHomeRepository _atHomeRepository;
  final HeadlessWebviewUseCase _webview;
  final ChapterDao _chapterDao;
  final LogBox _logBox;

  GetChapterUseCase({
    required ChapterRepository chapterRepository,
    required AtHomeRepository atHomeRepository,
    required HeadlessWebviewUseCase webview,
    required ChapterDao chapterDao,
    required LogBox logBox,
  }) : _chapterRepository = chapterRepository,
       _atHomeRepository = atHomeRepository,
       _chapterDao = chapterDao,
       _logBox = logBox,
       _webview = webview;

  Future<Chapter> _mangadex({
    required String mangaId,
    required String chapterId,
  }) async {
    final response = await Future.wait([
      _chapterRepository.detail(chapterId, includes: [Include.manga]),
      _atHomeRepository.url(chapterId),
    ]);

    final chapter = response[0] as ChapterResponse;
    final atHome = response[1] as AtHomeResponse;

    return Chapter(
      id: chapter.data?.id,
      title: chapter.data?.attributes?.title,
      chapter: chapter.data?.attributes?.chapter,
      volume: chapter.data?.attributes?.volume,
      images: atHome.images,
      translatedLanguage: chapter.data?.attributes?.translatedLanguage,
      mangaId: mangaId,
    );
  }

  Future<List<String>> _scrapping({
    required String? url,
    required SourceEnum source,
    bool useCache = true,
  }) async {
    if (url == null) {
      throw DataNotFoundException();
    }

    final selector = [
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
    ].join('.');

    final document = await _webview.open(
      url,
      scripts: [
        if (source == SourceEnum.asurascan)
          'window.document.querySelectorAll(\'$selector\')[0].click()',
      ],
      useCache: useCache,
    );

    final parser = ChapterImageHtmlParser.forSource(
      root: document,
      source: source,
    );

    return parser.images;
  }

  Future<Result<Chapter>> execute({
    required SourceEnum source,
    required String mangaId,
    required String chapterId,
    bool useCache = true,
  }) async {
    try {
      final raw = await _chapterDao.search(ids: [chapterId]);
      final chapter = raw.firstOrNull.let(
        (e) => e.chapter?.let((d) => Chapter.fromDrift(d, images: e.images)),
      );

      if (chapter != null && chapter.images.or([]).isNotEmpty) {
        return Success(chapter);
      }

      final data = await switch (source) {
        SourceEnum.mangadex => _mangadex(
          mangaId: mangaId,
          chapterId: chapterId,
        ),
        _ => _scrapping(
          url: chapter?.webUrl,
          source: source,
          useCache: useCache,
        ).then((e) => chapter?.copyWith(images: e)),
      };

      final results = await sync(
        dao: _chapterDao,
        values: [
          ...[data].nonNulls,
        ],
        logBox: _logBox,
      );

      final result = results.firstOrNull;

      if (result == null) {
        throw DataNotFoundException();
      }

      return Success(result);
    } catch (e) {
      return Error(e);
    }
  }
}
