import 'package:core_environment/core_environment.dart';
import 'package:flutter/material.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:ui_common/ui_common.dart';

import 'locale_picker_bottom_sheet_cubit.dart';
import 'locale_picker_bottom_sheet_state.dart';

class LocalePickerBottomSheetScreen extends StatefulWidget {
  const LocalePickerBottomSheetScreen({super.key});

  static Widget create({
    required List<Country> countries,
    required List<Language> languages,
    Locale? locale,
  }) {
    return BlocProvider(
      create: (context) => LocalePickerBottomSheetCubit(
        initialState: LocalePickerBottomSheetState(
          countries: countries,
          languages: languages,
          locale: locale,
        ),
      ),
      child: const LocalePickerBottomSheetScreen(),
    );
  }

  @override
  State<LocalePickerBottomSheetScreen> createState() =>
      _LocalePickerBottomSheetScreenState();
}

class _LocalePickerBottomSheetScreenState
    extends State<LocalePickerBottomSheetScreen> {

  final _languageController = ScrollController();

  final _countryController = ScrollController();

  @override
  void dispose() {
    _languageController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Widget _bloc({
    required BlocWidgetBuilder<LocalePickerBottomSheetState> builder,
    BlocBuilderCondition<LocalePickerBottomSheetState>? buildWhen,
  }) {
    return BlocBuilder<LocalePickerBottomSheetCubit,
        LocalePickerBottomSheetState>(
      buildWhen: buildWhen,
      builder: builder,
    );
  }

  LocalePickerBottomSheetCubit _cubit(BuildContext context) {
    return context.read<LocalePickerBottomSheetCubit>();
  }

  void _onTapLanguage(BuildContext context, Language language) {
    final locale = _cubit(context).state.locale;
    final code = language.isoCode;
    if (locale == null || code == null) return;
    _cubit(context).update(Locale(code, locale.countryCode));
  }

  void _onTapCountry(BuildContext context, Country country) {
    final locale = _cubit(context).state.locale;
    if (locale == null) return;
    _cubit(context).update(Locale(locale.languageCode, country.alpha2Code));
  }

  @override
  Widget build(BuildContext context) {
    return _bloc(
      builder: (context, state) {
        final languages = state.languages
            .map(
              (e) => ListTile(
                title: Text(e.name ?? ''),
                selected: state.locale?.languageCode == e.isoCode,
                selectedTileColor: Theme.of(context).selectedRowColor,
                onTap: () => _onTapLanguage(context, e),
              ),
            )
            .toList();

        final countries = state.countries
            .map(
              (e) => ListTile(
                title: Text(
                  e.name ?? '',
                  textAlign: TextAlign.end,
                ),
                selected: state.locale?.countryCode == e.alpha2Code,
                selectedTileColor: Theme.of(context).selectedRowColor,
                onTap: () => _onTapCountry(context, e),
              ),
            )
            .toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Language'),
                  Text('Country'),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: ListView.separated(
                      key: const PageStorageKey('language_picker'),
                      controller: _languageController,
                      itemCount: languages.length,
                      itemBuilder: (context, index) => languages[index],
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        thickness: 1,
                      ),
                    ),
                  ),
                  const VerticalDivider(width: 1, thickness: 1),
                  Flexible(
                    child: ListView.separated(
                      key: const PageStorageKey('country_picker'),
                      controller: _countryController,
                      itemCount: countries.length,
                      itemBuilder: (context, index) => countries[index],
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        thickness: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context.dismissSheet(
                        result: _cubit(context).state.locale,
                      ),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
