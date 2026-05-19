import 'dart:typed_data';

import 'package:manga_service_drift/manga_service_drift.dart';

abstract class AddDynamicSourceUseCase {
  Future<void> execute({
    required String name,
    required String baseUrl,
    String? iconUrl,
    required String sourceCode,
    required List<int> bytecode,
  });
}

class AddDynamicSourceUseCaseImpl implements AddDynamicSourceUseCase {
  final DynamicSourceDao _dynamicSourceDao;

  AddDynamicSourceUseCaseImpl({
    required DynamicSourceDao dynamicSourceDao,
  }) : _dynamicSourceDao = dynamicSourceDao;

  @override
  Future<void> execute({
    required String name,
    required String baseUrl,
    String? iconUrl,
    required String sourceCode,
    required List<int> bytecode,
  }) async {
    await _dynamicSourceDao.insertOrUpdate(
      DynamicSourceTablesCompanion.insert(
        name: name,
        baseUrl: baseUrl,
        iconUrl: Value(iconUrl),
        sourceCode: sourceCode,
        bytecode: Uint8List.fromList(bytecode),
      ),
    );
  }
}
