import 'package:equatable/equatable.dart';

import '../database/database.dart';

class ChapterModel extends Equatable{
  final ChapterDrift? chapter;
  final List<ImageDrift> images;

  const ChapterModel({
    this.chapter,
    this.images = const [],
  });

  @override
  List<Object?> get props => [chapter, images];
}