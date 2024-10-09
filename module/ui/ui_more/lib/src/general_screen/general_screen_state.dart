import 'dart:ui';

import 'package:equatable/equatable.dart';

class GeneralScreenState extends Equatable {
  const GeneralScreenState({this.locale});

  final Locale? locale;

  @override
  List<Object?> get props => [locale];
}