library log_box;

import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';

import 'src/common/log_storage.dart';
import 'src/model/log_html_model.dart';
import 'src/model/log_model.dart';
import 'src/screen/dashboard/dashboard_screen.dart';
import 'src/screen/webview/webview_screen.dart';

class LogBox {
  static final LogBox _instance = LogBox._();
  final LogStorage _storage = LogStorage();
  final navigatorObserver = NavigatorObserver();

  factory LogBox() => _instance;

  LogBox._();

  void logHtml(
    Uri uri,
    String html, {
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

  void navigateToLogBox({ThemeData? theme}) {
    navigatorObserver.navigator?.push(
      MaterialPageRoute<dynamic>(
        builder: (context) => Theme(
          data: theme ?? Theme.of(context),
          child: DashboardScreen(
            storage: _storage,
          ),
        ),
      ),
    );
  }

  void navigateToWebview({
    required Uri uri,
    required String html,
    ThemeData? theme,
    ValueSetter<String?>? onTapSnapshot,
  }) {
    navigatorObserver.navigator?.push(
      MaterialPageRoute<dynamic>(
        builder: (context) => Theme(
          data: theme ?? Theme.of(context),
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
