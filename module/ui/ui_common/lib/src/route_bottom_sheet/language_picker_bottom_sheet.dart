import 'package:core_environment/core_environment.dart';
import 'package:core_route/core_route.dart';

import '../../ui_common.dart';

class LanguagePickerBottomSheet extends BottomSheetRoute {
  LanguagePickerBottomSheet({
    super.key,
    super.name,
    Language? selectedLanguage,
  }) : super(
          child: PickerBottomSheet(
            names: Language.values.map((e) => e.name).toList(),
            selectedName: selectedLanguage?.name,
          ),
          draggable: true,
          elevation: 16,
          expanded: false,
        );
}
