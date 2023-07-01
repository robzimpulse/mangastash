import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';

HttpClientAdapter getAdapter() {
  final adapter = DefaultHttpClientAdapter();

  const charlesIp = String.fromEnvironment('PROXY_IP', defaultValue: "");

  if (charlesIp.isEmpty) return adapter;

  adapter.onHttpClientCreate = (client) {
    client.findProxy = (uri) => "PROXY $charlesIp:8888;";
    client.badCertificateCallback = (cert, host, port) => true;
    return client;
  };

  return adapter;
}