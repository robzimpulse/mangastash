import 'package:drift/drift.dart';
import 'package:drift_db_viewer/drift_db_viewer.dart';
import 'package:flutter/material.dart';

class DatabaseViewer {
  static final DatabaseViewer _instance = DatabaseViewer._();
  final navigatorObserver = NavigatorObserver();

  factory DatabaseViewer() => _instance;

  DatabaseViewer._();

  void navigateToViewer({
    required GeneratedDatabase database,
    ThemeData? theme,
  }) {
    navigatorObserver.navigator?.push(
      MaterialPageRoute<dynamic>(
        builder: (context) => Theme(
          data: theme ?? Theme.of(context),
          child: DriftDbViewer(database),
        ),
      ),
    );
  }
}
