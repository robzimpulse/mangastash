import 'dart:io';

import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

Future<void> sqlWorkaround() async {
  if (Platform.isAndroid) {
    await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
  }
}