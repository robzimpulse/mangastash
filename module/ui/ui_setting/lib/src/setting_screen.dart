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

  ThemeData? get _theme => listenThemeUseCase.themeDataStream.valueOrNull;

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
            SwitchListTile(
              title: const Text('Lights'),
              value: _theme?.brightness == Brightness.dark,
              onChanged: (bool value) {
                themeUpdateUseCase.updateTheme(
                  theme: value ? ThemeData.dark() : ThemeData.light(),
                );
              },
              secondary: const Icon(Icons.lightbulb_outline),
            ),
          ],
        ),
      ),
    );
  }
}
