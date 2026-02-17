import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'enum/chapter_display_enum.dart';
import 'enum/chapter_sort_option_enum.dart';
import 'enum/chapter_sort_order_enum.dart';

class ChapterConfig extends Equatable {
  const ChapterConfig({
    this.downloaded = false,
    this.unread = false,
    this.display = ChapterDisplayEnum.title,
    this.sortOption = ChapterSortOptionEnum.chapterNumber,
    this.sortOrder = ChapterSortOrderEnum.desc,
  });

  final bool? downloaded;
  final bool? unread;
  final ChapterDisplayEnum display;
  final ChapterSortOptionEnum sortOption;
  final ChapterSortOrderEnum sortOrder;

  @override
  List<Object?> get props {
    return [downloaded, unread, display, sortOption, sortOrder];
  }

  ChapterConfig copyWith({
    ValueGetter<bool?>? downloaded,
    ValueGetter<bool?>? unread,
    ChapterDisplayEnum? display,
    ChapterSortOptionEnum? sortOption,
    ChapterSortOrderEnum? sortOrder,
  }) {
    return ChapterConfig(
      downloaded: downloaded != null ? downloaded() : this.downloaded,
      unread: unread != null ? unread() : this.unread,
      display: display ?? this.display,
      sortOption: sortOption ?? this.sortOption,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
