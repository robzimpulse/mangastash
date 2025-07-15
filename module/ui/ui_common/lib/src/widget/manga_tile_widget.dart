import 'package:core_environment/core_environment.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/material.dart';

import 'base/cached_network_image_widget.dart';

class MangaTileWidget extends StatelessWidget {
  const MangaTileWidget({
    super.key,
    required this.manga,
    this.padding = const EdgeInsets.all(0),
    this.onTap,
    this.isOnLibrary = false,
    this.isPrefetching = false,
    this.onLongPress,
    this.cacheManager,
  });

  final Manga manga;
  final bool isOnLibrary;
  final bool isPrefetching;
  final BaseCacheManager? cacheManager;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final sourceIconUrl =
        manga.source?.let((e) => SourceEnum.fromValue(name: e))?.icon;

    return Row(
      children: [
        CachedNetworkImageWidget(
          fit: BoxFit.cover,
          cacheManager: cacheManager,
          imageUrl: manga.coverUrl.or(
            'https://placehold.co/400?text=Cover+Url',
          ),
          width: 50,
          height: 50,
          errorBuilder: (context, error, _) => const Icon(Icons.error),
          progressBuilder: (context, progress) => Center(
            child: CircularProgressIndicator(
              value: progress,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(manga.title.or('Manga Title')),
          ),
        ),
        if (isPrefetching)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(),
          ),
        if (isOnLibrary) const Icon(Icons.bookmark),
        if (sourceIconUrl != null) ...[
          Container(
            width: 24,
            height: 24,
            color: isOnLibrary
                ? Colors.transparent
                : Colors.black.withValues(alpha: 0.5),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: CachedNetworkImageWidget(
                cacheManager: cacheManager,
                imageUrl: sourceIconUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, _) => const Center(
                  child: Icon(Icons.error),
                ),
                progressBuilder: (context, progress) => Center(
                  child: CircularProgressIndicator(
                    value: progress,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
