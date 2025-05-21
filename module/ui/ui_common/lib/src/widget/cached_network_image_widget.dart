import 'package:core_environment/core_environment.dart';
import 'package:core_storage/core_storage.dart';
import 'package:flutter/widgets.dart';

class CachedNetworkImageWidget extends StatelessWidget {
  const CachedNetworkImageWidget({
    super.key,
    this.cacheManager,
    required this.imageUrl,
    this.fit,
    this.headers,
    this.progressBuilder,
    this.errorBuilder,
    this.width,
    this.height,
  });

  final BaseCacheManager? cacheManager;

  final String imageUrl;

  final BoxFit? fit;

  final Map<String, String>? headers;

  final Widget Function(
    BuildContext context,
    double progress,
  )? progressBuilder;

  final ImageErrorWidgetBuilder? errorBuilder;

  final double? width;

  final double? height;

  @override
  Widget build(BuildContext context) {
    final cache = cacheManager;
    return SizedBox(
      width: width,
      height: height,
      child: cache == null
          ? Image.network(
              imageUrl,
              fit: fit,
              headers: headers,
              loadingBuilder: (context, child, event) {
                final progress = event?.progress;
                if (progress == null) return child;
                return progressBuilder?.call(context, progress) ?? child;
              },
              errorBuilder: errorBuilder,
              width: width,
              height: height,
            )
          : StreamBuilder(
              stream: cache.getFileStream(
                imageUrl,
                headers: headers,
                withProgress: true,
              ),
              builder: (context, snapshot) {
                final data = snapshot.data;
                const fallback = SizedBox.shrink();

                if (data == null) {
                  return progressBuilder?.call(context, 0.0) ?? fallback;
                }

                if (data is FileInfo) {
                  return Image.file(
                    data.file,
                    fit: fit,
                    width: width,
                    height: height,
                    errorBuilder: errorBuilder,
                  );
                }

                if (data is DownloadProgress) {
                  final progress = data.progress ?? 0;
                  return progressBuilder?.call(context, progress) ?? fallback;
                }

                return fallback;
              },
            ),
    );
  }
}

extension ProgressExtension on ImageChunkEvent {
  double? get progress {
    return expectedTotalBytes?.let((value) => value / cumulativeBytesLoaded);
  }
}
