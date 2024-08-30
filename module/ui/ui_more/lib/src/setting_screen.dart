import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

class SettingScreen extends StatefulWidget {
  final Alice alice;
  final ListenThemeUseCase listenThemeUseCase;
  final UpdateThemeUseCase themeUpdateUseCase;
  final ListenLocaleUseCase listenLocaleUseCase;
  final UpdateLocaleUseCase updateLocaleUseCase;
  final ListenCurrentTimezoneUseCase listenCurrentTimezoneUseCase;

  const SettingScreen({
    super.key,
    required this.alice,
    required this.listenThemeUseCase,
    required this.themeUpdateUseCase,
    required this.listenLocaleUseCase,
    required this.updateLocaleUseCase,
    required this.listenCurrentTimezoneUseCase,
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
      listenCurrentTimezoneUseCase: locator(),
    );
  }

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
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
                onChanged: _onChangeTheme,
                secondary: SizedBox(
                  height: double.infinity,
                  child: Icon(icon),
                ),
              );
            },
          ),
          StreamBuilder<Locale>(
            stream: widget.listenLocaleUseCase.localeDataStream,
            builder: (context, snapshot) => ListTile(
              title: const Text('Language'),
              trailing: Text('${snapshot.data?.language.name}'),
              leading: const SizedBox(
                height: double.infinity,
                child: Icon(Icons.translate),
              ),
              onTap: _showLanguagePicker,
            ),
          ),
          StreamBuilder<Locale>(
            stream: widget.listenLocaleUseCase.localeDataStream,
            builder: (context, snapshot) => ListTile(
              title: const Text('Country'),
              trailing: Text('${snapshot.data?.country?.name}'),
              leading: const SizedBox(
                height: double.infinity,
                child: Icon(Icons.language),
              ),
              onTap: _showCountryPicker,
            ),
          ),
          StreamBuilder<String>(
            stream: widget.listenCurrentTimezoneUseCase.timezoneDataStream,
            builder: (context, snapshot) => ListTile(
              title: const Text('Timezone'),
              trailing: Text('${snapshot.data}'),
              leading: const SizedBox(
                height: double.infinity,
                child: Icon(Icons.access_time_rounded),
              ),
            ),
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

  void _onChangeTheme(bool value) {
    widget.themeUpdateUseCase.updateTheme(
      theme: value ? ThemeData.dark() : ThemeData.light(),
    );
  }

  void _showLanguagePicker() async {
    final locale = widget.listenLocaleUseCase.localeDataStream.valueOrNull;
    final result = await context.showBottomSheet<String>(
      builder: (context) => PickerBottomSheet(
        names: Language.sorted.map((e) => e.name).toList(),
      ),
    );
    if (result == null || locale == null) return;
    widget.updateLocaleUseCase.updateLocale(
      locale: Locale(Language.fromName(result).code, locale.countryCode),
    );
  }

  void _showCountryPicker() async {
    final locale = widget.listenLocaleUseCase.localeDataStream.valueOrNull;
    final result = await context.showBottomSheet<String>(
      builder: (context) => PickerBottomSheet(
        names: Country.sorted.map((e) => e.name).toList(),
        selectedName: locale?.country?.name,
      ),
    );

    if (locale == null || result == null) return;
    widget.updateLocaleUseCase.updateLocale(
      locale: Locale(locale.languageCode, Country.fromName(result).code),
    );
  }
}
