import 'dart:async';

import 'package:flutter/material.dart';

import 'completer_extension.dart';

extension ImageProviderExtension on ImageProvider {
  Future<ImageInfo> get imageInfo {
    final completer = Completer<ImageInfo>();
    final listener = ImageStreamListener(
      (info, _) => completer.safeComplete(info),
    );
    final stream = resolve(const ImageConfiguration())..addListener(listener);
    return completer.future.whenComplete(() => stream.removeListener(listener));
  }
}
