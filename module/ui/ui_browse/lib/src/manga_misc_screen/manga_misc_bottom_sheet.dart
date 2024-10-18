import 'package:core_route/core_route.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:service_locator/service_locator.dart';

import 'manga_misc_screen.dart';

class MangaMiscBottomSheetRoute extends BottomSheetRoute {
  MangaMiscBottomSheetRoute({
    super.key,
    super.name,
    required ServiceLocator locator,
    MangaChapterConfig? config,
  }) : super(
          child: MangaMiscScreen.create(
            locator: locator,
            config: config,
          ),
          draggable: true,
          elevation: 16,
          expanded: false,
        );
}
