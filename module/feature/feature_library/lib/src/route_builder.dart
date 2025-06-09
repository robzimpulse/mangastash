import 'package:core_route/core_route.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:feature_browse/feature_browse.dart';
import 'package:flutter/widgets.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_browse/ui_browse.dart';

import 'route_path.dart';

class LibraryRouteBuilder extends BaseRouteBuilder {
  @override
  GoRoute root({
    required ServiceLocator locator,
  }) {
    return GoRoute(
      path: LibraryRoutePath.library,
      name: LibraryRoutePath.library,
      pageBuilder: (context, state) => NoTransitionPage(
        child: LibraryMangaScreen.create(
          locator: locator,
          onTapManga: (manga) => context.push(
            BrowseRoutePath.mangaDetail
                .replaceAll(':source', '${manga?.source}')
                .replaceAll(':mangaId', '${manga?.id}'),
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
