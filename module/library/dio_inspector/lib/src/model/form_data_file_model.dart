import 'package:equatable/equatable.dart';

class FormDataFileModel extends Equatable {
  const FormDataFileModel({
    this.fileName,
    required this.contentType,
    required this.length,
  });

  final String? fileName;
  final String contentType;
  final int length;

  @override
  List<Object?> get props => [fileName, contentType, length];
}
