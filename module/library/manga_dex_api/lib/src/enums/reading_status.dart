enum ReadingStatus {
  reading('reading'),
  onHold('on_hold'),
  planToRead('plan_to_read'),
  dropped('dropped'),
  reReading('re_reading'),
  completed('completed');

  final String rawValue;

  const ReadingStatus(this.rawValue);

  factory ReadingStatus.fromRawValue(String rawValue) {
    return ReadingStatus.values.firstWhere(
      (e) => e.rawValue == rawValue,
      orElse: () => ReadingStatus.reading,
    );
  }
}
