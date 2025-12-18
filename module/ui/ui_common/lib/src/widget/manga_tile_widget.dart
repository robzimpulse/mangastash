import 'package:cached_network_image/cached_network_image.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/material.dart';

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
    final sourceIconUrl = manga.source?.let(
      (e) => SourceEnum.fromValue(name: e),
    );
    final title = manga.title;

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            CachedNetworkImage(
              fit: BoxFit.cover,
              cacheManager: cacheManager,
              imageUrl: manga.coverUrl.or(
                'https://placehold.co/400?text=Cover+Url',
              ),
              width: 50,
              height: 50,
              memCacheWidth: 50,
              memCacheHeight: 50,
              errorWidget: (context, url, error) {
                return const Center(child: Icon(Icons.error));
              },
              progressIndicatorBuilder: (context, url, progress) {
                return Center(
                  child: CircularProgressIndicator(value: progress.progress),
                );
              },
            ),
            if (title != null)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(title),
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
              SizedBox(
                width: 24,
                height: 24,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: CachedNetworkImage(
                    cacheManager: cacheManager,
                    imageUrl: sourceIconUrl.icon,
                    fit: BoxFit.contain,
                    errorWidget: (context, url, error) {
                      return const Center(child: Icon(Icons.error));
                    },
                    progressIndicatorBuilder: (context, url, progress) {
                      return Center(
                        child: CircularProgressIndicator(
                          value: progress.progress,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
