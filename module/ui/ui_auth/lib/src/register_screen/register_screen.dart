import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'register_cubit.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  static Widget create({
    required ServiceLocator locator,
  }) {
    return BlocProvider(
      create: (context) => RegisterCubit(),
      child: const RegisterScreen(),
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
