import 'package:core_storage/core_storage.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'backup_restore_screen_state.dart';

class BackupRestoreScreenCubit extends Cubit<BackupRestoreScreenState> {
  BackupRestoreScreenCubit({
    BackupRestoreScreenState initialState = const BackupRestoreScreenState(),
    required GetRootPathUseCase getRootPathUseCase,
  }) : super(initialState.copyWith(path: getRootPathUseCase.rootPath));
}
