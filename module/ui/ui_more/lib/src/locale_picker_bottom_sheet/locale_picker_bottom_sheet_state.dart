import 'dart:ui';

import 'package:core_environment/core_environment.dart';
import 'package:equatable/equatable.dart';

class LocalePickerBottomSheetState extends Equatable with EquatableMixin {
  final List<Language> languages;

  final List<Country> countries;

  final Locale? locale;

  const LocalePickerBottomSheetState({
    this.languages = const [],
    this.countries = const [],
    this.locale,
  });

  @override
  List<Object?> get props => [languages, countries, locale];

  LocalePickerBottomSheetState copyWith({
    List<Language>? languages,
    List<Country>? countries,
    Locale? locale,
  }) {
    return LocalePickerBottomSheetState(
      languages: languages ?? this.languages,
      countries: countries ?? this.countries,
      locale: locale ?? this.locale,
    );
  }
}
