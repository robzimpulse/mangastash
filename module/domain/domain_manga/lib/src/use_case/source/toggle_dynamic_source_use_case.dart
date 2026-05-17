import 'package:manga_service_drift/manga_service_drift.dart';

abstract class ToggleDynamicSourceUseCase {
  Future<void> execute(String id, bool isActive);
}

class ToggleDynamicSourceUseCaseImpl implements ToggleDynamicSourceUseCase {
  final DynamicSourceDao _dynamicSourceDao;

  ToggleDynamicSourceUseCaseImpl({
    required DynamicSourceDao dynamicSourceDao,
  }) : _dynamicSourceDao = dynamicSourceDao;

  @override
  Future<void> execute(String id, bool isActive) async {
    await _dynamicSourceDao.insertOrUpdate(
      DynamicSourceTablesCompanion(
        id: Value(id),
        isActive: Value(isActive),
      ),
    );
  }
}
