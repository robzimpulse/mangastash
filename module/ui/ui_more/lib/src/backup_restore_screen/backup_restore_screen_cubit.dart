import 'package:safe_bloc/safe_bloc.dart';

import 'backup_restore_screen_state.dart';

class BackupRestoreScreenCubit extends Cubit<BackupRestoreScreenState> {
  BackupRestoreScreenCubit({
    BackupRestoreScreenState initialState = const BackupRestoreScreenState(),
  }) : super(initialState);

  void init() {}
}
