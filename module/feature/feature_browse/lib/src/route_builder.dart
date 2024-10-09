import 'package:core_environment/core_environment.dart';
import 'package:core_route/core_route.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_browse/ui_browse.dart';
import 'package:ui_common/ui_common.dart';

import 'route_path.dart';

class BrowseRouteBuilder extends BaseRouteBuilder {
  @override
  GoRoute root({
    required ServiceLocator locator,
  }) {
    return GoRoute(
      path: BrowseRoutePath.browse,
      name: BrowseRoutePath.browse,
      pageBuilder: (context, state) => NoTransitionPage(
        child: BrowseSourceScreen.create(
          locator: locator,
          // TODO: implement redirect to search source screen
          onTapSearchManga: () => context.showSnackBar(
            message: '🚧🚧🚧 Under Construction 🚧🚧🚧',
          ),
          onTapSource: (source) => context.push(
            BrowseRoutePath.browseManga.replaceAll(
              ':sourceId',
              source.id ?? '',
            ),
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
          sourceId: state.pathParameters['sourceId'].asOrNull<String>(),
          onTapManga: (mangaId) => context.push(
            BrowseRoutePath.mangaDetail
                .replaceAll(
                  ':sourceId',
                  state.pathParameters['sourceId'].asOrNull<String>() ?? '',
                )
                .replaceAll(':mangaId', mangaId ?? ''),
          ),
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: BrowseRoutePath.mangaDetail,
        name: BrowseRoutePath.mangaDetail,
        builder: (context, state) => MangaDetailScreen.create(
          locator: locator,
          sourceId: state.pathParameters['sourceId'].asOrNull<String>(),
          mangaId: state.pathParameters['mangaId'].asOrNull<String>(),
          onTapChapter: (chapterId) => context.push(
            BrowseRoutePath.chapterDetail
                .replaceAll(
                  ':sourceId',
                  state.pathParameters['sourceId'].asOrNull<String>() ?? '',
                )
                .replaceAll(
                  ':mangaId',
                  state.pathParameters['mangaId'].asOrNull<String>() ?? '',
                )
                .replaceAll(':chapterId', chapterId ?? ''),
          ),
          onTapSort: () => context.push(BrowseRoutePath.chapterConfig),
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: BrowseRoutePath.chapterDetail,
        name: BrowseRoutePath.chapterDetail,
        builder: (context, state) => MangaReaderScreen.create(
          locator: locator,
          sourceId: state.pathParameters['sourceId'].asOrNull<String>(),
          mangaId: state.pathParameters['mangaId'].asOrNull<String>(),
          chapterId: state.pathParameters['chapterId'].asOrNull<String>(),
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: BrowseRoutePath.chapterConfig,
        name: BrowseRoutePath.chapterConfig,
        pageBuilder: (context, state) => MangaMiscBottomSheetRoute(
          locator: locator,
        ),
      ),
    ];
  }
}
