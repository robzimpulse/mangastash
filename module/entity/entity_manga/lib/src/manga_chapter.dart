import 'package:core_environment/core_environment.dart';
import 'package:equatable/equatable.dart';
import 'package:manga_service_drift/manga_service_drift.dart';

import 'chapter.dart';
import 'manga.dart';

class MangaChapter extends Equatable {
  final Manga? manga;

  final Chapter? chapter;

  const MangaChapter({this.manga, this.chapter});

  @override
  List<Object?> get props => [manga, chapter];

  factory MangaChapter.fromDrift(HistoryModel model) {
    return MangaChapter(
      manga: model.manga?.let((e) => Manga.fromDrift(e)),
      chapter: model.chapter?.let((e) => Chapter.fromDrift(e)),
    );
  }
}
