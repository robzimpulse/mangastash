import 'package:flutter/material.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';

import 'register_screen_cubit.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  static Widget create({
    required ServiceLocator locator,
  }) {
    return BlocProvider(
      create: (context) => RegisterScreenCubit(),
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
