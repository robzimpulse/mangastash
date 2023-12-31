import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'manga_shelf_item_layout.dart';

class MangaShelfItem extends StatelessWidget {
  const MangaShelfItem({
    super.key,
    required this.title,
    required this.coverUrl,
    required this.layout,
    this.onTap,
  });

  final String title;

  final String coverUrl;

  final MangaShelfItemLayout layout;

  final VoidCallback? onTap;

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
        Visibility(
          visible: title.isNotEmpty == true,
          child: Container(
            width: double.infinity,
            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
            padding: const EdgeInsets.all(4.0),
            child: Text(
              title,
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _comfortableGrid(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: CachedNetworkImage(
            fit: BoxFit.fill,
            imageUrl: coverUrl,
            placeholder: (context, url) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
            errorWidget: (context, url, error) {
              return const Center(
                child: Icon(Icons.error),
              );
            },
          ),
        ),
        Visibility(
          visible: title.isNotEmpty == true,
          child: Container(
            width: double.infinity,
            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
            padding: const EdgeInsets.all(4.0),
            child: Text(
              title,
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
