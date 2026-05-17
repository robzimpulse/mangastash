import 'package:equatable/equatable.dart';

class SourceEditorScreenState extends Equatable {
  final String? id;
  final String name;
  final String baseUrl;
  final String? iconUrl;
  final String sourceCode;
  final bool isSaving;
  final bool isTesting;
  final String? testResult;
  final String? error;

  const SourceEditorScreenState({
    this.id,
    this.name = '',
    this.baseUrl = '',
    this.iconUrl,
    this.sourceCode = '',
    this.isSaving = false,
    this.isTesting = false,
    this.testResult,
    this.error,
  });

  SourceEditorScreenState copyWith({
    String? id,
    String? name,
    String? baseUrl,
    String? iconUrl,
    String? sourceCode,
    bool? isSaving,
    bool? isTesting,
    String? testResult,
    String? error,
  }) {
    return SourceEditorScreenState(
      id: id ?? this.id,
      name: name ?? this.name,
      baseUrl: baseUrl ?? this.baseUrl,
      iconUrl: iconUrl ?? this.iconUrl,
      sourceCode: sourceCode ?? this.sourceCode,
      isSaving: isSaving ?? this.isSaving,
      isTesting: isTesting ?? this.isTesting,
      testResult: testResult ?? this.testResult,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [id, name, baseUrl, iconUrl, sourceCode, isSaving, isTesting, testResult, error];
}
