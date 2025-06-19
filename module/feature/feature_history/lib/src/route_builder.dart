import 'package:core_route/core_route.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:feature_browse/feature_browse.dart';
import 'package:flutter/widgets.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_updates/ui_updates.dart';

import 'route_path.dart';

class HistoryRouteBuilder extends BaseRouteBuilder {
  @override
  GoRoute root({
    required ServiceLocator locator,
  }) {
    return GoRoute(
      path: HistoryRoutePath.history,
      name: HistoryRoutePath.history,
      pageBuilder: (context, state) => NoTransitionPage(
        child: MangaHistoryScreen.create(
          locator: locator,
          onTapChapter: (manga, chapter) => context.pushNamed(
            BrowseRoutePath.chapterDetail,
            pathParameters: {
              BrowseRoutePath.sourceQuery: manga.source ?? '',
              BrowseRoutePath.mangaIdQuery: manga.id ?? '',
              BrowseRoutePath.chapterIdQuery: chapter.id ?? '',
            },
          ),
          onTapManga: (manga) => context.pushNamed(
            BrowseRoutePath.mangaDetail,
            pathParameters: {
              BrowseRoutePath.sourceQuery: manga?.source ?? '',
              BrowseRoutePath.mangaIdQuery: manga?.id ?? '',
            },
            extra: MangaDetailExtra(manga: manga, param: null),
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
    return [];
  }
}
