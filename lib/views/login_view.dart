import 'package:flutter/material.dart';
import 'package:flutter_app/services/auth/auth_exceptions.dart';
import 'package:flutter_app/services/auth/bloc/auth_bloc.dart';
import 'package:flutter_app/services/auth/bloc/auth_event.dart';
import 'package:flutter_app/services/auth/bloc/auth_state.dart';
import 'package:flutter_app/utilities/dialogs/error_dialog.dart';
import 'package:flutter_app/utilities/dialogs/loading_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  CloseDialog? _closeDialogHandle;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          final CloseDialog = _closeDialogHandle;
          if (!state.isLoading && CloseDialog != null) {
            CloseDialog();
            _closeDialogHandle = null;
          } else if (state.isLoading && CloseDialog == null) {
            _closeDialogHandle = showLoadingDialog(
              context: context,
              text: 'Loading...',
            );
          }
          if (state.exception is UserNotFoundAuthException) {
            await showErrorDialog(context, 'User not found.');
          } else if (state.exception is WrongPasswordAuthException) {
            await showErrorDialog(context, 'Wrong Credentials');
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, 'Authentication error.');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Login')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _email,
                decoration: const InputDecoration(hintText: 'enter your email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                  hintText: 'enter your password',
                ),
              ),
              const SizedBox(height: 18),
              TextButton(
                onPressed: () async {
                  final email = _email.text;
                  final password = _password.text;
                  context.read<AuthBloc>().add(AuthEventLogIn(email, password));
                },
                child: const Text('login'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed:
                    () => context.read<AuthBloc>().add(
                      const AuthEventShouldRegister(),
                    ),

                child: const Text('Not registered? Sign up here'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
