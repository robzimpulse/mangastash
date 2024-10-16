import 'package:core_route/core_route.dart';
import 'package:flutter/material.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';

import '../../../core_auth.dart';
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
        listenAuthUseCase: locator(),
        logoutUseCase: locator(),
      ),
      child: const LoginScreen(),
    );
  }

  LoginScreenCubit _cubit(BuildContext context) => context.read();

  Widget _consumer({
    required BlocWidgetBuilder<LoginScreenState> builder,
    BlocBuilderCondition<LoginScreenState>? buildWhen,
    required BlocWidgetListener<LoginScreenState> listener,
    BlocListenerCondition<LoginScreenState>? listenWhen,
  }) {
    return BlocConsumer<LoginScreenCubit, LoginScreenState>(
      buildWhen: buildWhen,
      builder: builder,
      listenWhen: listenWhen,
      listener: listener,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _consumer(
      listenWhen: (prev, curr) {
        final isChanged = prev.authState != curr.authState;
        final isLoggedIn = curr.authState?.status == AuthStatus.loggedIn;
        return isChanged && isLoggedIn;
      },
      listener: (context, state) => context.pop(state.authState),
      builder: (context, state) => PopScope(
        canPop: !state.isLoading,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Login Screen'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Center(
                    child: Text(state.toString()),
                  ),
                ),
                ElevatedButton(
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
                      : const Text('Login Anonymously'),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  onPressed: () => _cubit(context).logout(),
                  child: const Text('Logout'),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  onPressed: () => context.pop(state.authState),
                  child: const Text('Back'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
