import 'package:core_environment/core_environment.dart';
import 'package:core_route/core_route.dart';
import 'package:service_locator/service_locator.dart';

import '../widget/picker_widget.dart';

class LanguagePickerBottomSheet extends BottomSheetRoute {
  LanguagePickerBottomSheet({
    super.key,
    super.name,
    required ServiceLocator locator,
    Language? selected,
  }) : super(
          child: (context, controller) => PickerWidget(
            options: Language.values.map((e) => e.name).toList(),
            selected: selected?.name,
            controller: controller,
            onSelected: (value) => context.pop(value),
          ),
          draggable: true,
          elevation: 16,
          isScrollControlled: true,
        );
}
