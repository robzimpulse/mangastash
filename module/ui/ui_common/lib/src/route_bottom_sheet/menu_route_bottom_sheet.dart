import 'package:core_route/core_route.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:service_locator/service_locator.dart';

import '../widget/manga_menu_widget.dart';

class MenuRouteBottomSheet extends BottomSheetRoute {
  MenuRouteBottomSheet({
    super.key,
    super.name,
    required ServiceLocator locator,
    bool? isOnLibrary,
  }) : super(
          child: (context, controller) => MangaMenuWidget(
            isOnLibrary: isOnLibrary,
            onTapLibrary: () => context.pop(MangaMenu.library),
            onTapPrefetch: () => context.pop(MangaMenu.prefetch),
            onTapDownload: () => context.pop(MangaMenu.download),
          ),
          draggable: true,
          elevation: 16,
        );
}
