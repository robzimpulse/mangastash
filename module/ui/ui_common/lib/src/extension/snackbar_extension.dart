import 'package:flutter/material.dart';

extension SnackbarExtension on BuildContext {
  void showSnackBar({required String message}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message, style: Theme.of(this).textTheme.bodyText1),
        backgroundColor: Theme.of(this).backgroundColor,
      ),
    );
  }
}
