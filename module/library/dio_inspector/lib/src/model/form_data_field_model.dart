import 'package:equatable/equatable.dart';

class FormDataFieldModel extends Equatable {
  const FormDataFieldModel({
    required this.name,
    required this.value,
  });

  final String name;
  final String value;

  @override
  List<Object?> get props => [name, value];
}
