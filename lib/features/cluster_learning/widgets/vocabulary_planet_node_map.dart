import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/icons/kivo_icon_registry.dart';
import '../../../app/theme/kivo_theme_tokens.dart';
import '../view_model/vocabulary_planet_view_state.dart';

class VocabularyPlanetNodeMap extends StatelessWidget {
  const VocabularyPlanetNodeMap({
    super.key,
    required this.nodes,
    required this.onNodeSelected,
  });

  final List<VocabularyPlanetNodeData> nodes;
  final ValueChanged<VocabularyPlanetNodeData> onNodeSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mapWidth = constraints.maxWidth;
        final isCompactSet = nodes.length <= 5;
        final mapHeight = isCompactSet
            ? math.max(mapWidth * 1.32, 500.0)
            : math.max(mapWidth * 2.16, 760.0);
        final starSize = _planetStarSize(mapWidth, isCompactSet: isCompactSet);
        final starCenter = Offset(
          mapWidth * 0.50,
          mapHeight * (isCompactSet ? 0.50 : 0.46),
        );

        return SizedBox(
          height: mapHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _PlanetDecorPainter(
                    starCenterRatioY: isCompactSet ? 0.50 : 0.46,
                  ),
                ),
              ),
              Positioned(
                left: starCenter.dx - starSize / 2,
                top: starCenter.dy - starSize / 2,
                child: _ProgressStar(size: starSize),
              ),
              for (var index = 0; index < nodes.length; index += 1)
                _PositionedPlanetNode(
                  node: nodes[index],
                  index: index,
                  totalCount: nodes.length,
                  mapWidth: mapWidth,
                  mapHeight: mapHeight,
                  starCenter: starCenter,
                  useCompactOrbit: isCompactSet,
                  onTap: () => onNodeSelected(nodes[index]),
                ),
            ],
          ),
        );
      },
    );
  }

  static double _planetStarSize(double mapWidth, {required bool isCompactSet}) {
    return (mapWidth * (isCompactSet ? 0.23 : 0.25)).clamp(82.0, 112.0);
  }
}

class _PositionedPlanetNode extends StatelessWidget {
  const _PositionedPlanetNode({
    required this.node,
    required this.index,
    required this.totalCount,
    required this.mapWidth,
    required this.mapHeight,
    required this.starCenter,
    required this.useCompactOrbit,
    required this.onTap,
  });

  final VocabularyPlanetNodeData node;
  final int index;
  final int totalCount;
  final double mapWidth;
  final double mapHeight;
  final Offset starCenter;
  final bool useCompactOrbit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = _nodeSize(
      mapWidth,
      node.size,
      useCompactOrbit: useCompactOrbit,
    );
    final center = useCompactOrbit
        ? _compactOrbitCenter(
            index,
            totalCount,
            mapWidth,
            mapHeight,
            starCenter,
          )
        : Offset(
            ((node.alignment.x + 1) / 2) * mapWidth,
            ((node.alignment.y + 1) / 2) * mapHeight,
          );
    final breathingRoom = size * 0.1;
    final left = (center.dx - size / 2).clamp(
      breathingRoom,
      mapWidth - size - breathingRoom,
    );
    final top = (center.dy - size / 2).clamp(
      breathingRoom,
      mapHeight - size - breathingRoom,
    );

    return Positioned(
      left: left,
      top: top,
      child: _VocabularyPlanetNode(node: node, size: size, onTap: onTap),
    );
  }

  static Offset _compactOrbitCenter(
    int index,
    int totalCount,
    double mapWidth,
    double mapHeight,
    Offset starCenter,
  ) {
    if (totalCount == 5) {
      final positions = <Offset>[
        Offset(mapWidth * 0.50, mapHeight * 0.14),
        Offset(mapWidth * 0.80, mapHeight * 0.36),
        Offset(mapWidth * 0.68, mapHeight * 0.78),
        Offset(mapWidth * 0.32, mapHeight * 0.78),
        Offset(mapWidth * 0.20, mapHeight * 0.36),
      ];
      return positions[index];
    }

    final radiusX = mapWidth * 0.32;
    final radiusY = mapHeight * 0.33;
    final startAngle = -math.pi / 2;
    final angle = startAngle + (math.pi * 2 * index / totalCount);
    return Offset(
      starCenter.dx + math.cos(angle) * radiusX,
      starCenter.dy + math.sin(angle) * radiusY,
    );
  }

  static double _nodeSize(
    double mapWidth,
    double designSize, {
    required bool useCompactOrbit,
  }) {
    final denominator = useCompactOrbit ? 500.0 : 540.0;
    final minSize = useCompactOrbit ? 82.0 : 72.0;
    final maxSize = useCompactOrbit ? 120.0 : 116.0;
    return (mapWidth * (designSize / denominator)).clamp(minSize, maxSize);
  }
}

class _VocabularyPlanetNode extends StatelessWidget {
  const _VocabularyPlanetNode({
    required this.node,
    required this.size,
    required this.onTap,
  });

  final VocabularyPlanetNodeData node;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = VocabularyNodePalette.fromNode(node);
    final isLocked = node.status == VocabularyNodeStatus.locked;
    final label = node.label.replaceAll('\n', ' ');

    return Semantics(
      button: true,
      label: label,
      enabled: !isLocked,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          key: ValueKey('vocabulary-node-${node.id}'),
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: palette.rim,
            boxShadow: [
              BoxShadow(
                color: palette.shadow,
                blurRadius: size * 0.1,
                offset: Offset(0, size * 0.07),
              ),
            ],
          ),
          padding: EdgeInsets.only(bottom: size * 0.06),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.35, -0.45),
                radius: 0.95,
                colors: [Colors.white.withAlpha(246), palette.surface],
              ),
              border: Border.all(color: palette.border, width: 1.1),
            ),
            alignment: Alignment.center,
            child: SizedBox(
              width: size * 0.74,
              height: size * 0.45,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Text(
                  node.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: KivoTextStyles.cardTitle.copyWith(
                    color: palette.text,
                    fontSize: 22,
                    height: 1.02,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressStar extends StatelessWidget {
  const _ProgressStar({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: KivoColors.softMintCard.withAlpha(168),
              border: Border.all(
                color: KivoColors.kivoTeal.withAlpha(70),
                width: 1.4,
              ),
            ),
          ),
          SizedBox(
            width: size * 0.83,
            height: size * 0.83,
            child: CircularProgressIndicator(
              value: 0.72,
              strokeWidth: size * 0.075,
              backgroundColor: Colors.white.withAlpha(190),
              color: KivoColors.kivoTeal,
              strokeCap: StrokeCap.round,
            ),
          ),
          Container(
            width: size * 0.56,
            height: size * 0.56,
            decoration: const BoxDecoration(
              color: KivoColors.lightSurface,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              KivoIconRegistry.reward('star', tone: KivoIconTone.fill),
              color: KivoColors.warningGold,
              size: size * 0.32,
              shadows: const [
                Shadow(color: KivoColors.actionOrange, blurRadius: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanetDecorPainter extends CustomPainter {
  const _PlanetDecorPainter({required this.starCenterRatioY});

  final double starCenterRatioY;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke;
    final fill = Paint()..style = PaintingStyle.fill;
    final marks = <_DecorMark>[
      _DecorMark(0.07, 0.03, KivoColors.warningGold, true),
      _DecorMark(0.28, 0.03, KivoColors.kivoTeal, false),
      _DecorMark(0.76, 0.02, KivoColors.keywordBlue, false),
      _DecorMark(0.96, 0.05, KivoColors.warningGold, true),
      _DecorMark(0.04, 0.34, KivoColors.errorCoral, true),
      _DecorMark(0.29, 0.34, KivoColors.errorCoral, false),
      _DecorMark(0.96, 0.22, KivoColors.kivoTeal, true),
      _DecorMark(0.94, 0.49, KivoColors.warningGold, true),
      _DecorMark(0.05, 0.58, KivoColors.kivoTeal, true),
      _DecorMark(0.73, 0.69, KivoColors.keywordBlue, false),
      _DecorMark(0.35, 0.82, KivoColors.kivoTeal, true),
      _DecorMark(0.97, 0.92, KivoColors.kivoTeal, true),
      _DecorMark(0.39, 0.94, KivoColors.warningGold, true),
      _DecorMark(0.06, 0.96, KivoColors.errorCoral, false),
      _DecorMark(0.31, 0.99, KivoColors.keywordBlue, false),
    ];

    for (final mark in marks) {
      final center = Offset(size.width * mark.x, size.height * mark.y);
      if (mark.star) {
        _drawStar(canvas, center, size.shortestSide * 0.018, mark.color);
      } else {
        fill.color = mark.color.withAlpha(74);
        paint
          ..color = mark.color.withAlpha(190)
          ..strokeWidth = 1.4;
        canvas.drawCircle(center, size.shortestSide * 0.012, fill);
        canvas.drawCircle(center, size.shortestSide * 0.012, paint);
      }
    }

    final center = Offset(size.width * 0.50, size.height * starCenterRatioY);
    paint
      ..color = KivoColors.kivoTeal.withAlpha(56)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 18; i += 1) {
      final angle = (math.pi * 2 / 18) * i;
      final start = Offset(
        center.dx + math.cos(angle) * size.shortestSide * 0.10,
        center.dy + math.sin(angle) * size.shortestSide * 0.10,
      );
      final end = Offset(
        center.dx + math.cos(angle) * size.shortestSide * 0.13,
        center.dy + math.sin(angle) * size.shortestSide * 0.13,
      );
      canvas.drawLine(start, end, paint);
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

    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withAlpha(68);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..color = color.withAlpha(210);
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _PlanetDecorPainter oldDelegate) {
    return oldDelegate.starCenterRatioY != starCenterRatioY;
  }
}

class _DecorMark {
  const _DecorMark(this.x, this.y, this.color, this.star);

  final double x;
  final double y;
  final Color color;
  final bool star;
}
