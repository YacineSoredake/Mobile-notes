import 'package:flutter/material.dart';
import 'package:flutter_app/services/auth/auth_exceptions.dart';
import 'package:flutter_app/services/auth/bloc/auth_bloc.dart';
import 'package:flutter_app/services/auth/bloc/auth_event.dart';
import 'package:flutter_app/services/auth/bloc/auth_state.dart';
import 'package:flutter_app/utilities/dialogs/error_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

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
        if (state is AuthStateRegistering) {
          if (state.exception is WeakPasswordAuthException) {
            await showErrorDialog(context, "Weak password");
          } else if (state.exception is EmailAlreadyInUseAuthException ||
              state.exception is InvalidEmailAuthException) {
            await showErrorDialog(context, "Invalid email or already in use");
          } else {
            await showErrorDialog(
              context,
              "Error: ${state.exception.toString()}",
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Register')),
        body: Column(
          children: [
            TextField(
              controller: _email,
              decoration: InputDecoration(hintText: 'enter your email'),
            ),
            TextField(
              controller: _password,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: InputDecoration(hintText: 'enter your password'),
            ),
            TextButton(
              onPressed: () async {
                final email = _email.text;
                final password = _password.text;
                context.read<AuthBloc>().add(
                  AuthEventRegister(email, password),
                );
              },
              child: const Text('register'),
            ),
            TextButton(
              onPressed:
                  () => context.read<AuthBloc>().add(
                    const AuthEventLogOut()
                  ),
              child: const Text('already registered? Sign in here'),
            ),
          ],
        ),
      ),
    );
  }
}
