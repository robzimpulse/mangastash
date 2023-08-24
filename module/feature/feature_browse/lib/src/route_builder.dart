import 'package:core_network/core_network.dart';
import 'package:core_route/core_route.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_browse/ui_browse.dart';
import 'package:ui_common/ui_common.dart';
import 'package:ui_mangadex/ui_mangadex.dart';

import 'route_path.dart';

class BrowseRouteBuilder extends BaseRouteBuilder {
  @override
  GoRoute root({
    required ServiceLocator locator,
    required GlobalKey<NavigatorState> rootNavigatorKey,
    required GlobalKey<NavigatorState> shellNavigatorKey,
  }) {
    return GoRoute(
      path: BrowseRoutePath.browse,
      name: BrowseRoutePath.browse,
      builder: (context, state) => BrowseSourceScreen.create(
        locator: locator,
        // TODO: implement redirect to search source screen
        onTapSearchManga: (context) => context.showSnackBar(
          message: '🚧🚧🚧 Under Construction 🚧🚧🚧',
        ),
        onTapSource: (context, source) => context.push(
          BrowseRoutePath.browseSource,
          extra: source,
        ),
      ),
      pageBuilder: (context, state) => NoTransitionPage(
        child: BrowseSourceScreen.create(
          locator: locator,
          // TODO: implement redirect to search source screen
          onTapSearchManga: (context) => context.showSnackBar(
            message: '🚧🚧🚧 Under Construction 🚧🚧🚧',
          ),
          onTapSource: (context, source) => context.push(
            BrowseRoutePath.browseSource,
            extra: source,
          ),
        ),
      ),
    );
  }

  @override
  List<RouteBase> routes({
    required ServiceLocator locator,
    required GlobalKey<NavigatorState> rootNavigatorKey,
    required GlobalKey<NavigatorState> shellNavigatorKey,
  }) {
    return [
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: BrowseRoutePath.browseSource,
        name: BrowseRoutePath.browseSource,
        redirect: (context, state) {
          final source = state.extra as MangaSource?;
          if (source == null) return 'undefined';
          return '${BrowseRoutePath.browse}/${source.id}';
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '${BrowseRoutePath.browse}/${MangaSource.mangadex.id}',
        name: '${BrowseRoutePath.browse}/${MangaSource.mangadex.id}',
        builder: (context, state) => BrowseMangaDexScreen.create(
          locator: locator,
        ),
      ),
      // TODO: add more route for specific source browse screen here
    ];
  }
}
