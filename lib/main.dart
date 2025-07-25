import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/constants/routes.dart';
import 'package:flutter_app/firebase_options.dart';
import 'package:flutter_app/services/auth/auth_service.dart';
import 'package:flutter_app/views/login_view.dart';
import 'package:flutter_app/views/notes/notes_views.dart';
import 'package:flutter_app/views/register_view.dart';
import 'package:flutter_app/views/verifyEmail_view.dart';
import 'package:flutter_app/views/notes/new_note.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 7, 136, 26),
        ),
      ),
      home: const HomePage(),
      routes: {
        LoginRoute: (context) => const LoginView(),
        RegisterRoute: (context) => const RegisterView(),
        NotesRoute: (context) => const NotesView(),
        VerifyEmailRoute: (context) => const EmailVerifyView(),
        newNoteRoute: (context) => const NewNoteView(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.firebase().currentUser;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (user == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginView()),
        );
      } else if (!user.emailVerified) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const EmailVerifyView()),
        );
      } else {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(NotesRoute, (route) => false);
      }
    });

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}




