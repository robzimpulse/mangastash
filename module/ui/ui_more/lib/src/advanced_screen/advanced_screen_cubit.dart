import 'package:core_storage/core_storage.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'advanced_screen_state.dart';

class AdvancedScreenCubit extends Cubit<AdvancedScreenState>
    with AutoSubscriptionMixin {
  final MangaDao _mangaDao;
  final ChapterDao _chapterDao;
  final TagDao _tagDao;

  AdvancedScreenCubit({
    AdvancedScreenState initialState = const AdvancedScreenState(),
    required DiagnosticDao diagnosticDao,
    required MangaDao mangaDao,
    required ChapterDao chapterDao,
    required TagDao tagDao,
  }) : _mangaDao = mangaDao,
       _chapterDao = chapterDao,
       _tagDao = tagDao,
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

  void showDuplicateManga(bool isExpanded) {
    emit(state.copyWith(isDuplicatedMangaExpanded: isExpanded));
  }

  void showDuplicateChapter(bool isExpanded) {
    emit(state.copyWith(isDuplicatedChapterExpanded: isExpanded));
  }

  void showDuplicateTag(bool isExpanded) {
    emit(state.copyWith(isDuplicatedTagExpanded: isExpanded));
  }

  void showOrphanedChapter(bool isExpanded) {
    emit(state.copyWith(isOrphanedExpanded: isExpanded));
  }

  Future<void> deleteMangas(List<MangaDrift> mangas) async {
    await _mangaDao.remove(ids: [...mangas.map((e) => e.id)]);
  }

  Future<void> deleteChapters(List<ChapterDrift> chapters) async {
    await _chapterDao.remove(ids: [...chapters.map((e) => e.id)]);
  }

  Future<void> deleteTags(List<TagDrift> tags) async {
    await _tagDao.remove(ids: [...tags.map((e) => e.id)]);
  }
}
