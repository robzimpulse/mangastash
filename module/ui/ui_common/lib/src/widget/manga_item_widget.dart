import 'package:core_environment/core_environment.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/material.dart';

import 'base/cached_network_image_widget.dart';

class MangaItemWidget extends StatelessWidget {
  const MangaItemWidget({
    super.key,
    required this.manga,
    this.padding = const EdgeInsets.all(0),
    this.onTap,
    this.onLongPress,
    this.cacheManager,
  });

  final Manga manga;
  final BaseCacheManager? cacheManager;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.scaffoldBackgroundColor,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: padding,
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: CachedNetworkImageWidget(
                    cacheManager: cacheManager,
                    fit: BoxFit.fill,
                    imageUrl: manga.coverUrl.or(
                      'https://placehold.co/400?text=Cover+Url',
                    ),
                    errorBuilder: (context, error, _) => const Center(
                      child: Icon(Icons.error),
                    ),
                    progressBuilder: (context, progress) => Center(
                      child: CircularProgressIndicator(value: progress),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  width: double.infinity,
                  color: theme.scaffoldBackgroundColor.withValues(alpha: 0.7),
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    manga.title.or('Manga Title'),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
