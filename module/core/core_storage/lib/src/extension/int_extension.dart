extension IntExtension on int {
  double get inKb => this / (1024);

  double get inMb => inKb / (1024);

  double get inGb => inMb / (1024);

  String get formattedSize {
    if (this < 1000) return '$this b';
    if (inKb < 1000) return '$inKb Kb';
    if (inMb < 1000) return '$inMb Mb';
    return '$inGb Gb';
  }
}
