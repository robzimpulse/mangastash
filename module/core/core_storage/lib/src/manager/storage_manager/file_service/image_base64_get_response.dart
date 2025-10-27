import 'dart:convert';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ImageBase64GetResponse implements FileServiceResponse {

  final String _imageBase64;

  ImageBase64GetResponse(this._imageBase64);

  @override
  Stream<List<int>> get content {
    final values = _imageBase64.split(RegExp(r'[:;,]+'));
    final data = values.lastOrNull;
    if (data == null) return Stream.value([]);
    return Stream.value(base64.decode(data));
  }

  @override
  int? get contentLength => _imageBase64.length;

  @override
  String? get eTag => null;

  @override
  String get fileExtension {
    final values = _imageBase64.split(RegExp(r'[:;,]+'));
    final value = values.firstOrNull?.split('/').lastOrNull;
    return value ?? 'jpeg';
  }

  @override
  int get statusCode => 200;

  @override
  DateTime get validTill => DateTime.now().add(const Duration(days: 7));
 }