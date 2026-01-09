import 'package:rxdart/rxdart.dart';

abstract class ListenPrefetchChapterConfig {
  ValueStream<int> get numOfPrefetchedPrevChapter;

  ValueStream<int> get numOfPrefetchedNextChapter;

  void updateNumOfPrefetchedPrevChapter({required int value});

  void updateNumOfPrefetchedNextChapter({required int value});
}
