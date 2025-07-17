library dio_inspector;

import 'package:flutter/material.dart';

import 'src/common/http_activity_storage.dart';
import 'src/common/inspector_interceptor.dart';
import 'src/screen/dashboard/dashboard_screen.dart';

class DioInspector {
  static final DioInspector _instance = DioInspector._();
  final HttpActivityStorage _storage = HttpActivityStorage();
  final navigatorObserver = NavigatorObserver();

  factory DioInspector() => _instance;

  DioInspector._();

  InspectorInterceptor getDioRequestInterceptor() {
    return InspectorInterceptor(storage: _storage);
  }

  void navigateToInspector({ThemeData? theme}) {
    navigatorObserver.navigator?.push(
      MaterialPageRoute<dynamic>(
        builder: (context) => Theme(
          data: theme ?? Theme.of(context),
          child: DashboardScreen(storage: _storage),
        ),
      ),
    );
  }
}
