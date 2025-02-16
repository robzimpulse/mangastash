import 'package:core_route/core_route.dart';
import 'package:flutter/material.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';

import '../../enum/auth_status.dart';
import 'register_screen_cubit.dart';
import 'register_screen_state.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  static Widget create({
    required ServiceLocator locator,
  }) {
    return BlocProvider(
      create: (context) => RegisterScreenCubit(
        registerUseCase: locator(),
        listenAuthUseCase: locator(),
      ),
      child: const RegisterScreen(),
    );
  }

  RegisterScreenCubit _cubit(BuildContext context) => context.read();

  BlocBuilder _builder({
    required BlocWidgetBuilder<RegisterScreenState> builder,
    BlocBuilderCondition<RegisterScreenState>? buildWhen,
  }) {
    return BlocBuilder<RegisterScreenCubit, RegisterScreenState>(
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
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        onPressed: () => _cubit(context).registerWithEmail(),
        child: isLoading
            ? const CircularProgressIndicator()
            : const Text('Register'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<RegisterScreenCubit, RegisterScreenState>(
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
              title: const Text('Register Screen'),
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
