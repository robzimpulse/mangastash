import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Helper {
  static void copyToClipboard({
    String text = '',
    required BuildContext context,
    String message = 'Copied to clipboard',
  }) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}