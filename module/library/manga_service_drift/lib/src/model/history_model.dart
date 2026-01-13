import 'package:equatable/equatable.dart';

import '../database/database.dart';

class HistoryModel extends Equatable {
  final MangaDrift? manga;
  final ChapterDrift? chapter;

  const HistoryModel({this.manga, this.chapter});

  @override
  List<Object?> get props => [manga, chapter];
}
