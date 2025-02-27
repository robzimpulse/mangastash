import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:log_box/log_box.dart';
import 'package:system_proxy/system_proxy.dart';

import '../use_case/get_proxy_use_case.dart';

class SystemProxyManager implements GetSystemProxyUseCase {
  @override
  String? host;

  @override
  String? port;

  SystemProxyManager({this.host, this.port});

  static Future<SystemProxyManager> create({required LogBox log}) async {
    String? host;
    String? port;

    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      final setting = await SystemProxy.getProxySettings();
      host = setting?['host'];
      port = setting?['port'];
    }

    if (kDebugMode && port != null && host != null) {
      HttpOverrides.global = _SystemProxyHttpOverrides(
        port: port,
        host: host,
        bypassSslValidation: true,
      );
      log.log(
        'Using proxy with host: $host:$port',
        name: 'SystemProxyManager',
      );
    }

    return SystemProxyManager(host: host, port: port);
  }
}

class _SystemProxyHttpOverrides extends HttpOverrides {
  String port;
  String host;
  bool? bypassSslValidation;

  _SystemProxyHttpOverrides({
    required this.port,
    required this.host,
    this.bypassSslValidation,
  });

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final httpClient = super.createHttpClient(context);
    final value = host.isNotEmpty ? "PROXY $host:$port;" : 'DIRECT';
    httpClient.findProxy = (uri) => value;
    if (bypassSslValidation == true) {
      httpClient.badCertificateCallback = (_, __, ___) => true;
    }
    return httpClient;
  }
}
