import 'package:core_analytics/core_analytics.dart';
import 'package:dio/dio.dart';
import 'package:universal_io/io.dart';

import '../mixin/user_agent_mixin.dart';

class UserAgentManager {
  UserAgentManager({required LogBox log}) : _log = log;

  final LogBox _log;

  /// Every attached Dio is re-stamped on publish — attaching a second Dio
  /// must not orphan the first (review on #183).
  final Set<Dio> _dios = {};

  bool _published = false;

  String _current = UserAgentMixin.staticUserAgent;

  String get current => _current;

  void attach(Dio dio) {
    _dios.add(dio);
    dio.options.headers[HttpHeaders.userAgentHeader] = _current;
  }

  void publish(String userAgent) {
    if (_published) {
      return;
    }

    if (userAgent.trim().isEmpty) {
      return;
    }

    _published = true;
    _current = userAgent;
    _log.log(
      'Publish user agent: $userAgent',
      name: 'UserAgentManager',
    );

    for (final dio in _dios) {
      dio.options.headers[HttpHeaders.userAgentHeader] = _current;
    }
  }
}
