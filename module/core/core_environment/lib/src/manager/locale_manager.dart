import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:core_storage/core_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl_standalone.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/listen_locale_use_case.dart';
import '../use_case/update_locale_use_case.dart';

class LocaleManager implements ListenLocaleUseCase, UpdateLocaleUseCase {
  final Storage _storage;

  late final BehaviorSubject<Locale> _localeDataStream;

  static const _key = 'locale';

  static Future<LocaleManager> create({
    required Storage storage,
  }) async {
    await initializeDateFormatting();
    final value = storage.getString(_key) ?? await findSystemLocale();
    final language = value.split('_').firstOrNull ?? 'en';
    final country = value.split('_').lastOrNull;
    return LocaleManager._(
      storage: storage,
      initialLocale: Locale(language, country),
    );
  }

  LocaleManager._({
    required Storage storage,
    required Locale initialLocale,
  })  : _storage = storage,
        _localeDataStream = BehaviorSubject.seeded(initialLocale);

  @override
  ValueStream<Locale?> get localeDataStream => _localeDataStream.stream;

  @override
  void updateLocale({required Locale locale}) {
    final values = [
      locale.languageCode,
      locale.countryCode,
    ].nonNulls.join('_');
    _storage.setString(_key, values);
    _localeDataStream.add(locale);
  }
}
