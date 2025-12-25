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
      pageBuilder: (context, state) {
        return NoTransitionPage(
          name: UpdatesRoutePath.updates,
          child: MangaUpdatesScreen.create(
            locator: locator,
            onTapChapter: (manga, chapter) {
              final source = manga.source;
              final mangaId = manga.id;
              final chapterId = chapter.id;

              return context.pushNamed(
                BrowseRoutePath.chapterDetail,
                pathParameters: {
                  if (source != null) BrowsePathParam.source: source,
                  if (mangaId != null) BrowsePathParam.mangaId: mangaId,
                  if (chapterId != null) BrowsePathParam.chapterId: chapterId,
                },
              );
            },
            onTapManga: (manga) {
              final source = manga?.source;
              final mangaId = manga?.id;

              context.pushNamed(
                BrowseRoutePath.mangaDetail,
                pathParameters: {
                  if (source != null) BrowsePathParam.source: source,
                  if (mangaId != null) BrowsePathParam.mangaId: mangaId,
                },
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
    return [];
  }
}
