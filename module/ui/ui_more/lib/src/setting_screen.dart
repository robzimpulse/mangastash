import 'package:collection/collection.dart';
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
            builder: (context, snapshot) {
              final locale = snapshot.data;
              final language = locale?.language(
                widget.getLanguageListUseCase.languages,
              );
              return ListTile(
                title: const Text('Language'),
                trailing: Text('${language?.name}'),
                leading: const SizedBox(
                  height: double.infinity,
                  child: Icon(Icons.translate),
                ),
                onTap: _showLanguagePicker,
              );
            },
          ),
          StreamBuilder<Locale>(
            stream: widget.listenLocaleUseCase.localeDataStream,
            builder: (context, snapshot) {
              final locale = snapshot.data;
              final country = locale?.country(
                widget.getCountryListUseCase.countries,
              );
              return ListTile(
                title: const Text('Country'),
                trailing: Text('${country?.name}'),
                leading: const SizedBox(
                  height: double.infinity,
                  child: Icon(Icons.language),
                ),
                onTap: () => _showCountryPicker(context),
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

  void _onChangeTheme(bool value) {
    widget.themeUpdateUseCase.updateTheme(
      theme: value ? ThemeData.dark() : ThemeData.light(),
    );
  }

  void _showLanguagePicker() async {
    final languages = widget.getLanguageListUseCase.languages;
    final result = await context.showBottomSheet<String>(
      builder: (context) => PickerBottomSheet(
        names: languages.map((e) => e.name).whereNotNull().toList(),
      ),
    );
    final code = languages.firstWhereOrNull((e) => e.name == result)?.isoCode;
    final locale = widget.listenLocaleUseCase.localeDataStream.valueOrNull;
    if (code == null || locale == null) return;
    widget.updateLocaleUseCase.updateLocale(
      locale: Locale(code, locale.countryCode),
    );
  }

  void _showCountryPicker(BuildContext context) async {
    final countries = widget.getCountryListUseCase.countries;
    final result = await context.showBottomSheet<String>(
      builder: (context) => PickerBottomSheet(
        names: countries.map((e) => e.name).whereNotNull().toList(),
      ),
    );
    final code =
        countries.firstWhereOrNull((e) => e.name == result)?.alpha2Code;
    final locale = widget.listenLocaleUseCase.localeDataStream.valueOrNull;
    if (code == null || locale == null) return;
    widget.updateLocaleUseCase.updateLocale(
      locale: Locale(locale.languageCode, code),
    );
  }
}
