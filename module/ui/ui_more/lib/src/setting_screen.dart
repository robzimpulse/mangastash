import 'package:alice_lightweight/alice.dart';
import 'package:core_environment/core_environment.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

class SettingScreen extends StatelessWidget {
  final Alice alice;
  final ListenThemeUseCase listenThemeUseCase;
  final UpdateThemeUseCase themeUpdateUseCase;
  final ListenLocaleUseCase listenLocaleUseCase;
  final UpdateLocaleUseCase updateLocaleUseCase;

  const SettingScreen({
    super.key,
    required this.alice,
    required this.listenThemeUseCase,
    required this.themeUpdateUseCase,
    required this.listenLocaleUseCase,
    required this.updateLocaleUseCase,
  });

  static Widget create({
    required ServiceLocator locator,
  }) {
    return SettingScreen(
      alice: locator(),
      listenThemeUseCase: locator(),
      themeUpdateUseCase: locator(),
      listenLocaleUseCase: locator(),
      updateLocaleUseCase: locator(),
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
              final icon =
                  isDarkMode ? Icons.lightbulb_outline : Icons.lightbulb_sharp;

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
          StreamBuilder<String>(
            stream: listenLocaleUseCase.localeDataStream,
            builder: (context, snapshot) {
              final locale = snapshot.data;
              return ListTile(
                title: const Text('Language'),
                trailing: Text('$locale'),
                leading: const SizedBox(
                  height: double.infinity,
                  child: Icon(Icons.translate),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('HTTP Inspector'),
            onTap: () => alice.showInspector(),
            leading: const SizedBox(
              height: double.infinity,
              child: Icon(Icons.http),
            ),
          ),
        ],
      ),
    );
  }
}
