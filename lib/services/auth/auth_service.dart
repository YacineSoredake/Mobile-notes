import 'package:flutter_app/services/auth/auth_provider.dart';
import 'package:flutter_app/services/auth/auth_user.dart';

class AuthService implements AuthProvider {
 final AuthProvider provider; 
 const AuthService(this.provider);
 
  @override
  AuthUser? get currentUser => provider.currentUser;
 
  @override
  Future<AuthUser> initialize() {
    // TODO: implement initialize
    throw UnimplementedError();
  }
 
  @override
  Future<AuthUser> logIn({required String email, required String password}) => provider.logIn(email: email, password: password);
 
  @override
  Future<void> logOut() => provider.logOut();
 
  @override
  Future<AuthUser> register({required String email, required String password}) => provider.register(email: email, password: password);
 
  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();
 
  @override
  Future<void> sendPasswordReset({required String toEmail}) {
    // TODO: implement sendPasswordReset
    throw UnimplementedError();
  }
}
