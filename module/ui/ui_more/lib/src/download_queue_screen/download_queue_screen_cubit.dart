import 'package:domain_manga/domain_manga.dart';
import 'package:rxdart/rxdart.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'download_queue_screen_state.dart';

class DownloadQueueScreenCubit extends Cubit<DownloadQueueScreenState>
    with AutoSubscriptionMixin {
  DownloadQueueScreenCubit({
    required DownloadChapterProgressStreamUseCase
        downloadChapterProgressStreamUseCase,
    required DownloadChapterProgressUseCase downloadChapterProgressUseCase,
    required DownloadChapterUseCase downloadChapterUseCase,
    DownloadQueueScreenState initialState = const DownloadQueueScreenState(),
  }) : super(initialState) {
    // TODO: update this
    // final List<CombineLatestStream> streams = [];
    // for (final entry in downloadChapterUseCase.progress.entries) {
    //   final key = Stream.value(entry.key);
    //   final value = entry.value.stream;
    //
    //   streams.add(
    //     CombineLatestStream.combine2(key, value, (a, b) => MapEntry(a, b)),
    //   );

      //   final progress = downloadChapterProgressUseCase.downloadChapterProgress(
      //     source: key.$1,
      //     mangaId: key.$2,
      //     chapterId: key.$3,
      //   );
      //
      //   if (progress != 0 && progress != 1) {
      //     final stream =
      //         downloadChapterProgressStreamUseCase.downloadChapterProgressStream(
      //       source: key.$1,
      //       mangaId: key.$2,
      //       chapterId: key.$3,
      //     );
      //     addSubscription(stream.listen((event) => _updateProgress(key, event)));
      //   }
    // }
  }

  void _updateProgress(DownloadChapterKey key, (int, double) value) {
    final progress = state.progress ?? {};
    emit(state.copyWith(progress: Map.of(progress)..[key] = value));
  }
}
