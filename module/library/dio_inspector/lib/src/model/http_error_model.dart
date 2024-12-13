import 'package:equatable/equatable.dart';

class HttpErrorModel extends Equatable {
  final dynamic error;
  final StackTrace? stackTrace;

  const HttpErrorModel({this.error, this.stackTrace});

  @override
  List<Object?> get props => [error, stackTrace];
}