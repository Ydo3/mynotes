import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group('Mock Authentication', () {
    late MockAuthProvider provider;

    setUp(() {
      provider = MockAuthProvider();
    });

    test('should not be initialized to begin with', () {
      expect(provider.isInitialized, false);
    });

    test('can not log out if not initialized', () async {
      await expectLater(
        provider.logOut(),
        throwsA(isA<NotInitializedException>()),
      );
    });

    test('should be able to be initialized', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test('user should be null after initialization', () {
      expect(
        provider.currentUser,
        isNull,
      );
    });

    test(
      'should be initialize in lss than 2 seconds',
      () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      },
      timeout: const Timeout(Duration(seconds: 2)),
    );

    test(
      'create user should delegate to login function',
      () async {
        await provider.initialize();
        final badEmailUser = provider.createUser(
          email: 'foo@gmail.com',
          password: 'anypassword',
        );
        await expectLater(
          badEmailUser,
          throwsA(isA<UserNotFoundOrWrongPasswordAuthException>()),
        );

        final badPasswordUser = provider.createUser(
          email: 'someone@gmail.com',
          password: 'foobar',
        );
        await expectLater(
          badPasswordUser,
          throwsA(isA<UserNotFoundOrWrongPasswordAuthException>()),
        );

        final user = await provider.createUser(email: 'foo', password: 'bar');
        expect(provider.currentUser, user);
        expect(user.isEmailVerified, false);
      },
    );

    test('Logged in user should be able to get verified', () async {
      await provider.initialize();
      await provider.logIn(email: 'email', password: 'password');
      await provider.sendEmailVeification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test('should be able to logout and login again', () async {
      await provider.initialize();
      await provider.logIn(email: 'email', password: 'password');
      await provider.logOut();
      await provider.logIn(
        email: 'email',
        password: 'password',
      );
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;
  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) {
    if (!isInitialized) throw NotInitializedException();
    if (email == 'foo@gmail.com')
      throw UserNotFoundOrWrongPasswordAuthException();
    if (password == 'foobar') throw UserNotFoundOrWrongPasswordAuthException();
    const user = AuthUser(isEmailVerified: false);
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundOrWrongPasswordAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVeification() async {
    if (!isInitialized) throw {NotInitializedException};
    final user = _user;
    if (user == null) throw UserNotFoundOrWrongPasswordAuthException();
    const newUser = AuthUser(isEmailVerified: true);
    _user = newUser;
  }
}
