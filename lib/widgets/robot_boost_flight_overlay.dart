// High-Fluidity Jetpack Boost, Warp Portal & Fly-Into-Page Transition Overlay
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;
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

/// Evaluates continuous velocity kinematics for Bolts' crouch ignition,
/// foreground zoom fly-by, hyper-speed dive into the destination portal,
/// 360-degree victory barrel roll, and elastic landing back on dock.
class BoostFlightKinematics {
  static const double swapProgressThreshold = 0.49;

  static BoostFlightPose evaluate({
    required double t,
    required Offset start,
    required Offset target,
    required bool isWideStage,
    required double stageWidth,
  }) {
    final p = t.clamp(0.0, 1.0);
    final dirSign = target.dx >= start.dx ? 1.0 : -1.0;

    // Phase 1 (0.00 -> 0.14): Squash-and-stretch thruster ignition crouch + spring lift
    if (p < 0.14) {
      final s = (p / 0.14).clamp(0.0, 1.0);
      final dy = 10.0 * math.sin(s * math.pi) - 24.0 * (s * s);
      final dx = dirSign * 4.0 * (s * s);
      return BoostFlightPose(
        position: start + Offset(dx, dy),
        scale: (1.0 - 0.07 * math.sin(s * math.pi) + 0.08 * (s * s))
            .clamp(0.88, 1.15),
        tiltAngle: (-0.08 * math.sin(s * math.pi) + 0.14 * dirSign * (s * s))
            .clamp(-0.35, 0.35),
        yaw: 0.32 * s * s * dirSign,
        pitch: -0.08 * s,
        opacity: 1.0,
        boostThrust: 0.55 + 0.85 * Curves.easeOut.transform(s),
        tapBounce: s < 0.5 ? (s * 0.4) : 0.2 * (1.0 - (s - 0.5) * 2.0),
      );
    }

    // Phase 2 (0.14 -> 0.49): Foreground zoom fly-by & accelerating dive INTO portal
    if (p <= swapProgressThreshold) {
      final u = ((p - 0.14) / (swapProgressThreshold - 0.14)).clamp(0.0, 1.0);
      // Continuous acceleration right into portal impact (no braking halt at u=1!)
      final w = u * (0.38 + 0.62 * u);

      final launchPos = start + Offset(dirSign * 4.0, -24.0);
      final (c1, c2) = _outboundControls(
        launchPos: launchPos,
        target: target,
        isWideStage: isWideStage,
        stageWidth: stageWidth,
      );

      final pos = _cubicBezier(launchPos, c1, c2, target, w);
      final tangent = _cubicBezierDerivative(launchPos, c1, c2, target, w);
      final velocityAngle =
          (math.atan2(tangent.dy, tangent.dx.abs() + 120.0) * 0.55 +
                  0.26 * math.sin(u * math.pi)) *
              dirSign;
      final tilt = lerpDouble(0.14 * dirSign, velocityAngle, (u / 0.22).clamp(0.0, 1.0))!
          .clamp(-0.56, 0.58);

      // Swell boldly toward camera (~1.38x) during arc, then streak deep into portal (~0.24x)
      final swell = math.sin(u * math.pi * 0.86) * 0.38 * (1.0 - u * u);
      final shrink = math.pow(u, 2.25).toDouble() * 0.84;
      final scale = (1.08 + swell - shrink).clamp(0.22, 1.44);

      final opacity =
          u > 0.85 ? (1.0 - ((u - 0.85) / 0.15)).clamp(0.0, 1.0) : 1.0;

      return BoostFlightPose(
        position: pos,
        scale: scale,
        tiltAngle: tilt,
        yaw: (0.32 + 0.34 * math.sin(u * math.pi)) * dirSign,
        pitch: -0.08 + 0.28 * u,
        opacity: opacity,
        boostThrust: 1.45,
        tapBounce: 0.0,
      );
    }

    // Phase 3 (0.49 -> 1.00): Bursts OUT of opened portal + 360° barrel flip + elastic settle
    final v = ((p - swapProgressThreshold) / (1.0 - swapProgressThreshold))
        .clamp(0.0, 1.0);
    // High exit burst velocity decelerating butter-smoothly to 0 at landing
    final wv = 1.0 - math.pow(1.0 - v, 2.45).toDouble();

    final (r1, r2) = _returnControls(
      start: start,
      target: target,
      isWideStage: isWideStage,
      stageWidth: stageWidth,
    );
    final pos = _cubicBezier(target, r1, r2, start, wv);

    // Smooth scale rebound (0.24 -> 1.08 -> 1.0) without harsh settle jitter
    final riseT = Curves.easeOutCubic.transform((v / 0.52).clamp(0.0, 1.0));
    final settleT = v <= 0.52
        ? 0.0
        : Curves.easeInOutSine.transform(((v - 0.52) / 0.48).clamp(0.0, 1.0));
    final scale = (0.24 + 0.84 * riseT - 0.08 * settleT).clamp(0.24, 1.12);

    // Playful 360-degree celebratory victory barrel flip mid-return
    final flipEase =
        Curves.easeInOutCubic.transform(((v - 0.08) / 0.60).clamp(0.0, 1.0));
    final bankingGlide = (-0.28 * math.sin(v * math.pi) * dirSign);
    final tiltAngle = (flipEase * math.pi * 2.0 * -dirSign) + bankingGlide;

    final opacity = (v / 0.10).clamp(0.0, 1.0);
    final thrust = (1.35 * math.pow(1.0 - v, 1.6)).toDouble().clamp(0.0, 1.35);

    return BoostFlightPose(
      position: pos,
      scale: scale,
      tiltAngle: tiltAngle,
      yaw: (-0.34 * (1.0 - wv)) * dirSign,
      pitch: -0.06 * math.sin(v * math.pi),
      opacity: opacity,
      boostThrust: thrust,
      tapBounce: v > 0.86
          ? math.sin(((v - 0.86) / 0.14) * math.pi) * 0.34
          : 0.0,
    );
  }

  /// Synced 3D depth card transition (monotonic easeOutQuart arrival prevents
  /// sub-pixel web text shimmer while diving into / out of the portal).
  static ({double scale, double opacity, double rotateY}) evaluatePaneTransition(
    double t,
  ) {
    final p = t.clamp(0.0, 1.0);
    if (p < swapProgressThreshold) {
      final outT =
          Curves.easeInCubic.transform((p / swapProgressThreshold).clamp(0.0, 1.0));
      return (
        scale: 1.0 - 0.13 * outT,
        opacity: 1.0 - 0.84 * outT,
        rotateY: -0.18 * outT,
      );
    }

    final inFrac = ((p - swapProgressThreshold) / 0.44).clamp(0.0, 1.0);
    final inEase = Curves.easeOutQuart.transform(inFrac);
    final alphaReveal = ((p - swapProgressThreshold) / 0.14).clamp(0.0, 1.0);
    return (
      scale: 0.84 + 0.16 * inEase,
      opacity: alphaReveal,
      rotateY: 0.22 * (1.0 - inEase),
    );
  }

  static (Offset, Offset) _outboundControls({
    required Offset launchPos,
    required Offset target,
    required bool isWideStage,
    required double stageWidth,
  }) {
    if (isWideStage) {
      final highY = math.min(launchPos.dy, target.dy) - 118.0;
      return (
        Offset(lerpDouble(launchPos.dx, target.dx, 0.28)!, highY),
        Offset(target.dx - 44.0, highY + 18.0),
      );
    }
    final sweepX = math.min(stageWidth - 20.0, math.max(launchPos.dx, target.dx) + 76.0);
    return (
      Offset(sweepX, launchPos.dy - 46.0),
      Offset(sweepX, target.dy - 58.0),
    );
  }

  static (Offset, Offset) _returnControls({
    required Offset start,
    required Offset target,
    required bool isWideStage,
    required double stageWidth,
  }) {
    if (isWideStage) {
      final lowY = math.max(start.dy, target.dy) + 46.0;
      return (
        Offset(target.dx - 48.0, lowY + 10.0),
        Offset(lerpDouble(target.dx, start.dx, 0.72)!, lowY - 12.0),
      );
    }
    final laneX = math.max(24.0, start.dx - 26.0);
    return (
      Offset(laneX, target.dy - 24.0),
      Offset(laneX, start.dy + 34.0),
    );
  }

  static Offset _cubicBezier(
    Offset p0,
    Offset c1,
    Offset c2,
    Offset p1,
    double t,
  ) {
    final u = 1.0 - t;
    final tt = t * t;
    final uu = u * u;
    final uuu = uu * u;
    final ttt = tt * t;
    return Offset(
      uuu * p0.dx + 3 * uu * t * c1.dx + 3 * u * tt * c2.dx + ttt * p1.dx,
      uuu * p0.dy + 3 * uu * t * c1.dy + 3 * u * tt * c2.dy + ttt * p1.dy,
    );
  }

  static Offset _cubicBezierDerivative(
    Offset p0,
    Offset c1,
    Offset c2,
    Offset p1,
    double t,
  ) {
    final u = 1.0 - t;
    final dx = 3 * u * u * (c1.dx - p0.dx) +
        6 * u * t * (c2.dx - c1.dx) +
        3 * t * t * (p1.dx - c2.dx);
    final dy = 3 * u * u * (c1.dy - p0.dy) +
        6 * u * t * (c2.dy - c1.dy) +
        3 * t * t * (p1.dy - c2.dy);
    return Offset(dx, dy);
  }
}

/// Overlay layer rendering full-stage hyperspeed lines, volumetric plasma clouds,
/// multi-ring rotating gear/energy portal, destination warp pill, and 3D airborne Bolts.
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

  static String _warpBannerText(int stage) {
    switch (stage) {
      case 1:
        return '🚀 WARP TO EXAMPLES! ⚙️';
      case 2:
        return '🎯 WARP TO YOUR PLAN!';
      case 3:
        return '🚀 WARP TO CADET PASS!';
      default:
        return '🤖 WARP BACK TO BOLTS!';
    }
  }

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

        // Floating warp callout banner visible during peak jump (t = 0.22 .. 0.78)
        final bannerAlpha = progress < 0.20 || progress > 0.80
            ? 0.0
            : (progress < 0.34
                ? (progress - 0.20) / 0.14
                : (progress > 0.64 ? (0.80 - progress) / 0.16 : 1.0));
        final bannerScale = 0.86 + 0.14 * bannerAlpha;
        final bannerLeft = (portalTargetCenter.dx - 110.0)
            .clamp(12.0, math.max(12.0, stageW - 232.0))
            .toDouble();
        final bannerTop = math.max(8.0, portalTargetCenter.dy - 118.0);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: RepaintBoundary(
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
            ),
            if (bannerAlpha > 0.02)
              Positioned(
                left: bannerLeft,
                top: bannerTop,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: bannerAlpha.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: bannerScale,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0F172A), Color(0xFF312E81)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: paintStyle.neonColor.withValues(alpha: 0.9),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: paintStyle.neonColor.withValues(alpha: 0.35),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                        child: Text(
                          _warpBannerText(targetStage),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
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
                            idle: (0.25 + progress * 3.4) % 1.0,
                            entrance: 1.0,
                            rawEntrance: 1.0,
                            tapBounce: pose.tapBounce,
                            confettiProgress: progress > 0.80
                                ? ((progress - 0.80) / 0.20).clamp(0.0, 1.0)
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

/// Paints radial warp speed streaks, billowing thruster exhaust puffs, glowing
/// plasma trail, golden spinning gear confetti, and multi-ring page portal vortex.
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

    // 1. Subtle radial hyperspeed wind lines across entire stage
    if (p >= 0.14 && p <= 0.82) {
      _drawHyperspeedStreaks(canvas, size, p);
    }

    // 2. Dual takeoff shockwave & smoke puffs
    if (p <= 0.28) {
      final k = (p / 0.28).clamp(0.0, 1.0);
      final ringR = 18.0 + k * 56.0;
      final alpha = (1.0 - k) * 0.72;
      canvas.drawOval(
        Rect.fromCenter(
          center: startCenter + const Offset(0, 34),
          width: ringR * 2.1,
          height: ringR * 0.74,
        ),
        Paint()
          ..color = const Color(0xFFF97316).withValues(alpha: alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5 * (1.0 - k * 0.45),
      );
      for (final side in [-1.0, 1.0]) {
        final puffX = startCenter.dx + side * (18.0 + k * 42.0);
        final puffY = startCenter.dy + 34.0 - k * 10.0;
        canvas.drawCircle(
          Offset(puffX, puffY),
          (12.0 - k * 4.0).clamp(3.0, 14.0),
          Paint()..color = Colors.white.withValues(alpha: (1.0 - k) * 0.58),
        );
      }
    }

    // 3. Swirling plasma exhaust ribbon + billowing clouds + tumbling mini gears/stars
    _drawExhaustTrail(canvas, p);

    // 4. Multi-ring glowing destination page portal + supernova swap flash
    if (p >= 0.16 && p <= 0.86) {
      _drawPagePortal(canvas, p);
    }

    // 5. Hero touchdown sonic ring + celebration sparks on dock
    if (p >= 0.86) {
      final k = ((p - 0.86) / 0.14).clamp(0.0, 1.0);
      final ringR = 14.0 + k * 54.0;
      canvas.drawOval(
        Rect.fromCenter(
          center: startCenter + const Offset(0, 34),
          width: ringR * 2.0,
          height: ringR * 0.68,
        ),
        Paint()
          ..color = paintStyle.neonColor.withValues(alpha: (1.0 - k) * 0.78)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0,
      );
    }
  }

  void _drawHyperspeedStreaks(Canvas canvas, Size size, double p) {
    final intensity = p <= 0.49
        ? ((p - 0.14) / 0.35).clamp(0.0, 1.0)
        : (1.0 - ((p - 0.49) / 0.33)).clamp(0.0, 1.0);
    if (intensity <= 0.02) return;

    const rays = 14;
    final origin = portalTargetCenter;
    for (int i = 0; i < rays; i++) {
      final angle = (i / rays) * math.pi * 2.0 + 0.18;
      final phase = (p * 3.6 + i * 0.21) % 1.0;
      final rInner = 95.0 + phase * 85.0;
      final rOuter = rInner + 38.0 + (i % 3) * 18.0;
      final a = origin + Offset(math.cos(angle) * rInner, math.sin(angle) * rInner);
      final b = origin + Offset(math.cos(angle) * rOuter, math.sin(angle) * rOuter);
      canvas.drawLine(
        a,
        b,
        Paint()
          ..color = (i.isEven ? paintStyle.neonColor : Colors.white)
              .withValues(alpha: 0.26 * intensity * (1.0 - phase * 0.6))
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawExhaustTrail(Canvas canvas, double p) {
    const swap = BoostFlightKinematics.swapProgressThreshold;
    double? tailStart;
    if (p >= 0.10 && p <= swap) {
      tailStart = math.max(0.10, p - 0.24);
    } else if (p > swap) {
      tailStart = math.max(swap, p - 0.22);
    }
    if (tailStart == null) return;

    const samples = 20;
    final points = <Offset>[];
    final poses = <BoostFlightPose>[];
    final tailEnd = p <= swap ? math.min(p, swap) : p;
    for (int i = 0; i <= samples; i++) {
      final u = tailStart + (tailEnd - tailStart) * (i / samples);
      final pose = BoostFlightKinematics.evaluate(
        t: u,
        start: startCenter,
        target: portalTargetCenter,
        isWideStage: isWideStage,
        stageWidth: stageWidth,
      );
      final nozzleOffset = Offset(
        -math.sin(pose.tiltAngle) * 18.0 * pose.scale,
        math.cos(pose.tiltAngle) * 18.0 * pose.scale,
      );
      points.add(pose.position + nozzleOffset);
      poses.add(pose);
    }

    if (points.length < 2) return;

    for (int i = 0; i < points.length - 1; i++) {
      final frac = (i + 1) / points.length;
      final a = points[i];
      final b = points[i + 1];
      final wScale = poses[i + 1].scale.clamp(0.35, 1.35);

      canvas.drawLine(
        a,
        b,
        Paint()
          ..color = paintStyle.swatch.withValues(alpha: 0.30 * frac)
          ..strokeWidth = 22.0 * frac * wScale
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        a,
        b,
        Paint()
          ..color = Color.lerp(
            const Color(0xFFF97316),
            const Color(0xFFFDE047),
            frac,
          )!
              .withValues(alpha: 0.72 * frac)
          ..strokeWidth = 11.0 * frac * wScale
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        a,
        b,
        Paint()
          ..color = const Color(0xFFE0F2FE).withValues(alpha: 0.88 * frac)
          ..strokeWidth = 4.2 * frac * wScale
          ..strokeCap = StrokeCap.round,
      );
    }

    // Billowing jetpack vapor puffs & tumbling golden stars / mini cogs
    for (int i = 2; i < points.length - 1; i += 3) {
      final frac = i / points.length;
      final pt = points[i];
      final wobble = Offset(
        math.sin(i * 2.3 + p * 16) * 14 * (1.0 - frac * 0.3),
        math.cos(i * 1.9 + p * 14) * 14 * (1.0 - frac * 0.3),
      );

      // Vapor puff behind flame
      canvas.drawCircle(
        pt - wobble * 0.4,
        (9.0 * (1.0 - frac * 0.3)).clamp(3.0, 10.0),
        Paint()..color = Colors.white.withValues(alpha: 0.42 * frac),
      );

      // Orbiting 4-point cartoon stars / gears
      _drawStarSparkle(
        canvas,
        pt + wobble,
        5.2 * frac + 1.6,
        (i.isEven ? const Color(0xFFFDE047) : paintStyle.neonColor)
            .withValues(alpha: 0.90 * frac),
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
          ..color = const Color(0xFFBAE6FD).withValues(alpha: 0.80)
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round;
        for (final side in [-1.0, 1.0]) {
          final offset = perp * (side * 26.0) - dir * 16.0;
          canvas.drawLine(
            head + offset,
            head + offset - dir * 32.0,
            speedPaint,
          );
        }
      }
    }
  }

  void _drawPagePortal(Canvas canvas, double p) {
    const swap = BoostFlightKinematics.swapProgressThreshold;
    final openT = ((p - 0.16) / (swap - 0.16)).clamp(0.0, 1.0);
    final closeT = ((p - swap) / 0.37).clamp(0.0, 1.0);
    final intensity = p <= swap
        ? Curves.easeOut.transform(openT)
        : (1.0 - Curves.easeInQuad.transform(closeT));

    final radius = (p <= swap
            ? 16.0 + Curves.easeOut.transform(openT) * 92.0
            : 108.0 + closeT * 44.0)
        .clamp(10.0, 160.0);

    // Multi-layered cosmic portal nebula (shader bounds match circle so edge fades cleanly to 0 alpha)
    final auraRadius = radius * 1.35;
    canvas.drawCircle(
      portalTargetCenter,
      auraRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.82 * intensity),
            paintStyle.neonColor.withValues(alpha: 0.48 * intensity),
            AppColors.primary.withValues(alpha: 0.22 * intensity),
            Colors.transparent,
          ],
          stops: const [0.0, 0.36, 0.68, 1.0],
        ).createShader(
          Rect.fromCircle(center: portalTargetCenter, radius: auraRadius),
        ),
    );

    // Counter-rotating dual concentric holographic rings
    for (final ring in [
      (rScale: 0.68, speed: 9.0, width: 3.6, color: paintStyle.trimColor),
      (rScale: 0.44, speed: -12.0, width: 2.8, color: const Color(0xFFE0F2FE)),
    ]) {
      canvas.save();
      canvas.translate(portalTargetCenter.dx, portalTargetCenter.dy);
      canvas.rotate(p * ring.speed);
      final teeth = targetStage == 1 ? 8 : 5;
      final sweep = (math.pi * 2 / teeth) * 0.58;
      final arcPaint = Paint()
        ..color = ring.color.withValues(alpha: 0.90 * intensity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = ring.width
        ..strokeCap = StrokeCap.round;
      final arcRect = Rect.fromCircle(
        center: Offset.zero,
        radius: radius * ring.rScale,
      );
      for (int i = 0; i < teeth; i++) {
        canvas.drawArc(arcRect, i * (math.pi * 2 / teeth), sweep, false, arcPaint);
      }
      canvas.restore();
    }

    // Supernova impact flash right around swap moment (t = 0.44 .. 0.55)
    final distFromSwap = (p - swap).abs();
    if (distFromSwap < 0.08) {
      final flash = (1.0 - distFromSwap / 0.08).clamp(0.0, 1.0);
      canvas.drawCircle(
        portalTargetCenter,
        radius * (0.45 + flash * 0.45),
        Paint()..color = Colors.white.withValues(alpha: 0.68 * flash),
      );
    }

    // Expanding star bursts around portal rim
    for (int i = 0; i < 10; i++) {
      final a = (i * math.pi / 5.0) + p * 3.4;
      final r = radius * (0.64 + 0.40 * (p <= swap ? openT : closeT));
      final sparkPos =
          portalTargetCenter + Offset(math.cos(a) * r, math.sin(a) * r);
      _drawStarSparkle(
        canvas,
        sparkPos,
        6.0 * intensity + 1.5,
        (i.isEven ? const Color(0xFFFDE047) : paintStyle.neonColor)
            .withValues(alpha: 0.92 * intensity),
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
