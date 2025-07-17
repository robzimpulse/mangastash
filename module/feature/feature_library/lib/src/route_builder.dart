import 'package:core_route/core_route.dart';
import 'package:feature_browse/feature_browse.dart';
import 'package:feature_common/feature_common.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_browse/ui_browse.dart';

import 'route_path.dart';

class LibraryRouteBuilder extends BaseRouteBuilder {
  @override
  GoRoute root({
    required ServiceLocator locator,
    List<NavigatorObserver> observers = const [],
  }) {
    return GoRoute(
      path: LibraryRoutePath.library,
      name: LibraryRoutePath.library,
      pageBuilder: (context, state) => NoTransitionPage(
        child: LibraryMangaScreen.create(
          locator: locator,
          onTapManga: (manga) => context.pushNamed(
            BrowseRoutePath.mangaDetail,
            pathParameters: {
              BrowseRoutePath.sourceQuery: manga?.source ?? '',
              BrowseRoutePath.mangaIdQuery: manga?.id ?? '',
            },
          ),
          onTapAddManga: () => context.pushNamed<String>(
            BrowseRoutePath.addManga,
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
        path: BrowseRoutePath.addManga,
        name: BrowseRoutePath.addManga,
        pageBuilder: (context, state) => TextFieldDialog(
          locator: locator,
          title: 'Add Manga',
          onSubmitted: (text) => context.pop(text),
        ),
      ),
    ];
  }
}
