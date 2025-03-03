import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:html/dom.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import '../../manager/headless_webview_manager.dart';
import '../../mixin/sync_chapters_mixin.dart';

class SearchChapterOnAsuraScanUseCase with SyncChaptersMixin {
  final MangaServiceFirebase _mangaServiceFirebase;
  final MangaChapterServiceFirebase _mangaChapterServiceFirebase;
  final HeadlessWebviewManager _webview;

  SearchChapterOnAsuraScanUseCase({
    required MangaServiceFirebase mangaServiceFirebase,
    required MangaChapterServiceFirebase mangaChapterServiceFirebase,
    required HeadlessWebviewManager webview,
  })  : _mangaServiceFirebase = mangaServiceFirebase,
        _mangaChapterServiceFirebase = mangaChapterServiceFirebase,
        _webview = webview;

  Future<Result<List<MangaChapter>>> execute({
    required String? mangaId,
    SearchChapterParameter? parameter,
  }) async {
    if (mangaId == null) return Error(Exception('Manga ID Empty'));

    final result = await _mangaServiceFirebase.get(id: mangaId);
    final url = result?.webUrl;

    if (result == null || url == null) {
      return Error(Exception('Data not found'));
    }

    final document = await _webview.open(url);

    if (document == null) {
      return Error(Exception('Error parsing html'));
    }

    final List<MangaChapter> chapters = [];

    final container = document.querySelector(
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

    for (final element in container?.children ?? <Element>[]) {
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
      final chapter = chapterData?.map((text) {
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
          .replaceAll('th', '')
          .asDateTime
          ?.toIso8601String();

      chapters.add(
        MangaChapter(
          mangaId: mangaId,
          mangaTitle: result.title,
          title: title?.isNotEmpty == true ? title : null,
          chapter: '${chapter ?? url?.split('/').lastOrNull}',
          readableAt: releaseDate,
          webUrl: ['https://asuracomic.net', 'series', url].join('/'),
        ),
      );
    }

    return Success(
      await sync(
        mangaChapterServiceFirebase: _mangaChapterServiceFirebase,
        values: chapters,
      ),
    );
  }
}
