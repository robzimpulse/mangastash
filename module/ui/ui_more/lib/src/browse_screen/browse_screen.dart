import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'browse_screen_cubit.dart';
import 'browse_screen_state.dart';

class BrowseScreen extends StatelessWidget {
  const BrowseScreen({
    super.key,
  });

  static Widget create({
    required ServiceLocator locator,
  }) {
    return const BrowseScreen();
  }

  BrowseScreenCubit _cubit(BuildContext context) => context.read();

  BlocBuilder _builder({
    required BlocWidgetBuilder<BrowseScreenState> builder,
    BlocBuilderCondition<BrowseScreenState>? buildWhen,
  }) {
    return BlocBuilder<BrowseScreenCubit, BrowseScreenState>(
      buildWhen: buildWhen,
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(
        title: const Text('Browse Screen'),
      ),
      body: AdaptivePhysicListView(
        children: [
          ListTile(
            title: const Text('Search Manga Options'),
            subtitle: const Text('Global Filter for Browsing Manga'),
            leading: const Icon(Icons.filter_list),
            onTap: () => context.showSnackBar(
              message: '🚧🚧🚧 Under Construction 🚧🚧🚧',
            ),
          ),
        ],
      ),
    );
  }
}
