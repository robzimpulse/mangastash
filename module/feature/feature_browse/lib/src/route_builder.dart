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
      pageBuilder: (context, state) => NoTransitionPage(
        name: BrowseRoutePath.browse,
        child: BrowseSourceScreen.create(
          locator: locator,
          // TODO: implement redirect to search source screen
          onTapSearchManga: () => context.showSnackBar(
            message: '🚧🚧🚧 Under Construction 🚧🚧🚧',
          ),
          onTapSource: (source) => context.pushNamed(
            BrowseRoutePath.browseManga,
            pathParameters: {'source': source.name},
          ),
        ),
      ),
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
        builder: (context, state) => BrowseMangaScreen.create(
          locator: locator,
          source: state.pathParameters[BrowseRoutePath.sourceQuery],
          onTapManga: (manga, param) => context.pushNamed(
            BrowseRoutePath.mangaDetail,
            pathParameters: {
              BrowseRoutePath.sourceQuery:
                  state.pathParameters[BrowseRoutePath.sourceQuery] ?? '',
              BrowseRoutePath.mangaIdQuery: manga.id ?? '',
            },
          ),
          onTapFilter: (param, tags) => context.push(
            BrowseRoutePath.searchParam,
            extra: SearchParameterExtra(
              tags: tags,
              parameter: param,
            ),
          ),
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: BrowseRoutePath.mangaDetail,
        name: BrowseRoutePath.mangaDetail,
        builder: (context, state) => MangaDetailScreen.create(
          locator: locator,
          source: state.pathParameters[BrowseRoutePath.sourceQuery],
          mangaId: state.pathParameters[BrowseRoutePath.mangaIdQuery],
          onTapChapter: (chapter) => context.pushNamed(
            BrowseRoutePath.chapterDetail,
            pathParameters: {
              BrowseRoutePath.sourceQuery:
                  state.pathParameters[BrowseRoutePath.sourceQuery] ?? '',
              BrowseRoutePath.mangaIdQuery:
                  state.pathParameters[BrowseRoutePath.mangaIdQuery] ?? '',
              BrowseRoutePath.chapterIdQuery: chapter.id ?? '',
            },
          ),
          onTapSort: (config) => context.push<ChapterConfig>(
            BrowseRoutePath.chapterConfig,
            extra: config,
          ),
          onTapManga: (manga) => context.pushNamed(
            BrowseRoutePath.mangaDetail,
            pathParameters: {
              BrowseRoutePath.sourceQuery:
                  state.pathParameters[BrowseRoutePath.sourceQuery] ?? '',
              BrowseRoutePath.mangaIdQuery: manga.id ?? '',
            },
          ),
          onMangaMenu: (manga, isOnLibrary) => context.pushNamed<MangaMenu>(
            CommonRoutePath.menu,
            queryParameters: {
              CommonRoutePath.menuIsOnLibrary: isOnLibrary ? 'true' : 'false',
            },
          ),
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: BrowseRoutePath.chapterDetail,
        name: BrowseRoutePath.chapterDetail,
        builder: (context, state) => MangaReaderScreen.create(
          locator: locator,
          source: state.pathParameters[BrowseRoutePath.sourceQuery],
          mangaId: state.pathParameters[BrowseRoutePath.mangaIdQuery],
          chapterId: state.pathParameters[BrowseRoutePath.chapterIdQuery],
          onTapShortcut: (chapterId) => context.pushReplacementNamed(
            BrowseRoutePath.chapterDetail,
            pathParameters: {
              BrowseRoutePath.sourceQuery:
                  state.pathParameters[BrowseRoutePath.sourceQuery] ?? '',
              BrowseRoutePath.mangaIdQuery:
                  state.pathParameters[BrowseRoutePath.mangaIdQuery] ?? '',
              BrowseRoutePath.chapterIdQuery: chapterId ?? '',
            },
          ),
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: BrowseRoutePath.chapterConfig,
        name: BrowseRoutePath.chapterConfig,
        pageBuilder: (context, state) => MangaMiscBottomSheetRoute(
          locator: locator,
          config: state.extra.castOrNull(),
        ),
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
