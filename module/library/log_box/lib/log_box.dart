library log_box;

import 'dart:async';

import 'package:flutter/material.dart';

import 'src/common/log_storage.dart';
import 'src/model/log_model.dart';

class LogBox {
  static final LogBox _instance = LogBox._internal();
  final LogStorage _storage = LogStorage();

  String? _password;

  factory LogBox({String? password = ''}) {
    return _instance.._init(password);
  }

  LogBox._internal() : _password = '';

  void _init(String? password) {
    _password = password;
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
  }

  void navigateToLogBox({ThemeData? theme}) {
    // navigatorObserver.navigator?.push(
    //   MaterialPageRoute<dynamic>(
    //     builder: (context) => Theme(
    //       data: theme ?? Theme.of(context),
    //       child: DashboardScreen(
    //         password: _password ?? '',
    //         storage: _storage,
    //       ),
    //     ),
    //   ),
    // );
  }
}
