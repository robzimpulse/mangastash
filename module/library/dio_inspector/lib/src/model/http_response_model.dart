import 'package:equatable/equatable.dart';

class HttpResponseModel extends Equatable {
  factory HttpResponseModel.create({
    int? status,
    int size = 0,
    String? body,
    Map<String, List<String>>? headers,
  }) {
    return HttpResponseModel._(
      status: status,
      size: size,
      time: DateTime.now(),
      body: body,
      headers: headers,
    );
  }

  const HttpResponseModel._({
    this.status,
    required this.size,
    required this.time,
    this.body,
    this.headers,
  });

  final int? status;
  final int size;
  final DateTime time;
  final String? body;
  final Map<String, List<String>>? headers;

  @override
  List<Object?> get props => [
        status,
        size,
        time,
        body,
        headers,
      ];
}
