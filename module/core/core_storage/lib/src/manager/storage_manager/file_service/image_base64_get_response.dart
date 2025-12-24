import 'dart:convert';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_cache_manager/src/web/mime_converter.dart';

class ImageBase64GetResponse implements FileServiceResponse {
  @override
  late final Stream<List<int>> content;

  @override
  late final String fileExtension;

  @override
  late final int? contentLength;

  @override
  late final String? eTag;

  @override
  late final int statusCode;

  @override
  late final DateTime validTill;

  ImageBase64GetResponse({required String imageBase64}) {
    final values = imageBase64.split(RegExp(r'[:;,]+'));
    final ext = values[1].split('/').lastOrNull;
    final data = values.lastOrNull;

    if (data == null) {
      throw ArgumentError('Null Base64 Data');
    }

    if (ext == null) {
      throw ArgumentError('Null Base64 Extension');
    }

    final imageByte = base64.decode(data);

    if (imageBase64.isEmpty) {
      throw ArgumentError('Empty Base64 Data');
    }

    final mime = mimeTypes.values.where((e) => e.contains(ext)).firstOrNull;

    if (mime == null) {
      throw ArgumentError('Unsupported Base64 Extension [$ext]');
    }

    content = Stream.value(imageByte);
    fileExtension = mime;
    contentLength = imageByte.length;
    eTag = null;
    statusCode = 200;
    validTill = DateTime.now().add(const Duration(days: 7));
  }
}
