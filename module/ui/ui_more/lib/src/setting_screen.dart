import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'locale_picker_bottom_sheet/locale_picker_bottom_sheet_screen.dart';

class SettingScreen extends StatefulWidget {
  final Alice alice;
  final ListenThemeUseCase listenThemeUseCase;
  final UpdateThemeUseCase themeUpdateUseCase;
  final ListenLocaleUseCase listenLocaleUseCase;
  final UpdateLocaleUseCase updateLocaleUseCase;
  final GetLanguageListUseCase getLanguageListUseCase;
  final GetCountryListUseCase getCountryListUseCase;

  const SettingScreen({
    super.key,
    required this.alice,
    required this.listenThemeUseCase,
    required this.themeUpdateUseCase,
    required this.listenLocaleUseCase,
    required this.updateLocaleUseCase,
    required this.getLanguageListUseCase,
    required this.getCountryListUseCase,
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
      getCountryListUseCase: locator(),
      getLanguageListUseCase: locator(),
    );
  }

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
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
            stream: widget.listenThemeUseCase.themeDataStream,
            builder: (context, snapshot) {
              final theme = snapshot.data;
              final isDarkMode = theme?.brightness == Brightness.dark;
              final title = isDarkMode ? 'Lights' : 'Dark';
              final icon =
                  isDarkMode ? Icons.lightbulb_outline : Icons.lightbulb_sharp;

              return SwitchListTile(
                title: Text('$title Mode'),
                value: isDarkMode,
                onChanged: (bool value) => widget.themeUpdateUseCase.updateTheme(
                  theme: value ? ThemeData.dark() : ThemeData.light(),
                ),
                secondary: SizedBox(
                  height: double.infinity,
                  child: Icon(icon),
                ),
              );
            },
          ),
          StreamBuilder<Locale>(
            stream: widget.listenLocaleUseCase.localeDataStream,
            builder: (context, snapshot) {
              final locale = snapshot.data;
              return ListTile(
                title: const Text('Language'),
                trailing: Text('${locale?.flagEmoji}'),
                leading: const SizedBox(
                  height: double.infinity,
                  child: Icon(Icons.translate),
                ),
                onTap: _showLanguagePicker,
              );
            },
          ),
          ListTile(
            title: const Text('HTTP Inspector'),
            onTap: () => widget.alice.showInspector(),
            leading: const SizedBox(
              height: double.infinity,
              child: Icon(Icons.http),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker() async {
    final result = await context.showBottomSheet<Locale>(
      builder: (context) => LocalePickerBottomSheetScreen.create(
        countries: widget.getCountryListUseCase.countries,
        languages: widget.getLanguageListUseCase.languages,
        locale: widget.listenLocaleUseCase.localeDataStream.valueOrNull,
      ),
    );
    if (result == null) return;
    widget.updateLocaleUseCase.updateLocale(locale: result);
  }
}
