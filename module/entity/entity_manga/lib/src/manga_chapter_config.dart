import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'enum/chapter_display_enum.dart';
import 'enum/chapter_sort_option_enum.dart';
import 'enum/chapter_sort_order_enum.dart';

class ChapterConfig extends Equatable {
  const ChapterConfig({
    this.downloaded,
    this.unread,
    this.bookmarked,
    this.display = ChapterDisplayEnum.title,
    this.sortOption = ChapterSortOptionEnum.chapterNumber,
    this.sortOrder = ChapterSortOrderEnum.asc,
  });

  final bool? downloaded;
  final bool? unread;
  final bool? bookmarked;
  final ChapterDisplayEnum display;
  final ChapterSortOptionEnum sortOption;
  final ChapterSortOrderEnum sortOrder;

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

  ChapterConfig copyWith({
    ValueGetter<bool?>? downloaded,
    ValueGetter<bool?>? unread,
    ValueGetter<bool?>? bookmarked,
    ChapterDisplayEnum? display,
    ChapterSortOptionEnum? sortOption,
    ChapterSortOrderEnum? sortOrder,
  }) {
    return ChapterConfig(
      downloaded: downloaded != null ? downloaded() : this.downloaded,
      unread: unread != null ? unread() : this.unread,
      bookmarked: bookmarked != null ? bookmarked() : this.bookmarked,
      display: display ?? this.display,
      sortOption: sortOption ?? this.sortOption,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}