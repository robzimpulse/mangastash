import '../models/common/server_exception.dart';

class MangadexServerException implements Exception {
  final ServerException info;

  static const Map<String, dynamic> _defaultValue = {
    'result': 'error',
    'errors': [
      {'id': 'string', 'status': 0, 'title': 'string', 'detail': 'string'}
    ]
  };

  MangadexServerException([Map<String, dynamic> error = _defaultValue])
      : info = ServerException.fromJson(error);
}
