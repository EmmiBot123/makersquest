// Jetpack Boost & Fly-Into-Page Stage Transition Overlay for 3D Cartoon Bolts
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'robot_3d_cartoon_painter.dart';

/// Instantaneous 3D flight pose for Bolts during a boost-into-page transition.
class BoostFlightPose {
  final Offset position;
  final double scale;
  final double tiltAngle;
  final double yaw;
  final double pitch;
  final double opacity;
  final double boostThrust;
  final double tapBounce;

  const BoostFlightPose({
    required this.position,
    required this.scale,
    required this.tiltAngle,
    required this.yaw,
    required this.pitch,
    required this.opacity,
    required this.boostThrust,
    required this.tapBounce,
  });
}

/// Evaluates Bolts' takeoff, dive-into-portal, and heroic return trajectory
/// cleanly across desktop (`isWideStage == true`) and mobile viewports.
class BoostFlightKinematics {
  static BoostFlightPose evaluate({
    required double t,
    required Offset start,
    required Offset target,
    required bool isWideStage,
    required double stageWidth,
  }) {
    final p = t.clamp(0.0, 1.0);

    // Phase 1 (0.00 -> 0.09): Thruster ignition crouch & lift-off
    if (p < 0.09) {
      final s = (p / 0.09).clamp(0.0, 1.0);
      final lift = -12.0 * Curves.easeOut.transform(s);
      return BoostFlightPose(
        position: start + Offset(0, lift),
        scale: 1.0 - 0.06 * math.sin(s * math.pi) + 0.05 * s,
        tiltAngle: 0.16 * s,
        yaw: 0.34 * s,
        pitch: -0.08 * s,
        opacity: 1.0,
        boostThrust: 0.65 + 0.70 * s,
        tapBounce: s * 0.25,
      );
    }

    // Phase 2 (0.09 -> 0.45): High-speed boost arc plunging INTO target page portal
    if (p <= 0.45) {
      final u = ((p - 0.09) / 0.36).clamp(0.0, 1.0);
      final e = Curves.easeInOutQuad.transform(u);
      final launchPos = start + const Offset(0, -12.0);
      final ctrlOut = _outboundControlPoint(
        launchPos: launchPos,
        target: target,
        isWideStage: isWideStage,
        stageWidth: stageWidth,
      );

      final pos = _quadBezier(launchPos, ctrlOut, target, e);
      final tangent = _quadBezierDerivative(launchPos, ctrlOut, target, e);
      final dirSign = target.dx >= launchPos.dx ? 1.0 : -1.0;
      final tilt = (math.atan2(tangent.dy, tangent.dx.abs() + 95.0) * 0.55 +
              dirSign * 0.24 * math.sin(u * math.pi))
          .clamp(-0.48, 0.52);

      // Perspective zoom into portal as Bolts nears the page
      final portalDive = Curves.easeInCubic.transform(u);
      final scale = 1.06 +
          0.08 * math.sin(u * math.pi * 0.55) -
          0.74 * portalDive;
      final opacity =
          u > 0.78 ? (1.0 - ((u - 0.78) / 0.22)).clamp(0.0, 1.0) : 1.0;

      return BoostFlightPose(
        position: pos,
        scale: scale.clamp(0.30, 1.15),
        tiltAngle: tilt,
        yaw: (0.34 + 0.28 * math.sin(u * math.pi)) * dirSign,
        pitch: -0.08 + 0.26 * u,
        opacity: opacity,
        boostThrust: 1.38,
        tapBounce: 0.0,
      );
    }

    // Phase 3 (0.45 -> 0.50): Portal swap flash right as destination page pops open
    if (p < 0.50) {
      return BoostFlightPose(
        position: target,
        scale: 0.30,
        tiltAngle: 0.0,
        yaw: 0.2,
        pitch: 0.0,
        opacity: 0.0,
        boostThrust: 1.15,
        tapBounce: 0.0,
      );
    }

    // Phase 4 (0.50 -> 1.00): Bursts back out of opened page & sticks hero landing
    final v = ((p - 0.50) / 0.50).clamp(0.0, 1.0);
    final ev = Curves.easeOutCubic.transform(v);
    final ctrlIn = _returnControlPoint(
      start: start,
      target: target,
      isWideStage: isWideStage,
      stageWidth: stageWidth,
    );

    final pos = _quadBezier(target, ctrlIn, start, ev);
    final scaleGrowth = v <= 0.76
        ? Curves.easeOutBack.transform((v / 0.76).clamp(0.0, 1.0))
        : 1.0;
    final settleOvershoot =
        v <= 0.76 ? (0.34 + 0.66 * scaleGrowth) : (1.0 + math.sin(((v - 0.76) / 0.24) * math.pi) * 0.03);
    final opacity = (v / 0.14).clamp(0.0, 1.0);
    final dirSign = target.dx >= start.dx ? 1.0 : -1.0;

    return BoostFlightPose(
      position: pos,
      scale: settleOvershoot.clamp(0.32, 1.12),
      tiltAngle: (-0.30 * math.sin(v * math.pi) * dirSign).clamp(-0.38, 0.38),
      yaw: -0.26 * (1.0 - ev) * dirSign,
      pitch: -0.08 * math.sin(v * math.pi),
      opacity: opacity,
      boostThrust: 1.18 * (1.0 - Curves.easeInQuad.transform(v)),
      tapBounce: v > 0.84
          ? math.sin(((v - 0.84) / 0.16) * math.pi) * 0.36
          : 0.0,
    );
  }

  /// Synced transform applied to the destination pane so the page swoops/zooms
  /// open right when Bolts dives through its portal.
  static ({double scale, double opacity}) evaluatePaneTransition(double t) {
    final p = t.clamp(0.0, 1.0);
    if (p < 0.44) {
      final pull = ((p - 0.14) / 0.30).clamp(0.0, 1.0);
      final easePull = Curves.easeInQuad.transform(pull);
      return (
        scale: 1.0 - 0.08 * easePull,
        opacity: 1.0 - 0.70 * easePull,
      );
    }
    final pop = ((p - 0.44) / 0.44).clamp(0.0, 1.0);
    final springScale = Curves.easeOutBack.transform(pop);
    final opacityReveal = ((p - 0.44) / 0.16).clamp(0.0, 1.0);
    return (
      scale: 0.85 + 0.15 * springScale,
      opacity: opacityReveal,
    );
  }

  static Offset _outboundControlPoint({
    required Offset launchPos,
    required Offset target,
    required bool isWideStage,
    required double stageWidth,
  }) {
    if (isWideStage) {
      return Offset(
        (launchPos.dx + target.dx) * 0.50,
        math.min(launchPos.dy, target.dy) - 88.0,
      );
    }
    return Offset(
      math.min(stageWidth - 28.0, math.max(launchPos.dx, target.dx) + 64.0),
      (launchPos.dy + target.dy) * 0.34 - 24.0,
    );
  }

  static Offset _returnControlPoint({
    required Offset start,
    required Offset target,
    required bool isWideStage,
    required double stageWidth,
  }) {
    if (isWideStage) {
      return Offset(
        (start.dx + target.dx) * 0.48,
        math.max(start.dy, target.dy) + 38.0,
      );
    }
    return Offset(
      math.max(26.0, start.dx - 16.0),
      (start.dy + target.dy) * 0.58,
    );
  }

  static Offset _quadBezier(Offset a, Offset c, Offset b, double t) {
    final u = 1.0 - t;
    return Offset(
      u * u * a.dx + 2.0 * u * t * c.dx + t * t * b.dx,
      u * u * a.dy + 2.0 * u * t * c.dy + t * t * b.dy,
    );
  }

  static Offset _quadBezierDerivative(Offset a, Offset c, Offset b, double t) {
    final dx = 2.0 * (1.0 - t) * (c.dx - a.dx) + 2.0 * t * (b.dx - c.dx);
    final dy = 2.0 * (1.0 - t) * (c.dy - a.dy) + 2.0 * t * (b.dy - c.dy);
    return Offset(dx, dy);
  }
}

/// Overlay layer rendering Bolts' glowing jetpack plasma trail, hyperspace page
/// portal, landing shockwave ripple, and 3D airborne cartoon Bolts.
class BoostFlightStageOverlay extends StatelessWidget {
  final double progress;
  final Offset startCenter;
  final Offset portalTargetCenter;
  final double robotHeight;
  final bool isWideStage;
  final int targetStage;
  final RobotPaint paintStyle;
  final RobotHat hat;
  final bool isDancing;

  const BoostFlightStageOverlay({
    super.key,
    required this.progress,
    required this.startCenter,
    required this.portalTargetCenter,
    required this.robotHeight,
    required this.isWideStage,
    required this.targetStage,
    required this.paintStyle,
    required this.hat,
    required this.isDancing,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stageW = constraints.maxWidth.isFinite ? constraints.maxWidth : 600.0;
        final pose = BoostFlightKinematics.evaluate(
          t: progress,
          start: startCenter,
          target: portalTargetCenter,
          isWideStage: isWideStage,
          stageWidth: stageW,
        );

        final flyH = robotHeight;
        final flyW = flyH * 1.08;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: BoostFlightTrailPainter(
                    progress: progress,
                    startCenter: startCenter,
                    portalTargetCenter: portalTargetCenter,
                    isWideStage: isWideStage,
                    stageWidth: stageW,
                    targetStage: targetStage,
                    paintStyle: paintStyle,
                  ),
                ),
              ),
            ),
            if (pose.opacity > 0.01)
              Positioned(
                left: pose.position.dx - flyW * 0.5,
                top: pose.position.dy - flyH * 0.5,
                width: flyW,
                height: flyH,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: pose.opacity,
                    child: Transform.rotate(
                      angle: pose.tiltAngle,
                      alignment: Alignment.center,
                      child: Transform.scale(
                        scale: pose.scale,
                        alignment: Alignment.center,
                        child: CustomPaint(
                          painter: TalkingRobot3DCartoonPainter(
                            idle: (0.25 + progress * 2.8) % 1.0,
                            entrance: 1.0,
                            rawEntrance: 1.0,
                            tapBounce: pose.tapBounce,
                            confettiProgress: progress > 0.85
                                ? ((progress - 0.85) / 0.15).clamp(0.0, 1.0)
                                : 0.0,
                            mood: RobotMood.excited,
                            isTalking: false,
                            paintStyle: paintStyle,
                            hat: hat,
                            hasBoosters: true,
                            isDancing: isDancing,
                            userYaw: pose.yaw,
                            userPitch: pose.pitch,
                            showGroundShadow: false,
                            boostThrust: pose.boostThrust,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Paints the rocket plasma exhaust ribbon, warp speed lines, takeoff & landing
/// shockwave rings, and the spinning glowing page portal.
class BoostFlightTrailPainter extends CustomPainter {
  final double progress;
  final Offset startCenter;
  final Offset portalTargetCenter;
  final bool isWideStage;
  final double stageWidth;
  final int targetStage;
  final RobotPaint paintStyle;

  BoostFlightTrailPainter({
    required this.progress,
    required this.startCenter,
    required this.portalTargetCenter,
    required this.isWideStage,
    required this.stageWidth,
    required this.targetStage,
    required this.paintStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final p = progress.clamp(0.0, 1.0);

    // 1. Takeoff ignition shockwave ring
    if (p <= 0.25) {
      final k = (p / 0.25).clamp(0.0, 1.0);
      final ringR = 16.0 + k * 44.0;
      final alpha = (1.0 - k) * 0.65;
      canvas.drawOval(
        Rect.fromCenter(
          center: startCenter + const Offset(0, 34),
          width: ringR * 1.9,
          height: ringR * 0.68,
        ),
        Paint()
          ..color = const Color(0xFFF97316).withValues(alpha: alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.2 * (1.0 - k * 0.5),
      );
    }

    // 2. Glowing rocket exhaust ribbon along analytical flight arc
    _drawExhaustTrail(canvas, p);

    // 3. Spinning destination page portal (especially accented for Examples gears!)
    if (p >= 0.20 && p <= 0.80) {
      _drawPagePortal(canvas, p);
    }

    // 4. Hero touchdown ring on dock pad
    if (p >= 0.86) {
      final k = ((p - 0.86) / 0.14).clamp(0.0, 1.0);
      final ringR = 12.0 + k * 42.0;
      canvas.drawOval(
        Rect.fromCenter(
          center: startCenter + const Offset(0, 34),
          width: ringR * 1.85,
          height: ringR * 0.62,
        ),
        Paint()
          ..color = paintStyle.neonColor.withValues(alpha: (1.0 - k) * 0.72)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.8,
      );
    }
  }

  void _drawExhaustTrail(Canvas canvas, double p) {
    double? tailStart;
    if (p >= 0.08 && p <= 0.47) {
      tailStart = math.max(0.08, p - 0.20);
    } else if (p >= 0.50) {
      tailStart = math.max(0.50, p - 0.18);
    }
    if (tailStart == null) return;

    const samples = 16;
    final points = <Offset>[];
    final tailEnd = p <= 0.47 ? math.min(p, 0.45) : p;
    for (int i = 0; i <= samples; i++) {
      final u = tailStart + (tailEnd - tailStart) * (i / samples);
      final pose = BoostFlightKinematics.evaluate(
        t: u,
        start: startCenter,
        target: portalTargetCenter,
        isWideStage: isWideStage,
        stageWidth: stageWidth,
      );
      // Anchor exhaust directly beneath tilted rocket thruster nozzles
      final nozzleOffset = Offset(
        -math.sin(pose.tiltAngle) * 18.0 * pose.scale,
        math.cos(pose.tiltAngle) * 18.0 * pose.scale,
      );
      points.add(pose.position + nozzleOffset);
    }

    if (points.length < 2) return;

    for (int i = 0; i < points.length - 1; i++) {
      final frac = (i + 1) / points.length;
      final a = points[i];
      final b = points[i + 1];

      // Outer thruster aura
      canvas.drawLine(
        a,
        b,
        Paint()
          ..color = paintStyle.swatch.withValues(alpha: 0.28 * frac)
          ..strokeWidth = 18.0 * frac
          ..strokeCap = StrokeCap.round,
      );
      // Warm orange-gold plasma ribbon
      canvas.drawLine(
        a,
        b,
        Paint()
          ..color = Color.lerp(
            const Color(0xFFF97316),
            const Color(0xFFFDE047),
            frac,
          )!
              .withValues(alpha: 0.68 * frac)
          ..strokeWidth = 9.5 * frac
          ..strokeCap = StrokeCap.round,
      );
      // Bright cyan-white core streak
      canvas.drawLine(
        a,
        b,
        Paint()
          ..color = const Color(0xFFE0F2FE).withValues(alpha: 0.85 * frac)
          ..strokeWidth = 3.6 * frac
          ..strokeCap = StrokeCap.round,
      );
    }

    // Crisp trailing star sparks + anime warp speed lines along flight path
    for (int i = 2; i < points.length; i += 3) {
      final frac = i / points.length;
      final pt = points[i];
      final wobble = Offset(
        math.sin(i * 2.1 + p * 14) * 10 * (1.0 - frac * 0.4),
        math.cos(i * 1.7 + p * 12) * 10 * (1.0 - frac * 0.4),
      );
      _drawStarSparkle(
        canvas,
        pt + wobble,
        4.6 * frac + 1.4,
        (i.isEven ? const Color(0xFFFDE047) : paintStyle.neonColor)
            .withValues(alpha: 0.85 * frac),
      );
    }

    if (points.length >= 6) {
      final head = points.last;
      final prev = points[points.length - 4];
      final delta = head - prev;
      final dist = delta.distance;
      if (dist > 1.0) {
        final dir = delta / dist;
        final perp = Offset(-dir.dy, dir.dx);
        final speedPaint = Paint()
          ..color = const Color(0xFFBAE6FD).withValues(alpha: 0.72)
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round;
        for (final side in [-1.0, 1.0]) {
          final offset = perp * (side * 22.0) - dir * 16.0;
          canvas.drawLine(
            head + offset,
            head + offset - dir * 24.0,
            speedPaint,
          );
        }
      }
    }
  }

  void _drawPagePortal(Canvas canvas, double p) {
    final openT = ((p - 0.20) / 0.26).clamp(0.0, 1.0);
    final closeT = ((p - 0.46) / 0.34).clamp(0.0, 1.0);
    final intensity = p <= 0.46
        ? Curves.easeOut.transform(openT)
        : (1.0 - Curves.easeInQuad.transform(closeT));

    final radius = (p <= 0.46
            ? 14.0 + Curves.easeOutBack.transform(openT) * 68.0
            : 82.0 + closeT * 34.0)
        .clamp(8.0, 120.0);

    final rect = Rect.fromCenter(
      center: portalTargetCenter,
      width: radius * 1.45,
      height: radius * 1.45,
    );

    // Radial luminous portal glow
    canvas.drawCircle(
      portalTargetCenter,
      radius * 1.15,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.72 * intensity),
            paintStyle.neonColor.withValues(alpha: 0.45 * intensity),
            AppColors.primary.withValues(alpha: 0.22 * intensity),
            Colors.transparent,
          ],
          stops: const [0.0, 0.42, 0.74, 1.0],
        ).createShader(rect.inflate(radius * 0.4)),
    );

    // Spinning segmented energy ring around portal
    canvas.save();
    canvas.translate(portalTargetCenter.dx, portalTargetCenter.dy);
    canvas.rotate(p * 8.0);
    final arcPaint = Paint()
      ..color = paintStyle.trimColor.withValues(alpha: 0.88 * intensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;

    final arcRect = Rect.fromCircle(center: Offset.zero, radius: radius * 0.62);
    final teeth = targetStage == 1 ? 6 : 4;
    final sweep = (math.pi * 2 / teeth) * 0.58;
    for (int i = 0; i < teeth; i++) {
      canvas.drawArc(
        arcRect,
        i * (math.pi * 2 / teeth),
        sweep,
        false,
        arcPaint,
      );
    }
    canvas.restore();

    // Bursting sparkles around portal at swap moment
    for (int i = 0; i < 8; i++) {
      final a = (i * math.pi / 4.0) + p * 3.0;
      final r = radius * (0.68 + 0.35 * (p <= 0.46 ? openT : closeT));
      final sparkPos = portalTargetCenter + Offset(math.cos(a) * r, math.sin(a) * r);
      _drawStarSparkle(
        canvas,
        sparkPos,
        5.5 * intensity + 1.5,
        (i.isEven ? const Color(0xFFFDE047) : paintStyle.neonColor)
            .withValues(alpha: 0.9 * intensity),
      );
    }
  }

  void _drawStarSparkle(Canvas canvas, Offset c, double r, Color color) {
    final star = Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r)
      ..close();
    canvas.drawPath(star, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant BoostFlightTrailPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.startCenter != startCenter ||
        oldDelegate.portalTargetCenter != portalTargetCenter ||
        oldDelegate.targetStage != targetStage ||
        oldDelegate.paintStyle != paintStyle;
  }
}
