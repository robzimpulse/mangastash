import 'package:core_storage/core_storage.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'advanced_screen_state.dart';

class AdvancedScreenCubit extends Cubit<AdvancedScreenState>
    with AutoSubscriptionMixin {
  final MangaDao _mangaDao;
  final ChapterDao _chapterDao;

  AdvancedScreenCubit({
    AdvancedScreenState initialState = const AdvancedScreenState(),
    required DiagnosticDao diagnosticDao,
    required MangaDao mangaDao,
    required ChapterDao chapterDao,
  }) : _mangaDao = mangaDao,
       _chapterDao = chapterDao,
       super(initialState) {
    addSubscription(
      diagnosticDao.duplicateManga.listen(
        (e) => emit(state.copyWith(duplicatedManga: e)),
      ),
    );
    addSubscription(
      diagnosticDao.duplicateTag.listen(
        (e) => emit(state.copyWith(duplicatedTag: e)),
      ),
    );
    addSubscription(
      diagnosticDao.duplicateChapter.listen(
        (e) => emit(state.copyWith(duplicatedChapter: e)),
      ),
    );
    addSubscription(
      diagnosticDao.orphanChapter.listen(
        (e) => emit(state.copyWith(orphanedChapter: e)),
      ),
    );
  }

}
