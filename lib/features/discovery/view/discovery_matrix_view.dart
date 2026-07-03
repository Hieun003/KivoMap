import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/icons/kivo_icon_registry.dart';
import '../../../app/responsive/kivo_scale.dart';
import '../../../app/theme/kivo_theme_tokens.dart';
import '../view_model/discovery_view_model.dart';
import '../view_model/discovery_view_state.dart';

class DiscoveryMatrixView extends GetView<DiscoveryViewModel> {
  const DiscoveryMatrixView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: KivoGradients.lightBackground,
        ),
        child: SafeArea(
          bottom: true,
          child: Obx(() {
            if (controller.isLoading.value) {
              return const _DiscoveryLoadingState();
            }

            final errorMessage = controller.errorMessage.value;
            if (errorMessage != null) {
              return _DiscoveryMessageState(
                title: 'Ch\u01b0a m\u1edf \u0111\u01b0\u1ee3c ma tr\u1eadn',
                message: errorMessage,
                buttonLabel: 'Th\u1eed l\u1ea1i',
                onPressed: controller.refresh,
              );
            }

            final matrixState = controller.state.value;
            if (matrixState == null) {
              return _DiscoveryMessageState(
                title: 'Ch\u01b0a c\u00f3 ng\u1eef c\u1ea3nh',
                message:
                    'T\u1eeb n\u00e0y \u0111ang \u0111\u01b0\u1ee3c Kivo chu\u1ea9n b\u1ecb th\u00eam ng\u1eef c\u1ea3nh.',
                buttonLabel: 'Quay l\u1ea1i',
                onPressed: controller.goBack,
              );
            }

            return _DiscoveryMatrixContent(
              state: matrixState,
              selectedContextId: controller.selectedContextId.value,
              onBack: controller.goBack,
              onContextSelected: (contextNode) {
                final canOpen = controller.selectContext(contextNode);
                if (canOpen) {
                  Get.bottomSheet<void>(
                    _DiscoveryContextBottomSheet(contextNode: contextNode),
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                  );
                }
              },
            );
          }),
        ),
      ),
    );
  }
}

class _DiscoveryMatrixContent extends StatelessWidget {
  const _DiscoveryMatrixContent({
    required this.state,
    required this.selectedContextId,
    required this.onBack,
    required this.onContextSelected,
  });

  final DiscoveryMatrixState state;
  final String? selectedContextId;
  final VoidCallback onBack;
  final ValueChanged<DiscoveryContextNode> onContextSelected;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            KivoScale.w(18),
            KivoScale.h(10),
            KivoScale.w(18),
            KivoScale.h(28),
          ),
          sliver: SliverList.list(
            children: [
              _DiscoveryHeader(
                title: state.title,
                subtitle: state.subtitle,
                onBack: onBack,
              ),
              SizedBox(height: KivoScale.h(12)),
              _DiscoveryMatrixMap(
                state: state,
                selectedContextId: selectedContextId,
                onContextTap: onContextSelected,
              ),
              SizedBox(height: KivoScale.h(10)),
              _DiscoverySentencePanel(
                englishChunks: state.englishChunks,
                vietnameseChunks: state.vietnameseChunks,
              ),
              SizedBox(height: KivoScale.h(8)),
              const _TapHint(),
            ],
          ),
        ),
      ],
    );
  }
}

class _DiscoveryHeader extends StatelessWidget {
  const _DiscoveryHeader({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: KivoScale.h(88).clamp(76, 100),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(left: 0, top: 0, child: _BackButton(onPressed: onBack)),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: KivoScale.w(62)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: KivoTextStyles.display.copyWith(
                        fontSize: KivoScale.sp(34, min: 24),
                        color: KivoColors.coffeeText,
                        height: 1.04,
                      ),
                    ),
                  ),
                  SizedBox(height: KivoScale.h(4)),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: KivoTextStyles.cardTitle.copyWith(
                        color: KivoColors.inkText,
                        fontSize: KivoScale.sp(19, min: 15),
                        height: 1.08,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final size = KivoScale.w(54).clamp(46, 64).toDouble();

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(235),
          borderRadius: BorderRadius.circular(KivoScale.r(20)),
          border: Border.all(color: KivoColors.keywordOrange.withAlpha(70)),
          boxShadow: [
            BoxShadow(
              color: KivoColors.orangeShadow.withAlpha(56),
              blurRadius: KivoScale.r(12),
              offset: Offset(0, KivoScale.h(6)),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(
          KivoIconRegistry.system('back', tone: KivoIconTone.bold),
          color: KivoColors.coffeeText,
          size: size * 0.46,
        ),
      ),
    );
  }
}

class _DiscoveryMatrixMap extends StatelessWidget {
  const _DiscoveryMatrixMap({
    required this.state,
    required this.selectedContextId,
    required this.onContextTap,
  });

  final DiscoveryMatrixState state;
  final String? selectedContextId;
  final ValueChanged<DiscoveryContextNode> onContextTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mapWidth = constraints.maxWidth;
        const designWidth = 390.0;
        const designHeight = 560.0;
        final canvasScale = (mapWidth / designWidth).clamp(0.82, 1.04);
        final canvasWidth = designWidth * canvasScale;
        final mapHeight = designHeight * canvasScale;
        final canvasLeft = (mapWidth - canvasWidth) / 2;
        final rootSize = 106.0 * canvasScale;
        final rootCenter = Offset(
          canvasLeft + canvasWidth * 0.50,
          mapHeight * 0.50,
        );
        final cardSize = Size(166.0 * canvasScale, 70.0 * canvasScale);
        final contextCenters = {
          for (final node in state.contexts)
            node.id: Offset(
              canvasLeft + ((node.alignment.x + 1) / 2) * canvasWidth,
              ((node.alignment.y + 1) / 2) * mapHeight,
            ),
        };

        return SizedBox(
          height: mapHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _DiscoveryDecorPainter(
                    rootCenter: rootCenter,
                    cardCenters: contextCenters,
                    cardSize: cardSize,
                    contexts: state.contexts,
                    selectedContextId: selectedContextId,
                  ),
                ),
              ),
              for (final contextNode in state.contexts)
                _PositionedContextCard(
                  contextNode: contextNode,
                  center: contextCenters[contextNode.id]!,
                  cardSize: cardSize,
                  mapWidth: mapWidth,
                  mapHeight: mapHeight,
                  scale: canvasScale,
                  isSelected: selectedContextId == contextNode.id,
                  onTap: () => onContextTap(contextNode),
                ),
              Positioned(
                left: rootCenter.dx - rootSize / 2,
                top: rootCenter.dy - rootSize / 2,
                child: _DiscoveryRootNode(node: state.root, size: rootSize),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PositionedContextCard extends StatelessWidget {
  const _PositionedContextCard({
    required this.contextNode,
    required this.center,
    required this.cardSize,
    required this.mapWidth,
    required this.mapHeight,
    required this.scale,
    required this.isSelected,
    required this.onTap,
  });

  final DiscoveryContextNode contextNode;
  final Offset center;
  final Size cardSize;
  final double mapWidth;
  final double mapHeight;
  final double scale;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final left = (center.dx - cardSize.width / 2).clamp(
      10.0,
      mapWidth - cardSize.width - 10.0,
    );
    final top = (center.dy - cardSize.height / 2).clamp(
      22.0,
      mapHeight - cardSize.height - 18.0,
    );

    return Positioned(
      left: left,
      top: top,
      width: cardSize.width,
      height: cardSize.height,
      child: _DiscoveryContextCard(
        contextNode: contextNode,
        scale: scale,
        isSelected: isSelected,
        onTap: onTap,
      ),
    );
  }
}

class _DiscoveryContextCard extends StatelessWidget {
  const _DiscoveryContextCard({
    required this.contextNode,
    required this.scale,
    required this.isSelected,
    required this.onTap,
  });

  final DiscoveryContextNode contextNode;
  final double scale;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cardScale = scale;
    final isLocked = contextNode.status == DiscoveryContextStatus.locked;
    final isActive = isSelected || contextNode.isDiscovered;
    final borderColor = isActive
        ? KivoColors.successGreen
        : isLocked
        ? const Color(0xFFC8C2B8)
        : const Color(0xFFD7C1A2);
    final iconColor = isActive
        ? KivoColors.successGreen
        : isLocked
        ? KivoColors.secondaryText
        : KivoColors.actionOrange;

    return Semantics(
      button: true,
      enabled: !isLocked,
      label: '${contextNode.order}. ${contextNode.title}',
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: KivoDurations.fast,
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.fromLTRB(
                cardScale * 14,
                cardScale * 8,
                cardScale * 12,
                cardScale * 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(isLocked ? 220 : 242),
                borderRadius: BorderRadius.circular(24 * cardScale),
                border: Border.all(
                  color: borderColor,
                  width: isActive ? 1.7 : 1.0,
                ),
                boxShadow: isActive ? KivoShadows.soft : KivoShadows.soft,
              ),
              child: Row(
                children: [
                  Container(
                    width: 42 * cardScale,
                    height: 42 * cardScale,
                    decoration: BoxDecoration(
                      color: isActive
                          ? KivoColors.softMintCard.withAlpha(210)
                          : KivoColors.warmCard.withAlpha(isLocked ? 90 : 180),
                      borderRadius: BorderRadius.circular(14 * cardScale),
                      border: Border.all(color: borderColor.withAlpha(130)),
                    ),
                    child: Icon(
                      KivoIconRegistry.vocabulary(
                        contextNode.iconKey,
                        tone: KivoIconTone.duotone,
                      ),
                      color: iconColor,
                      size: 25 * cardScale,
                    ),
                  ),
                  SizedBox(width: 10 * cardScale),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            contextNode.title,
                            maxLines: 1,
                            style: KivoTextStyles.cardTitle.copyWith(
                              color: isLocked
                                  ? KivoColors.secondaryText
                                  : KivoColors.inkText,
                              fontSize: 17.5 * cardScale,
                              height: 1.04,
                            ),
                          ),
                        ),
                        SizedBox(height: 3 * cardScale),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '(${contextNode.translation})',
                            maxLines: 1,
                            style: KivoTextStyles.body.copyWith(
                              color: isLocked
                                  ? KivoColors.secondaryText
                                  : KivoColors.inkText,
                              fontSize: 12.5 * cardScale,
                              height: 1.1,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: -8 * cardScale,
              top: -10 * cardScale,
              child: Container(
                width: 30 * cardScale,
                height: 30 * cardScale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? KivoColors.softMintCard : Colors.white,
                  border: Border.all(color: borderColor, width: 1.4),
                  boxShadow: KivoShadows.soft,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${contextNode.order}',
                  style: KivoTextStyles.cardTitle.copyWith(
                    color: KivoColors.inkText,
                    fontSize: 14 * cardScale,
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

class _DiscoveryRootNode extends StatelessWidget {
  const _DiscoveryRootNode({required this.node, required this.size});

  final DiscoveryRootNode node;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withAlpha(240),
        border: Border.all(color: node.accentColor.withAlpha(185), width: 2.6),
        boxShadow: [
          BoxShadow(
            color: node.accentColor.withAlpha(112),
            blurRadius: KivoScale.r(22),
            spreadRadius: KivoScale.r(3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            KivoIconRegistry.vocabulary(
              node.iconKey,
              tone: KivoIconTone.duotone,
            ),
            color: node.accentColor,
            size: size * 0.34,
          ),
          SizedBox(height: size * 0.04),
          SizedBox(
            width: size * 0.78,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                node.label,
                maxLines: 1,
                style: KivoTextStyles.cardTitle.copyWith(
                  color: node.accentColor,
                  fontSize: size * 0.20,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscoveryDecorPainter extends CustomPainter {
  const _DiscoveryDecorPainter({
    required this.rootCenter,
    required this.cardCenters,
    required this.cardSize,
    required this.contexts,
    required this.selectedContextId,
  });

  final Offset rootCenter;
  final Map<String, Offset> cardCenters;
  final Size cardSize;
  final List<DiscoveryContextNode> contexts;
  final String? selectedContextId;

  @override
  void paint(Canvas canvas, Size size) {
    _drawMarks(canvas, size);
    _drawPaths(canvas);
  }

  void _drawPaths(Canvas canvas) {
    for (final context in contexts) {
      final cardCenter = cardCenters[context.id]!;
      final target = _edgePointToward(cardCenter, rootCenter, cardSize);
      final isActive = selectedContextId == context.id || context.isDiscovered;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = isActive ? 4.2 : 2.6
        ..strokeCap = StrokeCap.round
        ..color = isActive
            ? KivoColors.warningGold.withAlpha(230)
            : const Color(0xFF9A9A9A).withAlpha(185);

      if (isActive) {
        final glow = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 11
          ..strokeCap = StrokeCap.round
          ..color = KivoColors.warningGold.withAlpha(68);
        canvas.drawPath(_curvedPath(target, rootCenter), glow);
        canvas.drawPath(_curvedPath(target, rootCenter), paint);
      } else {
        _drawDashedPath(canvas, _curvedPath(target, rootCenter), paint);
      }
    }
  }

  Path _curvedPath(Offset start, Offset end) {
    final path = Path()..moveTo(start.dx, start.dy);
    final control = Offset(
      (start.dx + end.dx) / 2,
      (start.dy + end.dy) / 2 + (start.dx < end.dx ? 34 : -34),
    );
    path.quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
    return path;
  }

  Offset _edgePointToward(Offset center, Offset target, Size boxSize) {
    final delta = target - center;
    if (delta.distance == 0) {
      return center;
    }

    final scaleX =
        (boxSize.width / 2) / delta.dx.abs().clamp(1, double.infinity);
    final scaleY =
        (boxSize.height / 2) / delta.dy.abs().clamp(1, double.infinity);
    return center + delta * math.min(scaleX, scaleY);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      const dashLength = 11.0;
      const gapLength = 9.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(
            distance,
            math.min(distance + dashLength, metric.length),
          ),
          paint,
        );
        distance += dashLength + gapLength;
      }
    }
  }

  void _drawMarks(Canvas canvas, Size size) {
    final fill = Paint()..style = PaintingStyle.fill;
    final marks = <_DecorMark>[
      _DecorMark(0.15, 0.07, KivoColors.kivoTeal, true),
      _DecorMark(0.27, 0.12, KivoColors.errorCoral, true),
      _DecorMark(0.44, 0.10, KivoColors.targetPurple, true),
      _DecorMark(0.82, 0.11, KivoColors.errorCoral, true),
      _DecorMark(0.94, 0.12, KivoColors.targetPurple, true),
      _DecorMark(0.10, 0.40, KivoColors.kivoTeal, false),
      _DecorMark(0.82, 0.46, KivoColors.kivoTeal, true),
      _DecorMark(0.12, 0.76, KivoColors.errorCoral, true),
      _DecorMark(0.46, 0.83, KivoColors.warningGold, true),
      _DecorMark(0.86, 0.78, KivoColors.warningGold, false),
    ];

    for (final mark in marks) {
      final center = Offset(size.width * mark.x, size.height * mark.y);
      if (mark.star) {
        _drawStar(canvas, center, size.shortestSide * 0.018, mark.color);
      } else {
        fill.color = mark.color.withAlpha(95);
        canvas.drawCircle(center, size.shortestSide * 0.012, fill);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Color color) {
    final path = Path();
    for (var i = 0; i < 10; i += 1) {
      final currentRadius = i.isEven ? radius : radius * 0.48;
      final angle = -math.pi / 2 + i * math.pi / 5;
      final point = Offset(
        center.dx + math.cos(angle) * currentRadius,
        center.dy + math.sin(angle) * currentRadius,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.fill
        ..color = color.withAlpha(78),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = color.withAlpha(210),
    );
  }

  @override
  bool shouldRepaint(covariant _DiscoveryDecorPainter oldDelegate) {
    return oldDelegate.rootCenter != rootCenter ||
        oldDelegate.selectedContextId != selectedContextId ||
        oldDelegate.cardCenters != cardCenters;
  }
}

class _DiscoverySentencePanel extends StatelessWidget {
  const _DiscoverySentencePanel({
    required this.englishChunks,
    required this.vietnameseChunks,
  });

  final List<DiscoverySentenceChunk> englishChunks;
  final List<DiscoverySentenceChunk> vietnameseChunks;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            KivoScale.w(18),
            KivoScale.h(26),
            KivoScale.w(16),
            KivoScale.h(14),
          ),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(226),
            borderRadius: BorderRadius.circular(KivoScale.r(20)),
            border: Border.all(color: const Color(0xFFE6B76D)),
            boxShadow: KivoShadows.soft,
          ),
          child: Column(
            children: [
              _ChunkRow(chunks: englishChunks),
              Padding(
                padding: EdgeInsets.symmetric(vertical: KivoScale.h(8)),
                child: const Divider(color: KivoColors.lightBorder, height: 1),
              ),
              _ChunkRow(chunks: vietnameseChunks),
            ],
          ),
        ),
        Positioned(
          left: KivoScale.w(12),
          top: -KivoScale.h(16),
          child: Container(
            width: KivoScale.w(42).clamp(36, 48),
            height: KivoScale.w(34).clamp(30, 40),
            decoration: BoxDecoration(
              color: KivoColors.warmCard,
              borderRadius: BorderRadius.circular(KivoScale.r(16)),
              border: Border.all(color: KivoColors.warningGold),
              boxShadow: KivoShadows.soft,
            ),
            child: Icon(
              KivoIconRegistry.system('dialogue', tone: KivoIconTone.duotone),
              color: KivoColors.actionOrange,
              size: KivoScale.w(24).clamp(20, 28),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChunkRow extends StatelessWidget {
  const _ChunkRow({required this.chunks});

  final List<DiscoverySentenceChunk> chunks;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: KivoScale.w(7),
      runSpacing: KivoScale.h(7),
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [for (final chunk in chunks) _SentenceChunkChip(chunk: chunk)],
    );
  }
}

class _SentenceChunkChip extends StatelessWidget {
  const _SentenceChunkChip({required this.chunk});

  final DiscoverySentenceChunk chunk;

  @override
  Widget build(BuildContext context) {
    final isPlain =
        chunk.tone == DiscoveryChipTone.context &&
        !chunk.text.contains('-') &&
        chunk.text.length < 12;
    if (isPlain) {
      return Text(
        chunk.text,
        style: KivoTextStyles.body.copyWith(
          fontSize: KivoScale.sp(13, min: 10),
          fontWeight: FontWeight.w700,
        ),
      );
    }

    final palette = DiscoveryChipPalette.fromTone(chunk.tone);
    return Container(
      constraints: BoxConstraints(maxWidth: KivoScale.w(235).clamp(130, 280)),
      padding: EdgeInsets.symmetric(
        horizontal: KivoScale.w(9),
        vertical: KivoScale.h(6),
      ),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(KivoScale.r(12)),
        border: Border.all(color: palette.border.withAlpha(190)),
        boxShadow: [
          BoxShadow(
            color: palette.shadow.withAlpha(58),
            blurRadius: KivoScale.r(7),
            offset: Offset(0, KivoScale.h(3)),
          ),
        ],
      ),
      child: Text(
        chunk.text,
        textAlign: TextAlign.center,
        style: KivoTextStyles.cardTitle.copyWith(
          color: palette.text,
          fontSize: KivoScale.sp(chunk.text.length > 22 ? 10 : 13, min: 9),
          height: 1.12,
        ),
      ),
    );
  }
}

class _TapHint extends StatelessWidget {
  const _TapHint();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: KivoScale.h(6)),
      child: Column(
        children: [
          Icon(
            KivoIconRegistry.system('discover', tone: KivoIconTone.duotone),
            color: KivoColors.actionOrange,
            size: KivoScale.w(28).clamp(24, 32),
          ),
          SizedBox(height: KivoScale.h(4)),
          Text(
            'Ch\u1ea1m v\u00e0o c\u00e1c ng\u1eef c\u1ea3nh \u0111\u1ec3 kh\u00e1m ph\u00e1\nc\u00e1ch t\u1eeb v\u1ef1ng n\u00e0y \u0111\u01b0\u1ee3c s\u1eed d\u1ee5ng nh\u00e9!',
            textAlign: TextAlign.center,
            style: KivoTextStyles.body.copyWith(
              fontSize: KivoScale.sp(12, min: 10),
              fontWeight: FontWeight.w700,
              color: KivoColors.coffeeText,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscoveryContextBottomSheet extends StatelessWidget {
  const _DiscoveryContextBottomSheet({required this.contextNode});

  final DiscoveryContextNode contextNode;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          KivoScale.w(24),
          KivoScale.h(12),
          KivoScale.w(24),
          KivoScale.h(24),
        ),
        decoration: BoxDecoration(
          color: KivoColors.lightSurface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(KivoScale.r(32)),
          ),
          boxShadow: KivoShadows.soft,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: KivoScale.w(72),
              height: KivoScale.h(6),
              decoration: BoxDecoration(
                color: KivoColors.lightBorder,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            SizedBox(height: KivoScale.h(18)),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contextNode.title,
                        style: KivoTextStyles.sectionTitle.copyWith(
                          fontSize: KivoScale.sp(24, min: 18),
                        ),
                      ),
                      Text(
                        contextNode.sentence,
                        style: KivoTextStyles.body.copyWith(
                          fontSize: KivoScale.sp(15, min: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    KivoIconRegistry.system('close', tone: KivoIconTone.bold),
                    color: KivoColors.secondaryText,
                  ),
                ),
              ],
            ),
            SizedBox(height: KivoScale.h(18)),
            for (final line in contextNode.dialogue)
              _DialogueBubble(line: line),
            SizedBox(height: KivoScale.h(10)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(KivoScale.w(16)),
              decoration: BoxDecoration(
                color: KivoColors.warmCard,
                borderRadius: BorderRadius.circular(KivoScale.r(18)),
                border: Border.all(
                  color: KivoColors.warningGold.withAlpha(180),
                ),
              ),
              child: Text(
                contextNode.tip,
                style: KivoTextStyles.body.copyWith(
                  fontSize: KivoScale.sp(15, min: 12),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogueBubble extends StatelessWidget {
  const _DialogueBubble({required this.line});

  final DiscoveryDialogueLine line;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: KivoScale.h(10)),
      padding: EdgeInsets.all(KivoScale.w(14)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KivoScale.r(18)),
        border: Border.all(color: KivoColors.lightBorder),
      ),
      child: RichText(
        text: TextSpan(
          style: KivoTextStyles.body.copyWith(
            fontSize: KivoScale.sp(15, min: 12),
          ),
          children: [
            TextSpan(
              text: '${line.speaker}: ',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            TextSpan(text: line.text),
          ],
        ),
      ),
    );
  }
}

class _DiscoveryLoadingState extends StatelessWidget {
  const _DiscoveryLoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(KivoScale.w(30)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: KivoColors.targetPurple),
            SizedBox(height: KivoScale.h(16)),
            Text(
              '\u0110ang m\u1edf Ma tr\u1eadn Kh\u00e1m ph\u00e1...',
              style: KivoTextStyles.body,
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscoveryMessageState extends StatelessWidget {
  const _DiscoveryMessageState({
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(KivoScale.w(30)),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(KivoScale.w(24)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(KivoScale.r(28)),
            border: Border.all(color: KivoColors.lightBorder),
            boxShadow: KivoShadows.soft,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: KivoTextStyles.sectionTitle.copyWith(
                  fontSize: KivoScale.sp(24, min: 18),
                ),
              ),
              SizedBox(height: KivoScale.h(10)),
              Text(
                message,
                textAlign: TextAlign.center,
                style: KivoTextStyles.body.copyWith(
                  fontSize: KivoScale.sp(16, min: 12),
                ),
              ),
              SizedBox(height: KivoScale.h(18)),
              FilledButton(onPressed: onPressed, child: Text(buttonLabel)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DecorMark {
  const _DecorMark(this.x, this.y, this.color, this.star);

  final double x;
  final double y;
  final Color color;
  final bool star;
}
