import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../common/data.dart';

part 'search.g.dart';

///@nodoc
@JsonSerializable()
class Search extends Equatable {
  final String? result;
  final String? response;
  final List<Data>? data;
  final int? limit;
  final int? offset;
  final int? total;

  const Search(
    this.data,
    this.limit,
    this.offset,
    this.total,
    this.result,
    this.response,
  );

  factory Search.fromJson(Map<String, dynamic> json) => _$SearchFromJson(json);

  Map<String, dynamic> toJson() => _$SearchToJson(this);

  @override
  List<Object?> get props {
    return [data, limit, offset, total, result, response];
  }
}
