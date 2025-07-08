import 'package:flutter/material.dart';
import 'package:flutter_app/constants/routes.dart';
import 'package:flutter_app/services/auth/auth_exceptions.dart';
import 'package:flutter_app/services/auth/auth_service.dart';
import 'package:flutter_app/utilities/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
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
              try {
                await AuthService.firebase().logIn(
                  email: email,
                  password: password,
                );
                final user = AuthService.firebase().currentUser;
                if (user?.emailVerified ?? false) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(NotesRoute, (route) => false);
                } else {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(VerifyEmailRoute, (route) => false);
                }
              } on UserNotFoundAuthException {
                await showErrorDialog(
                  context,
                  'User not found. Please register first.',
                );
              } on WrongPasswordAuthException {
                await showErrorDialog(
                  context,
                  'Wrong password. Please try again.',
                );
              } on InvalidEmailAuthException {
                await showErrorDialog(
                  context,
                  'Invalid email. Please try again.',
                );
              } on GenericAuthException {
                await showErrorDialog(
                  context,
                  'Authentication error. Please try again later.',
                );
              }
            },
            child: const Text('login'),
          ),

          TextButton(
            onPressed:
                (() => {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(RegisterRoute, (route) => false),
                }),
            child: const Text('Not registered? Sign up here'),
          ),
        ],
      ),
    );
  }
}
