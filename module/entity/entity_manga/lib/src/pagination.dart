import 'package:equatable/equatable.dart';

class Pagination<T> extends Equatable {
  final List<T>? data;
  final String? page;
  final int? limit;
  final String? offset;
  final int? total;

  const Pagination({this.data, this.page, this.limit, this.offset, this.total});

  @override
  List<Object?> get props => [limit, page, offset, total, data];
}
