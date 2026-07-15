part of 'secret_passage_story_view.dart';

class _EnergyLinkPainter extends CustomPainter {
  const _EnergyLinkPainter({required this.progress, required this.pulse});

  final double progress;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;

    final nodes = {
      'center': Offset(0.525 * size.width, 0.69 * size.height),
      'leftMid': Offset(0.18 * size.width, 0.56 * size.height),
      'rightMid': Offset(0.83 * size.width, 0.56 * size.height),
      'farLeft': Offset(0.35 * size.width, 0.46 * size.height),
      'farRight': Offset(0.65 * size.width, 0.46 * size.height),
      'altar': Offset(0.50 * size.width, 0.385 * size.height),
    };

    final center = nodes['center']!;
    final leftMid = nodes['leftMid']!;
    final rightMid = nodes['rightMid']!;
    final farLeft = nodes['farLeft']!;
    final farRight = nodes['farRight']!;
    final altar = nodes['altar']!;

    final scale = size.width / 778.0;

    final paths = [
      _EnergyPath(
        begin: center,
        end: leftMid,
        start: 0.00,
        endTime: 0.35,
      ),
      _EnergyPath(
        begin: center,
        end: rightMid,
        start: 0.00,
        endTime: 0.35,
      ),
      _EnergyPath(
        begin: leftMid,
        end: farLeft,
        start: 0.30,
        endTime: 0.65,
      ),
      _EnergyPath(
        begin: rightMid,
        end: farRight,
        start: 0.30,
        endTime: 0.65,
      ),
      _EnergyPath(
        begin: farLeft,
        end: altar,
        start: 0.60,
        endTime: 0.95,
      ),
      _EnergyPath(
        begin: farRight,
        end: altar,
        start: 0.60,
        endTime: 0.95,
      ),
    ];

    final pulseWave = 0.65 + 0.35 * pulse;

    final floorGlowPaint = Paint()
      ..color = const Color(0x0C1FE4CE)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * 0.16 * pulseWave
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.10);

    final floorReflectPaint = Paint()
      ..color = const Color(0x1F65FBE8)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * 0.07 * pulseWave
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.04);

    final glowPaint = Paint()
      ..color = const Color(0x1A65FBE8)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * 0.025
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.016);

    final tealGlowPaint = Paint()
      ..color = const Color(0x551FE4CE)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * 0.008
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.005);

    final tealPaint = Paint()
      ..color = const Color(0xBB1FE4CE)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * 0.003;

    final corePaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * 0.0013;

    final double time = DateTime.now().millisecondsSinceEpoch / 1000.0;

    final List<List<Offset>> allPlasmaPoints = [];
    final List<List<Offset>> allCracklePoints = [];
    final List<double> localProgresses = [];
    final List<Offset> currentEnds = [];

    // Base wave settings for natural magic flow
    const waveAmplitude = 14.0;
    const waveFrequency = 1.4;
    const waveSpeed = 6.0;

    for (int i = 0; i < paths.length; i++) {
      final pathData = paths[i];
      final localProgress =
          ((progress - pathData.start) / (pathData.endTime - pathData.start))
              .clamp(0.0, 1.0);
      localProgresses.add(localProgress);

      final currentEnd = Offset(
        pathData.begin.dx + (pathData.end.dx - pathData.begin.dx) * localProgress,
        pathData.begin.dy + (pathData.end.dy - pathData.begin.dy) * localProgress,
      );
      currentEnds.add(currentEnd);

      if (localProgress <= 0.0) {
        allPlasmaPoints.add([]);
        allCracklePoints.add([]);
        continue;
      }

      // Generate undulating plasma points
      final plasma = _getPlasmaPoints(
        begin: pathData.begin,
        currentEnd: currentEnd,
        localProgress: localProgress,
        time: time,
        scale: scale,
        waveAmplitude: waveAmplitude,
        waveFrequency: waveFrequency,
        speed: waveSpeed,
      );
      allPlasmaPoints.add(plasma);

      // Generate dynamic high-frequency crackle points
      final crackle = _getCracklePoints(
        begin: pathData.begin,
        currentEnd: currentEnd,
        localProgress: localProgress,
        time: time,
        scale: scale,
        pathIndex: i,
        amplitude: 10.0,
      );
      allCracklePoints.add(crackle);
    }

    // 1. Draw floor glows and atmospheric back glows
    for (int i = 0; i < paths.length; i++) {
      final localProgress = localProgresses[i];
      if (localProgress <= 0.0) continue;

      final plasma = allPlasmaPoints[i];
      if (plasma.isEmpty) continue;

      final floorPath = Path();
      floorPath.moveTo(plasma.first.dx, plasma.first.dy);
      for (final pt in plasma.skip(1)) {
        floorPath.lineTo(pt.dx, pt.dy);
      }

      // Draw diffuse floor reflections & atmospheric blooms
      canvas.drawPath(floorPath, floorGlowPaint);
      canvas.drawPath(floorPath, floorReflectPaint);
      canvas.drawPath(floorPath, glowPaint);
      canvas.drawPath(floorPath, tealGlowPaint);
    }

    // 2. Draw plasma core, crackles, and flowing sparks
    for (int i = 0; i < paths.length; i++) {
      final localProgress = localProgresses[i];
      if (localProgress <= 0.0) continue;

      final plasma = allPlasmaPoints[i];
      final crackle = allCracklePoints[i];
      final pathData = paths[i];

      // Draw plasma core
      if (plasma.isNotEmpty) {
        final plasmaPath = Path();
        plasmaPath.moveTo(plasma.first.dx, plasma.first.dy);
        for (final pt in plasma.skip(1)) {
          plasmaPath.lineTo(pt.dx, pt.dy);
        }
        canvas.drawPath(plasmaPath, tealPaint);
        canvas.drawPath(plasmaPath, corePaint);
      }

      // Draw highly-dynamic electric arc overlay
      if (crackle.isNotEmpty) {
        final cracklePath = Path();
        cracklePath.moveTo(crackle.first.dx, crackle.first.dy);
        for (final pt in crackle.skip(1)) {
          cracklePath.lineTo(pt.dx, pt.dy);
        }

        final cracklePaint = Paint()
          ..color = const Color(0xAAE6FFFB)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 0.9 * scale;

        final crackleGlow = Paint()
          ..color = const Color(0x441FE4CE)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 3.5 * scale
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1.8 * scale);

        canvas.drawPath(cracklePath, crackleGlow);
        canvas.drawPath(cracklePath, cracklePaint);
      }

      // Draw flowing particles/sparks along the paths
      _drawFlowingParticles(
        canvas: canvas,
        begin: pathData.begin,
        end: pathData.end,
        localProgress: localProgress,
        time: time,
        scale: scale,
        pulseWave: pulseWave,
        waveAmplitude: waveAmplitude,
        waveFrequency: waveFrequency,
        waveSpeed: waveSpeed,
      );

      // Draw active head spark (only when the path is currently growing)
      if (localProgress < 1.0 && plasma.isNotEmpty) {
        final sparkPaint = Paint()
          ..color = const Color(0xFFFFFFFF)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.012);
        canvas.drawCircle(plasma.last, size.width * 0.016, sparkPaint);
      }
    }
  }

  List<Offset> _getPlasmaPoints({
    required Offset begin,
    required Offset currentEnd,
    required double localProgress,
    required double time,
    required double scale,
    required double waveAmplitude,
    required double waveFrequency,
    required double speed,
  }) {
    final List<Offset> points = [];
    const steps = 30;

    final dx = currentEnd.dx - begin.dx;
    final dy = currentEnd.dy - begin.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len < 1.0) return points;

    final nx = -dy / len;
    final ny = dx / len;

    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      final pt = Offset(
        begin.dx + dx * t,
        begin.dy + dy * t,
      );

      final tAbsolute = t * localProgress;
      // Anchor the displacements to 0 at the absolute ends of the segment
      final anchor = math.sin(tAbsolute * math.pi);

      final phase1 = tAbsolute * math.pi * waveFrequency - time * speed;
      final phase2 = tAbsolute * math.pi * (waveFrequency * 2.1) + time * (speed * 1.4);
      final wave = (math.sin(phase1) * 0.72 + math.cos(phase2) * 0.28) * waveAmplitude * scale;

      points.add(Offset(
        pt.dx + nx * wave * anchor,
        pt.dy + ny * wave * anchor,
      ));
    }
    return points;
  }

  List<Offset> _getCracklePoints({
    required Offset begin,
    required Offset currentEnd,
    required double localProgress,
    required double time,
    required double scale,
    required int pathIndex,
    required double amplitude,
  }) {
    final List<Offset> points = [];
    const steps = 22;

    final dx = currentEnd.dx - begin.dx;
    final dy = currentEnd.dy - begin.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len < 1.0) return points;

    final nx = -dy / len;
    final ny = dx / len;

    // Use discrete time steps to animate the lightning's chaotic jump (crackle at 16fps)
    final frameIndex = (time * 16.0).floor();
    final rand = math.Random(frameIndex * 19 + pathIndex);

    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      final pt = Offset(
        begin.dx + dx * t,
        begin.dy + dy * t,
      );

      final tAbsolute = t * localProgress;
      final anchor = math.sin(tAbsolute * math.pi);

      // Fractal displacement (coarse noise + fine detail)
      final coarseNoise = (rand.nextDouble() * 2.0 - 1.0) * amplitude * scale;
      final fineNoise = (rand.nextDouble() * 2.0 - 1.0) * (amplitude * 0.45) * scale;
      final noise = coarseNoise * 0.7 + fineNoise * 0.3;

      points.add(Offset(
        pt.dx + nx * noise * anchor,
        pt.dy + ny * noise * anchor,
      ));
    }
    return points;
  }

  void _drawFlowingParticles({
    required Canvas canvas,
    required Offset begin,
    required Offset end,
    required double localProgress,
    required double time,
    required double scale,
    required double pulseWave,
    required double waveAmplitude,
    required double waveFrequency,
    required double waveSpeed,
  }) {
    final dx = end.dx - begin.dx;
    final dy = end.dy - begin.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len < 1.0) return;

    final nx = -dy / len;
    final ny = dx / len;

    const particleCount = 2;
    for (int p = 0; p < particleCount; p++) {
      final double pOffset = p / particleCount;
      const particleSpeed = 0.45;
      final double tParticle = (time * particleSpeed + pOffset) % 1.0;

      // Draw particle only if the growing beam has passed this point
      if (tParticle <= localProgress) {
        final ptNominal = Offset(
          begin.dx + dx * tParticle,
          begin.dy + dy * tParticle,
        );

        final anchor = math.sin(tParticle * math.pi);

        final phase1 = tParticle * math.pi * waveFrequency - time * waveSpeed;
        final phase2 = tParticle * math.pi * (waveFrequency * 2.1) + time * (waveSpeed * 1.4);
        final wave = (math.sin(phase1) * 0.72 + math.cos(phase2) * 0.28) * waveAmplitude * scale;

        final pt = Offset(
          ptNominal.dx + nx * wave * anchor,
          ptNominal.dy + ny * wave * anchor,
        );

        final glowPaint = Paint()
          ..color = const Color(0xDD65FBE8)
          ..blendMode = BlendMode.plus
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4.5 * scale);

        final corePaint = Paint()
          ..color = const Color(0xFFFFFFFF);

        canvas.drawCircle(pt, 6.0 * scale * pulseWave, glowPaint);
        canvas.drawCircle(pt, 2.0 * scale, corePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _EnergyLinkPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.pulse != pulse;
  }
}

class _EnergyPath {
  const _EnergyPath({
    required this.begin,
    required this.end,
    required this.start,
    required this.endTime,
  });

  final Offset begin;
  final Offset end;
  final double start;
  final double endTime;
}
