import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:system_proxy/system_proxy.dart';

import '../system_proxy_http_overrides.dart';
import '../use_case/get_proxy_use_case.dart';

class SystemProxyManager implements GetSystemProxyUseCase {
  @override
  String? host;

  @override
  String? port;

  SystemProxyManager({this.host, this.port});

  static Future<SystemProxyManager> init() async {
    String? host;
    String? port;

    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      final setting = await SystemProxy.getProxySettings();
      host = setting?['host'];
      port = setting?['port'];
    }

    if (kDebugMode && port != null && host != null) {
      HttpOverrides.global = SystemProxyHttpOverrides(port: port, host: host);
      log('Using proxy with host: $host:$port', name: 'Core Network');
    }

    return SystemProxyManager(host: host, port: port);
  }
}
