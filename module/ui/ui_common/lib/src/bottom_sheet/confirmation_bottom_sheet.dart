import 'package:core_route/core_route.dart';
import 'package:flutter/material.dart';
import 'package:intersperse/intersperse.dart';

class ConfirmationBottomSheet extends StatelessWidget {
  const ConfirmationBottomSheet({
    super.key,
    this.title,
    required this.content,
    this.positiveButtonText,
    this.negativeButtonText,
  });

  final String? title;
  final String content;

  final String? positiveButtonText;
  final String? negativeButtonText;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (title != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(title ?? ''),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(content),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: <Widget>[
              if (negativeButtonText != null)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.pop(false),
                    child: Text(negativeButtonText ?? ''),
                  ),
                ),
              if (positiveButtonText != null)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.pop(true),
                    child: Text(positiveButtonText ?? ''),
                  ),
                ),
            ].intersperse(const SizedBox(width: 16)).toList(),
          ),
        )
      ].intersperse(const Divider(height: 1, thickness: 1)).toList(),
    );
  }
}
