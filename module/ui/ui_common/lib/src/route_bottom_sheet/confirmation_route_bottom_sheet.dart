import 'package:core_route/core_route.dart';
import 'package:service_locator/service_locator.dart';

import '../widget/base/confirmation_widget.dart';

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
            onTapPositiveButton: () => context.pop(true),
            onTapNegativeButton: () => context.pop(false),
          ),
          draggable: true,
          elevation: 16,
        );
}
