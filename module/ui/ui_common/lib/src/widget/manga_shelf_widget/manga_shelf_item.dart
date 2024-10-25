import 'package:cached_network_image/cached_network_image.dart';
import 'package:core_storage/core_storage.dart';
import 'package:flutter/material.dart';

import 'manga_shelf_item_layout.dart';

class MangaShelfItem extends StatelessWidget {
  const MangaShelfItem({
    super.key,
    required this.title,
    required this.coverUrl,
    required this.layout,
    this.onTap,
    this.isOnLibrary = false,
    this.cacheManager,
  });

  final String title;

  final String coverUrl;

  final bool isOnLibrary;

  final MangaShelfItemLayout layout;

  final VoidCallback? onTap;

  final BaseCacheManager? cacheManager;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: _content(context),
      onTap: () => onTap?.call(),
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
        CachedNetworkImage(
          cacheManager: cacheManager,
          imageUrl: coverUrl,
          width: 50,
          height: 50,
          errorWidget: (context, url, error) => const Icon(Icons.error),
          progressIndicatorBuilder: (context, url, downloadProgress) {
            return Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  value: downloadProgress.progress,
                ),
              ),
            );
          },
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(title),
          ),
        ),
        if (isOnLibrary) const Icon(Icons.bookmark),
      ],
    );
  }

  Widget _compactGrid(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: CachedNetworkImage(
              cacheManager: cacheManager,
              fit: BoxFit.fill,
              imageUrl: coverUrl,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => const Center(
                child: Icon(Icons.error),
              ),
            ),
          ),
        ),
        if (title.isNotEmpty == true)
          Container(
            width: double.infinity,
            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
            padding: const EdgeInsets.all(4.0),
            child: Text(
              title,
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        if (isOnLibrary) ...[
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
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
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _comfortableGrid(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              CachedNetworkImage(
                cacheManager: cacheManager,
                fit: BoxFit.fill,
                imageUrl: coverUrl,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(Icons.error),
                ),
              ),
              if (isOnLibrary) ...[
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
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
                      style: Theme.of(context).textTheme.labelSmall,
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
            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
            padding: const EdgeInsets.all(4.0),
            child: Text(
              title,
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}
