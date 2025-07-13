import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';
import 'package:flutter_app/services/auth/auth_provider.dart';

@immutable
class AuthUser {
  final bool emailVerified;
  const AuthUser({required this.emailVerified});

  factory AuthUser.fromFirebase(User user) =>
      AuthUser(emailVerified: user.emailVerified);
}


