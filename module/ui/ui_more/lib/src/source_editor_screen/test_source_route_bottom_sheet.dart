import 'package:core_route/core_route.dart';
import 'package:service_locator/service_locator.dart';

import 'widget/test_source_widget.dart';

class TestSourceRouteBottomSheet extends BottomSheetRoute {
  TestSourceRouteBottomSheet({
    super.key,
    super.name,
    required ServiceLocator locator,
  }) : super(
          child: (context, controller) => TestSourceWidget(
            onRunTest: (result) => context.pop(result),
          ),
          draggable: true,
          elevation: 16,
        );
}
