import 'package:core_route/core_route.dart';
import 'package:feature_browse/feature_browse.dart';
import 'package:flutter/widgets.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_updates/ui_updates.dart';

import 'route_path.dart';

class UpdatesRouteBuilder extends BaseRouteBuilder {
  @override
  GoRoute root({
    required ServiceLocator locator,
    ValueGetter<List<NavigatorObserver>>? observers,
  }) {
    return GoRoute(
      path: UpdatesRoutePath.updates,
      name: UpdatesRoutePath.updates,
      pageBuilder: (context, state) => NoTransitionPage(
        name: UpdatesRoutePath.updates,
        child: MangaUpdatesScreen.create(
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
