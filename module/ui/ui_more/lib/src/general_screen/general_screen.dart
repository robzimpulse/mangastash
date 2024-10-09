import 'package:core_environment/core_environment.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'general_screen_cubit.dart';
import 'general_screen_state.dart';

class GeneralScreen extends StatelessWidget {
  final Future<String?> Function()? onTapLanguageMenu;
  final Future<String?> Function()? onTapCountryMenu;

  const GeneralScreen({
    super.key,
    this.onTapLanguageMenu,
    this.onTapCountryMenu,
  });

  static Widget create({
    required ServiceLocator locator,
    Future<String?> Function()? onTapLanguageMenu,
    Future<String?> Function()? onTapCountryMenu,
  }) {
    return BlocProvider(
      create: (_) => GeneralScreenCubit(
        initialState: const GeneralScreenState(),
        updateLocaleUseCase: locator(),
        listenLocaleUseCase: locator(),
      ),
      child: GeneralScreen(
        onTapLanguageMenu: onTapLanguageMenu,
          onTapCountryMenu: onTapCountryMenu,
      ),
    );
  }

  GeneralScreenCubit _cubit(BuildContext context) => context.read();

  Widget _builder({
    required BlocWidgetBuilder<GeneralScreenState> builder,
    BlocBuilderCondition<GeneralScreenState>? buildWhen,
  }) {
    return BlocBuilder<GeneralScreenCubit, GeneralScreenState>(
      buildWhen: buildWhen,
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(
        title: const Text('General Screen'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _builder(
              buildWhen: (prev, curr) => prev.locale != curr.locale,
              builder: (_, state) => ListTile(
                title: const Text('Language'),
                trailing: Text('${state.locale?.language.name}'),
                leading: const SizedBox(
                  height: double.infinity,
                  child: Icon(Icons.translate),
                ),
                onTap: () async {
                  final result = await onTapLanguageMenu?.call();
                  if (result == null || !context.mounted) return;
                  _cubit(context).changeLanguage(result);
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _builder(
              buildWhen: (prev, curr) => prev.locale != curr.locale,
              builder: (_, state) => ListTile(
                title: const Text('Country'),
                trailing: Text('${state.locale?.country?.name}'),
                leading: const SizedBox(
                  height: double.infinity,
                  child: Icon(Icons.translate),
                ),
                onTap: () async {
                  final result = await onTapCountryMenu?.call();
                  if (result == null || !context.mounted) return;
                  _cubit(context).changeCountry(result);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
