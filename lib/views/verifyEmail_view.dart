import 'package:flutter/material.dart';
import 'package:flutter_app/services/auth/bloc/auth_bloc.dart';
import 'package:flutter_app/services/auth/bloc/auth_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmailVerifyView extends StatefulWidget {
  const EmailVerifyView({super.key});

  @override
  State<EmailVerifyView> createState() => _EmailVerifyViewState();
}

class _EmailVerifyViewState extends State<EmailVerifyView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "We've sent you an email verification. Please check your email inbox.",
            ),
            const Text(
              "If you didn't receive an email verification. Please click here.",
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                context.read<AuthBloc>().add(
                  const AuthEventSendEmailVerfication(),
                );
              },
              child: const Text("Send Email Verification"),
            ),
            TextButton(
              onPressed: () async {
                context.read<AuthBloc>().add(const AuthEventLogOut());
              },
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}
