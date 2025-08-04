import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:flutter/widgets.dart';

class NetworkImageWidget extends StatelessWidget {
  const NetworkImageWidget({
    super.key,
    this.dio,
    required this.imageUrl,
    this.fit,
    this.headers,
    this.progressBuilder,
    this.errorBuilder,
    this.width,
    this.height,
  });

  final Dio? dio;

  final String imageUrl;

  final BoxFit? fit;

  final Map<String, String>? headers;

  final Widget Function(BuildContext, double?)? progressBuilder;

  final ImageErrorWidgetBuilder? errorBuilder;

  final double? width;

  final double? height;

  @override
  Widget build(BuildContext context) {
    final dio = this.dio;

    Widget view;

    if (dio == null) {
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
      view = Image(
        image: DioImage.string(imageUrl, dio: dio, headers: headers),
        fit: fit,
        loadingBuilder: (context, child, event) {
          final progress = event?.progress;
          print('Progress: $progress');
          if (progress == null) return child;
          return progressBuilder?.call(context, progress) ?? child;
        },
        errorBuilder: errorBuilder,
        width: width,
        height: height,
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
