import 'package:faro/faro.dart';

class LocalTransport extends FaroTransport {
  LocalTransport() : super(apiKey: '', collectorUrl: '');

  @override
  Future<void> send(Map<String, dynamic> payloadJson) async {
    // TODO: implement send

  }
}
