import 'package:core_environment/core_environment.dart';
import 'package:core_route/core_route.dart';
import 'package:service_locator/service_locator.dart';

import '../../ui_common.dart';

class CountryPickerBottomSheet extends BottomSheetRoute {
  CountryPickerBottomSheet({
    super.key,
    super.name,
    required ServiceLocator locator,
    Country? selected,
  }) : super(
          child: PickerBottomSheet.create(
            locator: locator,
            options: Country.values.map((e) => e.name).toList(),
            selected: selected?.name,
          ),
          draggable: true,
          elevation: 16,
          expanded: false,
        );
}
