import 'dart:async';

import '../database/database.dart';

typedef LoggerCallback =
    void Function(
      String message, {
      Map<String, dynamic>? extra,
      DateTime? time,
      int? sequenceNumber,
      int? level,
      String? name,
      Zone? zone,
      Object? error,
      StackTrace? stackTrace,
    });

typedef DuplicatedMangaResult = Map<(String?, String?), List<MangaDrift>>;
typedef DuplicatedChapterResult = Map<(String?, String?), List<ChapterDrift>>;
typedef DuplicatedTagResult = Map<(String?, String?), List<TagDrift>>;
