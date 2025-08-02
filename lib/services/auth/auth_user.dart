import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';
import 'package:flutter_app/services/auth/auth_provider.dart';

@immutable
class AuthUser {
  final String id;
  final String? email;
  final bool emailVerified;
  const AuthUser({
    required this.email,
    required this.emailVerified,
    required this.id,
  });

  factory AuthUser.fromFirebase(User user) => AuthUser(
    email: user.email,
    emailVerified: user.emailVerified,
    id: user.uid,
  );
}
