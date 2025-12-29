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
    ValueGetter<List<NavigatorObserver>>? observers,
  }) {
    return GoRoute(
      path: LibraryRoutePath.library,
      name: LibraryRoutePath.library,
      pageBuilder: (context, state) {
        return NoTransitionPage(
          name: LibraryRoutePath.library,
          child: LibraryMangaScreen.create(
            locator: locator,
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
            onTapMangaMenu: (isOnLibrary) {
              return context.pushNamed(
                CommonRoutePath.mangaMenu,
                queryParameters: {
                  CommonQueryParam.isOnLibrary: isOnLibrary.toString(),
                },
              );
            },
            onTapAddManga: () => context.pushNamed(BrowseRoutePath.addManga),
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
        path: BrowseRoutePath.addManga,
        name: BrowseRoutePath.addManga,
        pageBuilder: (context, state) {
          return TextFieldDialog(
            locator: locator,
            title: 'Add Manga',
            onSubmitted: (text) => context.pop(text),
          );
        },
      ),
    ];
  }
}
