import 'package:flutter/material.dart';
import 'package:flutter_app/constants/routes.dart';
import 'package:flutter_app/services/auth/auth_exceptions.dart';
import 'package:flutter_app/services/auth/auth_service.dart';

import 'package:flutter_app/utilities/show_error_dialog.dart';

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
    return Scaffold(
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
              try {
                await AuthService.firebase().register(
                  email: email,
                  password: password,
                );
                AuthService.firebase().sendEmailVerification();
                Navigator.of(context).pushNamed(VerifyEmailRoute);
              } on WeakPasswordAuthException {
                await showErrorDialog(context, "weak password");
              } on EmailAlreadyInUseAuthException {
                await showErrorDialog(context, "email already in use");
              } on InvalidEmailAuthException {
                await showErrorDialog(context, "invalid email");
              } on GenericAuthException catch (e) {
                await showErrorDialog(context, "error: ${e.toString()}");
              }
            },
            child: const Text('register'),
          ),
          TextButton(
            onPressed:
                (() => {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(LoginRoute, (route) => false),
                }),
            child: const Text('already registered? Sign in here'),
          ),
        ],
      ),
    );
  }
}
