import 'package:core_network/core_network.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'advanced_screen_cubit.dart';
import 'advanced_screen_state.dart';

class AdvancedScreen extends StatelessWidget {

  final Alice alice;

  const AdvancedScreen({
    super.key,
    required this.alice
  });

  static Widget create({
    required ServiceLocator locator,
  }) {
    return BlocProvider(
      create: (_) => AdvancedScreenCubit(
        initialState: const AdvancedScreenState(),
      ),
      child: AdvancedScreen(
        alice: locator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(
        title: const Text('Advanced Screen'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('HTTP Inspector'),
            onTap: () => alice.showInspector(),
            leading: const SizedBox(
              height: double.infinity,
              child: Icon(Icons.http),
            ),
          )
        ],
      ),
    );
  }
}
