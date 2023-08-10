import 'package:rxdart/rxdart.dart';

abstract class ListenLocaleUseCase {
  ValueStream<String> get localeDataStream;
}