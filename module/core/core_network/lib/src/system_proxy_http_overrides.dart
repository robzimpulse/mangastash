import 'dart:io';

class SystemProxyHttpOverrides extends HttpOverrides {
  String port;
  String host;
  bool? bypassSslValidation;

  SystemProxyHttpOverrides({
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