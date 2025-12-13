import 'package:flutter/foundation.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

Future<void> sqlWorkaround() async {
  if (defaultTargetPlatform == TargetPlatform.android) {
    await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
  }
}