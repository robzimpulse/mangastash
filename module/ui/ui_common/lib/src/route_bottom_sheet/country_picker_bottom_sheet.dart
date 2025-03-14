import 'package:core_environment/core_environment.dart';
import 'package:core_route/core_route.dart';
import 'package:service_locator/service_locator.dart';

import '../bottom_sheet/picker_bottom_sheet/picker_bottom_sheet.dart';

class CountryPickerBottomSheet extends BottomSheetRoute {
  CountryPickerBottomSheet({
    super.key,
    super.name,
    required ServiceLocator locator,
    Country? selected,
  }) : super(
          child: (context, controller) => PickerBottomSheet.create(
            locator: locator,
            options: Country.values.map((e) => e.name).toList(),
            selected: selected?.name,
            controller: controller,
          ),
          draggable: true,
          elevation: 16,
          isScrollControlled: true,
        );
}
