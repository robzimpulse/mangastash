import 'package:core_environment/core_environment.dart';
import 'package:flutter/material.dart';
import 'package:intersperse/intersperse.dart';

class ConfirmationWidget extends StatelessWidget {
  const ConfirmationWidget({
    super.key,
    this.title,
    required this.content,
    this.positiveButtonText,
    this.negativeButtonText,
    this.onTapPositiveButton,
    this.onTapNegativeButton,
  });

  final String? title;
  final String content;

  final String? positiveButtonText;
  final String? negativeButtonText;

  final VoidCallback? onTapPositiveButton;
  final VoidCallback? onTapNegativeButton;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget?>[
        title?.let(
          (text) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              title ?? '',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.start,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Text(content),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Row(
            children: <Widget?>[
              negativeButtonText?.let(
                (text) => Expanded(
                  child: OutlinedButton(
                    onPressed: onTapNegativeButton,
                    child: Text(negativeButtonText ?? ''),
                  ),
                ),
              ),
              positiveButtonText?.let(
                (text) => Expanded(
                  child: OutlinedButton(
                    onPressed: onTapPositiveButton,
                    child: Text(positiveButtonText ?? ''),
                  ),
                ),
              ),
            ].nonNulls.intersperse(const SizedBox(width: 16)).toList(),
          ),
        ),
      ].nonNulls.intersperse(const Divider(height: 1, thickness: 1)).toList(),
    );
  }
}
