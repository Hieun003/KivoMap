import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../app/assets/image_paths.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/kivo_theme_tokens.dart';
import '../view_model/auth_controller.dart';

class AuthEntryView extends StatefulWidget {
  const AuthEntryView({super.key});

  @override
  State<AuthEntryView> createState() => _AuthEntryViewState();
}

class _AuthEntryViewState extends State<AuthEntryView> {
  AuthController get _auth => Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: KivoColors.cream,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: KivoColors.cream,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: KivoColors.cream,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 760;
              final horizontalPadding = constraints.maxWidth < 380
                  ? 18.0
                  : 24.0;
              final mascotHeight = compact ? 190.0 : 270.0;

              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  compact ? 16 : 26,
                  horizontalPadding,
                  24,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: math.max(
                      0,
                      constraints.maxHeight - (compact ? 40 : 50),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Kivo Language',
                        textAlign: TextAlign.center,
                        style: KivoTextStyles.display.copyWith(
                          color: KivoColors.inkText,
                          fontSize: constraints.maxWidth < 380 ? 34 : 40,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Khám phá tiếng Anh qua\nbối cảnh thực tế cùng Kivo!',
                        textAlign: TextAlign.center,
                        style: KivoTextStyles.body.copyWith(
                          color: KivoColors.secondaryText,
                          fontSize: 17,
                          height: 1.42,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: compact ? 8 : 14),
                      SizedBox(
                        height: mascotHeight,
                        width: double.infinity,
                        child: Image.asset(
                          KivoImagePaths.kivoLogin,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: compact ? 8 : 14),
                      _LoginCard(
                        auth: _auth,
                        onGoogle: _signInWithGoogle,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Điều khoản dịch vụ & Chính sách bảo mật',
                        textAlign: TextAlign.center,
                        style: KivoTextStyles.caption.copyWith(
                          color: KivoColors.secondaryText,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    try {
      final success = await _auth.signInWithGoogle();
      if (success) Get.offAllNamed<void>(AppRoutes.root);
    } on Object {
      // AuthController exposes the user-facing error reactively.
    }
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.auth,
    required this.onGoogle,
  });

  final AuthController auth;
  final VoidCallback onGoogle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: KivoColors.lightBorder),
        boxShadow: KivoShadows.soft,
      ),
      child: Column(
        children: [
          Text(
            'Chào mừng bạn!',
            textAlign: TextAlign.center,
            style: KivoTextStyles.screenTitle.copyWith(
              color: KivoColors.inkText,
              fontSize: 27,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Đăng nhập hoặc tạo tài khoản nhanh chóng chỉ với một chạm',
            textAlign: TextAlign.center,
            style: KivoTextStyles.body.copyWith(
              color: KivoColors.secondaryText,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          Obx(() {
            final error = auth.errorMessage.value;
            return Column(
              children: [
                _GoogleAuthButton(
                  isLoading: auth.isBusy.value,
                  onPressed: auth.isBusy.value ? null : onGoogle,
                ),
                if (error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: KivoColors.errorCoral.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      error,
                      textAlign: TextAlign.center,
                      style: KivoTextStyles.caption.copyWith(
                        color: KivoColors.errorCoral,
                      ),
                    ),
                  ),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _GoogleAuthButton extends StatelessWidget {
  const _GoogleAuthButton({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: OutlinedButton(
        key: const ValueKey('auth-google-button'),
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: KivoColors.inkText,
          side: const BorderSide(color: KivoColors.lightBorder, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: KivoColors.kivoTeal,
                ),
              )
            else
              const CustomPaint(
                size: Size.square(24),
                painter: _GoogleMarkPainter(),
              ),
            const SizedBox(width: 12),
            Text(
              'Tiếp tục với Google',
              style: KivoTextStyles.body.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleMarkPainter extends CustomPainter {
  const _GoogleMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(2.5);
    const strokeWidth = 4.5;

    void drawArc(Color color, double start, double sweep) {
      canvas.drawArc(
        arcRect,
        start,
        sweep,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.butt,
      );
    }

    drawArc(const Color(0xFF4285F4), -0.75, 1.55);
    drawArc(const Color(0xFF34A853), 0.80, 1.25);
    drawArc(const Color(0xFFFBBC05), 2.05, 1.05);
    drawArc(const Color(0xFFEA4335), 3.10, 1.45);

    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.square;
    canvas.drawLine(
      Offset(size.width * 0.52, size.height * 0.52),
      Offset(size.width * 0.92, size.height * 0.52),
      bluePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
