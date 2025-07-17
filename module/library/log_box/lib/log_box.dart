library log_box;

import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart' as material;

import 'src/common/navigator_observer.dart';
import 'src/common/storage.dart';
import 'src/model/log_html_model.dart';
import 'src/model/log_model.dart';
import 'src/screen/dashboard/dashboard_screen.dart';
import 'src/screen/webview/webview_screen.dart';

export 'src/use_case/measure_process_use_case.dart';

class LogBox {
  static final LogBox _instance = LogBox._();
  final Storage _storage = Storage(capacity: 200);
  final navigatorObserver = NavigatorObserver();

  factory LogBox() => _instance;

  LogBox._();

  void logHtml(
    Uri uri,
    String html, {
    List<String> scripts = const [],
    DateTime? time,
    int? sequenceNumber,
    int level = 0,
    String name = '',
    Zone? zone,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _storage.addLog(
      log: LogHtmlModel(
        uri: uri,
        html: html,
        scripts: scripts,
        time: time ?? DateTime.now(),
        sequenceNumber: sequenceNumber,
        level: level,
        name: name,
        zone: zone,
        error: error,
        stackTrace: stackTrace,
      ),
    );
  }

  void log(
    String message, {
    Map<String, dynamic>? extra,
    DateTime? time,
    int? sequenceNumber,
    int level = 0,
    String name = '',
    Zone? zone,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _storage.addLog(
      log: LogModel(
        message: message,
        time: time ?? DateTime.now(),
        extra: extra,
        sequenceNumber: sequenceNumber,
        level: level,
        name: name,
        zone: zone,
        error: error,
        stackTrace: stackTrace,
      ),
    );
    dev.log(
      message,
      time: time ?? DateTime.now(),
      sequenceNumber: sequenceNumber,
      level: level,
      name: name,
      zone: zone,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void navigateToLogBox({
    material.ThemeData? theme,
    Function(String? url, String? html)? onTapSnapshot,
  }) {
    navigatorObserver.navigator?.push(
      material.MaterialPageRoute(
        builder:
            (context) => material.Theme(
              data: theme ?? material.Theme.of(context),
              child: DashboardScreen(storage: _storage),
            ),
      ),
    );
  }

  Future<void> navigateToWebview({
    required Uri uri,
    required String html,
    material.ThemeData? theme,
    Function(String? url, String? html)? onTapSnapshot,
  }) async {
    await navigatorObserver.navigator?.push(
      material.MaterialPageRoute(
        builder:
            (context) => material.Theme(
              data: theme ?? material.Theme.of(context),
              child: WebviewScreen(
                uri: uri,
                html: html,
                onTapSnapshot: onTapSnapshot,
              ),
            ),
      ),
    );
  }
}
