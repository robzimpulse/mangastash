import 'package:equatable/equatable.dart';

class Country extends Equatable with EquatableMixin {
  final String? name;

  final String? alpha2Code;

  final String? dialCode;

  const Country(this.name, this.alpha2Code, this.dialCode);

  @override
  List<Object?> get props => [name, alpha2Code, dialCode];
}
