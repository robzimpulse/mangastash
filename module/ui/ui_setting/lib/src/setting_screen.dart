import 'package:alice_lightweight/alice.dart';
import 'package:core_environment/core_environment.dart';
import 'package:flutter/material.dart';
import 'package:ui_common/ui_common.dart';

class SettingScreen extends StatelessWidget {
  final ListenThemeUseCase listenThemeUseCase;
  final Alice alice;
  final UpdateThemeUseCase themeUpdateUseCase;

  const SettingScreen({
    super.key,
    required this.alice,
    required this.listenThemeUseCase,
    required this.themeUpdateUseCase,
  });

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      onWillPop: () => Future.value(true),
      appBar: AppBar(
        title: const Text('Setting'),
      ),
      child: ListView(
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
          ListTile(
            title: const Text('Show Alice HTTP Inspector'),
            onTap: () => alice.showInspector(),
          )
        ],
      ),
    );
  }
}
