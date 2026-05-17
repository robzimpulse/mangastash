import 'package:domain_manga/domain_manga.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'source_management_screen_state.dart';

class SourceManagementScreenCubit extends Cubit<SourceManagementScreenState> with AutoSubscriptionMixin {
  final DynamicSourceDao _dynamicSourceDao;
  final ImportDynamicSourceUseCase _importDynamicSourceUseCase;
  final DeleteDynamicSourceUseCase _deleteDynamicSourceUseCase;
  final ToggleDynamicSourceUseCase _toggleDynamicSourceUseCase;

  SourceManagementScreenCubit({
    required DynamicSourceDao dynamicSourceDao,
    required ImportDynamicSourceUseCase importDynamicSourceUseCase,
    required DeleteDynamicSourceUseCase deleteDynamicSourceUseCase,
    required ToggleDynamicSourceUseCase toggleDynamicSourceUseCase,
  }) : _dynamicSourceDao = dynamicSourceDao,
       _importDynamicSourceUseCase = importDynamicSourceUseCase,
       _deleteDynamicSourceUseCase = deleteDynamicSourceUseCase,
       _toggleDynamicSourceUseCase = toggleDynamicSourceUseCase,
       super(const SourceManagementScreenState()) {
    _init();
  }

  void _init() {
    addSubscription(
      _dynamicSourceDao.watchAll().listen((sources) {
        emit(state.copyWith(dynamicSources: sources));
      }),
    );
  }

  Future<void> importFromUrl(String url) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await _importDynamicSourceUseCase.fromUrl(url);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> deleteSource(String id) async {
    await _deleteDynamicSourceUseCase.execute(id);
  }

  Future<void> toggleSource(String id, bool isActive) async {
    await _toggleDynamicSourceUseCase.execute(id, isActive);
  }
}
