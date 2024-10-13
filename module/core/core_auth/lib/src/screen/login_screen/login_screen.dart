import 'package:flutter/material.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';

import 'login_screen_cubit.dart';
import 'login_screen_state.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static Widget create({
    required ServiceLocator locator,
    String? onFinishPath,
  }) {
    return BlocProvider(
      create: (context) => LoginScreenCubit(
        loginAnonymously: locator(),
      ),
      child: const LoginScreen(),
    );
  }

  LoginScreenCubit _cubit(BuildContext context) => context.read();

  Widget _builder({
    required BlocWidgetBuilder<LoginScreenState> builder,
    BlocBuilderCondition<LoginScreenState>? buildWhen,
  }) {
    return BlocBuilder<LoginScreenCubit, LoginScreenState>(
      buildWhen: buildWhen,
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: Container()),
            _builder(
              builder: (context, state) => ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                onPressed: () => _cubit(context).loginAnonymously(),
                child: state.isLoading
                    ? const CircularProgressIndicator()
                    : Text(
                        'Login Anonymously',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
