import 'package:core_route/core_route.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:service_locator/service_locator.dart';

import 'manga_search_param_configurator_screen.dart';

class MangaSearchParamConfiguratorBottomSheet extends BottomSheetRoute {
  MangaSearchParamConfiguratorBottomSheet({
    super.key,
    super.name,
    required ServiceLocator locator,
    SearchParameterExtra? extra,
  }) : super(
          child: (context, controller) {
            return MangaSearchParamConfiguratorScreen.create(
              locator: locator,
              scrollController: controller,
              param: extra?.parameter,
              tags: [...?extra?.tags],
            );
          },
          draggable: true,
          elevation: 16,
          isScrollControlled: true,
        );
}
