import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';

import '../../manga_service_drift.dart';
import '../extension/value_or_null_extension.dart';

class MangaChapterImageDrift extends Equatable {
  final String? createdAt;
  final String? updatedAt;
  final String? id;
  final String? chapterId;
  final String? webUrl;
  final int? order;

  const MangaChapterImageDrift({
    this.id,
    this.webUrl,
    this.chapterId,
    this.createdAt,
    this.updatedAt,
    this.order,
  });

  @override
  List<Object?> get props => [
        id,
        webUrl,
        chapterId,
        createdAt,
        updatedAt,
        order,
      ];

  factory MangaChapterImageDrift.fromCompanion(
    MangaChapterImageTablesCompanion image,
  ) {
    return MangaChapterImageDrift(
      id: image.id.valueOrNull,
      webUrl: image.webUrl.valueOrNull,
      chapterId: image.chapterId.valueOrNull,
      createdAt: image.createdAt.valueOrNull,
      updatedAt: image.updatedAt.valueOrNull,
      order: image.order.valueOrNull,
    );
  }

  MangaChapterImageTablesCompanion toCompanion() {
    return MangaChapterImageTablesCompanion(
      createdAt: Value.absentIfNull(createdAt),
      updatedAt: Value.absentIfNull(updatedAt),
      id: Value.absentIfNull(id),
      webUrl: Value.absentIfNull(webUrl),
      chapterId: Value.absentIfNull(chapterId),
    );
  }
}
