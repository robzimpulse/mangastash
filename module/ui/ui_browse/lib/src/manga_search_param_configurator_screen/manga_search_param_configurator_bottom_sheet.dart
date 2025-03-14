import 'package:core_route/core_route.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:service_locator/service_locator.dart';

import 'manga_search_param_configurator_screen.dart';

class MangaSearchParamConfiguratorBottomSheet extends BottomSheetRoute {
  MangaSearchParamConfiguratorBottomSheet({
    super.key,
    super.name,
    required ServiceLocator locator,
    SearchMangaParameter? parameter,
  }) : super(
          child: (context, controller) {
            return MangaSearchParamConfiguratorScreen.create(
              locator: locator,
              scrollController: controller,
              param: parameter,
            );
          },
          draggable: true,
          elevation: 16,
          isScrollControlled: true,
        );
}
