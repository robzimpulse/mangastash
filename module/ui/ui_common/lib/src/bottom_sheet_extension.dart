import 'package:flutter/material.dart';

extension BottomSheetExtension on BuildContext {
  Future<T?> showBottomSheet<T>({
    required WidgetBuilder builder,
  }) async {
    final statusBar = MediaQuery.of(this).viewPadding.top;
    final maxHeight = MediaQuery.of(this).size.height - statusBar;

    return showModalBottomSheet<T>(
      context: this,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Theme.of(this).bottomSheetTheme.backgroundColor,
      constraints: BoxConstraints(maxHeight: maxHeight),
      builder: builder,
    );
  }

  void dismissSheet<T>({T? result}) {
    Navigator.of(this).pop(result);
  }
}
