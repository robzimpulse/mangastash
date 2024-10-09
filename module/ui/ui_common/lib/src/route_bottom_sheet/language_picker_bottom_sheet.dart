import 'package:core_environment/core_environment.dart';
import 'package:core_route/core_route.dart';
import 'package:service_locator/service_locator.dart';

import '../../ui_common.dart';

class LanguagePickerBottomSheet extends BottomSheetRoute {
  LanguagePickerBottomSheet({
    super.key,
    super.name,
    required ServiceLocator locator,
    Language? selectedLanguage,
  }) : super(
          child: PickerBottomSheet.create(
            locator: locator,
            options: Language.values.map((e) => e.name).toList(),
            selected: selectedLanguage?.name,
          ),
          draggable: true,
          elevation: 16,
          expanded: false,
        );
}
