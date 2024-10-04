import 'package:core_environment/core_environment.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/material.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'setting_screen_state.dart';

class SettingScreenCubit extends Cubit<SettingScreenState>
    with AutoSubscriptionMixin {
  final UpdateThemeUseCase _updateThemeUseCase;
  final UpdateLocaleUseCase _updateLocaleUseCase;

  SettingScreenCubit({
    SettingScreenState initialState = const SettingScreenState(),
    required ListenThemeUseCase listenThemeUseCase,
    required UpdateThemeUseCase updateThemeUseCase,
    required ListenLocaleUseCase listenLocaleUseCase,
    required UpdateLocaleUseCase updateLocaleUseCase,
    required ListenMangaChapterConfig listenMangaChapterConfig,
    required ListenCurrentTimezoneUseCase listenCurrentTimezoneUseCase,
  })  : _updateThemeUseCase = updateThemeUseCase,
        _updateLocaleUseCase = updateLocaleUseCase,
        super(initialState) {
    addSubscription(
      listenThemeUseCase.themeDataStream.listen(_updateThemeData),
    );
    addSubscription(
      listenLocaleUseCase.localeDataStream.listen(_updateLocaleData),
    );
    addSubscription(
      listenMangaChapterConfig.mangaChapterConfigStream
          .listen(_updateMangaChapterConfig),
    );
    addSubscription(
      listenCurrentTimezoneUseCase.timezoneDataStream
          .listen(_updateTimeZoneData),
    );
  }

  void _updateThemeData(ThemeData data) {
    emit(state.copyWith(isDarkMode: data.brightness == Brightness.dark));
  }

  void _updateLocaleData(Locale? data) {
    emit(state.copyWith(locale: data));
  }

  void _updateMangaChapterConfig(MangaChapterConfig data) {
    emit(state.copyWith(mangaChapterConfig: data));
  }

  void _updateTimeZoneData(String data) {
    emit(state.copyWith(timezone: data));
  }

  void changeDarkMode(bool value) {
    _updateThemeUseCase.updateTheme(
      theme: value ? ThemeData.dark() : ThemeData.light(),
    );
  }

  void changeLanguage(String languageName) {
    final locale = state.locale;
    if (locale == null) return;
    _updateLocaleUseCase.updateLocale(
      locale: Locale(
        Language.fromName(languageName).code,
        locale.countryCode,
      ),
    );
  }

  void changeCountry(String countryName) {
    final locale = state.locale;
    if (locale == null) return;
    _updateLocaleUseCase.updateLocale(
      locale: Locale(
        locale.languageCode,
        Country.fromName(countryName).code,
      ),
    );
  }
}
