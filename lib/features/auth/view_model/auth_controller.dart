import 'dart:async';
import 'dart:developer' as developer;

import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/database_engine_service.dart';
import '../../../data/user_profile_service.dart';
import '../../../data/user_session_scope_service.dart';
import '../data/auth_repository.dart';

class AuthController extends GetxController {
  AuthController({
    required AuthRepository repository,
    DatabaseEngineService? databaseEngine,
    UserProfileService? profileService,
    UserSessionScopeService? sessionScope,
  }) : _repository = repository,
       _databaseEngine = databaseEngine,
       _profileService = profileService ?? UserProfileService(),
       _sessionScope = sessionScope ?? UserSessionScopeService();

  final AuthRepository _repository;
  final DatabaseEngineService? _databaseEngine;
  final UserProfileService _profileService;
  final UserSessionScopeService _sessionScope;

  final Rxn<AuthUser> user = Rxn<AuthUser>();
  final RxBool isReady = false.obs;
  final RxBool isBusy = false.obs;
  final RxnString errorMessage = RxnString();

  StreamSubscription<AuthUser?>? _authSubscription;
  String? _verificationId;
  int? _resendToken;
  String? _pendingPhoneNumber;

  String? get pendingPhoneNumber => _pendingPhoneNumber;
  bool get hasPendingVerification => _verificationId != null;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _repository.initialize();
      _authSubscription = _repository.authStateChanges.listen(
        _handleAuthState,
        onError: (Object error, StackTrace stackTrace) {
          developer.log(
            'Authentication state failed.',
            name: 'KivoMap.Auth',
            error: error,
            stackTrace: stackTrace,
          );
          isReady.value = true;
        },
      );
    } on Object catch (error, stackTrace) {
      developer.log(
        'Authentication initialization failed.',
        name: 'KivoMap.Auth',
        error: error,
        stackTrace: stackTrace,
      );
      errorMessage.value = 'Không thể khởi tạo đăng nhập.';
      isReady.value = true;
    }
  }

  Future<void> _handleAuthState(AuthUser? nextUser) async {
    isReady.value = false;
    _sessionScope.bind(nextUser?.uid);
    user.value = nextUser;
    if (nextUser != null) {
      await _bootstrapUser(nextUser);
    }
    isReady.value = true;
  }

  Future<void> _bootstrapUser(AuthUser authUser) async {
    try {
      final databaseEngine = _databaseEngine ?? DatabaseEngineService();
      await databaseEngine.activateUserRuntimeEnvironment(
        userId: authUser.uid,
        name: authUser.displayName?.trim().isNotEmpty == true
            ? authUser.displayName!.trim()
            : 'Người học Kivo',
        email: authUser.email ?? '',
        phoneNumber: authUser.phoneNumber,
      );
      await _profileService.bindAuthenticatedUser(
        uid: authUser.uid,
        displayName: authUser.displayName,
        email: authUser.email,
        phoneNumber: authUser.phoneNumber,
      );
    } on Object catch (error, stackTrace) {
      developer.log(
        'User bootstrap failed.',
        name: 'KivoMap.Auth',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<bool> signInWithGoogle() async {
    return _runAuthAction(() async {
      await _repository.signInWithGoogle();
      return true;
    });
  }

  Future<PhoneCodeStatus?> sendPhoneCode(String rawPhoneNumber) async {
    final normalized = normalizeVietnamPhoneNumber(rawPhoneNumber);
    if (normalized == null) {
      errorMessage.value = 'Nhập số điện thoại Việt Nam hợp lệ.';
      return null;
    }

    return _runAuthAction(() async {
      final delivery = await _repository.sendPhoneCode(normalized);
      _pendingPhoneNumber = normalized;
      if (delivery.isAutoVerified) {
        return PhoneCodeStatus.autoVerified;
      }
      _verificationId = delivery.verificationId;
      _resendToken = delivery.resendToken;
      return PhoneCodeStatus.codeSent;
    });
  }

  Future<bool> verifyOtp(String code) async {
    if (code.length != 6 || int.tryParse(code) == null) {
      errorMessage.value = 'Nhập đủ 6 chữ số của mã OTP.';
      return false;
    }
    final verificationId = _verificationId;
    if (verificationId == null) {
      errorMessage.value = 'Phiên xác thực không còn hiệu lực. Hãy gửi lại mã.';
      return false;
    }

    return _runAuthAction(() async {
      await _repository.verifySmsCode(
        verificationId: verificationId,
        smsCode: code,
      );
      _clearPendingVerification();
      return true;
    });
  }

  Future<bool> resendOtp() async {
    final phone = _pendingPhoneNumber;
    if (phone == null) {
      errorMessage.value = 'Không tìm thấy số điện thoại cần xác thực.';
      return false;
    }

    return _runAuthAction(() async {
      final delivery = await _repository.sendPhoneCode(
        phone,
        forceResendingToken: _resendToken,
      );
      if (delivery.isAutoVerified) {
        _clearPendingVerification();
        Get.offAllNamed<void>(AppRoutes.root);
        return true;
      }
      _verificationId = delivery.verificationId;
      _resendToken = delivery.resendToken;
      return true;
    });
  }

  Future<void> signOut() async {
    await _runAuthAction(() async {
      await _repository.signOut();
      _profileService.resetToGuest();
      _clearPendingVerification();
      return true;
    });
    Get.offAllNamed<void>(AppRoutes.root);
  }

  void clearError() => errorMessage.value = null;

  String? normalizeVietnamPhoneNumber(String input) {
    var digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('84')) {
      digits = digits.substring(2);
    } else if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    if (digits.length != 9 || !digits.startsWith(RegExp(r'[35789]'))) {
      return null;
    }
    return '+84$digits';
  }

  String maskedPendingPhone() {
    final phone = _pendingPhoneNumber;
    if (phone == null || phone.length < 7) return '';
    return '${phone.substring(0, 5)} *** ${phone.substring(phone.length - 3)}';
  }

  Future<T> _runAuthAction<T>(Future<T> Function() action) async {
    isBusy.value = true;
    errorMessage.value = null;
    try {
      return await action();
    } on AuthFailure catch (error) {
      errorMessage.value = error.message;
      rethrow;
    } finally {
      isBusy.value = false;
    }
  }

  void _clearPendingVerification() {
    _verificationId = null;
    _resendToken = null;
    _pendingPhoneNumber = null;
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }
}

enum PhoneCodeStatus { codeSent, autoVerified }
