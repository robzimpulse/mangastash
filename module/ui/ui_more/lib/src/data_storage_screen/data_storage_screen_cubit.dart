import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:ui_common/ui_common.dart' hide Error;
import 'package:universal_io/universal_io.dart';

import 'data_storage_screen_state.dart';

class DataStorageScreenCubit extends Cubit<DataStorageScreenState>
    with AutoSubscriptionMixin {
  final SetBackupPathUseCase _setBackupPathUseCase;
  final FilesystemPickerUsecase _filesystemPickerUsecase;
  final AppDatabase _database;

  DataStorageScreenCubit({
    DataStorageScreenState initialState = const DataStorageScreenState(),
    required ListenBackupPathUseCase listenBackupPathUseCase,
    required SetBackupPathUseCase setBackupPathUseCase,
    required FilesystemPickerUsecase filesystemPickerUsecase,
    required AppDatabase database,
  }) : _setBackupPathUseCase = setBackupPathUseCase,
       _filesystemPickerUsecase = filesystemPickerUsecase,
       _database = database,
       super(initialState) {
    addSubscription(
      listenBackupPathUseCase.backupPathStream.listen(
        (e) => emit(state.copyWith(backupPath: e)),
      ),
    );
  }

  Future<void> setBackupPath(BuildContext context) async {
    final directory = await _filesystemPickerUsecase.directory(context);
    if (directory is Error<Directory>) throw directory.error;
    if (directory is Success<Directory>) {
      _setBackupPathUseCase.setBackupPath(directory.data.path);
    }
  }

  Future<File> backup() => _database.backup();

  Future<void> restore(BuildContext context) async {
    final file = await _filesystemPickerUsecase.file(context);

    if (file is Success<File>) {
      await _database.restore(file: file.data);
      return;
    }

    if (file is Error<File>) throw file.error;
    throw Exception('Something went wrong');
  }
}
