import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'enum/manga_chapter_display_enum.dart';
import 'enum/manga_chapter_sort_option_enum.dart';
import 'enum/manga_chapter_sort_order_enum.dart';

class MangaChapterConfig extends Equatable {
  const MangaChapterConfig({
    this.downloaded,
    this.unread,
    this.bookmarked,
    this.display = MangaChapterDisplayEnum.title,
    this.sortOption = MangaChapterSortOptionEnum.chapterNumber,
    this.sortOrder = MangaChapterSortOrderEnum.asc,
  });

  final bool? downloaded;
  final bool? unread;
  final bool? bookmarked;
  final MangaChapterDisplayEnum display;
  final MangaChapterSortOptionEnum sortOption;
  final MangaChapterSortOrderEnum sortOrder;

  @override
  List<Object?> get props {
    return [
      downloaded,
      unread,
      bookmarked,
      display,
      sortOption,
      sortOrder,
    ];
  }

  MangaChapterConfig copyWith({
    ValueGetter<bool?>? downloaded,
    ValueGetter<bool?>? unread,
    ValueGetter<bool?>? bookmarked,
    MangaChapterDisplayEnum? display,
    MangaChapterSortOptionEnum? sortOption,
    MangaChapterSortOrderEnum? sortOrder,
  }) {
    return MangaChapterConfig(
      downloaded: downloaded != null ? downloaded() : this.downloaded,
      unread: unread != null ? unread() : this.unread,
      bookmarked: bookmarked != null ? bookmarked() : this.bookmarked,
      display: display ?? this.display,
      sortOption: sortOption ?? this.sortOption,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}