import 'package:cached_network_image/cached_network_image.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/material.dart';

import 'base/image_info_widget.dart';

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
  final BaseCacheManager? cacheManager;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final source = manga.source?.let(Sources.fromName);
    final sourceIconUrl = source?.iconUrl;
    final title = manga.title;
    // Issue #206: the source moved away from the host this manga was saved
    // on — mark the tile (the manga is frozen; new-domain results never
    // attach to it). Resolved through the Sources facade like the icon, so
    // the badge follows a saved script edit at once.
    final movedHost = source?.movedHostOf(manga.webUrl);

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
                  child: CachedNetworkImage(
                    cacheManager: cacheManager,
                    fit: BoxFit.fill,
                    memCacheWidth: 300,
                    memCacheHeight: 420,
                    imageUrl: manga.coverUrl.or(
                      'https://placehold.co/400?text=Cover+Url',
                    ),
                    errorWidget: (context, url, error) {
                      return ImageInfoWidget.error(
                        url: url,
                        error: error,
                      );
                    },
                    progressIndicatorBuilder: (context, url, progress) {
                      return ImageInfoWidget.loading(
                        url: url,
                        progress: progress.progress,
                      );
                    },
                  ),
                ),
              ),
              if (isOnLibrary) ...[
                Positioned.fill(
                  child: Container(color: Colors.black.withValues(alpha: 0.5)),
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
              // Issue #206: sits below the In-Library chip (top: 4) so the
              // two never overlap, and away from the source icon (top-right).
              if (movedHost != null)
                Positioned(
                  top: 28,
                  left: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    child: Tooltip(
                      message: 'Source moved',
                      child: Icon(
                        Icons.link_off,
                        key: const Key('source-moved-badge'),
                        size: 14,
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ),
              if (title != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: double.infinity,
                    color: theme.scaffoldBackgroundColor.withValues(alpha: 0.7),
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      title,
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
                    color:
                        isOnLibrary
                            ? Colors.transparent
                            : Colors.black.withValues(alpha: 0.5),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: CachedNetworkImage(
                        cacheManager: cacheManager,
                        imageUrl: sourceIconUrl,
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
