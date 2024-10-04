import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SettingScreenState extends Equatable {
  const SettingScreenState({
    this.isDarkMode = false,
    this.locale,
    this.mangaChapterConfig,
    this.timezone,
  });

  final Locale? locale;

  final MangaChapterConfig? mangaChapterConfig;

  final String? timezone;

  final bool isDarkMode;

  @override
  List<Object?> get props => [isDarkMode, locale, mangaChapterConfig, timezone];

  SettingScreenState copyWith({
    bool? isDarkMode,
    Locale? locale,
    MangaChapterConfig? mangaChapterConfig,
    String? timezone,
  }) {
    return SettingScreenState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      locale: locale ?? this.locale,
      mangaChapterConfig: mangaChapterConfig ?? this.mangaChapterConfig,
      timezone: timezone ?? this.timezone,
    );
  }
}
