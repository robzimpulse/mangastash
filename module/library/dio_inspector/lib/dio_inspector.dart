library dio_inspector;

import 'package:flutter/material.dart';

import 'src/common/http_activity_storage.dart';
import 'src/common/inspector_interceptor.dart';
import 'src/screen/dashboard/dashboard_screen.dart';

class DioInspector {
  static final DioInspector _instance = DioInspector._internal();
  final HttpActivityStorage _storage = HttpActivityStorage();
  final navigatorObserver = NavigatorObserver();

  bool _isDebugMode;
  String? _password;

  factory DioInspector({
    required bool isDebugMode,
    String? password = '',
  }) {
    return _instance.._init(isDebugMode, password);
  }

  DioInspector._internal()
      : _isDebugMode = false,
        _password = '';

  void _init(
    bool isDebugMode,
    String? password,
  ) {
    _isDebugMode = isDebugMode;
    _password = password;
  }

  InspectorInterceptor getDioRequestInterceptor() {
    return InspectorInterceptor(
      kIsDebug: _isDebugMode,
      navigatorKey: navigatorObserver,
      storage: _storage,
    );
  }

  void navigateToInspector({ThemeData? theme}) {
    navigatorObserver.navigator?.push(
      MaterialPageRoute<dynamic>(
        builder: (context) => Theme(
          data: theme ?? Theme.of(context),
          child: DashboardScreen(
            password: _password ?? '',
            storage: _storage,
          ),
        ),
      ),
    );
  }
}
