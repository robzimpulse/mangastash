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

  final ImageLoadingBuilder? progressBuilder;

  final ImageErrorWidgetBuilder? errorBuilder;

  final double? width;

  final double? height;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      fit: fit,
      headers: headers,
      loadingBuilder: progressBuilder,
      errorBuilder: errorBuilder,
      width: width,
      height: height,
    );
  }
}

extension ProgressExtension on ImageChunkEvent {
  double? get progress {
    return expectedTotalBytes?.let((value) => value / cumulativeBytesLoaded);
  }
}
