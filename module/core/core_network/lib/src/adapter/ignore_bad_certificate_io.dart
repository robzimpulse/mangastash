import 'package:flutter/foundation.dart';
import 'package:universal_io/universal_io.dart';

import 'bad_certificate_http_overrides.dart';

void ignoreBadCertificate() {
  if (kDebugMode) {
    HttpOverrides.global = BadCertificateHttpOverrides();
  }
}