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
          onTapSearchManga: (context) => context.showSnackBar(
            message: '🚧🚧🚧 Under Construction 🚧🚧🚧',
          ),
          onTapSource: (context, source) => context.push(
            BrowseRoutePath.browseSourceManga.replaceAll(
              ':id',
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
        path: BrowseRoutePath.browseSourceManga,
        name: BrowseRoutePath.browseSourceManga,
        builder: (context, state) => BrowseMangaScreen.create(
          locator: locator,
          id: state.pathParameters['id'].asOrNull<String>(),
        ),
      ),
      // GoRoute(
      //   parentNavigatorKey: rootNavigatorKey,
      //   path: BrowseRoutePath.browseSource,
      //   name: BrowseRoutePath.browseSource,
      //   redirect: (context, state) {
      //     final source = state.extra as MangaSource?;
      //     if (source == null) return 'undefined';
      //     return '${BrowseRoutePath.browse}/${source.id}';
      //   },
      // ),
      // GoRoute(
      //   parentNavigatorKey: rootNavigatorKey,
      //   path: '${BrowseRoutePath.browse}/${MangaSource.mangadex.id}',
      //   name: '${BrowseRoutePath.browse}/${MangaSource.mangadex.id}',
      //   builder: (context, state) => BrowseMangaDexScreen.create(
      //     locator: locator,
      //     onTapManga: (context, manga) => context.push(
      //       '${BrowseRoutePath.browse}/${MangaSource.mangadex.id}/${manga.id}',
      //     ),
      //   ),
      // ),
      // GoRoute(
      //   parentNavigatorKey: rootNavigatorKey,
      //   path: [
      //     BrowseRoutePath.browse,
      //     MangaSource.mangadex.id,
      //     ':mangaId',
      //   ].join('/'),
      //   name: [
      //     BrowseRoutePath.browse,
      //     MangaSource.mangadex.id,
      //     ':mangaId',
      //   ].join('/'),
      //   builder: (context, state) => DetailMangaScreen.create(
      //     locator: locator,
      //     mangaId: state.pathParameters['mangaId'] ?? '',
      //     onTapChapter: (context, chapterId) => context.push(
      //       [
      //         BrowseRoutePath.browse,
      //         MangaSource.mangadex.id,
      //         state.pathParameters['mangaId'] ?? '',
      //         chapterId ?? '',
      //       ].join('/'),
      //     ),
      //   ),
      // ),
      // GoRoute(
      //   parentNavigatorKey: rootNavigatorKey,
      //   path: [
      //     BrowseRoutePath.browse,
      //     MangaSource.mangadex.id,
      //     ':mangaId',
      //     ':chapterId'
      //   ].join('/'),
      //   name: [
      //     BrowseRoutePath.browse,
      //     MangaSource.mangadex.id,
      //     ':mangaId',
      //     ':chapterId'
      //   ].join('/'),
      //   builder: (context, state) => ReaderMangaScreen.create(
      //     locator: locator,
      //     mangaId: state.pathParameters['mangaId'] ?? '',
      //     chapterId: state.pathParameters['chapterId'] ?? '',
      //   ),
      // ),
      // TODO: add more route for specific source browse screen here
    ];
  }
}
