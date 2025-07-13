import 'package:flutter_app/services/auth/auth_user.dart';

abstract class AuthProvider {
  AuthUser? get currentUser;

  Future<void> initialize();

  Future<AuthUser> logIn({required String email, required String password});

  Future<AuthUser> register({required String email, required String password});

  Future<void> sendEmailVerification();

  Future<void> logOut();

  Future<void> sendPasswordReset({required String toEmail});
}
