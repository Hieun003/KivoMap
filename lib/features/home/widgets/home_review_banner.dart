import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/assets/image_paths.dart';
import '../../../app/responsive/kivo_scale.dart';
import '../../../app/theme/kivo_theme_tokens.dart';
import '../view_model/home_view_state.dart';

class HomeReviewBanner extends StatelessWidget {
  const HomeReviewBanner({
    super.key,
    required this.status,
    this.onStartLearning,
    this.onStartReview,
  });

  final HomeReviewBannerStatus status;
  final VoidCallback? onStartLearning;
  final VoidCallback? onStartReview;

  @override
  Widget build(BuildContext context) {
    final content = _HomeReviewBannerContent.fromStatus(status);
    final effectiveCallback = switch (status) {
      HomeReviewBannerStatus.noWords => onStartLearning,
      HomeReviewBannerStatus.noDueReview => null,
      HomeReviewBannerStatus.reviewDue => onStartReview,
    };

    return SizedBox(
      height: KivoScale.w(470),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            top: KivoScale.w(18),
            child: Container(
              decoration: BoxDecoration(
                gradient: content.gradient,
                borderRadius: BorderRadius.circular(KivoScale.r(30)),
                border: Border.all(
                  color: content.borderColor.withAlpha(78),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: KivoColors.tealShadow.withAlpha(18),
                    blurRadius: KivoScale.r(22),
                    offset: Offset(0, KivoScale.h(9)),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: KivoScale.w(16),
            top: KivoScale.h(-6),
            bottom: KivoScale.w(18),
            width: KivoScale.w(252),
            child: _BannerIllustration(
              imagePath: content.imagePath,
              isMuted: !content.isButtonEnabled,
            ),
          ),
          Positioned(
            left: KivoScale.w(286),
            right: KivoScale.w(24),
            top: KivoScale.w(48),
            bottom: KivoScale.w(32),
            child: _BannerCopy(content: content, onPressed: effectiveCallback),
          ),
        ],
      ),
    );
  }
}

class _BannerIllustration extends StatelessWidget {
  const _BannerIllustration({required this.imagePath, required this.isMuted});

  final String imagePath;
  final bool isMuted;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: KivoScale.w(28),
          top: KivoScale.w(64),
          child: _LightBurst(
            size: KivoScale.w(38),
            opacity: isMuted ? 0.18 : 0.72,
          ),
        ),
        Positioned(
          right: KivoScale.w(20),
          top: KivoScale.w(86),
          child: _LightBurst(
            size: KivoScale.w(32),
            opacity: isMuted ? 0.14 : 0.58,
          ),
        ),
        Positioned(
          left: KivoScale.w(54),
          bottom: KivoScale.w(76),
          child: _LightBurst(
            size: KivoScale.w(28),
            opacity: isMuted ? 0.12 : 0.5,
          ),
        ),
        Positioned(
          child: Image.asset(
            imagePath,
            width: KivoScale.w(500),
            height: KivoScale.w(1200),
            fit: BoxFit.cover,
            opacity: AlwaysStoppedAnimation(isMuted ? 0.78 : 1),
          ),
        ),
      ],
    );
  }
}

class _LightBurst extends StatelessWidget {
  const _LightBurst({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: CustomPaint(
        size: Size.square(size),
        painter: _LightBurstPainter(),
      ),
    );
  }
}

class _LightBurstPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = KivoColors.warningGold
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final rays = <({double angle, double inner, double outer})>[
      (angle: -1.55, inner: 0.22, outer: 0.48),
      (angle: -0.55, inner: 0.18, outer: 0.43),
      (angle: 0.4, inner: 0.2, outer: 0.46),
      (angle: 1.45, inner: 0.18, outer: 0.42),
      (angle: 2.55, inner: 0.2, outer: 0.44),
      (angle: 3.25, inner: 0.18, outer: 0.38),
    ];

    for (final ray in rays) {
      final direction = Offset(math.cos(ray.angle), math.sin(ray.angle));
      canvas.drawLine(
        center + direction * size.width * ray.inner,
        center + direction * size.width * ray.outer,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BannerCopy extends StatelessWidget {
  const _BannerCopy({required this.content, required this.onPressed});

  final _HomeReviewBannerContent content;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (content.title != null) ...[
          Text(
            content.title!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: KivoTextStyles.screenTitle.copyWith(
              color: KivoColors.deepTeal,
              fontSize: KivoScale.sp(31, min: 19),
              height: 1.1,
            ),
          ),
          SizedBox(height: KivoScale.h(12)),
        ],
        Text(
          content.message,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: KivoTextStyles.body.copyWith(
            color: KivoColors.inkText,
            fontSize: KivoScale.sp(17, min: 12),
            height: 1.42,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: KivoScale.h(24)),
        _BannerButton(
          label: content.buttonLabel,
          enabled: content.isButtonEnabled,
          onPressed: onPressed,
        ),
      ],
    );
  }
}

class _BannerButton extends StatelessWidget {
  const _BannerButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final buttonGradient = enabled
        ? KivoGradients.cyanButton
        : LinearGradient(
            colors: [
              KivoColors.disabledText.withAlpha(64),
              KivoColors.disabledText.withAlpha(96),
            ],
          );

    return Semantics(
      button: true,
      enabled: enabled,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(KivoScale.r(22)),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: KivoScale.w(82)),
          decoration: BoxDecoration(
            gradient: buttonGradient,
            borderRadius: BorderRadius.circular(KivoScale.r(22)),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: KivoColors.tealShadow.withAlpha(44),
                      blurRadius: KivoScale.r(13),
                      offset: Offset(0, KivoScale.h(6)),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: KivoScale.w(16)),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: KivoTextStyles.cta.copyWith(
                fontSize: KivoScale.sp(27, min: 16),
                color: enabled ? Colors.white : KivoColors.secondaryText,
                shadows: enabled
                    ? const [
                        Shadow(
                          color: KivoColors.deepTeal,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeReviewBannerContent {
  const _HomeReviewBannerContent({
    required this.imagePath,
    required this.message,
    required this.buttonLabel,
    required this.isButtonEnabled,
    required this.gradient,
    required this.borderColor,
    this.title,
  });

  final String imagePath;
  final String? title;
  final String message;
  final String buttonLabel;
  final bool isButtonEnabled;
  final LinearGradient gradient;
  final Color borderColor;

  static _HomeReviewBannerContent fromStatus(HomeReviewBannerStatus status) {
    return switch (status) {
      HomeReviewBannerStatus.noWords => _HomeReviewBannerContent(
        imagePath: KivoImagePaths.giftBox,
        message:
            'Kho kiến thức của bạn vẫn còn trống! Hãy bắt đầu hành trình chinh phục từ mới để mở khóa những phần quà thú vị nhé.',
        buttonLabel: 'Bắt đầu học ngay 🚀',
        isButtonEnabled: true,
        gradient: KivoGradients.mintCard,
        borderColor: KivoColors.kivoTeal.withAlpha(136),
      ),
      HomeReviewBannerStatus.noDueReview => _HomeReviewBannerContent(
        imagePath: KivoImagePaths.lowEnergyTrophy,
        message:
            'Cúp vàng đã được bảo trì! Bạn đã phản xạ quá xuất sắc hôm nay. Hãy quay lại vào khung giờ tới để tiếp tục giữ phong độ nhé!',
        buttonLabel: 'Vào Đo Phản Xạ ⚡',
        isButtonEnabled: false,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [KivoColors.lightSurface, KivoColors.lightBorder],
        ),
        borderColor: KivoColors.disabledText.withAlpha(70),
      ),
      HomeReviewBannerStatus.reviewDue => _HomeReviewBannerContent(
        imagePath: KivoImagePaths.trophy,
        title: 'Sẵn sàng thử thách chứ?',
        message:
            'Hãy xem phản xạ của bạn nhanh nhạy đến đâu với những tình huống từ kiến thức bạn đã học nhé!',
        buttonLabel: 'Vào Đo Phản Xạ ⚡',
        isButtonEnabled: true,
        gradient: KivoGradients.mintCard,
        borderColor: KivoColors.kivoTeal.withAlpha(136),
      ),
    };
  }
}
