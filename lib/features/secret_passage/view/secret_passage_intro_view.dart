import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/assets/image_paths.dart';
import '../../../app/theme/kivo_theme_tokens.dart';
import 'secret_passage_story_view.dart';

enum SecretPassageStage { intro, story }

class SecretPassageIntroView extends StatefulWidget {
  const SecretPassageIntroView({super.key});

  static const double sourceWidth = 852;
  static const double sourceHeight = 1846;
  static const double sourceAspectRatio = sourceHeight / sourceWidth;

  @override
  State<SecretPassageIntroView> createState() => _SecretPassageIntroViewState();
}

class _SecretPassageIntroViewState extends State<SecretPassageIntroView>
    with SingleTickerProviderStateMixin {
  SecretPassageStage _stage = SecretPassageStage.intro;
  late final AnimationController _controller;
  late final Animation<double> _ease;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _ease = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.addListener(_onAnimationProgress);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        precacheImage(const AssetImage(KivoImagePaths.caveIntro), context);
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onAnimationProgress);
    _controller.dispose();
    super.dispose();
  }

  void _onAnimationProgress() {
    if (_controller.value >= 0.75 && _stage == SecretPassageStage.intro) {
      setState(() {
        _stage = SecretPassageStage.story;
      });
    }
  }

  Future<void> _openPassage() async {
    if (_controller.isAnimating) return;
    setState(() {
      _stage = SecretPassageStage.intro;
    });
    await _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KivoColors.darkCave,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final sceneWidth = constraints.maxWidth.clamp(
              0.0,
              SecretPassageIntroView.sourceWidth,
            );
            final sceneHeight =
                sceneWidth * SecretPassageIntroView.sourceAspectRatio;
            final scale = sceneWidth / SecretPassageIntroView.sourceWidth;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Center(
                child: SizedBox(
                  width: sceneWidth,
                  height: sceneHeight,
                  child: AnimatedBuilder(
                    animation: _ease,
                    builder: (context, child) {
                      final t = _ease.value;
                      final shake = _controller.isAnimating && t < 0.28
                          ? math.sin(t * math.pi * 42) * (1 - t / 0.28) * 4
                          : 0.0;

                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          if (_stage == SecretPassageStage.intro) ...[
                            const _CaveBackdrop(),
                            Image.asset(
                              KivoImagePaths.secretCaveGate,
                              width: sceneWidth,
                              height: sceneHeight,
                              fit: BoxFit.fill,
                            ),
                            Transform.translate(
                              offset: Offset(shake, 0),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  _CrackOverlay(t: t, scale: scale),
                                  for (var index = 0; index < 8; index += 1)
                                    _StoneShard(
                                      index: index,
                                      t: t,
                                      scale: scale,
                                    ),
                                ],
                              ),
                            ),
                            _Mascot(scale: scale),
                            _Sparkle(
                              left: 388,
                              top: 102,
                              size: 28,
                              index: 1,
                              scale: scale,
                            ),
                            _Sparkle(
                              left: 64,
                              top: 815,
                              size: 33,
                              index: 2,
                              scale: scale,
                            ),
                            _Sparkle(
                              left: 758,
                              top: 846,
                              size: 34,
                              index: 3,
                              scale: scale,
                            ),
                            _TitleBlock(scale: scale),
                            _PromptBox(scale: scale, onTap: _openPassage),
                            _ScaledTapTarget(
                              key: const ValueKey('secret-passage-back'),
                              sceneWidth: sceneWidth,
                              left: 34,
                              top: 58,
                              width: 92,
                              height: 92,
                              onTap: Get.back<void>,
                            ),
                            _ScaledTapTarget(
                              key: const ValueKey('secret-passage-stone'),
                              sceneWidth: sceneWidth,
                              left: 170,
                              top: 405,
                              width: 515,
                              height: 515,
                              onTap: _openPassage,
                            ),
                            _ScaledTapTarget(
                              key: const ValueKey(
                                'secret-passage-stone-prompt',
                              ),
                              sceneWidth: sceneWidth,
                              left: 120,
                              top: 1458,
                              width: 610,
                              height: 260,
                              onTap: _openPassage,
                            ),
                            _OpeningGlow(t: t, scale: scale),
                          ] else ...[
                            SecretPassageStoryView(
                              scale: scale,
                              startTypewriter: _controller.value >= 0.99,
                            ),
                          ],
                          _SceneFlash(t: _controller.value),
                        ],
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CaveBackdrop extends StatelessWidget {
  const _CaveBackdrop();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF062F38), Color(0xFF04262D), Color(0xFF022027)],
        ),
      ),
    );
  }
}

class _StoneShard extends StatelessWidget {
  const _StoneShard({
    required this.index,
    required this.t,
    required this.scale,
  });

  final int index;
  final double t;
  final double scale;

  static const double _left = 126;
  static const double _top = 290;
  static const double _width = 600;
  static const double _height = 666;

  @override
  Widget build(BuildContext context) {
    final angle = -math.pi / 2 + (index + 0.5) * (math.pi * 2 / 8);
    final breakProgress = Curves.easeOutBack.transform((t / 0.82).clamp(0, 1));
    final distance = 118 * breakProgress * scale;
    final fade = Curves.easeIn.transform(((t - 0.44) / 0.56).clamp(0.0, 1.0));
    final opacity = (1 - fade * 0.88).clamp(0.0, 1.0);

    return Positioned(
      left: _left * scale,
      top: _top * scale,
      width: _width * scale,
      height: _height * scale,
      child: Opacity(
        opacity: opacity,
        child: Transform.translate(
          offset: Offset(
            math.cos(angle) * distance,
            math.sin(angle) * distance,
          ),
          child: Transform.rotate(
            angle: math.sin(angle) * 0.22 * breakProgress,
            child: Image.asset(
              KivoImagePaths.mysteryStoneShard(index),
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    );
  }
}

class _OpeningGlow extends StatelessWidget {
  const _OpeningGlow({required this.t, required this.scale});

  final double t;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final glow = Curves.easeOutCubic.transform((t / 0.86).clamp(0.0, 1.0));
    final bloom = Curves.easeOutExpo.transform(
      ((t - 0.62) / 0.38).clamp(0.0, 1.0),
    );
    final size = (130 + 610 * glow + 340 * bloom) * scale;

    return Positioned(
      left: 426 * scale - size / 2,
      top: 625 * scale - size / 2,
      width: size,
      height: size,
      child: IgnorePointer(
        child: Opacity(
          opacity: (0.05 + 0.72 * glow + 0.22 * bloom).clamp(0, 0.94),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withAlpha(245),
                  KivoColors.glowMint.withAlpha(202),
                  KivoColors.kivoTeal.withAlpha(82),
                  Colors.transparent,
                ],
                stops: const [0, 0.26, 0.58, 1],
              ),
              boxShadow: [
                BoxShadow(
                  color: KivoColors.glowMint.withAlpha(
                    (150 * glow + 80 * bloom).round().clamp(0, 255),
                  ),
                  blurRadius: (90 + 42 * bloom) * scale,
                  spreadRadius: (28 + 38 * bloom) * scale,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SceneFlash extends StatelessWidget {
  const _SceneFlash({required this.t});

  final double t;

  @override
  Widget build(BuildContext context) {
    double opacity = 0.0;
    if (t < 0.5) {
      opacity = 0.0;
    } else if (t >= 0.5 && t < 0.75) {
      final progress = ((t - 0.5) / 0.25).clamp(0.0, 1.0);
      opacity = Curves.easeInCubic.transform(progress);
    } else if (t >= 0.75 && t <= 0.88) {
      opacity = 1.0;
    } else {
      final progress = ((1.0 - t) / 0.12).clamp(0.0, 1.0);
      opacity = Curves.easeOutCubic.transform(progress);
    }

    if (opacity <= 0.005) return const SizedBox.shrink();

    return Positioned.fill(
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity,
          child: const DecoratedBox(
            decoration: BoxDecoration(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _CrackOverlay extends StatelessWidget {
  const _CrackOverlay({required this.t, required this.scale});

  final double t;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final crack = (t / 0.36).clamp(0.0, 1.0);
    if (crack <= 0) return const SizedBox.shrink();

    return Positioned(
      left: 226 * scale,
      top: 440 * scale,
      width: 400 * scale,
      height: 400 * scale,
      child: IgnorePointer(
        child: Opacity(
          opacity: (0.18 + 0.65 * crack).clamp(0, 0.83),
          child: CustomPaint(painter: _CrackPainter(progress: crack)),
        ),
      ),
    );
  }
}

class _Mascot extends StatelessWidget {
  const _Mascot({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: 760 * scale,
      width: 285 * scale,
      child: Image.asset(KivoImagePaths.kivoExplorer, fit: BoxFit.contain),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 120 * scale,
      right: 120 * scale,
      top: 1205 * scale,
      child: Text(
        'L\u1ed1i \u0111i b\u00ed m\u1eadt\nh\u00f4m nay...',
        textAlign: TextAlign.center,
        style: KivoTextStyles.display.copyWith(
          color: KivoColors.cream,
          fontSize: 58 * scale,
          height: 1.16,
          letterSpacing: 0,
          shadows: [
            Shadow(color: Colors.black.withAlpha(80), blurRadius: 8 * scale),
          ],
        ),
      ),
    );
  }
}

class _PromptBox extends StatelessWidget {
  const _PromptBox({required this.scale, required this.onTap});

  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 120 * scale,
      right: 120 * scale,
      top: 1458 * scale,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 22 * scale,
            vertical: 26 * scale,
          ),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(24 * scale),
            border: Border.all(
              color: KivoColors.warningGold,
              width: 2.5 * scale,
            ),
          ),
          child: Text(
            '\ud83d\udc49 Ch\u1ea1m v\u00e0o phi\u1ebfn \u0111\u00e1\n\u0111\u1ec3 m\u1edf ra\nm\u1ed9t v\u00f9ng \u0111\u1ea5t m\u1edbi',
            textAlign: TextAlign.center,
            style: KivoTextStyles.darkBody.copyWith(
              color: KivoColors.warningGold,
              fontSize: 36 * scale,
              height: 1.36,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}

class _Sparkle extends StatelessWidget {
  const _Sparkle({
    required this.left,
    required this.top,
    required this.size,
    required this.index,
    required this.scale,
  });

  final double left;
  final double top;
  final double size;
  final int index;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final path = switch (index) {
      1 => KivoImagePaths.magicSpark1,
      2 => KivoImagePaths.magicSpark2,
      _ => KivoImagePaths.magicSpark3,
    };

    return Positioned(
      left: left * scale,
      top: top * scale,
      width: size * scale,
      height: size * scale,
      child: Image.asset(path, fit: BoxFit.contain),
    );
  }
}

class _CrackPainter extends CustomPainter {
  const _CrackPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.white.withAlpha(230)
      ..strokeWidth = size.width * 0.012
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    final glowPaint = Paint()
      ..color = KivoColors.warningGold.withAlpha(210)
      ..strokeWidth = size.width * 0.006
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < 10; i += 1) {
      final angle = -math.pi / 2 + i * math.pi * 2 / 10;
      final length = size.width * (0.15 + 0.25 * progress + (i % 3) * 0.035);
      final bend =
          Offset(math.cos(angle + 0.52), math.sin(angle + 0.52)) *
          size.width *
          0.045;
      final start =
          center + Offset(math.cos(angle), math.sin(angle)) * size.width * 0.06;
      final end = center + Offset(math.cos(angle), math.sin(angle)) * length;
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(
          center.dx + bend.dx,
          center.dy + bend.dy,
          end.dx,
          end.dy,
        );
      canvas.drawPath(path, paint);
      canvas.drawPath(path, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CrackPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _ScaledTapTarget extends StatelessWidget {
  const _ScaledTapTarget({
    super.key,
    required this.sceneWidth,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.onTap,
  });

  final double sceneWidth;
  final double left;
  final double top;
  final double width;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scale = sceneWidth / SecretPassageIntroView.sourceWidth;

    return Positioned(
      left: left * scale,
      top: top * scale,
      width: width * scale,
      height: height * scale,
      child: Semantics(
        button: true,
        child: Material(
          color: Colors.transparent,
          child: InkWell(onTap: onTap),
        ),
      ),
    );
  }
}
