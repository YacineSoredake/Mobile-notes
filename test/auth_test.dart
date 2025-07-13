import 'package:flutter_app/services/auth/auth_exceptions.dart';
import 'package:flutter_app/services/auth/auth_provider.dart';
import 'package:test/test.dart';
import 'package:flutter_app/services/auth/auth_user.dart';

void main() {}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _initialized = false;
  bool get initialized => _initialized;

  @override
  // TODO: implement currentUser
  AuthUser? get currentUser => _user;
  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _initialized = true;
  }

  @override
  Future<AuthUser> logIn({required String email, required String password}) {
    if (!initialized) throw NotInitializedException();
    if (email == "foo@bar.com") throw UserNotFoundAuthException();
    if (password == "foonbar") throw WrongPasswordAuthException();
    const user = AuthUser(emailVerified: true);
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
   if (!initialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
     await Future.delayed(const Duration(seconds: 1));
    _user = null;
    return Future.value();
  }

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
  }) async {
    if (!initialized) {
      throw NotInitializedException();
    }
    await Future.delayed(const Duration(seconds: 1));
    return logIn(email: email, password: password);
  }

  @override
  Future<void> sendEmailVerification() {
   if (!initialized) throw NotInitializedException();
   final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const verifiedUser = AuthUser(emailVerified: true);
    _user = verifiedUser;
    return Future.value();
  }

  @override
  Future<void> sendPasswordReset({required String toEmail}) { 
    throw UnimplementedError();
  }
}
