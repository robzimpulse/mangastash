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
        loginUseCase: locator(),
        listenAuthUseCase: locator(),
        loginAnonymouslyUseCase: locator(),
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

  List<Widget> _content(BuildContext context, bool isLoading) {
    return [
      TextField(
        decoration: const InputDecoration(
          labelText: 'Email',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.email),
        ),
        onChanged: (value) => _cubit(context).update(
          email: value,
        ),
        onSubmitted: (value) => _cubit(context).update(
          email: value,
        ),
      ),
      const SizedBox(height: 8),
      TextField(
        obscureText: true,
        decoration: const InputDecoration(
          labelText: 'Password',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.password),
        ),
        onChanged: (value) => _cubit(context).update(
          password: value,
        ),
        onSubmitted: (value) => _cubit(context).update(
          password: value,
        ),
      ),
      const SizedBox(height: 8),
      _builder(
        buildWhen: (prev, curr) => prev.error != curr.error,
        builder: (context, state) {
          final error = state.error;
          return error != null
              ? Text(
                  error.toString(),
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: Colors.red),
                )
              : const SizedBox.shrink();
        },
      ),
      const SizedBox(height: 8),
      ElevatedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        onPressed: () => _cubit(context).login(),
        child:
            isLoading ? const CircularProgressIndicator() : const Text('Login'),
      ),
      const SizedBox(height: 16),
      Text(
        'Or Register with',
        style: Theme.of(context).textTheme.labelLarge,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 16),
      Wrap(
        runAlignment: WrapAlignment.center,
        children: [
          TextButton.icon(
            onPressed: null,
            icon: const Icon(Icons.facebook),
            label: Text(
              'Facebook',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          TextButton.icon(
            onPressed: null,
            icon: const Icon(Icons.g_mobiledata),
            label: Text(
              'Google',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          TextButton.icon(
            onPressed: null,
            icon: const Icon(Icons.apple),
            label: Text(
              'Apple',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          TextButton.icon(
            onPressed: () => _cubit(context).loginAnonymously(),
            icon: const Icon(Icons.person),
            label: Text(
              'Anonymous',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<LoginScreenCubit, LoginScreenState>(
          listenWhen: (prev, curr) {
            final isChanged = prev.authState != curr.authState;
            final isLoggedIn = curr.authState?.status == AuthStatus.loggedIn;
            return isChanged && isLoggedIn;
          },
          listener: (context, state) => context.pop(state.authState),
        ),
      ],
      child: _builder(
        buildWhen: (prev, curr) => prev.isLoading != curr.isLoading,
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
                children: _content(context, state.isLoading),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
