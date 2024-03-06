import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'login_cubit.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static Widget create({
    required ServiceLocator locator,
  }) {
    return BlocProvider(
      create: (context) => LoginCubit(),
      child: const LoginScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🚧🚧🚧 Under Construction 🚧🚧🚧'),
      ),
      body: Container(),
    );
  }
}
