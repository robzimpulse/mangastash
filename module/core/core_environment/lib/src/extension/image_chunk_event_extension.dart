import 'package:flutter/material.dart';

import '../../core_environment.dart';

extension ProgressImageChunkEventExtension on ImageChunkEvent {
  /// download progress as an double between 0 and 1.
  /// When the final size is unknown or the downloaded size exceeds the total
  /// size [progress] is null.
  double? get progress {
    return expectedTotalBytes?.let(
      (e) => e > 0 ? cumulativeBytesLoaded / e : 0,
    );
  }
}
