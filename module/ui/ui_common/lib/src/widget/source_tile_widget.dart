import 'package:core_storage/core_storage.dart';
import 'package:flutter/material.dart';

import 'base/cached_network_image_widget.dart';
import 'base/shimmer_loading_widget.dart';

class SourceTileWidget extends StatelessWidget {
  const SourceTileWidget({
    super.key,
    this.url,
    this.name,
    this.onTap,
    this.iconUrl,
    this.isLoading = false,
    this.cacheManager,
  });

  final String? iconUrl;

  final String? url;

  final String? name;

  final GestureTapCallback? onTap;

  final bool isLoading;

  final CustomCacheManager? cacheManager;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        height: double.infinity,
        child: ShimmerLoading.circular(
          isLoading: isLoading,
          size: 16,
          child: CachedNetworkImageWidget(
            cacheManager: cacheManager,
            imageUrl: iconUrl ?? '',
            width: 16,
            height: 16,
            errorBuilder: (context, error, _) => const Icon(Icons.error),
            progressBuilder: (context, progress) => Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  value: progress,
                ),
              ),
            ),
          ),
        ),
      ),
      title: Align(
        alignment: Alignment.centerLeft,
        child: ShimmerLoading.multiline(
          isLoading: isLoading,
          width: 100,
          height: 12,
          lines: 1,
          child: Text(name ?? ''),
        ),
      ),
      subtitle: Align(
        alignment: Alignment.centerLeft,
        child: ShimmerLoading.multiline(
          isLoading: isLoading,
          width: 200,
          height: 10,
          lines: 1,
          child: Text(url ?? ''),
        ),
      ),
      onTap: onTap,
      minLeadingWidth: 16,
    );
  }
}
