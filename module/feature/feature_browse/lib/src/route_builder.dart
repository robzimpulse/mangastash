import 'package:core_environment/core_environment.dart';
import 'package:core_route/core_route.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:feature_common/feature_common.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_browse/ui_browse.dart';

import 'route_path.dart';

class BrowseRouteBuilder extends BaseRouteBuilder {
  @override
  GoRoute root({
    required ServiceLocator locator,
    ValueGetter<List<NavigatorObserver>>? observers,
  }) {
    return GoRoute(
      path: BrowseRoutePath.browse,
      name: BrowseRoutePath.browse,
      pageBuilder: (context, state) {
        return NoTransitionPage(
          name: BrowseRoutePath.browse,
          child: BrowseSourceScreen.create(
            locator: locator,
            onTapSearchManga: () {
              context.push(BrowseRoutePath.searchManga);
            },
            onTapSource: (source) {
              context.pushNamed(
                BrowseRoutePath.browseManga,
                pathParameters: {BrowsePathParam.source: source.name},
              );
            },
          ),
        );
      },
    );
  }

  @override
  List<RouteBase> routes({
    required ServiceLocator locator,
    required GlobalKey<NavigatorState> rootNavigatorKey,
  }) {
    return [
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: BrowseRoutePath.browseManga,
        name: BrowseRoutePath.browseManga,
        builder: (context, state) {
          final params = state.pathParameters;
          final queries = state.uri.queryParameters;
          final source = params[BrowsePathParam.source];
          final tagId = queries[BrowseQueryParam.tagId];

          return BrowseMangaScreen.create(
            locator: locator,
            source: source,
            tagId: tagId,
            onTapManga: (manga, param) {
              final mangaId = manga.id;
              return context.pushNamed(
                BrowseRoutePath.mangaDetail,
                pathParameters: {
                  if (source != null) BrowsePathParam.source: source,
                  if (mangaId != null) BrowsePathParam.mangaId: mangaId,
                },
              );
            },
            onTapMangaMenu: (isOnLibrary) {
              return context.pushNamed(
                CommonRoutePath.menu,
                queryParameters: {
                  CommonRoutePath.menuIsOnLibrary: isOnLibrary.toString(),
                },
              );
            },
            onTapFilter: (param, tags) {
              return context.push(
                BrowseRoutePath.searchParam,
                extra: SearchParameterExtra(tags: tags, parameter: param),
              );
            },
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: BrowseRoutePath.mangaDetail,
        name: BrowseRoutePath.mangaDetail,
        builder: (context, state) {
          final params = state.pathParameters;
          final source = params[BrowsePathParam.source];
          final mangaId = params[BrowsePathParam.mangaId];

          return MangaDetailScreen.create(
            locator: locator,
            source: source,
            mangaId: mangaId,
            onTapChapter: (chapter) {
              final chapterId = chapter.id;
              context.pushNamed(
                BrowseRoutePath.chapterDetail,
                pathParameters: {
                  if (source != null) BrowsePathParam.source: source,
                  if (mangaId != null) BrowsePathParam.mangaId: mangaId,
                  if (chapterId != null) BrowsePathParam.chapterId: chapterId,
                },
              );
            },
            onTapSort: (config) {
              return context.push<ChapterConfig>(
                BrowseRoutePath.chapterConfig,
                extra: config,
              );
            },
            onTapManga: (manga) {
              final mangaId = manga.id;
              context.pushNamed(
                BrowseRoutePath.mangaDetail,
                pathParameters: {
                  if (source != null) BrowsePathParam.source: source,
                  if (mangaId != null) BrowsePathParam.mangaId: mangaId,
                },
              );
            },
            onTapTag: (tag) {
              final tagId = tag.id;
              context.pushNamed(
                BrowseRoutePath.browseManga,
                pathParameters: {
                  if (source != null) BrowsePathParam.source: source,
                },
                queryParameters: {
                  if (tagId != null) BrowseQueryParam.tagId: tagId,
                },
              );
            },
            onMangaMenu: (manga, isOnLibrary) {
              return context.pushNamed<MangaMenu>(
                CommonRoutePath.menu,
                queryParameters: {
                  CommonRoutePath.menuIsOnLibrary: isOnLibrary.toString(),
                },
              );
            },
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: BrowseRoutePath.chapterDetail,
        name: BrowseRoutePath.chapterDetail,
        builder: (context, state) {
          final params = state.pathParameters;
          final source = params[BrowsePathParam.source];
          final mangaId = params[BrowsePathParam.mangaId];
          final chapterId = params[BrowsePathParam.chapterId];

          return MangaReaderScreen.create(
            locator: locator,
            source: source,
            mangaId: mangaId,
            chapterId: chapterId,
            onTapShortcut: (chapterId) {
              return context.pushReplacementNamed(
                BrowseRoutePath.chapterDetail,
                pathParameters: {
                  if (source != null) BrowsePathParam.source: source,
                  if (mangaId != null) BrowsePathParam.mangaId: mangaId,
                  BrowsePathParam.chapterId: chapterId,
                },
              );
            },
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: BrowseRoutePath.chapterConfig,
        name: BrowseRoutePath.chapterConfig,
        pageBuilder: (context, state) {
          return MangaMiscBottomSheetRoute(
            locator: locator,
            config: state.extra.castOrNull(),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: BrowseRoutePath.searchParam,
        name: BrowseRoutePath.searchParam,
        pageBuilder: (context, state) {
          return MangaSearchParamConfiguratorBottomSheet(
            locator: locator,
            extra: state.extra.castOrNull(),
          );
        },
      ),
      GoRoute(
        path: BrowseRoutePath.searchManga,
        name: BrowseRoutePath.searchManga,
        builder: (context, state) {
          return SearchMangaScreen.create(
            locator: locator,
            onTapManga: (manga, parameter) {
              final mangaId = manga.id;
              final source = manga.source;
              context.pushNamed(
                BrowseRoutePath.mangaDetail,
                pathParameters: {
                  if (source != null) BrowsePathParam.source: source,
                  if (mangaId != null) BrowsePathParam.mangaId: mangaId,
                },
              );
            },
          );
        },
      ),
    ];
  }
}
