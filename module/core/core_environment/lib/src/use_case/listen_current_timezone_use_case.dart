import 'package:rxdart/rxdart.dart';

abstract class ListenCurrentTimezoneUseCase {
  ValueStream<String> get timezoneDataStream;
}
