import 'package:core_storage/core_storage.dart';
import 'package:flutter/material.dart';

import '../base/cached_network_image_widget.dart';
import 'manga_shelf_item_layout.dart';

class MangaShelfItem extends StatelessWidget {
  const MangaShelfItem({
    super.key,
    required this.title,
    required this.coverUrl,
    required this.layout,
    this.onTap,
    this.onLongPress,
    this.isOnLibrary = false,
    this.isPrefetching = false,
    this.cacheManager,
    this.sourceIconUrl,
    this.padding = const EdgeInsets.all(0),
  });

  final String title;

  final String coverUrl;

  final bool isOnLibrary;

  final bool isPrefetching;

  final MangaShelfItemLayout layout;

  final VoidCallback? onTap;

  final VoidCallback? onLongPress;

  final BaseCacheManager? cacheManager;

  final String? sourceIconUrl;

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: padding,
          child: _content(context),
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    switch (layout) {
      case MangaShelfItemLayout.comfortableGrid:
        return _comfortableGrid(context);
      case MangaShelfItemLayout.compactGrid:
        return _compactGrid(context);
      case MangaShelfItemLayout.list:
        return _list(context);
    }
  }

  Widget _list(BuildContext context) {
    return Row(
      children: [
        CachedNetworkImageWidget(
          fit: BoxFit.cover,
          cacheManager: cacheManager,
          imageUrl: coverUrl,
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
                imageUrl: sourceIconUrl ?? '',
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

  Widget _compactGrid(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall;
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: CachedNetworkImageWidget(
              cacheManager: cacheManager,
              fit: BoxFit.fill,
              imageUrl: coverUrl,
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
                style: style?.copyWith(color: Colors.black),
              ),
            ),
          ),
        ],
        if (sourceIconUrl != null) ...[
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
                child: CachedNetworkImageWidget(
                  cacheManager: cacheManager,
                  imageUrl: sourceIconUrl ?? '',
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
        ],
        if (title.isNotEmpty == true)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity,
              color: Theme.of(context)
                  .scaffoldBackgroundColor
                  .withValues(alpha: 0.7),
              padding: const EdgeInsets.all(4.0),
              child: Text(
                title,
                maxLines: 2,
                textAlign: TextAlign.center,
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
    );
  }

  Widget _comfortableGrid(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall;
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              CachedNetworkImageWidget(
                cacheManager: cacheManager,
                fit: BoxFit.fill,
                imageUrl: coverUrl,
                errorBuilder: (context, error, _) => const Center(
                  child: Icon(Icons.error),
                ),
                progressBuilder: (context, progress) => Center(
                  child: CircularProgressIndicator(value: progress),
                ),
              ),
              if (sourceIconUrl != null) ...[
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    color: Colors.black.withValues(alpha: 0.5),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: CachedNetworkImageWidget(
                        cacheManager: cacheManager,
                        imageUrl: sourceIconUrl ?? '',
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
              ],
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
                      style: style?.copyWith(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (title.isNotEmpty == true)
          Container(
            width: double.infinity,
            color: Theme.of(context)
                .scaffoldBackgroundColor
                .withValues(alpha: 0.7),
            padding: const EdgeInsets.all(4.0),
            child: Text(
              title,
              maxLines: 2,
              textAlign: TextAlign.center,
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
    );
  }
}
