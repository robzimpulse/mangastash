import 'package:core_environment/core_environment.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/material.dart';

import 'base/network_image_widget.dart';

class MangaItemWidget extends StatelessWidget {
  const MangaItemWidget({
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
  final CustomCacheManager? cacheManager;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sourceIconUrl =
        manga.source?.let((e) => SourceEnum.fromValue(name: e))?.icon;

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
                  child: NetworkImageWidget(
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
              if (isOnLibrary) ...[
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                ),
                Positioned(
                  top: 4,
                  left: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    child: Text(
                      'In Library',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
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
              if (sourceIconUrl != null)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    color: isOnLibrary
                        ? Colors.transparent
                        : Colors.black.withValues(alpha: 0.5),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: NetworkImageWidget(
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
                ),
              if (isPrefetching)
                const Positioned.fill(
                  child: Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(),
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
