import 'dart:ui';

extension ImageRatioExtension on Image {
  double get ratio => height / width;
}
