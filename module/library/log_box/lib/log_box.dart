library log_box;

import 'dart:async';
import 'dart:developer' as dev;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'src/common/navigator_observer.dart' as alt;
import 'src/common/network_interceptor.dart';
import 'src/common/storage.dart';
import 'src/common/webview_delegate.dart';
import 'src/model/log_entry.dart';
import 'src/screen/dashboard/dashboard_screen.dart';
import 'src/screen/webview/webview_screen.dart';

export 'src/common/webview_delegate.dart';

class LogBox {
  static final LogBox _instance = LogBox._();
  final Storage _storage = Storage(capacity: 1000);

  String? _prevRouteName;
  NavigatorObserver get observer {
    return alt.NavigatorObserver(
      onEvent: (event) {
        _storage.add(
          log: event.copyWith(
            previousRoute: event.previousRoute ?? _prevRouteName,
          ),
        );
        if (event.route != null) _prevRouteName = event.route;
      },
    );
  }

  Interceptor get interceptor => NetworkInterceptor(storage: _storage);

  WebviewDelegate get webviewDelegate => WebviewDelegate(storage: _storage);

  factory LogBox() => _instance;

  LogBox._();

  void log(
    String message, {
    String? id,
    Map<String, dynamic>? extra,
    String? name,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _storage.add(
      log: LogEntry.create(
        id: id,
        name: name,
        message: message,
        extra: extra ?? {},
        error: error,
        stackTrace: stackTrace,
      ),
    );
    dev.log(message, name: name ?? 'Log Box');
  }

  void dashboard({required BuildContext context, ThemeData? theme}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: 'Log Box Dashboard'),
        builder: (context) {
          return Theme(
            data: theme ?? Theme.of(context),
            child: DashboardScreen(storage: _storage),
          );
        },
      ),
    );
  }

  Future<void> webview({
    required BuildContext context,
    required Uri uri,
    required String html,
    ThemeData? theme,
    Function(String? url, String? html)? onTapSnapshot,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: 'Log Box Webview'),
        builder: (context) {
          return Theme(
            data: theme ?? Theme.of(context),
            child: WebviewScreen(
              uri: uri,
              html: html,
              delegate: webviewDelegate,
              onTapSnapshot: onTapSnapshot,
            ),
          );
        },
      ),
    );
  }
}
