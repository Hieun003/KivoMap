import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/icons/kivo_icon_registry.dart';
import '../../../app/responsive/kivo_scale.dart';
import '../../../app/theme/kivo_theme_tokens.dart';
import '../view_model/discovery_view_state.dart';

class DiscoveryMatrixMap extends StatelessWidget {
  const DiscoveryMatrixMap({
    super.key,
    required this.state,
    required this.selectedContextId,
    required this.discoveredContextIds,
    required this.onContextTap,
  });

  final DiscoveryMatrixState state;
  final String? selectedContextId;
  final Set<String> discoveredContextIds;
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
        final rootSize = 96.0 * canvasScale;
        final rootCenter = Offset(
          canvasLeft + canvasWidth * 0.50,
          mapHeight * 0.50,
        );
        final cardSize = Size(152.0 * canvasScale, 68.0 * canvasScale);

        // Safe area mapping: map alignments to safe center bounds where cards never overflow the canvas boundaries
        final safeWidth =
            canvasWidth - cardSize.width - 12.0; // 6px margin on left & right
        final safeHeight =
            mapHeight - cardSize.height - 40.0; // 22px top, 18px bottom margin
        final contextCenters = {
          for (final node in state.contexts)
            node.id: Offset(
              canvasLeft +
                  6.0 +
                  cardSize.width / 2 +
                  ((node.alignment.x + 1) / 2) * safeWidth,
              22.0 +
                  cardSize.height / 2 +
                  ((node.alignment.y + 1) / 2) * safeHeight,
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
                    discoveredContextIds: discoveredContextIds,
                  ),
                ),
              ),
              for (final contextNode in state.contexts)
                _PositionedContextCard(
                  contextNode: contextNode,
                  center: contextCenters[contextNode.id]!,
                  cardSize: cardSize,
                  scale: canvasScale,
                  isSelected: selectedContextId == contextNode.id,
                  isDiscovered: discoveredContextIds.contains(contextNode.id),
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
    required this.scale,
    required this.isSelected,
    required this.isDiscovered,
    required this.onTap,
  });

  final DiscoveryContextNode contextNode;
  final Offset center;
  final Size cardSize;
  final double scale;
  final bool isSelected;
  final bool isDiscovered;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: center.dx - cardSize.width / 2,
      top: center.dy - cardSize.height / 2,
      width: cardSize.width,
      height: cardSize.height,
      child: _DiscoveryContextCard(
        contextNode: contextNode,
        scale: scale,
        isSelected: isSelected,
        isDiscovered: isDiscovered,
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
    required this.isDiscovered,
    required this.onTap,
  });

  final DiscoveryContextNode contextNode;
  final double scale;
  final bool isSelected;
  final bool isDiscovered;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cardScale = scale;
    final isActive = isSelected || isDiscovered || contextNode.isDiscovered;
    final borderColor = isSelected
        ? const Color(0xFF99E22C)
        : isDiscovered || contextNode.isDiscovered
        ? KivoColors.successGreen
        : const Color(0xFFD7C1A2);
    final iconColor = isSelected
        ? const Color(0xFF99E22C)
        : isDiscovered || contextNode.isDiscovered
        ? KivoColors.successGreen
        : KivoColors.actionOrange;

    return Semantics(
      button: true,
      enabled: true,
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
                cardScale * 12,
                cardScale * 6,
                cardScale * 10,
                cardScale * 6,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFF1FFE7)
                    : Colors.white.withAlpha(242),
                borderRadius: BorderRadius.circular(20 * cardScale),
                border: Border.all(
                  color: borderColor,
                  width: isSelected
                      ? 2.0
                      : (isDiscovered || contextNode.isDiscovered ? 1.5 : 1.0),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF99E22C).withAlpha(120),
                          blurRadius: 10.0 * cardScale,
                          spreadRadius: 1.5 * cardScale,
                        ),
                      ]
                    : KivoShadows.soft,
              ),
              child: Row(
                children: [
                  Container(
                    width: 38 * cardScale,
                    height: 38 * cardScale,
                    decoration: BoxDecoration(
                      color: isActive
                          ? KivoColors.softMintCard.withAlpha(210)
                          : KivoColors.warmCard.withAlpha(180),
                      borderRadius: BorderRadius.circular(12 * cardScale),
                      border: Border.all(color: borderColor.withAlpha(130)),
                    ),
                    child: Icon(
                      KivoIconRegistry.vocabulary(
                        contextNode.iconKey,
                        tone: KivoIconTone.duotone,
                      ),
                      color: iconColor,
                      size: 22 * cardScale,
                    ),
                  ),
                  SizedBox(width: 8 * cardScale),
                  Expanded(
                    child: Text(
                      contextNode.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: KivoTextStyles.cardTitle.copyWith(
                        color: KivoColors.inkText,
                        fontSize: 15.0 * cardScale,
                        height: 1.04,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: -6 * cardScale,
              top: -8 * cardScale,
              child: Container(
                width: 26 * cardScale,
                height: 26 * cardScale,
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
                    fontSize: 12 * cardScale,
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
        color: Colors.white.withAlpha(242),
        border: Border.all(color: node.accentColor.withAlpha(190), width: 2.8),
        boxShadow: [
          BoxShadow(
            color: node.accentColor.withAlpha(118),
            blurRadius: KivoScale.r(24),
            spreadRadius: KivoScale.r(4),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          KivoIconRegistry.vocabulary(node.iconKey, tone: KivoIconTone.duotone),
          color: node.accentColor,
          size: size * 0.48,
        ),
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
    required this.discoveredContextIds,
  });

  final Offset rootCenter;
  final Map<String, Offset> cardCenters;
  final Size cardSize;
  final List<DiscoveryContextNode> contexts;
  final String? selectedContextId;
  final Set<String> discoveredContextIds;

  @override
  void paint(Canvas canvas, Size size) {
    _drawMarks(canvas, size);
    _drawPaths(canvas);
  }

  void _drawPaths(Canvas canvas) {
    for (final context in contexts) {
      final cardCenter = cardCenters[context.id]!;
      final target = _edgePointToward(cardCenter, rootCenter, cardSize);
      final isSelected = selectedContextId == context.id;
      final isDiscovered =
          discoveredContextIds.contains(context.id) || context.isDiscovered;

      if (isSelected) {
        // Outer glow
        final glowOuter = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14.0
          ..strokeCap = StrokeCap.round
          ..color = KivoColors.warningGold.withAlpha(45);
        canvas.drawPath(_wavyCurvedPath(target, rootCenter), glowOuter);

        // Mid glow
        final glowMid = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8.0
          ..strokeCap = StrokeCap.round
          ..color = KivoColors.warningGold.withAlpha(110);
        canvas.drawPath(_wavyCurvedPath(target, rootCenter), glowMid);

        // Inner core
        final paintCore = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..strokeCap = StrokeCap.round
          ..color = Colors.white;
        canvas.drawPath(_wavyCurvedPath(target, rootCenter), paintCore);

        // Draw 4-pointed sparkles mathematically along the wavy path
        _drawPathSparkles(canvas, target, rootCenter);
      } else if (isDiscovered) {
        final discoveredPath = _wavyCurvedPath(
          target,
          rootCenter,
          waveAmplitude: 3.0,
          waveFrequency: 2.4,
        );
        final glow = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8.0
          ..strokeCap = StrokeCap.round
          ..color = KivoColors.warningGold.withAlpha(54);
        canvas.drawPath(discoveredPath, glow);

        final paintSolid = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.2
          ..strokeCap = StrokeCap.round
          ..color = KivoColors.warningGold.withAlpha(215);
        canvas.drawPath(discoveredPath, paintSolid);
      } else {
        // Undiscovered dashed line
        final paintDashed = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFFC0C0C0);
        _drawDashedPath(canvas, _curvedPath(target, rootCenter), paintDashed);
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

  void _drawPathSparkles(Canvas canvas, Offset start, Offset end) {
    final control = Offset(
      (start.dx + end.dx) / 2,
      (start.dy + end.dy) / 2 + (start.dx < end.dx ? 34 : -34),
    );

    // Sample 4 points along the curve (t = 0.2, 0.4, 0.6, 0.8)
    final points = <Offset>[];
    for (final t in [0.2, 0.4, 0.6, 0.8]) {
      final x =
          (1 - t) * (1 - t) * start.dx +
          2 * (1 - t) * t * control.dx +
          t * t * end.dx;
      final y =
          (1 - t) * (1 - t) * start.dy +
          2 * (1 - t) * t * control.dy +
          t * t * end.dy;
      points.add(Offset(x, y));
    }

    final color = KivoColors.warningGold;
    for (var i = 0; i < points.length; i++) {
      final p = points[i];

      final dx =
          2 * (1 - 0.5) * (control.dx - start.dx) +
          2 * 0.5 * (end.dx - control.dx);
      final dy =
          2 * (1 - 0.5) * (control.dy - start.dy) +
          2 * 0.5 * (end.dy - control.dy);
      final normal = Offset(-dy, dx);
      final unitNormal = normal.distance == 0
          ? Offset.zero
          : normal / normal.distance;

      final offsetDist = i == 0
          ? 12.0
          : i == 1
          ? -14.0
          : i == 2
          ? 10.0
          : -12.0;
      final finalPos = p + unitNormal * offsetDist;

      final radius = i.isEven ? 6.0 : 4.5;
      _draw4PointedSparkle(canvas, finalPos, radius, color);
    }
  }

  void _draw4PointedSparkle(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
  ) {
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final currentRadius = i.isEven ? radius : radius * 0.28;
      final angle = i * math.pi / 4;
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
        ..color = color.withAlpha(220),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = Colors.white.withAlpha(180),
    );
  }

  void _drawMarks(Canvas canvas, Size size) {
    final fill = Paint()..style = PaintingStyle.fill;
    final marks = <_DecorMark>[
      const _DecorMark(0.15, 0.07, KivoColors.kivoTeal, true),
      const _DecorMark(0.27, 0.12, KivoColors.errorCoral, true),
      const _DecorMark(0.44, 0.10, KivoColors.targetPurple, true),
      const _DecorMark(0.82, 0.11, KivoColors.errorCoral, true),
      const _DecorMark(0.94, 0.12, KivoColors.targetPurple, true),
      const _DecorMark(0.10, 0.40, KivoColors.kivoTeal, false),
      const _DecorMark(0.82, 0.46, KivoColors.kivoTeal, true),
      const _DecorMark(0.12, 0.76, KivoColors.errorCoral, true),
      const _DecorMark(0.46, 0.83, KivoColors.warningGold, true),
      const _DecorMark(0.86, 0.78, KivoColors.warningGold, false),
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
        oldDelegate.discoveredContextIds.length !=
            discoveredContextIds.length ||
        !oldDelegate.discoveredContextIds.containsAll(discoveredContextIds) ||
        oldDelegate.cardCenters != cardCenters;
  }
}

class _DecorMark {
  const _DecorMark(this.x, this.y, this.color, this.star);

  final double x;
  final double y;
  final Color color;
  final bool star;
}

Offset _edgePointToward(Offset center, Offset target, Size boxSize) {
  final delta = target - center;
  if (delta.distance == 0) {
    return center;
  }

  final scaleX = (boxSize.width / 2) / delta.dx.abs().clamp(1, double.infinity);
  final scaleY =
      (boxSize.height / 2) / delta.dy.abs().clamp(1, double.infinity);
  return center + delta * math.min(scaleX, scaleY);
}

Path _wavyCurvedPath(
  Offset start,
  Offset end, {
  double waveAmplitude = 5.0,
  double waveFrequency = 3.5,
}) {
  final path = Path()..moveTo(start.dx, start.dy);
  final control = Offset(
    (start.dx + end.dx) / 2,
    (start.dy + end.dy) / 2 + (start.dx < end.dx ? 34 : -34),
  );
  const steps = 30;
  for (var i = 1; i <= steps; i++) {
    final t = i / steps;
    final x =
        (1 - t) * (1 - t) * start.dx +
        2 * (1 - t) * t * control.dx +
        t * t * end.dx;
    final y =
        (1 - t) * (1 - t) * start.dy +
        2 * (1 - t) * t * control.dy +
        t * t * end.dy;

    final dx =
        2 * (1 - t) * (control.dx - start.dx) + 2 * t * (end.dx - control.dx);
    final dy =
        2 * (1 - t) * (control.dy - start.dy) + 2 * t * (end.dy - control.dy);
    final normal = Offset(-dy, dx);
    final unitNormal = normal.distance == 0
        ? Offset.zero
        : normal / normal.distance;

    final waveFactor = math.sin(t * math.pi * waveFrequency);
    final envelope = math.sin(t * math.pi); // smooth fade out at both ends
    final offsetPoint =
        Offset(x, y) + unitNormal * (waveFactor * envelope * waveAmplitude);
    path.lineTo(offsetPoint.dx, offsetPoint.dy);
  }
  return path;
}
