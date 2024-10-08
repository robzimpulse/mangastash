import 'package:equatable/equatable.dart';

class AppearanceScreenState extends Equatable {
  final bool isDarkMode;

  const AppearanceScreenState({
    this.isDarkMode = false,
  });

  @override
  List<Object?> get props => [isDarkMode];

  AppearanceScreenState copyWith({
    bool? isDarkMode,
  }) {
    return AppearanceScreenState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}
