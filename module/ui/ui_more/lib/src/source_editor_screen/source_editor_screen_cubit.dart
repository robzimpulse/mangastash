import 'package:core_network/core_network.dart';
import 'package:core_runtime/core_runtime.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'source_editor_screen_state.dart';

enum SourceTestType {
  getManga,
  searchManga,
  listChapters,
  getChapterImages,
  listTags,
  searchUrl,
}

class SourceEditorScreenCubit extends Cubit<SourceEditorScreenState> {
  final ImportDynamicSourceUseCase _importDynamicSourceUseCase;
  final SourceRuntime _sourceRuntime;
  final Dio _dio;

  SourceEditorScreenCubit({
    required ImportDynamicSourceUseCase importDynamicSourceUseCase,
    required SourceRuntime sourceRuntime,
    required Dio dio,
    DynamicSourceDrift? initialSource,
  }) : _importDynamicSourceUseCase = importDynamicSourceUseCase,
       _sourceRuntime = sourceRuntime,
       _dio = dio,
       super(
         SourceEditorScreenState(
           id: initialSource?.id,
           name: initialSource?.name ?? '',
           baseUrl: initialSource?.baseUrl ?? '',
           iconUrl: initialSource?.iconUrl,
           sourceCode: initialSource?.sourceCode ?? '',
         ),
       );

  void updateName(String name) => emit(state.copyWith(name: name));
  void updateBaseUrl(String url) => emit(state.copyWith(baseUrl: url));
  void updateSourceCode(String code) => emit(state.copyWith(sourceCode: code));

  Future<void> save() async {
    emit(state.copyWith(isSaving: true, error: null));
    try {
      await _importDynamicSourceUseCase.fromCode(
        state.name,
        state.baseUrl,
        state.sourceCode,
        iconUrl: state.iconUrl,
      );
    } catch (e) {
      emit(state.copyWith(error: 'Save failed: $e'));
    } finally {
      emit(state.copyWith(isSaving: false));
    }
  }

  Future<void> runTest(
    String input, {
    SourceTestType type = SourceTestType.getManga,
  }) async {
    emit(state.copyWith(isTesting: true, testResult: null, error: null));
    try {
      final bytecode = _sourceRuntime.getOrCreateBytecode(
        'test',
        state.sourceCode,
        useCache: false,
      );

      if (type == SourceTestType.searchUrl) {
        final result = await _sourceRuntime.execute(
          bytecode: bytecode,
          functionName: 'searchUrl',
          args: [SearchMangaParameter(title: input, page: 1)],
        );
        emit(state.copyWith(testResult: result.toString()));
        return;
      }

      final response = await _dio.get(input);
      final html = response.data as String;

      final result = await _sourceRuntime.execute(
        bytecode: bytecode,
        functionName: type.name,
        args: [html],
      );

      emit(state.copyWith(testResult: result.toString()));
    } catch (e) {
      emit(state.copyWith(error: 'Test failed: $e'));
    } finally {
      emit(state.copyWith(isTesting: false));
    }
  }
}
