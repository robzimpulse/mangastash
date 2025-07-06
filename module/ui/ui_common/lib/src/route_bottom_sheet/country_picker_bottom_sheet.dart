import 'package:core_environment/core_environment.dart';
import 'package:core_route/core_route.dart';
import 'package:service_locator/service_locator.dart';

import '../widget/base/picker_widget.dart';

class CountryPickerBottomSheet extends BottomSheetRoute {
  CountryPickerBottomSheet({
    super.key,
    super.name,
    required ServiceLocator locator,
    Country? selected,
  }) : super(
          child: (context, controller) => PickerWidget(
            options: Country.values.map((e) => e.name).toList(),
            selected: selected?.name,
            controller: controller,
            onSelected: (value) => context.pop(value),
          ),
          draggable: true,
          elevation: 16,
          isScrollControlled: true,
        );
}
