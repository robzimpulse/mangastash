import 'package:core_environment/core_environment.dart';
import 'package:flutter/material.dart';
import 'package:intersperse/intersperse.dart';

class MangaMenuWidget extends StatelessWidget {
  const MangaMenuWidget({
    super.key,
    this.isOnLibrary,
    this.onTapLibrary,
    this.onTapPrefetch,
    this.onTapDownload,
  });

  final bool? isOnLibrary;

  final VoidCallback? onTapLibrary;

  final VoidCallback? onTapPrefetch;

  final VoidCallback? onTapDownload;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            'Action',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.start,
          ),
        ),
        isOnLibrary?.let(
          (value) => ListTile(
            title: Text('${value ? 'Remove from' : 'Add to'} Library'),
            leading: Icon(
              value ? Icons.favorite_border : Icons.favorite,
            ),
            onTap: onTapLibrary,
          ),
        ),
        ListTile(
          title: const Text('Prefetch'),
          leading: const Icon(Icons.cloud_download),
          onTap: onTapPrefetch,
        ),
        ListTile(
          title: const Text('Download'),
          leading: const Icon(Icons.download),
          onTap: onTapDownload,
        ),
      ].nonNulls.intersperse(const Divider(height: 1, thickness: 1)).toList(),
    );
  }
}
