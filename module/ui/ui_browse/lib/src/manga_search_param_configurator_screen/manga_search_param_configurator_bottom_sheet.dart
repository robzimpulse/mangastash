import 'package:core_route/core_route.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:service_locator/service_locator.dart';

import 'manga_search_param_configurator_screen.dart';

class MangaSearchParamConfiguratorBottomSheet extends BottomSheetRoute {
  MangaSearchParamConfiguratorBottomSheet({
    super.key,
    super.name,
    required ServiceLocator locator,
    SearchMangaParameter? parameter,
  }) : super(
          child: MangaSearchParamConfiguratorScreen.create(
            locator: locator,
          ),
          draggable: true,
          elevation: 16,
          expanded: false,
        );
}
