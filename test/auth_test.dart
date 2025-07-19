import 'package:flutter_app/services/auth/auth_exceptions.dart';
import 'package:flutter_app/services/auth/auth_provider.dart';
import 'package:test/test.dart';
import 'package:flutter_app/services/auth/auth_user.dart';

void main() {
  late MockAuthProvider provider;

  setUp(() {
    provider = MockAuthProvider(); // Create fresh instance before each test
  });

  group('MockAuthProvider tests', () {
    test('should not be initialized to begin with', () {
      expect(provider.initialized, isFalse);
    });

    test('cannot logout without initialization', () {
      expect(() => provider.logOut(), throwsA(isA<NotInitializedException>()));
    });

    test('should be able to initialize', () async {
      await provider.initialize();
      expect(provider.initialized, isTrue);
    });

    test('user should be null after initialization', () async {
      await provider.initialize();
      expect(provider.currentUser, isNull);
    });

    test('should initialize in less than 2 seconds', () async {
      final start = DateTime.now();
      await provider.initialize();
      final end = DateTime.now();
      expect(end.difference(start).inSeconds, lessThan(2));
    });

    test('create user should delegate to logIn function', () async {
      await provider.initialize();

      expect(
        () => provider.register(email: 'foo@bar.com', password: 'anypassword'),
        throwsA(isA<UserNotFoundAuthException>()),
      );

      expect(
        () => provider.register(email: 'someone@bar.com', password: 'foonbar'),
        throwsA(isA<WrongPasswordAuthException>()),
      );

      final user = await provider.register(email: 'foo', password: 'bar');
      expect(provider.currentUser, equals(user));
      expect(user.emailVerified, isTrue);
    });

    test('logged user should be able to get verified', () async {
      await provider.initialize();
      await provider.register(email: 'foo', password: 'bar');
      await provider.sendEmailVerification();

      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.emailVerified, isTrue);
    });

    test('should be able to logout and login again', () async {
      await provider.initialize();
      await provider.register(email: 'foo', password: 'bar');

      await provider.logOut();
      expect(provider.currentUser, isNull);

      final user = await provider.logIn(email: 'foo', password: 'bar');
      expect(provider.currentUser, equals(user));
    });

    test('calling password reset throws UnimplementedError', () {
      expect(
        () => provider.sendPasswordReset(toEmail: 'foo@bar.com'),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _initialized = false;
  bool get initialized => _initialized;

  @override
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
  }

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
  }) async {
    if (!initialized) throw NotInitializedException();
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
