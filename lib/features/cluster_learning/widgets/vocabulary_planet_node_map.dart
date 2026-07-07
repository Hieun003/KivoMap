import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/icons/kivo_icon_registry.dart';
import '../../../app/theme/kivo_theme_tokens.dart';
import '../view_model/vocabulary_planet_view_state.dart';

class VocabularyPlanetNodeMap extends StatelessWidget {
  const VocabularyPlanetNodeMap({
    super.key,
    required this.nodes,
    required this.progressRatio,
    required this.onNodeSelected,
  });

  final List<VocabularyPlanetNodeData> nodes;
  final double progressRatio;
  final ValueChanged<VocabularyPlanetNodeData> onNodeSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mapWidth = constraints.maxWidth;
        final isCompactSet = nodes.length <= 6;
        final mapHeight = isCompactSet
            ? math.max(mapWidth * 1.34, 520.0)
            : math.max(mapWidth * 1.78, 700.0);
        final starSize = _planetStarSize(mapWidth, isCompactSet: isCompactSet);
        final starCenter = Offset(
          mapWidth * 0.50,
          mapHeight * (isCompactSet ? 0.50 : 0.48),
        );

        return SizedBox(
          height: mapHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _PlanetDecorPainter(
                    starCenterRatioY: isCompactSet ? 0.50 : 0.48,
                  ),
                ),
              ),
              Positioned(
                left: starCenter.dx - starSize / 2,
                top: starCenter.dy - starSize / 2,
                child: _ProgressStar(
                  size: starSize,
                  progressRatio: progressRatio,
                ),
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
      mapHeight - size - breathingRoom - 44.0, // reserve for label below circle
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
    final radiusX = mapWidth * 0.34;
    final radiusY = mapHeight * 0.29;
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
    final denominator = useCompactOrbit ? 610.0 : 560.0;
    final minSize = useCompactOrbit ? 74.0 : 70.0;
    final maxSize = useCompactOrbit ? 104.0 : 108.0;
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
    final label = node.label.replaceAll('\n', ' ');
    final statusLabel = _statusLabel(node.status);
    final isQuiet = node.status == VocabularyNodeStatus.notStarted;

    return Semantics(
      button: true,
      label: '$label, $statusLabel',
      enabled: true,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: Container(
                      key: ValueKey('vocabulary-node-${node.id}'),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: palette.rim,
                        boxShadow: [
                          BoxShadow(
                            color: palette.shadow,
                            blurRadius: size * (isQuiet ? 0.06 : 0.1),
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
                            colors: [
                              Colors.white.withAlpha(isQuiet ? 228 : 246),
                              palette.surface,
                            ],
                          ),
                          border: Border.all(
                            color: palette.border,
                            width: isQuiet ? 1.3 : 1.1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          KivoIconRegistry.vocabulary(
                            node.iconKey,
                            tone: KivoIconTone.fill,
                          ),
                          size: size * 0.42,
                          color: palette.text,
                        ),
                      ),
                    ),
                  ),
                  if (node.status != VocabularyNodeStatus.notStarted)
                    Positioned(
                      right: -2,
                      top: -3,
                      child: _NodeStatusBadge(status: node.status, size: size),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: size * 1.15,
              height: 38,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: KivoTextStyles.cardTitle.copyWith(
                  color: palette.text,
                  fontSize: 13,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(VocabularyNodeStatus status) {
    return switch (status) {
      VocabularyNodeStatus.notStarted => 'chua hoc, co the bam de kham pha',
      VocabularyNodeStatus.inProgress => 'dang hoc',
      VocabularyNodeStatus.srsActive => 'da vao SRS',
      VocabularyNodeStatus.reviewDue => 'den han on tap',
      VocabularyNodeStatus.mastered => 'da nam vung',
    };
  }
}

class _NodeStatusBadge extends StatelessWidget {
  const _NodeStatusBadge({required this.status, required this.size});

  final VocabularyNodeStatus status;
  final double size;

  @override
  Widget build(BuildContext context) {
    final icon = switch (status) {
      VocabularyNodeStatus.inProgress => KivoIconRegistry.reward(
        'star',
        tone: KivoIconTone.fill,
      ),
      VocabularyNodeStatus.reviewDue => KivoIconRegistry.system(
        'review',
        tone: KivoIconTone.fill,
      ),
      VocabularyNodeStatus.mastered => KivoIconRegistry.reward(
        'trophy',
        tone: KivoIconTone.fill,
      ),
      _ => KivoIconRegistry.system('check', tone: KivoIconTone.fill),
    };
    final color = switch (status) {
      VocabularyNodeStatus.inProgress => KivoColors.warningGold,
      VocabularyNodeStatus.reviewDue => KivoColors.actionOrange,
      VocabularyNodeStatus.mastered => KivoColors.successGreen,
      _ => KivoColors.kivoTeal,
    };

    return Container(
      width: size * 0.27,
      height: size * 0.27,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(245),
        shape: BoxShape.circle,
        border: Border.all(color: color.withAlpha(190), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(55),
            blurRadius: size * 0.06,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: color, size: size * 0.15),
    );
  }
}

class _ProgressStar extends StatelessWidget {
  const _ProgressStar({required this.size, required this.progressRatio});

  final double size;
  final double progressRatio;

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
              value: progressRatio.clamp(0.0, 1.0),
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
