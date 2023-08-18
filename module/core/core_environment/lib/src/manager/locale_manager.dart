import 'package:core_storage/core_storage.dart';
import 'package:intl/intl_standalone.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/listen_locale_use_case.dart';
import '../use_case/update_locale_use_case.dart';

class LocaleManager implements ListenLocaleUseCase, UpdateLocaleUseCase {
  final Storage _storage;

  final _localeDataStream = BehaviorSubject<String>.seeded('');

  static const _key = 'locale';

  LocaleManager({required Storage storage}) : _storage = storage {
    _init();
  }

  void _init() async {
    var value = _storage.getString(_key) ?? await findSystemLocale();
    updateLocale(locale: value);
  }

  @override
  ValueStream<String> get localeDataStream => _localeDataStream.stream;

  @override
  void updateLocale({required String locale}) {
    _storage.setString(_key, locale);
    _localeDataStream.add(locale);
  }
}
