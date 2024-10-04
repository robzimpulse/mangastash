import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'setting_screen_cubit.dart';
import 'setting_screen_state.dart';

class SettingScreen extends StatefulWidget {
  final Alice alice;

  const SettingScreen({
    super.key,
    required this.alice,
  });

  static Widget create({
    required ServiceLocator locator,
  }) {
    return BlocProvider(
      create: (context) => SettingScreenCubit(
        listenThemeUseCase: locator(),
        updateThemeUseCase: locator(),
        listenLocaleUseCase: locator(),
        updateLocaleUseCase: locator(),
        listenCurrentTimezoneUseCase: locator(),
        listenMangaChapterConfig: locator(),
      ),
      child: SettingScreen(
        alice: locator(),
      ),
    );
  }

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  SettingScreenCubit _cubit(BuildContext context) => context.read();

  Widget _builder({
    required BlocWidgetBuilder<SettingScreenState> builder,
    BlocBuilderCondition<SettingScreenState>? buildWhen,
  }) {
    return BlocBuilder<SettingScreenCubit, SettingScreenState>(
      buildWhen: buildWhen,
      builder: builder,
    );
  }

  Widget _buildDarkModeMenu(BuildContext context) {
    return _builder(
      buildWhen: (prev, curr) => prev.isDarkMode != curr.isDarkMode,
      builder: (_, state) => SwitchListTile(
        title: Text('${state.isDarkMode ? 'Lights' : 'Dark'} Mode'),
        value: state.isDarkMode,
        onChanged: (value) => _cubit(context).changeDarkMode(value),
        secondary: SizedBox(
          height: double.infinity,
          child: Icon(
            state.isDarkMode ? Icons.lightbulb_outline : Icons.lightbulb_sharp,
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageMenu(BuildContext context) {
    return _builder(
      buildWhen: (prev, curr) => prev.locale != curr.locale,
      builder: (_, state) => ListTile(
        title: const Text('Language'),
        trailing: Text('${state.locale?.language.name}'),
        leading: const SizedBox(
          height: double.infinity,
          child: Icon(Icons.translate),
        ),
        onTap: () => _showLanguagePicker(context, state),
      ),
    );
  }

  void _showLanguagePicker(
    BuildContext context,
    SettingScreenState state,
  ) async {
    final result = await context.showBottomSheet<String>(
      builder: (context) => PickerBottomSheet(
        names: Language.sorted.map((e) => e.name).toList(),
      ),
    );
    if (result == null || !context.mounted) return;
    _cubit(context).changeLanguage(result);
  }

  Widget _buildCountryMenu(BuildContext context) {
    return _builder(
      buildWhen: (prev, curr) => prev.locale != curr.locale,
      builder: (_, state) => ListTile(
        title: const Text('Country'),
        trailing: Text('${state.locale?.country?.name}'),
        leading: const SizedBox(
          height: double.infinity,
          child: Icon(Icons.language),
        ),
        onTap: () => _showCountryPicker(context, state),
      ),
    );
  }

  void _showCountryPicker(
    BuildContext context,
    SettingScreenState state,
  ) async {
    final result = await context.showBottomSheet<String>(
      builder: (context) => PickerBottomSheet(
        names: Country.sorted.map((e) => e.name).toList(),
        selectedName: state.locale?.country?.name,
      ),
    );
    if (result == null || !context.mounted) return;
    _cubit(context).changeCountry(result);
  }

  Widget _buildTimeZoneMenu(BuildContext context) {
    return _builder(
      buildWhen: (prev, curr) => prev.timezone != curr.timezone,
      builder: (context, state) => ListTile(
        title: const Text('Timezone'),
        trailing: Text('${state.timezone}'),
        leading: const SizedBox(
          height: double.infinity,
          child: Icon(Icons.access_time_rounded),
        ),
      ),
    );
  }

  Widget _buildHttpInspectorMenu(BuildContext context) {
    return ListTile(
      title: const Text('HTTP Inspector'),
      onTap: () => widget.alice.showInspector(),
      leading: const SizedBox(
        height: double.infinity,
        child: Icon(Icons.http),
      ),
    );
  }

  Widget _buildMangaSortMenu(BuildContext context) {
    return _builder(
      buildWhen: (prev, curr) =>
          prev.mangaChapterConfig != curr.mangaChapterConfig,
      builder: (context, state) => ListTile(
        title: const Text('Manga Chapter Sort'),
        onTap: () {},
        trailing: Text(
          [
            state.mangaChapterConfig?.sortOption.value ?? '',
            state.mangaChapterConfig?.sortOrder.value ?? '',
          ].join(' - '),
        ),
        leading: const SizedBox(
          height: double.infinity,
          child: Icon(Icons.sort),
        ),
      ),
    );
  }

  Widget _buildMangaChapterFilterMenu(BuildContext context) {
    return _builder(
      buildWhen: (prev, curr) =>
          prev.mangaChapterConfig != curr.mangaChapterConfig,
      builder: (context, state) => ListTile(
        title: const Text('Manga Chapter Filter'),
        onTap: () {},
        trailing: Text(
          [
            state.mangaChapterConfig?.unread ?? 'null',
            state.mangaChapterConfig?.bookmarked ?? 'null',
            state.mangaChapterConfig?.downloaded ?? 'null',
          ].join(' | '),
        ),
        leading: const SizedBox(
          height: double.infinity,
          child: Icon(Icons.filter_alt),
        ),
      ),
    );
  }

  Widget _buildMangaChapterDisplayMenu(BuildContext context) {
    return _builder(
      buildWhen: (prev, curr) =>
          prev.mangaChapterConfig != curr.mangaChapterConfig,
      builder: (context, state) => ListTile(
        title: const Text('Manga Chapter Display'),
        onTap: () {},
        trailing: Text(
          state.mangaChapterConfig?.display.value ?? '',
        ),
        leading: const SizedBox(
          height: double.infinity,
          child: Icon(Icons.display_settings),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(
        title: const Text('Setting'),
      ),
      body: ListView(
        children: [
          _buildDarkModeMenu(context),
          _buildLanguageMenu(context),
          _buildCountryMenu(context),
          _buildTimeZoneMenu(context),
          _buildMangaSortMenu(context),
          _buildMangaChapterFilterMenu(context),
          _buildMangaChapterDisplayMenu(context),
          _buildHttpInspectorMenu(context),
        ],
      ),
    );
  }
}
