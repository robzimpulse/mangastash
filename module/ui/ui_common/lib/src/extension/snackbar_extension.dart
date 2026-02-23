import 'package:flutter/material.dart';

extension SnackbarExtension on BuildContext {
  void showOnProgressSnackBar() {
    showSnackBar(message: '🚧🚧🚧 Under Construction 🚧🚧🚧');
  }

  void showSnackBar({required String message, List<Widget>? actions}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Expanded(
              child: Text(
                message,
                style: Theme.of(this).textTheme.bodyLarge,
              ),
            ),
            ...?actions,
          ],
        ),
        backgroundColor: Theme.of(this).colorScheme.surface,
      ),
    );
  }
}
