import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

enum MangaMiscDisplayEnum {
  title('Source Title'),
  chapter('Chapter Number');

  final String value;

  const MangaMiscDisplayEnum(this.value);
}

enum MangaMiscSortOptionEnum {
  chapterNumber('By Chapter Number'),
  uploadDate('By Upload Date');

  final String value;

  const MangaMiscSortOptionEnum(this.value);
}

enum MangaMiscSortOrderEnum {
  asc, desc;
}

class MangaMiscState extends Equatable {
  const MangaMiscState({
    this.downloaded,
    this.unread,
    this.bookmarked,
    this.display = MangaMiscDisplayEnum.title,
    this.sortOption = MangaMiscSortOptionEnum.chapterNumber,
    this.sortOrder = MangaMiscSortOrderEnum.asc
  });

  final bool? downloaded;
  final bool? unread;
  final bool? bookmarked;
  final MangaMiscDisplayEnum display;
  final MangaMiscSortOptionEnum sortOption;
  final MangaMiscSortOrderEnum sortOrder;

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

  MangaMiscState copyWith({
    ValueGetter<bool?>? downloaded,
    ValueGetter<bool?>? unread,
    ValueGetter<bool?>? bookmarked,
    MangaMiscDisplayEnum? display,
    MangaMiscSortOptionEnum? sortOption,
    MangaMiscSortOrderEnum? sortOrder,
  }) {
    return MangaMiscState(
      downloaded: downloaded != null ? downloaded() : this.downloaded,
      unread: unread != null ? unread() : this.unread,
      bookmarked: bookmarked != null ? bookmarked() : this.bookmarked,
      display: display ?? this.display,
      sortOption: sortOption ?? this.sortOption,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
