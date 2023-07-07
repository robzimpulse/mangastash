import 'package:alice_lightweight/alice.dart';
import 'package:core_environment/core_environment.dart';
import 'package:flutter/material.dart';
import 'package:service_locator/service_locator.dart';
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

  static Widget create({
    required ServiceLocator locator,
  }) {
    return SettingScreen(
      alice: locator(),
      listenThemeUseCase: locator(),
      themeUpdateUseCase: locator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      onWillPop: () => Future.value(true),
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
              final title = isDarkMode ? 'Lights' : 'Dark';
              final icon = isDarkMode
                  ? Icons.lightbulb_outline
                  : Icons.lightbulb_sharp;

              return SwitchListTile(
                title: Text('$title Mode'),
                value: isDarkMode,
                onChanged: (bool value) => themeUpdateUseCase.updateTheme(
                  theme: value ? ThemeData.dark() : ThemeData.light(),
                ),
                secondary: SizedBox(
                  height: double.infinity,
                  child: Icon(icon),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('HTTP Inspector'),
            onTap: () => alice.showInspector(),
            leading: const SizedBox(
              height: double.infinity,
              child: Icon(Icons.compare_arrows),
            ),
          ),
        ],
      ),
    );
  }
}
