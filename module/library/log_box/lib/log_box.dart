library log_box;

import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';

import 'src/common/navigator_observer.dart' as alt;
import 'src/common/storage.dart';
import 'src/model/log_entry.dart';
import 'src/screen/dashboard/dashboard_screen.dart';
import 'src/screen/webview/webview_screen.dart';

export 'src/use_case/measure_process_use_case.dart';

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
    // _storage.addLog(
    //   log: LogHtmlModel(
    //     uri: uri,
    //     html: html,
    //     scripts: scripts,
    //     time: time ?? DateTime.now(),
    //     sequenceNumber: sequenceNumber,
    //     level: level,
    //     name: name,
    //     zone: zone,
    //     error: error,
    //     stackTrace: stackTrace,
    //   ),
    // );
  }

  void log(
    String message, {
    String? id,
    Map<String, dynamic>? extra,
    String? name,
    Object? error,
  }) {
    _storage.add(
      log: LogEntry.create(
        id: id,
        message: [
          if (name != null && name.isNotEmpty) '[$name]',
          message,
        ].join(' '),
        extra: extra ?? {},
        error: error,
      ),
    );
    dev.log(message, name: name ?? 'Log Box');
  }

  void navigateToLogBox({
    required BuildContext context,
    ThemeData? theme,
    Function(String? url, String? html)? onTapSnapshot,
  }) {
    Navigator.of(context).push(
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

  Future<void> navigateToWebview({
    required BuildContext context,
    required Uri uri,
    required String html,
    ThemeData? theme,
    Function(String? url, String? html)? onTapSnapshot,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: 'Log Box Webview'),
        builder: (context) {
          return Theme(
            data: theme ?? Theme.of(context),
            child: WebviewScreen(
              uri: uri,
              html: html,
              onTapSnapshot: onTapSnapshot,
            ),
          );
        },
      ),
    );
  }
}
