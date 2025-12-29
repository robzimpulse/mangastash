import 'package:flutter/material.dart';
import 'package:intersperse/intersperse.dart';

class ImageMenuWidget extends StatelessWidget {
  const ImageMenuWidget({super.key, this.onTapDeleteImage});

  final VoidCallback? onTapDeleteImage;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'Action',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.start,
            ),
          ),
          ListTile(
            title: const Text('Delete Image'),
            leading: const Icon(Icons.delete),
            onTap: onTapDeleteImage,
          ),
        ].intersperse(const Divider(height: 1, thickness: 1)),
      ],
    );
  }
}
