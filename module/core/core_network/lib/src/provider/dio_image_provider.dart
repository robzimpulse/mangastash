import 'dart:async';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Fetches the given URL from the network, associating it with the given scale.
///
/// The image will be cached regardless of cache headers from the server.
///
/// See also:
///
///  * [Image.network].
///  * https://pub.dev/packages/http_image_provider
@immutable
class DioImageProvider extends ImageProvider<DioImageProvider> {
  /// Creates an object that fetches the image at the given URL.
  ///
  /// The arguments [url] and [scale] must not be null.
  /// [dio] will be the default [Dio] if not set.
  DioImageProvider.string(
    String url, {
    this.scale = 1.0,
    this.headers,
    required this.dio,
  }) : url = Uri.parse(url);

  /// Creates an object that fetches the image at the given URL.
  ///
  /// The arguments [url] and [scale] must not be null.
  /// [dio] will be the default [Dio] if not set.
  const DioImageProvider(
    this.url, {
    this.scale = 1.0,
    this.headers,
    required this.dio,
  });

  /// The URL from which the image will be fetched.
  final Uri url;

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  /// The HTTP headers that will be used with [HttpClient.get] to fetch image
  /// from network.
  ///
  /// When running flutter on the web, headers are not used.
  final Map<String, String>? headers;

  /// Dio client.
  final Dio dio;

  @override
  Future<DioImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<DioImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(
    DioImageProvider key,
    ImageDecoderCallback decode,
  ) {
    // Ownership of this controller is handed off to [_loadAsync]; it is that
    // method's responsibility to close the controller's stream when the image
    // has been loaded or an error is thrown.
    final chunkEvents = StreamController<ImageChunkEvent>();

    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, chunkEvents, decode),
      chunkEvents: chunkEvents.stream,
      scale: key.scale,
      debugLabel: key.url.toString(),
      informationCollector: () {
        return <DiagnosticsNode>[
          DiagnosticsProperty<ImageProvider>('Image provider', this),
          DiagnosticsProperty<DioImageProvider>('Image key', key),
        ];
      },
    );
  }

  Future<ui.Codec> _loadAsync(
    DioImageProvider key,
    StreamController<ImageChunkEvent> chunkEvents,
    ImageDecoderCallback decode,
  ) async {
    try {
      assert(key == this);

      chunkEvents.add(
        const ImageChunkEvent(
          cumulativeBytesLoaded: 0,
          expectedTotalBytes: null,
        ),
      );

      final response = await dio.getUri<dynamic>(
        url,
        options: Options(headers: headers, responseType: ResponseType.bytes),
        onReceiveProgress: (count, total) {
          chunkEvents.add(
            ImageChunkEvent(
              cumulativeBytesLoaded: count,
              expectedTotalBytes: total > 0 ? total : null,
            ),
          );
        },
      );

      if (response.statusCode != 200) {
        throw NetworkImageLoadException(
          uri: url,
          statusCode: response.statusCode!,
        );
      }

      final bytes = Uint8List.fromList(response.data as List<int>);

      if (bytes.lengthInBytes == 0) {
        throw NetworkImageLoadException(
          uri: url,
          statusCode: response.statusCode!,
        );
      }

      final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
      return decode(buffer);
    } catch (e) {
      // Depending on where the exception was thrown, the image cache may not
      // have had a chance to track the key in the cache at all.
      // Schedule a micro task to give the cache a chance to add the key.
      scheduleMicrotask(() {
        PaintingBinding.instance.imageCache.evict(key);
      });
      rethrow;
    } finally {
      unawaited(chunkEvents.close());
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is DioImageProvider &&
        other.url == url &&
        other.scale == scale;
  }

  @override
  int get hashCode => Object.hash(url, scale);

  @override
  String toString() =>
      '${objectRuntimeType(this, 'DioImage')}("$url", scale: $scale)';
}
