import 'package:flutter/material.dart';

import '../database/database.dart';
import '../screen/diagnostic_screen.dart';

extension NavigationExtension on AppDatabase {
  void diagnostic({required BuildContext context, ThemeData? theme}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: 'database/diagnostic'),
        builder: (context) {
          return Theme(
            data: theme ?? Theme.of(context),
            child: DiagnosticScreen(database: this),
          );
        },
      ),
    );
  }
}
