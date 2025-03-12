import 'package:core_environment/core_environment.dart';
import 'package:core_route/core_route.dart';
import 'package:service_locator/service_locator.dart';

import '../../ui_common.dart';

class LanguagePickerBottomSheet extends BottomSheetRoute {
  LanguagePickerBottomSheet({
    super.key,
    super.name,
    required ServiceLocator locator,
    Language? selected,
  }) : super(
          child: (context, controller) => PickerBottomSheet.create(
            locator: locator,
            options: Language.values.map((e) => e.name).toList(),
            selected: selected?.name,
            controller: controller,
          ),
          draggable: true,
          elevation: 16,
          isScrollControlled: true,
        );
}
