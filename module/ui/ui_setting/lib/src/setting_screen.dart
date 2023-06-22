import 'package:core_environment/core_environment.dart';
import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {
  final ListenThemeUseCase listenThemeUseCase;

  final UpdateThemeUseCase themeUpdateUseCase;

  const SettingScreen({
    super.key,
    required this.listenThemeUseCase,
    required this.themeUpdateUseCase,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(true),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Setting'),
        ),
        body: ListView(
          children: [
            StreamBuilder<ThemeData>(
              stream: listenThemeUseCase.themeDataStream,
              builder: (context, snapshot) {
                final theme = snapshot.data;
                final isDarkMode = theme?.brightness == Brightness.dark;
                return SwitchListTile(
                  title: Text(isDarkMode ? 'Lights' : 'Dark'),
                  value: isDarkMode,
                  onChanged: (bool value) => themeUpdateUseCase.updateTheme(
                    theme: value ? ThemeData.dark() : ThemeData.light(),
                  ),
                  secondary: Icon(
                    isDarkMode
                        ? Icons.lightbulb_outline
                        : Icons.lightbulb_sharp,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
