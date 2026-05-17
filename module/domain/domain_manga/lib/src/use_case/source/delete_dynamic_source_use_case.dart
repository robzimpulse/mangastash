import 'package:manga_service_drift/manga_service_drift.dart';

abstract class DeleteDynamicSourceUseCase {
  Future<void> execute(String id);
}

class DeleteDynamicSourceUseCaseImpl implements DeleteDynamicSourceUseCase {
  final DynamicSourceDao _dynamicSourceDao;

  DeleteDynamicSourceUseCaseImpl({
    required DynamicSourceDao dynamicSourceDao,
  }) : _dynamicSourceDao = dynamicSourceDao;

  @override
  Future<void> execute(String id) async {
    await _dynamicSourceDao.deleteSource(id);
  }
}
