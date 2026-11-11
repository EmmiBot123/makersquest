// Custom Painters for MakerQuest Gamified Roadmap Trail & Connectors
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum RoadSegmentStatus {
  completed, // Forest green / emerald with golden studs
  active,    // Electric purple / indigo with glowing gold dashes
  locked,    // Cobblestone / slate stone with dotted footprint
}

/// Continuous multi-node Bezier road painter for MakerQuest
class ContinuousRoadPainter extends CustomPainter {
  final List<Offset> anchors;
  final List<RoadSegmentStatus> statuses;

  ContinuousRoadPainter({
    required this.anchors,
    required this.statuses,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (anchors.length < 2) return;
    final w = size.width;
    final h = size.height;
    if (w <= 0 || h <= 0) return;

    // Pass 1: Draw ambient drop shadows for all segments
    for (int i = 0; i < anchors.length - 1; i++) {
      final p1 = anchors[i];
      final p2 = anchors[i + 1];
      final dy = (p2.dy - p1.dy).abs();
      if (dy <= 0) continue;

      final path = Path();
      path.moveTo(p1.dx, p1.dy);
      path.cubicTo(
        p1.dx,
        p1.dy + dy * 0.5,
        p2.dx,
        p1.dy + dy * 0.5,
        p2.dx,
        p2.dy,
      );

      final shadowPaint = Paint()
        ..color = const Color(0x1E000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 46.0
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawPath(path, shadowPaint);
    }

    // Pass 2: Draw Curbs, Surface, Dashes, and Studs for each segment
    for (int i = 0; i < anchors.length - 1; i++) {
      final p1 = anchors[i];
      final p2 = anchors[i + 1];
      final dy = (p2.dy - p1.dy).abs();
      if (dy <= 0) continue;

      final path = Path();
      path.moveTo(p1.dx, p1.dy);
      path.cubicTo(
        p1.dx,
        p1.dy + dy * 0.5,
        p2.dx,
        p1.dy + dy * 0.5,
        p2.dx,
        p2.dy,
      );

      final status = i < statuses.length ? statuses[i] : RoadSegmentStatus.locked;

      switch (status) {
        case RoadSegmentStatus.completed:
          // 1. Curb
          final curbPaint = Paint()
            ..color = const Color(0xFF047857)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 36.0
            ..strokeCap = StrokeCap.round;
          canvas.drawPath(path, curbPaint);

          // 2. Surface
          final surfacePaint = Paint()
            ..shader = LinearGradient(
              colors: const [Color(0xFF34D399), Color(0xFF10B981)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(Rect.fromPoints(p1, p2))
            ..style = PaintingStyle.stroke
            ..strokeWidth = 26.0
            ..strokeCap = StrokeCap.round;
          canvas.drawPath(path, surfacePaint);

          // 3. Dashes
          final dashPaint = Paint()
            ..color = Colors.white.withValues(alpha: 0.95)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.5
            ..strokeCap = StrokeCap.round;
          _drawDashedPath(canvas, path, dashPaint, dashLength: 9.0, gapLength: 6.0);

          // 4. Milestone studs
          _drawMilestoneBeads(canvas, path, const Color(0xFFFDE047));
          break;

        case RoadSegmentStatus.active:
          // 1. Glow
          final glowPaint = Paint()
            ..color = AppColors.primary.withValues(alpha: 0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 44.0
            ..strokeCap = StrokeCap.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
          canvas.drawPath(path, glowPaint);

          // 2. Curb
          final curbPaint = Paint()
            ..color = const Color(0xFF4338CA)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 36.0
            ..strokeCap = StrokeCap.round;
          canvas.drawPath(path, curbPaint);

          // 3. Surface
          final surfacePaint = Paint()
            ..shader = LinearGradient(
              colors: const [Color(0xFF818CF8), Color(0xFF6366F1)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(Rect.fromPoints(p1, p2))
            ..style = PaintingStyle.stroke
            ..strokeWidth = 26.0
            ..strokeCap = StrokeCap.round;
          canvas.drawPath(path, surfacePaint);

          // 4. Gold Warning Dashes
          final dashPaint = Paint()
            ..color = const Color(0xFFFDE047)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.5
            ..strokeCap = StrokeCap.round;
          _drawDashedPath(canvas, path, dashPaint, dashLength: 8.0, gapLength: 6.0);

          // 5. Active studs
          _drawMilestoneBeads(canvas, path, Colors.white);
          break;

        case RoadSegmentStatus.locked:
          // 1. Curb
          final curbPaint = Paint()
            ..color = const Color(0xFFCBD5E1)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 32.0
            ..strokeCap = StrokeCap.round;
          canvas.drawPath(path, curbPaint);

          // 2. Surface
          final surfacePaint = Paint()
            ..color = const Color(0xFFF1F5F9)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 22.0
            ..strokeCap = StrokeCap.round;
          canvas.drawPath(path, surfacePaint);

          // 3. Dashes
          final dashPaint = Paint()
            ..color = const Color(0xFF94A3B8)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5
            ..strokeCap = StrokeCap.round;
          _drawDashedPath(canvas, path, dashPaint, dashLength: 7.0, gapLength: 7.0);
          break;
      }
    }
  }

  void _drawMilestoneBeads(Canvas canvas, Path path, Color color) {
    final beadPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (final metric in path.computeMetrics()) {
      if (metric.length <= 0) continue;
      for (final fraction in [0.25, 0.5, 0.75]) {
        final pos = metric.getTangentForOffset(metric.length * fraction)?.position;
        if (pos != null) {
          canvas.drawCircle(pos, 3.0, beadPaint);
        }
      }
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint, {required double dashLength, required double gapLength}) {
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final currentDash = (distance + dashLength < metric.length) ? dashLength : metric.length - distance;
        final extractPath = metric.extractPath(distance, distance + currentDash);
        canvas.drawPath(extractPath, paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant ContinuousRoadPainter oldDelegate) {
    if (oldDelegate.anchors.length != anchors.length) return true;
    if (oldDelegate.statuses.length != statuses.length) return true;
    for (int i = 0; i < anchors.length; i++) {
      if (oldDelegate.anchors[i] != anchors[i]) return true;
    }
    for (int i = 0; i < statuses.length; i++) {
      if (oldDelegate.statuses[i] != statuses[i]) return true;
    }
    return false;
  }
}

/// Technical Blueprint & Graph Grid Background Painter
class BlueprintGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    if (w <= 0 || h <= 0) return;

    // 1. Blueprint Grid Lines
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0).withValues(alpha: 0.55)
      ..strokeWidth = 1.0;

    const gridSize = 28.0;
    for (double x = 0; x < w; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }
    for (double y = 0; y < h; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // 2. Major Blueprint Metric Markings every 140px
    final majorPaint = Paint()
      ..color = const Color(0xFFCBD5E1).withValues(alpha: 0.6)
      ..strokeWidth = 1.5;
    for (double x = 0; x < w; x += 140.0) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), majorPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Backward-compatibility Single-Segment RoadmapConnectorPainter
class RoadmapConnectorPainter extends CustomPainter {
  final double fromAlign; // -0.6 to 0.6
  final double toAlign;   // -0.6 to 0.6
  final bool isCompleted;
  final bool isActive;

  RoadmapConnectorPainter({
    required this.fromAlign,
    required this.toAlign,
    required this.isCompleted,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    if (w <= 0 || h <= 0) return;

    final x1 = (w * 0.5) + (fromAlign * (w * 0.38));
    final y1 = 0.0;
    final x2 = (w * 0.5) + (toAlign * (w * 0.38));
    final y2 = h;

    final path = Path();
    path.moveTo(x1, y1);
    path.cubicTo(
      x1,
      h * 0.5,
      x2,
      h * 0.5,
      x2,
      y2,
    );

    if (isCompleted) {
      final curbPaint = Paint()
        ..color = const Color(0xFF059669)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 28.0
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(path, curbPaint);

      final surfacePaint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF34D399), Color(0xFF10B981)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, w, h))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22.0
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(path, surfacePaint);
    } else if (isActive) {
      final curbPaint = Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 28.0
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(path, curbPaint);

      final surfacePaint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF818CF8), Color(0xFF6366F1)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, w, h))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22.0
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(path, surfacePaint);
    } else {
      final curbPaint = Paint()
        ..color = const Color(0xFFCBD5E1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 26.0
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(path, curbPaint);

      final surfacePaint = Paint()
        ..color = const Color(0xFFF1F5F9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20.0
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(path, surfacePaint);
    }
  }

  @override
  bool shouldRepaint(covariant RoadmapConnectorPainter oldDelegate) {
    return oldDelegate.fromAlign != fromAlign ||
        oldDelegate.toAlign != toAlign ||
        oldDelegate.isCompleted != isCompleted ||
        oldDelegate.isActive != isActive;
  }
}

// Backward-compatibility LevelMapPathPainter
class LevelMapPathPainter extends CustomPainter {
  final int completedLevels;
  final int totalLevels;

  LevelMapPathPainter({
    required this.completedLevels,
    required this.totalLevels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width < 50 || size.height < 50) return;

    final bgPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.emerald, AppColors.primary, AppColors.amber],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final stepX = size.width / (totalLevels > 1 ? totalLevels - 1 : 1);
    final midY = size.height * 0.45;

    path.moveTo(0, midY);

    for (int i = 0; i < totalLevels - 1; i++) {
      final x1 = i * stepX;
      final x2 = (i + 1) * stepX;
      final isEven = i % 2 == 0;
      final controlY = isEven ? midY - 35 : midY + 35;

      path.cubicTo(
        x1 + stepX * 0.4,
        controlY,
        x1 + stepX * 0.6,
        controlY,
        x2,
        midY,
      );
    }

    canvas.drawPath(path, bgPaint);
    canvas.drawPath(path, fgPaint);
  }

  @override
  bool shouldRepaint(covariant LevelMapPathPainter oldDelegate) {
    return oldDelegate.completedLevels != completedLevels ||
        oldDelegate.totalLevels != totalLevels;
  }
}
