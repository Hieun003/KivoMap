import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../app/assets/image_paths.dart';
import '../../../app/responsive/kivo_scale.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/kivo_theme_tokens.dart';
import '../view_model/auth_controller.dart';

class OtpVerificationView extends StatefulWidget {
  const OtpVerificationView({super.key});

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  final _otpController = TextEditingController();
  final _otpFocusNode = FocusNode();
  Timer? _timer;
  int _remainingSeconds = 60;

  AuthController get _auth => Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _startCountdown();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _otpFocusNode.requestFocus();
    });
  }

  void _startCountdown() {
    _timer?.cancel();
    _remainingSeconds = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() => _remainingSeconds = 0);
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: KivoColors.cream,
    body: SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          KivoScale.w(22),
          KivoScale.h(14),
          KivoScale.w(22),
          KivoScale.h(28),
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(KivoScale.r(16)),
                elevation: 2,
                child: IconButton(
                  onPressed: Get.back,
                  tooltip: 'Đổi số điện thoại',
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ),
            ),
            Image.asset(
              KivoImagePaths.kivoLogin,
              height: KivoScale.h(280),
              fit: BoxFit.contain,
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(KivoScale.w(24)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: KivoRadii.largeCard,
                border: Border.all(color: KivoColors.lightBorder),
                boxShadow: KivoShadows.soft,
              ),
              child: Column(
                children: [
                  Text(
                    'Xác thực OTP',
                    style: KivoTextStyles.screenTitle.copyWith(
                      color: KivoColors.inkText,
                      fontSize: KivoScale.sp(30, min: 24),
                    ),
                  ),
                  SizedBox(height: KivoScale.h(10)),
                  Text(
                    'Mã gồm 6 chữ số đã được gửi đến\n${_auth.maskedPendingPhone()}',
                    textAlign: TextAlign.center,
                    style: KivoTextStyles.body.copyWith(
                      color: KivoColors.secondaryText,
                    ),
                  ),
                  SizedBox(height: KivoScale.h(26)),
                  _OtpCodeField(
                    controller: _otpController,
                    focusNode: _otpFocusNode,
                    onChanged: (_) {
                      _auth.clearError();
                      setState(() {});
                    },
                    onComplete: _verifyCode,
                  ),
                  SizedBox(height: KivoScale.h(18)),
                  Text(
                    _remainingSeconds > 0
                        ? 'Có thể gửi lại mã sau ${_remainingSeconds}s'
                        : 'Bạn chưa nhận được mã?',
                    style: KivoTextStyles.caption,
                  ),
                  TextButton(
                    key: const ValueKey('auth-resend-otp'),
                    onPressed: _remainingSeconds == 0 && !_auth.isBusy.value
                        ? _resendCode
                        : null,
                    child: const Text('Gửi lại mã OTP'),
                  ),
                  Obx(() {
                    final error = _auth.errorMessage.value;
                    return Column(
                      children: [
                        if (error != null) ...[
                          SizedBox(height: KivoScale.h(6)),
                          Text(
                            error,
                            textAlign: TextAlign.center,
                            style: KivoTextStyles.caption.copyWith(
                              color: KivoColors.errorCoral,
                            ),
                          ),
                        ],
                        SizedBox(height: KivoScale.h(16)),
                        SizedBox(
                          width: double.infinity,
                          height: KivoScale.h(60),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: KivoGradients.cyanButton,
                              borderRadius: BorderRadius.circular(
                                KivoScale.r(18),
                              ),
                              boxShadow: KivoShadows.tealGlow,
                            ),
                            child: ElevatedButton(
                              key: const ValueKey('auth-verify-otp'),
                              onPressed: _auth.isBusy.value
                                  ? null
                                  : _verifyCode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                              ),
                              child: _auth.isBusy.value
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Text(
                                      'Xác thực',
                                      style: KivoTextStyles.body.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  SizedBox(height: KivoScale.h(10)),
                  TextButton(
                    onPressed: Get.back,
                    child: const Text('Đổi số điện thoại'),
                  ),
                ],
              ),
            ),
            SizedBox(height: KivoScale.h(22)),
            Text(
              'Không chia sẻ mã OTP với bất kỳ ai.',
              style: KivoTextStyles.caption,
            ),
          ],
        ),
      ),
    ),
  );

  Future<void> _verifyCode() async {
    _otpFocusNode.unfocus();
    try {
      final success = await _auth.verifyOtp(_otpController.text);
      if (success) Get.offAllNamed<void>(AppRoutes.root);
    } on Object {
      _otpFocusNode.requestFocus();
    }
  }

  Future<void> _resendCode() async {
    try {
      final success = await _auth.resendOtp();
      if (success && mounted) {
        _otpController.clear();
        _startCountdown();
        setState(() {});
      }
    } on Object {
      // AuthController exposes the user-facing error reactively.
    }
  }
}

class _OtpCodeField extends StatelessWidget {
  const _OtpCodeField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onComplete,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final code = controller.text;
    return Semantics(
      label: 'Mã OTP gồm 6 chữ số',
      textField: true,
      child: SizedBox(
        height: KivoScale.h(66),
        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                final isActive =
                    code.length == index || (code.length == 6 && index == 5);
                return AnimatedContainer(
                  duration: KivoDurations.fast,
                  width: KivoScale.w(66),
                  height: KivoScale.h(64),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: KivoColors.lightSurface,
                    borderRadius: BorderRadius.circular(KivoScale.r(15)),
                    border: Border.all(
                      color: isActive
                          ? KivoColors.actionCyan
                          : KivoColors.lightBorder,
                      width: isActive ? 1.8 : 1,
                    ),
                  ),
                  child: Text(
                    index < code.length ? code[index] : '',
                    style: KivoTextStyles.sectionTitle,
                  ),
                );
              }),
            ),
            Positioned.fill(
              child: Opacity(
                opacity: 0.01,
                child: TextField(
                  key: const ValueKey('auth-otp-field'),
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: TextInputType.number,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  maxLength: 6,
                  showCursor: false,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    onChanged(value);
                    if (value.length == 6) onComplete();
                  },
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
