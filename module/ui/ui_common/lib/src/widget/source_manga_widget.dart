import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class SourceMangaWidget extends StatelessWidget {
  const SourceMangaWidget({
    super.key,
    this.url = '',
    this.name = '',
    this.onTap,
    this.iconUrl = '',
    this.isLoading = false,
  });

  const SourceMangaWidget.shimmer({
    super.key,
  })  : isLoading = true,
        url = '',
        iconUrl = '',
        name = '',
        onTap = null;

  final String iconUrl;

  final String url;

  final String name;

  final GestureTapCallback? onTap;

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        height: double.infinity,
        child: CachedNetworkImage(
          imageUrl: iconUrl,
          width: 16,
          height: 16,
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
      ),
      title: Text(name),
      subtitle: Text(url),
      onTap: onTap,
      minLeadingWidth: 16,
    );
  }
}
