import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:core_storage/core_storage.dart';
import 'package:intl/intl_standalone.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/listen_locale_use_case.dart';
import '../use_case/update_locale_use_case.dart';

class LocaleManager implements ListenLocaleUseCase, UpdateLocaleUseCase {
  final SharedPreferencesStorage _storage;

  final _localeDataStream = BehaviorSubject<Locale?>.seeded(null);

  static const _key = 'locale';

  LocaleManager({
    required SharedPreferencesStorage storage,
  }) : _storage = storage {
    _init();
  }

  void _init() async {
    final value = _storage.getString(_key) ?? await findSystemLocale();
    final language = value.split('_').firstOrNull;
    final country = value.split('_').lastOrNull;
    if (language == null) return;
    updateLocale(locale: Locale(language, country));
  }

  @override
  ValueStream<Locale?> get localeDataStream => _localeDataStream.stream;

  @override
  void updateLocale({required Locale locale}) {
    final values = [
      locale.languageCode,
      locale.countryCode,
    ].whereNotNull().join('_');
    _storage.setString(_key, values);
    _localeDataStream.add(locale);
  }
}
