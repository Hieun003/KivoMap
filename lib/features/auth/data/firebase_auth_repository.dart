import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  bool _isInitialized = false;

  @override
  Stream<AuthUser?> get authStateChanges =>
      _firebaseAuth.authStateChanges().map(_mapUser);

  @override
  AuthUser? get currentUser => _mapUser(_firebaseAuth.currentUser);

  @override
  Future<void> initialize() async {}

  Future<void> _initializeGoogle() async {
    if (_isInitialized) return;
    await _googleSignIn.initialize();
    _isInitialized = true;
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    await _initializeGoogle();
    try {
      if (!_googleSignIn.supportsAuthenticate()) {
        throw const AuthFailure(
          'Thiết bị này chưa hỗ trợ đăng nhập Google trong ứng dụng.',
          code: 'google-not-supported',
        );
      }

      final googleUser = await _googleSignIn.authenticate();
      final idToken = googleUser.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const AuthFailure(
          'Google không trả về thông tin xác thực hợp lệ.',
          code: 'missing-google-id-token',
        );
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final result = await _firebaseAuth.signInWithCredential(credential);
      return _requireUser(result.user);
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthFailure(
          'Bạn đã hủy đăng nhập Google.',
          code: 'google-canceled',
        );
      }
      throw AuthFailure(
        'Không thể đăng nhập Google. Hãy thử lại.',
        code: error.code.name,
      );
    } on FirebaseAuthException catch (error) {
      throw _firebaseFailure(error);
    }
  }

  @override
  Future<PhoneCodeDelivery> sendPhoneCode(
    String phoneNumber, {
    int? forceResendingToken,
  }) async {
    final completer = Completer<PhoneCodeDelivery>();

    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      forceResendingToken: forceResendingToken,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (credential) async {
        try {
          final result = await _firebaseAuth.signInWithCredential(credential);
          if (!completer.isCompleted) {
            completer.complete(
              PhoneCodeDelivery.autoVerified(_requireUser(result.user)),
            );
          }
        } on FirebaseAuthException catch (error) {
          if (!completer.isCompleted) {
            completer.completeError(_firebaseFailure(error));
          }
        }
      },
      verificationFailed: (error) {
        if (!completer.isCompleted) {
          completer.completeError(_firebaseFailure(error));
        }
      },
      codeSent: (verificationId, resendToken) {
        if (!completer.isCompleted) {
          completer.complete(
            PhoneCodeDelivery.codeSent(
              verificationId: verificationId,
              resendToken: resendToken,
            ),
          );
        }
      },
      codeAutoRetrievalTimeout: (_) {},
    );

    return completer.future;
  }

  @override
  Future<AuthUser> verifySmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final result = await _firebaseAuth.signInWithCredential(credential);
      return _requireUser(result.user);
    } on FirebaseAuthException catch (error) {
      throw _firebaseFailure(error);
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    if (_isInitialized) {
      await _googleSignIn.signOut();
    }
  }

  AuthUser _requireUser(User? user) {
    final mapped = _mapUser(user);
    if (mapped == null) {
      throw const AuthFailure(
        'Không nhận được thông tin tài khoản.',
        code: 'missing-user',
      );
    }
    return mapped;
  }

  AuthUser? _mapUser(User? user) {
    if (user == null) return null;
    return AuthUser(
      uid: user.uid,
      displayName: user.displayName,
      email: user.email,
      phoneNumber: user.phoneNumber,
      photoUrl: user.photoURL,
    );
  }

  AuthFailure _firebaseFailure(FirebaseAuthException error) {
    final message = switch (error.code) {
      'invalid-phone-number' => 'Số điện thoại không hợp lệ.',
      'too-many-requests' =>
        'Bạn đã thử quá nhiều lần. Hãy đợi một lúc rồi thử lại.',
      'quota-exceeded' => 'Hệ thống đã đạt giới hạn gửi SMS hôm nay.',
      'invalid-verification-code' => 'Mã OTP không đúng. Hãy kiểm tra lại.',
      'session-expired' => 'Mã OTP đã hết hạn. Hãy gửi lại mã mới.',
      'network-request-failed' =>
        'Không có kết nối mạng. Hãy kiểm tra rồi thử lại.',
      'account-exists-with-different-credential' =>
        'Tài khoản này đã được liên kết với phương thức đăng nhập khác.',
      'user-disabled' => 'Tài khoản đã bị vô hiệu hóa.',
      _ => 'Không thể xác thực lúc này. Hãy thử lại.',
    };
    return AuthFailure(message, code: error.code);
  }
}
