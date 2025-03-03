import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'search_parameter.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class SearchParameter extends Equatable {
  final String? title;
  final num? limit;
  final String? offset;
  final String? page;

  const SearchParameter({
    this.title,
    this.limit,
    this.offset,
    this.page,
  });

  @override
  List<Object?> get props {
    return [
      title,
      limit,
      offset,
      page,
    ];
  }

  factory SearchParameter.fromJson(Map<String, dynamic> json) {
    return _$SearchParameterFromJson(json);
  }

  Map<String, dynamic> toJson() => _$SearchParameterToJson(this);

  SearchParameter copyWith({
    String? title,
    num? limit,
    String? offset,
    String? page,
  }) {
    return SearchParameter(
      title: title ?? this.title,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      page: page ?? this.page,
    );
  }
}
