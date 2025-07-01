import 'package:core_route/core_route.dart';
import 'package:service_locator/service_locator.dart';

import '../widget/confirmation_widget.dart';

class ConfirmationRouteBottomSheet extends BottomSheetRoute {
  ConfirmationRouteBottomSheet({
    super.key,
    super.name,
    required ServiceLocator locator,
    String? title,
    String? positiveButtonText,
    String? negativeButtonText,
    required String content,
  }) : super(
          child: (context, controller) => ConfirmationWidget(
            title: title,
            content: content,
            positiveButtonText: positiveButtonText,
            negativeButtonText: negativeButtonText,
          ),
          draggable: true,
          elevation: 16,
        );
}
