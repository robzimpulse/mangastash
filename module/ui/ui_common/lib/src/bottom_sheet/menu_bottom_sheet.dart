import 'package:flutter/material.dart';
import 'package:intersperse/intersperse.dart';

class MenuBottomSheet extends StatelessWidget {
  const MenuBottomSheet({super.key, this.title, this.content = const []});

  final String? title;

  final List<Widget> content;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (title != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              title ?? '',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.start,
            ),
          ),
        ...content,
      ].intersperse(const Divider(height: 1, thickness: 1)).toList(),
    );
  }
}
