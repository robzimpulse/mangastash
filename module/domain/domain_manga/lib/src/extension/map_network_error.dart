import 'package:core_network/core_network.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

Exception mapNetworkError(Object error) {
  return decodeMangadexEnvelope(error) ?? mapDioError(error);
}
