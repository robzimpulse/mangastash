import 'package:faro/faro.dart';
import 'package:universal_io/io.dart';

mixin FaroMixin {
  /// faro only support ios and android only
  Faro? get faro => Platform.isAndroid || Platform.isIOS ? Faro() : null;
}