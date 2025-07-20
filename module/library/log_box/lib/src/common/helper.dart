import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Helper {
  static const int _kilobyteAsByte = 1000;
  static const int _megabyteAsByte = 1000000;

  static const String _bytes = 'B';
  static const String _kiloBytes = 'kB';
  static const String _megaBytes = 'MB';

  static void copyToClipboard({
    required BuildContext context,
    String text = '',
    String message = 'Copied to clipboard',
  }) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  static String formatBytes(int bytes) {
    return switch (bytes) {
      int bytes when bytes < 0 => '-1 $_bytes',
      int bytes when bytes <= _kilobyteAsByte => '$bytes $_bytes',
      int bytes when bytes <= _megabyteAsByte =>
        '${_formatDouble(bytes / _kilobyteAsByte)} $_kiloBytes',
      _ => '${_formatDouble(bytes / _megabyteAsByte)} $_megaBytes',
    };
  }

  static String _formatDouble(double value) => value.toStringAsFixed(2);
}
