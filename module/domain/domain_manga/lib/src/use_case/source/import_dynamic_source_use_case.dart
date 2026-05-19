import 'package:core_network/core_network.dart';
import 'package:core_runtime/core_runtime.dart';

import 'add_dynamic_source_use_case.dart';

abstract class ImportDynamicSourceUseCase {
  Future<void> fromUrl(String url);
  Future<void> fromCode(String name, String baseUrl, String sourceCode, {String? iconUrl});
}

class ImportDynamicSourceUseCaseImpl implements ImportDynamicSourceUseCase {
  final Dio _dio;
  final SourceRuntime _sourceRuntime;
  final AddDynamicSourceUseCase _addDynamicSourceUseCase;

  ImportDynamicSourceUseCaseImpl({
    required Dio dio,
    required SourceRuntime sourceRuntime,
    required AddDynamicSourceUseCase addDynamicSourceUseCase,
  }) : _dio = dio,
       _sourceRuntime = sourceRuntime,
       _addDynamicSourceUseCase = addDynamicSourceUseCase;

  @override
  Future<void> fromUrl(String url) async {
    final response = await _dio.get(url);
    final sourceCode = response.data as String;
    
    // For simplicity, we assume metadata is in the source code as comments or we have a format.
    // Tacitly, let's assume we can parse name/baseUrl from the code or just use defaults for now.
    // In a real app, maybe a JSON manifest is better.
    // For now, let's just use placeholder metadata and let the user edit it.
    
    await fromCode('Imported Source', 'https://example.com', sourceCode);
  }

  @override
  Future<void> fromCode(String name, String baseUrl, String sourceCode, {String? iconUrl}) async {
    final bytecode = _sourceRuntime.getOrCreateBytecode(name, sourceCode);
    await _addDynamicSourceUseCase.execute(
      name: name,
      baseUrl: baseUrl,
      iconUrl: iconUrl,
      sourceCode: sourceCode,
      bytecode: bytecode,
    );
  }
}
