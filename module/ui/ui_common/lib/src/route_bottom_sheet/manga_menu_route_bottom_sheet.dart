import 'package:core_route/core_route.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:service_locator/service_locator.dart';

import '../widget/manga_menu_widget.dart';

class MangaMenuRouteBottomSheet extends BottomSheetRoute {
  MangaMenuRouteBottomSheet({
    super.key,
    super.name,
    required ServiceLocator locator,
    bool? isOnLibrary,
  }) : super(
         child: (context, controller) {
           return MangaMenuWidget(
             isOnLibrary: isOnLibrary,
             onTapLibrary: () => context.pop(MangaMenu.library),
             onTapPrefetch: () => context.pop(MangaMenu.prefetch),
             onTapDownload: () => context.pop(MangaMenu.download),
           );
         },
         draggable: true,
         elevation: 16,
       );
}
