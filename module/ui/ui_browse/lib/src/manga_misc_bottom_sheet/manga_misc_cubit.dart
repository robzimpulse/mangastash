import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/foundation.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'manga_misc_state.dart';

class MangaMiscCubit extends Cubit<MangaMiscState> with AutoSubscriptionMixin {
  final UpdateMangaChapterConfig _updateMangaChapterConfig;

  MangaMiscCubit({
    MangaMiscState initialState = const MangaMiscState(),
    required ListenMangaChapterConfig listenMangaChapterConfig,
    required UpdateMangaChapterConfig updateMangaChapterConfig,
  })  : _updateMangaChapterConfig = updateMangaChapterConfig,
        super(initialState) {
    addSubscription(
      listenMangaChapterConfig.mangaChapterConfigStream.listen(_updateConfig),
    );
  }

  void _updateConfig(MangaChapterConfig config) {
    emit(state.copyWith(config: config));
  }

  void update({
    ValueGetter<bool?>? downloaded,
    ValueGetter<bool?>? unread,
    ValueGetter<bool?>? bookmarked,
    MangaChapterDisplayEnum? display,
    MangaChapterSortOptionEnum? sortOption,
    MangaChapterSortOrderEnum? sortOrder,
  }) {
    final config = state.config;
    if (config == null) return;
    _updateMangaChapterConfig.updateMangaChapterConfig(
      config: config.copyWith(
        downloaded: downloaded,
        unread: unread,
        bookmarked: bookmarked,
        display: display,
        sortOption: sortOption,
        sortOrder: sortOrder,
      ),
    );
  }
}
