import 'package:equatable/equatable.dart';

import '../entity_manga.dart';

class DownloadChapter extends Equatable{

  final Manga? manga;

  final MangaChapter? chapter;

  const DownloadChapter({this.manga, this.chapter});

  @override
  List<Object?> get props => [manga, chapter];

}