import 'package:flutter/material.dart';
import 'package:flutter_app/constants/routes.dart';
import 'package:flutter_app/services/auth/auth_service.dart';

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
                await AuthService.firebase().sendEmailVerification();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Verification email sent")),
                );
              },
              child: const Text("Send Email Verification"),
            ),
            TextButton(
              onPressed: () async {
                await AuthService.firebase().logOut();
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(RegisterRoute, (route) => false);
              },
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}
