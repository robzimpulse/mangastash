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
            // TODO: implement redirect to search source screen
            onTapSearchManga: () {
              return context.showSnackBar(
                message: '🚧🚧🚧 Under Construction 🚧🚧🚧',
              );
            },
            onTapSource: (source) {
              context.pushNamed(
                BrowseRoutePath.browseManga,
                pathParameters: {'source': source.name},
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
          final source = params[BrowseRoutePath.sourceQuery];

          return BrowseMangaScreen.create(
            locator: locator,
            source: source,
            onTapManga: (manga, param) {
              return context.pushNamed(
                BrowseRoutePath.mangaDetail,
                pathParameters: {
                  BrowseRoutePath.sourceQuery: source ?? '',
                  BrowseRoutePath.mangaIdQuery: manga.id ?? '',
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
          final source = params[BrowseRoutePath.sourceQuery];
          final mangaId = params[BrowseRoutePath.mangaIdQuery];

          return MangaDetailScreen.create(
            locator: locator,
            source: source,
            mangaId: mangaId,
            onTapChapter: (chapter) {
              context.pushNamed(
                BrowseRoutePath.chapterDetail,
                pathParameters: {
                  BrowseRoutePath.sourceQuery: source ?? '',
                  BrowseRoutePath.mangaIdQuery: mangaId ?? '',
                  BrowseRoutePath.chapterIdQuery: chapter.id ?? '',
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
              context.pushNamed(
                BrowseRoutePath.mangaDetail,
                pathParameters: {
                  BrowseRoutePath.sourceQuery: source ?? '',
                  BrowseRoutePath.mangaIdQuery: manga.id ?? '',
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
          final source = params[BrowseRoutePath.sourceQuery];
          final mangaId = params[BrowseRoutePath.mangaIdQuery];
          final chapterId = params[BrowseRoutePath.chapterIdQuery];

          return MangaReaderScreen.create(
            locator: locator,
            source: source,
            mangaId: mangaId,
            chapterId: chapterId,
            onTapShortcut: (chapterId) {
              return context.pushReplacementNamed(
                BrowseRoutePath.chapterDetail,
                pathParameters: {
                  BrowseRoutePath.sourceQuery: source ?? '',
                  BrowseRoutePath.mangaIdQuery: mangaId ?? '',
                  BrowseRoutePath.chapterIdQuery: chapterId,
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
    ];
  }
}
