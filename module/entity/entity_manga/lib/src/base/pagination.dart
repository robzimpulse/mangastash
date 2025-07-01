import 'dart:convert';

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
  final int? page;
  final int? limit;
  final int? offset;
  final int? total;
  final bool? hasNextPage;
  final String? sourceUrl;

  const Pagination({
    this.data,
    this.page,
    this.limit,
    this.offset,
    this.total,
    this.hasNextPage,
    this.sourceUrl,
  });

  @override
  List<Object?> get props => [
        limit,
        page,
        offset,
        total,
        data,
        hasNextPage,
        sourceUrl,
      ];

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

  Pagination<T> copyWith({
    List<T>? data,
    int? page,
    int? limit,
    int? offset,
    int? total,
    bool? hasNextPage,
    String? sourceUrl,
  }) {
    return Pagination(
      data: data ?? this.data,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      total: total ?? this.total,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      sourceUrl: sourceUrl ?? this.sourceUrl,
    );
  }
}
