import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/assets/image_paths.dart';
import '../../../app/theme/kivo_theme_tokens.dart';
import '../../../data/kivo_seed_data.dart';
import 'passageway_story_view.dart';

enum PassagewayStageStatus { completed, current, locked }

class PassagewayCaveListView extends StatefulWidget {
  const PassagewayCaveListView({super.key, this.currentStageIndex = 1});

  static const double sourceWidth = 852;
  static double sourceHeight(int stageCount) => 122.0 + (stageCount - 1) * 436.0 + 250.0;

  final int currentStageIndex;

  static List<String> get stageNames => seedPassagewayCombos.map((combo) {
    final title = combo['title']?.toString() ?? '';
    final name = title.replaceAll('Rắc rối ở ', '');
    return name.isNotEmpty ? name[0].toUpperCase() + name.substring(1) : name;
  }).toList();

  @override
  State<PassagewayCaveListView> createState() => _PassagewayCaveListViewState();
}

class _PassagewayCaveListViewState extends State<PassagewayCaveListView>
    with TickerProviderStateMixin {
  late final AnimationController _introController;
  late final AnimationController _heartbeatController;
  late final Animation<double> _introAnimation;
  late final Animation<double> _heartbeatAnimation;
  int _unlockedStageIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadProgress();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 980),
    );
    _introAnimation = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeOutCubic,
    );
    _heartbeatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _heartbeatAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 16,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1,
          end: 0,
        ).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 18,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: 0.7,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 12,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.7,
          end: 0,
        ).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 16,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(0), weight: 38),
    ]).animate(_heartbeatController);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _introController.forward();
        _heartbeatController.repeat();
      }
    });
  }

  @override
  void dispose() {
    _introController.dispose();
    _heartbeatController.dispose();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _unlockedStageIndex = prefs.getInt('kivo.passageway.unlocked_index') ?? 1;
        });
      }
    } catch (e) {
      Get.log('Error loading passageway progress: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final stages = PassagewayCaveListView.stageNames;
    return Scaffold(
      backgroundColor: KivoColors.darkCave,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final sceneWidth = constraints.maxWidth.clamp(
              0.0,
              PassagewayCaveListView.sourceWidth,
            );
            final currentSourceHeight = PassagewayCaveListView.sourceHeight(stages.length);
            final sceneHeight =
                sceneWidth * (currentSourceHeight / PassagewayCaveListView.sourceWidth);
            final scale = sceneWidth / PassagewayCaveListView.sourceWidth;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Center(
                child: SizedBox(
                  width: sceneWidth,
                  height: sceneHeight,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([
                      _introAnimation,
                      _heartbeatAnimation,
                    ]),
                    builder: (context, child) {
                      final intro = _introAnimation.value;

                      return Stack(
                        children: [
                          const Positioned.fill(child: _PassagewayBackdrop()),
                          Positioned.fill(
                            child: Opacity(
                              opacity: Curves.easeOut.transform(
                                (intro / 0.52).clamp(0.0, 1.0),
                              ),
                              child: CustomPaint(
                                painter: _PassagewayPathPainter(
                                  scale: scale,
                                  progress: intro,
                                  stageCount: stages.length,
                                ),
                              ),
                            ),
                          ),
                          _BackButton(scale: scale),
                          for (
                            var index = 0;
                            index < stages.length;
                            index += 1
                          )
                            _StageNode(
                              key: ValueKey('passageway-stage-$index'),
                              stageNumber: index + 1,
                              name: stages[index],
                              status: _statusFor(index),
                              top: _nodeTop(index),
                              scale: scale,
                              heartbeat: _heartbeatAnimation.value,
                              onRefresh: _loadProgress,
                            ),
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

  PassagewayStageStatus _statusFor(int index) {
    if (index < _unlockedStageIndex - 1) {
      return PassagewayStageStatus.completed;
    }
    if (index == _unlockedStageIndex - 1) {
      return PassagewayStageStatus.current;
    }
    return PassagewayStageStatus.locked;
  }

  double _nodeTop(int index) {
    return 122.0 + index * 436.0;
  }
}

class _PassagewayBackdrop extends StatelessWidget {
  const _PassagewayBackdrop();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.16,
          colors: [Color(0xFF063A40), Color(0xFF022D32), Color(0xFF001E24)],
          stops: [0, 0.58, 1],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 36 * scale,
      top: 42 * scale,
      width: 92 * scale,
      height: 92 * scale,
      child: Material(
        color: const Color(0x172CE7D2),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24 * scale),
          side: BorderSide(
            color: KivoColors.glowMint.withAlpha(78),
            width: 2 * scale,
          ),
        ),
        child: IconButton(
          key: const ValueKey('passageway-back'),
          onPressed: Get.back<void>,
          icon: Icon(
            Icons.arrow_back_rounded,
            color: KivoColors.glowMint,
            size: 48 * scale,
          ),
        ),
      ),
    );
  }
}

class _StageNode extends StatelessWidget {
  const _StageNode({
    super.key,
    required this.stageNumber,
    required this.name,
    required this.status,
    required this.top,
    required this.scale,
    required this.heartbeat,
    this.onRefresh,
  });

  final int stageNumber;
  final String name;
  final PassagewayStageStatus status;
  final double top;
  final double scale;
  final double heartbeat;
  final VoidCallback? onRefresh;

  bool get _isCurrent => status == PassagewayStageStatus.current;
  bool get _isLocked => status == PassagewayStageStatus.locked;

  @override
  Widget build(BuildContext context) {
    final imagePath = _isLocked
        ? KivoImagePaths.stoneNodeLocked
        : KivoImagePaths.stoneNodeActive;
    final double opacity;
    if (_isLocked) {
      opacity = 0.72;
    } else if (status == PassagewayStageStatus.completed) {
      opacity = 0.78; // completed stage is slightly dimmer/faded
    } else {
      opacity = 1.0; // active/current stage is fully bright
    }

    return Positioned(
      left: 0,
      right: 0,
      top: top * scale,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (!_isLocked) {
            Get.to<void>(
              () => PassagewayStoryView(
                stageNumber: stageNumber,
                stageName: name,
              ),
            )?.then((_) {
              onRefresh?.call();
            });
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 330 * scale,
              height: 250 * scale,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
              children: [
                if (_isCurrent)
                  _CurrentGlow(scale: scale, heartbeat: heartbeat),
                Opacity(
                  opacity: opacity,
                  child: Image.asset(
                    imagePath,
                    width: 330 * scale,
                    height: 250 * scale,
                    fit: BoxFit.contain,
                  ),
                ),
                if (_isCurrent) ...[
                  _SparkDot(left: 30, top: 36, size: 5, scale: scale),
                  _SparkDot(left: 290, top: 64, size: 4, scale: scale),
                  _SparkDot(left: 52, top: 186, size: 4, scale: scale),
                ],
              ],
            ),
          ),
          Transform.translate(
            offset: Offset(0, -10 * scale),
            child: _StageLabel(
              stageNumber: stageNumber,
              name: _isLocked ? '???' : name,
              status: status,
              scale: scale,
            ),
          ),
        ],
      ),
    ),
  );
}
}

class _CurrentGlow extends StatelessWidget {
  const _CurrentGlow({required this.scale, required this.heartbeat});

  final double scale;
  final double heartbeat;

  @override
  Widget build(BuildContext context) {
    final pulse = heartbeat.clamp(0.0, 1.0);
    // Gentler and cleaner opacity pulse
    final glowOpacity = (0.45 + pulse * 0.25).clamp(0.0, 1.0);

    return Transform.scale(
      scale: 1.0 + pulse * 0.04,
      child: Container(
        width: 160 * scale,
        height: 160 * scale,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              KivoColors.glowMint.withAlpha((140 * glowOpacity).round()),
              KivoColors.kivoTeal.withAlpha((70 * glowOpacity).round()),
              KivoColors.kivoTeal.withAlpha((15 * glowOpacity).round()),
              Colors.transparent,
            ],
            stops: const [0.0, 0.35, 0.75, 1.0],
          ),
          boxShadow: [
            // A single very soft, concentrated outer glow instead of massive overlapping ones
            BoxShadow(
              color: KivoColors.glowMint.withAlpha((48 + pulse * 32).round()),
              blurRadius: (24 + pulse * 10) * scale,
              spreadRadius: 1 * scale,
            ),
          ],
        ),
      ),
    );
  }
}

class _SparkDot extends StatelessWidget {
  const _SparkDot({
    required this.left,
    required this.top,
    required this.size,
    required this.scale,
  });

  final double left;
  final double top;
  final double size;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left * scale,
      top: top * scale,
      width: size * scale,
      height: size * scale,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: KivoColors.glowMint,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: KivoColors.glowMint.withAlpha(180),
              blurRadius: 10 * scale,
              spreadRadius: 2 * scale,
            ),
          ],
        ),
      ),
    );
  }
}

class _StageLabel extends StatelessWidget {
  const _StageLabel({
    required this.stageNumber,
    required this.name,
    required this.status,
    required this.scale,
  });

  final int stageNumber;
  final String name;
  final PassagewayStageStatus status;
  final double scale;

  bool get _isCurrent => status == PassagewayStageStatus.current;
  bool get _isLocked => status == PassagewayStageStatus.locked;

  @override
  Widget build(BuildContext context) {
    final isCompleted = status == PassagewayStageStatus.completed;
    final borderColor = _isCurrent
        ? KivoColors.glowMint
        : KivoColors.glowMint.withAlpha(_isLocked ? 44 : (isCompleted ? 60 : 74));
    final textColor = _isCurrent
        ? KivoColors.cream
        : _isLocked
        ? KivoColors.darkText.withAlpha(116)
        : KivoColors.glowMint.withAlpha(isCompleted ? 186 : 255);

    return Container(
      constraints: BoxConstraints(minWidth: 230 * scale, maxWidth: 390 * scale),
      padding: EdgeInsets.symmetric(
        horizontal: 30 * scale,
        vertical: 12 * scale,
      ),
      decoration: BoxDecoration(
        color: const Color(0x6B062D31),
        borderRadius: BorderRadius.circular(18 * scale),
        border: Border.all(color: borderColor, width: 1.6 * scale),
        boxShadow: _isCurrent
            ? [
                BoxShadow(
                  color: KivoColors.glowMint.withAlpha(104),
                  blurRadius: 20 * scale,
                  spreadRadius: 2 * scale,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isCurrent) _LabelDiamond(scale: scale),
          Flexible(
            child: Text(
              '$stageNumber. $name',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textScaler: TextScaler.noScaling,
              style: KivoTextStyles.darkAccent.copyWith(
                color: textColor,
                fontSize: 25 * scale,
                height: 1.08,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
                shadows: _isCurrent
                    ? [
                        Shadow(
                          color: KivoColors.glowMint.withAlpha(150),
                          blurRadius: 10 * scale,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
          if (_isCurrent) _LabelDiamond(scale: scale),
        ],
      ),
    );
  }
}

class _LabelDiamond extends StatelessWidget {
  const _LabelDiamond({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7 * scale,
      height: 7 * scale,
      margin: EdgeInsets.symmetric(horizontal: 14 * scale),
      transform: Matrix4.rotationZ(math.pi / 4),
      decoration: const BoxDecoration(color: KivoColors.glowMint),
    );
  }
}

class _PassagewayPathPainter extends CustomPainter {
  const _PassagewayPathPainter({
    required this.scale,
    required this.progress,
    required this.stageCount,
  });

  final double scale;
  final double progress;
  final int stageCount;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = KivoColors.kivoTeal.withAlpha(186)
      ..strokeWidth = 4 * scale
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final centerX = size.width / 2;

    final List<({double from, double to})> segments = [];
    for (int i = 0; i < stageCount - 1; i++) {
      final fromY = 122.0 + i * 436.0 + 250.0 + 38.0;
      final toY = 122.0 + (i + 1) * 436.0 - 16.0;
      segments.add((from: fromY, to: toY));
    }

    final double startSegmentThreshold = stageCount > 1 ? 0.9 / (stageCount - 1) : 0.1;
    final double segmentDuration = stageCount > 1 ? 1.0 / (stageCount - 1) : 1.0;

    for (var index = 0; index < segments.length; index += 1) {
      final segmentProgress = ((progress - index * startSegmentThreshold) / segmentDuration).clamp(
        0.0,
        1.0,
      );
      final eased = Curves.easeOutCubic.transform(segmentProgress);
      final segment = segments[index];
      final start = Offset(centerX, segment.from * scale);
      final end = Offset(centerX, segment.to * scale);
      final revealedEnd = Offset.lerp(start, end, eased)!;

      _drawDottedLine(
        canvas: canvas,
        paint: paint,
        start: start,
        end: revealedEnd,
        dash: 11 * scale,
        gap: 13 * scale,
      );
      if (eased > 0.02) {
        _drawDiamond(canvas, start, 8 * scale, eased);
      }
      if (eased > 0.96) {
        _drawDiamond(canvas, end, 8 * scale, eased);
      }
    }
  }

  void _drawDottedLine({
    required Canvas canvas,
    required Paint paint,
    required Offset start,
    required Offset end,
    required double dash,
    required double gap,
  }) {
    final total = (end - start).distance;
    if (total <= 0) return;
    final direction = (end - start) / total;
    var distance = 0.0;

    while (distance < total) {
      final next = math.min(distance + dash, total);
      canvas.drawLine(
        start + direction * distance,
        start + direction * next,
        paint,
      );
      distance += dash + gap;
    }
  }

  void _drawDiamond(
    Canvas canvas,
    Offset center,
    double radius,
    double opacity,
  ) {
    final diamond = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..lineTo(center.dx + radius, center.dy)
      ..lineTo(center.dx, center.dy + radius)
      ..lineTo(center.dx - radius, center.dy)
      ..close();
    final paint = Paint()
      ..color = KivoColors.kivoTeal.withAlpha((255 * opacity).round())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * scale;
    canvas.drawPath(diamond, paint);
  }

  @override
  bool shouldRepaint(covariant _PassagewayPathPainter oldDelegate) {
    return oldDelegate.scale != scale ||
        oldDelegate.progress != progress ||
        oldDelegate.stageCount != stageCount;
  }
}
