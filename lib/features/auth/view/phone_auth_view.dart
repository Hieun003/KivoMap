import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../app/assets/image_paths.dart';
import '../../../app/responsive/kivo_scale.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/kivo_theme_tokens.dart';
import '../view_model/auth_controller.dart';

class PhoneAuthView extends StatefulWidget {
  const PhoneAuthView({super.key});

  @override
  State<PhoneAuthView> createState() => _PhoneAuthViewState();
}

class _PhoneAuthViewState extends State<PhoneAuthView> {
  final _phoneController = TextEditingController();
  final _focusNode = FocusNode();

  AuthController get _auth => Get.find<AuthController>();

  @override
  void dispose() {
    _phoneController.dispose();
    _focusNode.dispose();
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
              child: _BackButton(onPressed: Get.back),
            ),
            Image.asset(
              KivoImagePaths.kivoLogin,
              height: KivoScale.h(300),
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
                    'Số điện thoại của bạn',
                    textAlign: TextAlign.center,
                    style: KivoTextStyles.screenTitle.copyWith(
                      color: KivoColors.inkText,
                      fontSize: KivoScale.sp(28, min: 23),
                    ),
                  ),
                  SizedBox(height: KivoScale.h(10)),
                  Text(
                    'Kivo sẽ gửi một mã OTP để xác thực.\nBạn không cần tạo mật khẩu.',
                    textAlign: TextAlign.center,
                    style: KivoTextStyles.body.copyWith(
                      color: KivoColors.secondaryText,
                    ),
                  ),
                  SizedBox(height: KivoScale.h(26)),
                  TextField(
                    key: const ValueKey('auth-phone-field'),
                    controller: _phoneController,
                    focusNode: _focusNode,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.telephoneNumber],
                    inputFormatters: [_VietnamPhoneInputFormatter()],
                    onChanged: (_) => _auth.clearError(),
                    onSubmitted: (_) => _sendCode(),
                    style: KivoTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      hintText: '0912 345 678',
                      prefixIcon: const Icon(
                        Icons.phone_rounded,
                        color: KivoColors.kivoTeal,
                      ),
                      prefixText: '+84  ',
                      prefixStyle: KivoTextStyles.body.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      filled: true,
                      fillColor: KivoColors.lightSurface,
                      border: _inputBorder(),
                      enabledBorder: _inputBorder(),
                      focusedBorder: _inputBorder(
                        color: KivoColors.actionCyan,
                        width: 1.8,
                      ),
                    ),
                  ),
                  SizedBox(height: KivoScale.h(12)),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Dùng số điện thoại Việt Nam đang hoạt động.',
                      style: KivoTextStyles.caption,
                    ),
                  ),
                  Obx(() {
                    final error = _auth.errorMessage.value;
                    return Column(
                      children: [
                        if (error != null) ...[
                          SizedBox(height: KivoScale.h(12)),
                          Text(
                            error,
                            textAlign: TextAlign.center,
                            style: KivoTextStyles.caption.copyWith(
                              color: KivoColors.errorCoral,
                            ),
                          ),
                        ],
                        SizedBox(height: KivoScale.h(24)),
                        _SubmitButton(
                          label: 'Gửi mã OTP',
                          isLoading: _auth.isBusy.value,
                          onPressed: _auth.isBusy.value ? null : _sendCode,
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            SizedBox(height: KivoScale.h(22)),
            Text(
              'Số điện thoại chỉ được dùng để xác thực và bảo vệ tài khoản.',
              textAlign: TextAlign.center,
              style: KivoTextStyles.caption,
            ),
          ],
        ),
      ),
    ),
  );

  Future<void> _sendCode() async {
    _focusNode.unfocus();
    try {
      final status = await _auth.sendPhoneCode(_phoneController.text);
      if (!mounted || status == null) return;
      if (status == PhoneCodeStatus.autoVerified) {
        Get.offAllNamed<void>(AppRoutes.root);
      } else {
        Get.toNamed<void>(AppRoutes.authOtp);
      }
    } on Object {
      // AuthController exposes the user-facing error reactively.
    }
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(KivoScale.r(16)),
    elevation: 2,
    child: IconButton(
      key: const ValueKey('auth-back-button'),
      onPressed: onPressed,
      tooltip: 'Quay lại',
      icon: const Icon(Icons.arrow_back_rounded),
    ),
  );
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: KivoScale.h(60),
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: KivoGradients.cyanButton,
        borderRadius: BorderRadius.circular(KivoScale.r(18)),
        boxShadow: KivoShadows.tealGlow,
      ),
      child: ElevatedButton(
        key: const ValueKey('auth-submit-phone'),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KivoScale.r(18)),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                label,
                style: KivoTextStyles.body.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    ),
  );
}

OutlineInputBorder _inputBorder({
  Color color = KivoColors.lightBorder,
  double width = 1,
}) => OutlineInputBorder(
  borderRadius: BorderRadius.circular(KivoScale.r(18)),
  borderSide: BorderSide(color: color, width: width),
);

class _VietnamPhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('84') && digits.length > 9) {
      digits = digits.substring(2);
    }
    if (digits.startsWith('0') && digits.length > 1) {
      digits = digits.substring(1);
    }
    if (digits.length > 9) digits = digits.substring(0, 9);

    final groups = <String>[];
    for (var index = 0; index < digits.length; index += 3) {
      final end = (index + 3).clamp(0, digits.length);
      groups.add(digits.substring(index, end));
    }
    final formatted = groups.join(' ');
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
