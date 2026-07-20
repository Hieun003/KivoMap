class AuthUser {
  const AuthUser({
    required this.uid,
    this.displayName,
    this.email,
    this.phoneNumber,
    this.photoUrl,
  });

  final String uid;
  final String? displayName;
  final String? email;
  final String? phoneNumber;
  final String? photoUrl;
}

class PhoneCodeDelivery {
  const PhoneCodeDelivery.codeSent({
    required this.verificationId,
    this.resendToken,
  }) : autoVerifiedUser = null;

  const PhoneCodeDelivery.autoVerified(this.autoVerifiedUser)
    : verificationId = null,
      resendToken = null;

  final String? verificationId;
  final int? resendToken;
  final AuthUser? autoVerifiedUser;

  bool get isAutoVerified => autoVerifiedUser != null;
}

class AuthFailure implements Exception {
  const AuthFailure(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

abstract interface class AuthRepository {
  Stream<AuthUser?> get authStateChanges;
  AuthUser? get currentUser;

  Future<void> initialize();
  Future<AuthUser> signInWithGoogle();
  Future<PhoneCodeDelivery> sendPhoneCode(
    String phoneNumber, {
    int? forceResendingToken,
  });
  Future<AuthUser> verifySmsCode({
    required String verificationId,
    required String smsCode,
  });
  Future<void> signOut();
}
