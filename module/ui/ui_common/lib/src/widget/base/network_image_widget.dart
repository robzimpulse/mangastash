import 'package:core_environment/core_environment.dart';
import 'package:core_storage/core_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class NetworkImageWidget extends StatelessWidget {
  const NetworkImageWidget({
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

  final CustomCacheManager? cacheManager;

  final String imageUrl;

  final BoxFit? fit;

  final Map<String, String>? headers;

  final Widget Function(BuildContext, double?)? progressBuilder;

  final ImageErrorWidgetBuilder? errorBuilder;

  final double? width;

  final double? height;

  Widget _buildFrom(
    BuildContext context, {
    FileResponse? response,
    Object? error,
  }) {
    const fallback = SizedBox.shrink();
    final data = response;

    if (error != null) {
      return errorBuilder?.call(context, error, null) ?? fallback;
    }

    if (data == null) {
      return progressBuilder?.call(context, null) ?? fallback;
    }

    if (data is FileInfo) {
      if (kIsWeb) {
        return FutureBuilder(
          future: data.file.readAsBytes(),
          builder: (context, snapshot) {
            final data = snapshot.data;
            final error = snapshot.error;

            if (error != null) {
              return errorBuilder?.call(context, error, null) ?? fallback;
            }

            if (data == null) {
              return progressBuilder?.call(context, null) ?? fallback;
            }

            return Image.memory(
              data,
              fit: fit,
              width: width,
              height: height,
              errorBuilder: errorBuilder,
            );
          },
        );
      }

      return Image.file(
        data.file,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: errorBuilder,
      );
    }

    if (data is DownloadProgress) {
      final progress = data.progress;
      return progressBuilder?.call(context, progress) ?? fallback;
    }

    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final cache = cacheManager;

    Widget view;
    if (cache == null) {
      view = Image.network(
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
      );
    } else {
      view = StreamBuilder(
        stream: cache.images.getFileStream(
          imageUrl,
          headers: headers,
          withProgress: true,
        ),
        builder: (context, snapshot) {
          return _buildFrom(
            context,
            response: snapshot.data,
            error: snapshot.error,
          );
        },
      );
    }

    return SizedBox(width: width, height: height, child: view);
  }
}

extension ProgressExtension on ImageChunkEvent {
  double? get progress {
    return expectedTotalBytes?.let((value) => value / cumulativeBytesLoaded);
  }
}
