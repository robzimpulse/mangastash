import 'package:json_annotation/json_annotation.dart';

part 'pagination.g.dart';

@JsonSerializable()
class Pagination {
  final int? limit;
  final int? offset;
  final int? total;
  Pagination(
    this.limit,
    this.offset,
    this.total,
  );
  factory Pagination.fromJson(Map<String, dynamic> json) {
    return _$PaginationFromJson(json);
  }
  Map<String, dynamic> toJson() => _$PaginationToJson(this);
}
