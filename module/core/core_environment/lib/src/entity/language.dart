import 'package:equatable/equatable.dart';

class Language extends Equatable with EquatableMixin {
  final String? isoCode;

  final String? name;

  const Language(this.isoCode, this.name);

  @override
  List<Object?> get props => [isoCode, name];
}
