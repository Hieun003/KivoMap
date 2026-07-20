import 'package:flutter_test/flutter_test.dart';
import 'package:kivo_map/features/auth/data/auth_repository.dart';
import 'package:kivo_map/features/auth/view_model/auth_controller.dart';

void main() {
  late AuthController controller;

  setUp(() {
    controller = AuthController(repository: _FakeAuthRepository());
  });

  test('normalizes common Vietnamese phone formats to E.164', () {
    expect(
      controller.normalizeVietnamPhoneNumber('0912 345 678'),
      '+84912345678',
    );
    expect(
      controller.normalizeVietnamPhoneNumber('+84 912 345 678'),
      '+84912345678',
    );
    expect(
      controller.normalizeVietnamPhoneNumber('84-912-345-678'),
      '+84912345678',
    );
  });

  test('rejects invalid Vietnamese mobile numbers', () {
    expect(controller.normalizeVietnamPhoneNumber('0123'), isNull);
    expect(controller.normalizeVietnamPhoneNumber('0212345678'), isNull);
    expect(controller.normalizeVietnamPhoneNumber(''), isNull);
  });

  test('does not call Firebase when the phone number is invalid', () async {
    final result = await controller.sendPhoneCode('123');

    expect(result, isNull);
    expect(controller.errorMessage.value, isNotNull);
  });
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Stream<AuthUser?> get authStateChanges => Stream<AuthUser?>.empty();

  @override
  AuthUser? get currentUser => null;

  @override
  Future<void> initialize() async {}

  @override
  Future<PhoneCodeDelivery> sendPhoneCode(
    String phoneNumber, {
    int? forceResendingToken,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AuthUser> signInWithGoogle() {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<AuthUser> verifySmsCode({
    required String verificationId,
    required String smsCode,
  }) {
    throw UnimplementedError();
  }
}
