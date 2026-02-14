import 'package:rxdart/rxdart.dart';

abstract class ListenSettingIncognitoUseCase {
  ValueStream<bool> get incognitoState;
}
