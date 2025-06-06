import 'package:equatable/equatable.dart';

import 'chapter.dart';
import 'manga.dart';

class History extends Equatable {

  final Manga? manga;

  final Chapter? chapter;

  const History({this.manga, this.chapter});

  @override
  List<Object?> get props => [manga, chapter];

}