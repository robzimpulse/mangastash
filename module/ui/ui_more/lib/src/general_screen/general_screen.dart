import 'package:core_environment/core_environment.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'general_screen_cubit.dart';
import 'general_screen_state.dart';

class GeneralScreen extends StatelessWidget {
  const GeneralScreen({
    super.key,
  });

  static Widget create({
    required ServiceLocator locator,
  }) {
    return BlocProvider(
      create: (_) => GeneralScreenCubit(
        initialState: const GeneralScreenState(),
      ),
      child: const GeneralScreen(),
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
      body: const CustomScrollView(
        slivers: [
          // SliverToBoxAdapter(
          //   child: _builder(
          //     buildWhen: (prev, curr) => prev.locale != curr.locale,
          //     builder: (_, state) => ListTile(
          //       title: const Text('Language'),
          //       trailing: Text('${state.locale?.language.name}'),
          //       leading: const SizedBox(
          //         height: double.infinity,
          //         child: Icon(Icons.translate),
          //       ),
          //       // onTap: () => _showLanguagePicker(context, state),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  // Widget _buildLanguageMenu(BuildContext context) {
  //   return _builder(
  //     buildWhen: (prev, curr) => prev.locale != curr.locale,
  //     builder: (_, state) => ListTile(
  //       title: const Text('Language'),
  //       trailing: Text('${state.locale?.language.name}'),
  //       leading: const SizedBox(
  //         height: double.infinity,
  //         child: Icon(Icons.translate),
  //       ),
  //       onTap: () => _showLanguagePicker(context, state),
  //     ),
  //   );
  // }
  //
  // void _showLanguagePicker(
  //     BuildContext context,
  //     SettingScreenState state,
  //     ) async {
  //   final result = await context.showBottomSheet<String>(
  //     builder: (context) => PickerBottomSheet(
  //       names: Language.sorted.map((e) => e.name).toList(),
  //     ),
  //   );
  //   if (result == null || !context.mounted) return;
  //   _cubit(context).changeLanguage(result);
  // }
}
