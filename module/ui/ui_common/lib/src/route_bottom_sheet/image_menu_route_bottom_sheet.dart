import 'package:core_route/core_route.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:service_locator/service_locator.dart';

import '../widget/image_menu_widget.dart';

class ImageMenuRouteBottomSheet extends BottomSheetRoute {
  ImageMenuRouteBottomSheet({
    super.key,
    super.name,
    required ServiceLocator locator,
  }) : super(
         child: (context, controller) {
           return ImageMenuWidget(
             onTapDeleteImage: () => context.pop(ImageMenu.delete),
           );
         },
         draggable: true,
         elevation: 16,
       );
}
