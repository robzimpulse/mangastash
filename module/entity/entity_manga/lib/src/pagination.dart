import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pagination.g.dart';

@JsonSerializable(
  fieldRename: FieldRename.snake,
  explicitToJson: true,
  genericArgumentFactories: true,
)
class Pagination<T extends Equatable> extends Equatable {
  final List<T>? data;
  final String? page;
  final int? limit;
  final String? offset;
  final int? total;

  const Pagination({this.data, this.page, this.limit, this.offset, this.total});

  @override
  List<Object?> get props => [limit, page, offset, total, data];

  factory Pagination.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return _$PaginationFromJson(json, fromJsonT);
  }

  Map<String, dynamic> toJson(
    Object? Function(T value) toJsonT,
  ) =>
      _$PaginationToJson(this, toJsonT);
}
