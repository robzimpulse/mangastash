import 'package:core_route/core_route.dart';
import 'package:flutter/material.dart';
import 'package:service_locator/service_locator.dart';

class TextFieldDialog extends PopupDialogRoute {
  TextFieldDialog({
    super.key,
    super.name,
    required ServiceLocator locator,
    required String title,
    ValueChanged<String>? onSubmitted,
  }) : super(
          child: (context) {
            final controller = TextEditingController();

            return AlertDialog(
              title: Text(title),
              content: TextField(
                controller: controller,
                onSubmitted: onSubmitted,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    final text = controller.text;
                    controller.dispose();
                    onSubmitted?.call(text);
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
}
