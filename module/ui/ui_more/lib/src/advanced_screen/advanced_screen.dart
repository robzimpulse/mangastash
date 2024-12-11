import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'advanced_screen_cubit.dart';
import 'advanced_screen_state.dart';

class AdvancedScreen extends StatelessWidget {
  const AdvancedScreen({
    super.key,
  });

  static Widget create({
    required ServiceLocator locator,
  }) {
    return BlocProvider(
      create: (_) => AdvancedScreenCubit(
        initialState: const AdvancedScreenState(),
      ),
      child: const AdvancedScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(
        title: const Text('Advanced Screen'),
      ),
      body: AdaptivePhysicListView(
        children: [
          ListTile(
            title: const Text('HTTP Inspector'),
            onTap: () => context.showSnackBar(
              message: '🚧🚧🚧 Under Construction 🚧🚧🚧',
            ),
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
