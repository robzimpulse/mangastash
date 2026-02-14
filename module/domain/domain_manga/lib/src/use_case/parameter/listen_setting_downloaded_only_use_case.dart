import 'package:rxdart/rxdart.dart';

abstract class ListenSettingDownloadedOnlyUseCase {
  ValueStream<bool> get downloadedOnlyState;
}
