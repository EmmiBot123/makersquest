// True 3D Extruded Pixar/Vinyl-Style Cartoon Character Renderer for Bolts
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum RobotMood {
  greeting,
  explaining,
  thinking,
  excited,
  dancing,
}

enum RobotHat {
  none,
  cap,
  crown,
  topHat,
  visor,
}

extension RobotHatX on RobotHat {
  String get emoji {
    switch (this) {
      case RobotHat.none:
        return '📡';
      case RobotHat.cap:
        return '🧢';
      case RobotHat.crown:
        return '👑';
      case RobotHat.topHat:
        return '🎩';
      case RobotHat.visor:
        return '🕶️';
    }
  }

  String get label {
    switch (this) {
      case RobotHat.none:
        return 'Antenna';
      case RobotHat.cap:
        return 'Cap';
      case RobotHat.crown:
        return 'Crown';
      case RobotHat.topHat:
        return 'Magic';
      case RobotHat.visor:
        return 'Shades';
    }
  }

  RobotHat get next {
    final vals = RobotHat.values;
    return vals[(index + 1) % vals.length];
  }
}

enum RobotPaint {
  cobalt,
  amber,
  mint,
  magenta,
}

extension RobotPaintX on RobotPaint {
  String get label {
    switch (this) {
      case RobotPaint.cobalt:
        return 'Cobalt';
      case RobotPaint.amber:
        return 'Solar';
      case RobotPaint.mint:
        return 'Mint';
      case RobotPaint.magenta:
        return 'Cosmic';
    }
  }

  Color get swatch {
    switch (this) {
      case RobotPaint.cobalt:
        return const Color(0xFF3B82F6);
      case RobotPaint.amber:
        return const Color(0xFFF59E0B);
      case RobotPaint.mint:
        return const Color(0xFF10B981);
      case RobotPaint.magenta:
        return const Color(0xFFEC4899);
    }
  }

  Color get torsoColor {
    switch (this) {
      case RobotPaint.cobalt:
        return const Color(0xFF2563EB);
      case RobotPaint.amber:
        return const Color(0xFFEA580C);
      case RobotPaint.mint:
        return const Color(0xFF059669);
      case RobotPaint.magenta:
        return const Color(0xFF9333EA);
    }
  }

  Color get headColor {
    switch (this) {
      case RobotPaint.cobalt:
        return const Color(0xFF3B82F6);
      case RobotPaint.amber:
        return const Color(0xFFF59E0B);
      case RobotPaint.mint:
        return const Color(0xFF10B981);
      case RobotPaint.magenta:
        return const Color(0xFFC026D3);
    }
  }

  Color get headHighlight {
    switch (this) {
      case RobotPaint.cobalt:
        return const Color(0xFF93C5FD);
      case RobotPaint.amber:
        return const Color(0xFFFDE047);
      case RobotPaint.mint:
        return const Color(0xFF6EE7B7);
      case RobotPaint.magenta:
        return const Color(0xFFF9A8D4);
    }
  }

  Color get headShadow {
    switch (this) {
      case RobotPaint.cobalt:
        return const Color(0xFF1E3A8A);
      case RobotPaint.amber:
        return const Color(0xFFB45309);
      case RobotPaint.mint:
        return const Color(0xFF065F46);
      case RobotPaint.magenta:
        return const Color(0xFF701A75);
    }
  }

  Color get torsoHighlight {
    switch (this) {
      case RobotPaint.cobalt:
        return const Color(0xFF60A5FA);
      case RobotPaint.amber:
        return const Color(0xFFFBBF24);
      case RobotPaint.mint:
        return const Color(0xFF34D399);
      case RobotPaint.magenta:
        return const Color(0xFFD946EF);
    }
  }

  Color get torsoShadow {
    switch (this) {
      case RobotPaint.cobalt:
        return const Color(0xFF172554);
      case RobotPaint.amber:
        return const Color(0xFF9A3412);
      case RobotPaint.mint:
        return const Color(0xFF064E3B);
      case RobotPaint.magenta:
        return const Color(0xFF4A044E);
    }
  }

  Color get neonColor {
    switch (this) {
      case RobotPaint.cobalt:
        return const Color(0xFF38BDF8);
      case RobotPaint.amber:
        return const Color(0xFFFDE047);
      case RobotPaint.mint:
        return const Color(0xFF6EE7B7);
      case RobotPaint.magenta:
        return const Color(0xFFF472B6);
    }
  }

  Color get trimColor {
    switch (this) {
      case RobotPaint.cobalt:
        return const Color(0xFFFBBF24);
      case RobotPaint.amber:
        return const Color(0xFF38BDF8);
      case RobotPaint.mint:
        return const Color(0xFFFACC15);
      case RobotPaint.magenta:
        return const Color(0xFF38BDF8);
    }
  }
}

class _Vec3 {
  final double x;
  final double y;
  final double z;

  const _Vec3(this.x, this.y, this.z);
}

class _ProjPt {
  final Offset p;
  final double z;
  final double scale;

  const _ProjPt(this.p, this.z, this.scale);
}

class _RingSample {
  final double x;
  final double y;
  final double nx;
  final double ny;

  const _RingSample(this.x, this.y, this.nx, this.ny);
}

class _FaceQuad {
  final Offset a;
  final Offset b;
  final Offset c;
  final Offset d;
  final double avgZ;
  final Color color;

  const _FaceQuad(this.a, this.b, this.c, this.d, this.avgZ, this.color);
}

class TalkingRobot3DCartoonPainter extends CustomPainter {
  final double idle;
  final double entrance;
  final double rawEntrance;
  final double tapBounce;
  final double confettiProgress;
  final RobotMood mood;
  final bool isTalking;
  final RobotPaint paintStyle;
  final RobotHat hat;
  final bool hasBoosters;
  final bool isDancing;
  final double userYaw;
  final double userPitch;
  final bool showGroundShadow;
  final double boostThrust;
  final bool isRainbowMode;
  final double overchargeProgress;
  final double flipProgress;
  final double spinProgress;
  final double winkProgress;

  TalkingRobot3DCartoonPainter({
    required this.idle,
    required this.entrance,
    required this.rawEntrance,
    required this.tapBounce,
    required this.confettiProgress,
    required this.mood,
    required this.isTalking,
    required this.paintStyle,
    required this.hat,
    required this.hasBoosters,
    required this.isDancing,
    this.userYaw = 0.0,
    this.userPitch = 0.0,
    this.showGroundShadow = true,
    this.boostThrust = 0.0,
    this.isRainbowMode = false,
    this.overchargeProgress = 0.0,
    this.flipProgress = 0.0,
    this.spinProgress = 0.0,
    this.winkProgress = 0.0,
  });

  Color get _activeNeon => isRainbowMode
      ? HSLColor.fromAHSL(1.0, (idle * 360.0) % 360.0, 0.90, 0.58).toColor()
      : (overchargeProgress > 0.05 ? const Color(0xFFFACC15) : paintStyle.neonColor);

  static const Color _inkColor = Color(0xFF0F172A);
  static const double _fov = 360.0;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final scale = (h / 188.0).clamp(0.45, 1.45);

    canvas.save();

    // Slide-in on entry
    final slideX = (1.0 - entrance) * (-w * 0.42);
    final groundY = h - 11.0 * scale;

    // Animated vertical mechanics (hover boosters, jump impulse, dance hop, breathing bob)
    final boosterLift = hasBoosters
        ? (5.5 + math.sin(idle * 6 * math.pi).abs() * 3.0) * scale
        : 0.0;
    final jumpArc = math.sin(tapBounce * math.pi).clamp(0.0, 1.0);
    final jumpOffset = jumpArc * 16.0 * scale;
    final danceHop =
        isDancing ? math.sin(idle * 10 * math.pi).abs() * 6.5 * scale : 0.0;
    final danceSwayX =
        isDancing ? math.sin(idle * 6 * math.pi) * 5.0 * scale : 0.0;
    final bobOffset = math.sin(idle * 2 * math.pi) * 2.2 * scale;

    final cx = (w * 0.5) + slideX + danceSwayX;
    final liftFactor =
        ((jumpOffset + danceHop + boosterLift) / (26.0 * scale)).clamp(0.0, 1.0);

    // 1. Soft Ambient Contact Shadow / Disco Floor Spotlight (skipped during airborne boost flight)
    if (showGroundShadow) {
      final shadowCenterX = (w * 0.5) + slideX * 0.85 + danceSwayX * 0.4;
      final shadowBaseWidth = (isDancing ? 96.0 : 86.0) * (1.0 - 0.18 * liftFactor) * scale;
      final shadowHeight = (isDancing ? 16.0 : 14.0) * (1.0 - 0.14 * liftFactor) * scale;

      if (isDancing) {
        final discoBeat = 0.28 + 0.22 * math.sin(idle * 8 * math.pi).abs();
        final discoColor = (idle * 4).floor().isEven
            ? const Color(0xFFEC4899)
            : const Color(0xFF38BDF8);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(shadowCenterX, groundY),
            width: shadowBaseWidth * 1.18,
            height: shadowHeight * 1.12,
          ),
          Paint()
            ..shader = RadialGradient(
              colors: [
                discoColor.withValues(alpha: discoBeat),
                discoColor.withValues(alpha: discoBeat * 0.35),
                discoColor.withValues(alpha: 0.0),
              ],
            ).createShader(
              Rect.fromCenter(
                center: Offset(shadowCenterX, groundY),
                width: shadowBaseWidth * 1.18,
                height: shadowHeight * 1.12,
              ),
            ),
        );
      } else {
        final auraRect = Rect.fromCenter(
          center: Offset(shadowCenterX, groundY),
          width: shadowBaseWidth,
          height: shadowHeight,
        );
        canvas.drawOval(
          auraRect,
          Paint()
            ..shader = RadialGradient(
              colors: [
                paintStyle.swatch.withValues(alpha: 0.26),
                paintStyle.swatch.withValues(alpha: 0.0),
              ],
            ).createShader(auraRect),
        );
      }

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(shadowCenterX, groundY),
          width: shadowBaseWidth * 0.62,
          height: 6.5 * scale,
        ),
        Paint()
          ..color = _inkColor.withValues(alpha: 0.22 * (1.0 - 0.32 * liftFactor)),
      );
    }

    final flipLift =
        flipProgress > 0.001 && flipProgress < 0.999
            ? math.sin(flipProgress * math.pi) * 28.0 * scale
            : 0.0;
    final spinLift =
        spinProgress > 0.001 && spinProgress < 0.999
            ? math.sin(spinProgress * math.pi) * 18.0 * scale
            : 0.0;
    final baseY = groundY -
        4.0 * scale -
        jumpOffset -
        flipLift -
        spinLift -
        danceHop -
        boosterLift +
        bobOffset;

    if (showGroundShadow && spinProgress > 0.02 && spinProgress < 0.98) {
      final ringAlpha = math.sin(spinProgress * math.pi).clamp(0.0, 1.0);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, groundY - 4.0 * scale),
          width: 82.0 * scale,
          height: 18.0 * scale,
        ),
        Paint()
          ..color = const Color(0xFF38BDF8).withValues(alpha: ringAlpha * 0.65)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6 * scale,
      );
    }

    canvas.translate(cx, baseY);
    canvas.scale(scale);

    if (flipProgress > 0.001 && flipProgress < 0.999) {
      canvas.translate(0, -60);
      canvas.rotate(-flipProgress * 2.0 * math.pi);
      canvas.translate(0, 60);
    }

    // Squash & stretch + 3D turntable spin physics!
    double stretchY = 1.0;
    if (tapBounce > 0.01 && tapBounce < 0.99) {
      stretchY = 1.0 + math.sin(tapBounce * 2 * math.pi) * 0.11;
    } else if (winkProgress > 0.02 && winkProgress < 0.98) {
      stretchY = 1.0 + math.sin(winkProgress * math.pi).abs() * 0.04;
    } else if (isDancing) {
      stretchY = 1.0 + math.cos(idle * 10 * math.pi) * 0.048;
    } else {
      stretchY = 1.0 - math.sin(idle * 2 * math.pi) * 0.018;
    }
    final squashX = 1.0 / math.sqrt(stretchY);
    final turntableX = spinProgress > 0.001 && spinProgress < 0.999
        ? (0.24 + 0.76 * math.cos(spinProgress * math.pi * 2.0).abs())
        : 1.0;
    canvas.scale(squashX * turntableX, stretchY);

    // Compute natural hero 3/4 + interactive 3D angles
    final spinYawWave = spinProgress > 0.001 && spinProgress < 0.999
        ? math.sin(spinProgress * math.pi * 4.0) * 0.58
        : 0.0;
    final danceTurn = isDancing ? math.sin(idle * 6 * math.pi) * 0.28 : 0.0;
    final idleLook = math.sin(idle * 2 * math.pi) * 0.14;
    final explainTurn = mood == RobotMood.explaining ? 0.18 : 0.0;
    final baseBodyYaw = (0.14 + idleLook * 0.55 + danceTurn + explainTurn * 0.65 + spinYawWave + userYaw)
        .clamp(-0.78, 0.78);
    final baseBodyPitch =
        ((mood == RobotMood.excited ? -0.07 : 0.02) + userPitch * 0.75)
            .clamp(-0.36, 0.36);

    final headYaw = (baseBodyYaw * 1.28 + idleLook * 0.45 + explainTurn * 0.45 + userYaw * 0.32)
        .clamp(-0.92, 0.92);
    final headPitch = (baseBodyPitch * 1.15 +
            (mood == RobotMood.thinking ? -0.15 : math.sin(idle * 2 * math.pi) * 0.04) +
            userPitch * 0.35)
        .clamp(-0.42, 0.42);
    final headRoll = isDancing
        ? math.sin(idle * 6 * math.pi) * 0.10
        : (mood == RobotMood.thinking ? 0.12 : math.sin(idle * 2 * math.pi) * 0.03);

    // Confetti & Sparkle fountain behind/around Bolts
    _drawConfettiAndSparkles(canvas);

    // Coordinate pivots for torso vs articulated head
    const bodyPivot = _Vec3(0, -40, 0);
    const headPivot = _Vec3(0, -96, 0);

    // Subtle entrance tilt
    final bodyRoll = isDancing ? math.sin(idle * 6 * math.pi) * 0.065 : 0.0;

    _ProjPt projBody(_Vec3 v) =>
        _project(v, bodyPivot, baseBodyYaw, baseBodyPitch, bodyRoll);
    _ProjPt projHead(_Vec3 v) =>
        _project(v, headPivot, headYaw, headPitch, headRoll);

    // ------------------------------------------------------------
    // COMPUTE ARM TARGETS IN 3D SPACE
    // ------------------------------------------------------------
    final leftShoulder3 = const _Vec3(-27, -48, 2);
    final rightShoulder3 = const _Vec3(27, -48, 2);

    _Vec3 leftElbow3;
    _Vec3 leftWrist3;
    _Vec3 rightElbow3;
    _Vec3 rightWrist3;

    if (boostThrust > 0.3) {
      // Superhero rocket flight pose: right fist punches forward/up, left sweeps back!
      final punchFlutter = math.sin(idle * 12 * math.pi) * 2.5;
      leftElbow3 = _Vec3(-39, -40, -6);
      leftWrist3 = _Vec3(-49, -24 + punchFlutter, -14);
      rightElbow3 = _Vec3(34, -67, 12);
      rightWrist3 = _Vec3(39, -90 - punchFlutter, 24);
    } else if (winkProgress > 0.02 && winkProgress < 0.98) {
      final wWave = math.sin(winkProgress * math.pi * 6.0);
      leftElbow3 = _Vec3(-39, -56, 8);
      leftWrist3 = _Vec3(-45 + wWave * 8, -78 + wWave.abs() * 3, 18);
      rightElbow3 = _Vec3(37, -36, 6);
      rightWrist3 = const _Vec3(26, -54, 18);
    } else if (isDancing) {
      final groove = math.sin(idle * 10 * math.pi);
      leftElbow3 = _Vec3(-39, -54 - groove * 5, 6);
      leftWrist3 = _Vec3(-44 + groove * 5, -72 - groove * 10, 14);
      rightElbow3 = _Vec3(39, -54 + groove * 5, 6);
      rightWrist3 = _Vec3(44 + groove * 5, -72 + groove * 10, 14);
    } else if (mood == RobotMood.greeting) {
      final wave = math.sin(idle * 6 * math.pi);
      leftElbow3 = _Vec3(-39, -54, 8);
      leftWrist3 = _Vec3(-44 + wave * 7, -74 + wave.abs() * 3, 18);
      rightElbow3 = _Vec3(36, -34, 4);
      rightWrist3 = _Vec3(40, -24 + math.sin(idle * 2 * math.pi) * 3, 10);
    } else if (mood == RobotMood.excited || tapBounce > 0.02) {
      final cheer = math.sin(idle * 4 * math.pi) * 4 + tapBounce * 4;
      leftElbow3 = _Vec3(-39, -57, 6);
      leftWrist3 = _Vec3(-43, -76 - cheer, 14);
      rightElbow3 = _Vec3(39, -57, 6);
      rightWrist3 = _Vec3(43, -76 - cheer, 14);
    } else if (mood == RobotMood.explaining) {
      leftElbow3 = _Vec3(-36, -34, 4);
      leftWrist3 = _Vec3(-37, -23 + math.sin(idle * 2 * math.pi) * 3, 10);
      rightElbow3 = _Vec3(41, -43, 10);
      rightWrist3 = _Vec3(52 + math.sin(idle * 4 * math.pi) * 3, -50, 22);
    } else if (mood == RobotMood.thinking) {
      leftElbow3 = _Vec3(-35, -34, 4);
      leftWrist3 = _Vec3(-34, -22, 10);
      rightElbow3 = _Vec3(38, -50, 16);
      rightWrist3 = const _Vec3(23, -68, 25); // gloved hand touching chin!
    } else {
      final swing = math.sin(idle * 2 * math.pi) * 3.5;
      leftElbow3 = _Vec3(-36, -34 + swing * 0.4, 4);
      leftWrist3 = _Vec3(-39, -22 + swing, 12);
      rightElbow3 = _Vec3(36, -34 - swing * 0.4, 4);
      rightWrist3 = _Vec3(39, -22 - swing, 12);
    }

    final pLShoulder = projBody(leftShoulder3);
    final pLElbow = projBody(leftElbow3);
    final pLWrist = projBody(leftWrist3);
    final pRShoulder = projBody(rightShoulder3);
    final pRElbow = projBody(rightElbow3);
    final pRWrist = projBody(rightWrist3);

    final leftArmAvgZ = (pLShoulder.z + pLElbow.z + pLWrist.z) / 3.0;
    final rightArmAvgZ = (pRShoulder.z + pRElbow.z + pRWrist.z) / 3.0;

    // ------------------------------------------------------------
    // LAYER 1: PARTS BEHIND THE TORSO (Boosters, Suspension Wheels, Far Arm)
    // ------------------------------------------------------------
    final wheelRot = (1.0 - rawEntrance) * 6 * math.pi + tapBounce * 4 * math.pi;

    // Collect back-plane items & sort by depth
    final List<({double z, VoidCallback draw})> backItems = [];

    if (hasBoosters) {
      for (final side in [-1.0, 1.0]) {
        final topAnchor = projBody(_Vec3(side * 26.5, -52, -19));
        final botAnchor = projBody(_Vec3(side * 26.5, -24, -19));
        backItems.add((
          z: (topAnchor.z + botAnchor.z) * 0.5,
          draw: () => _draw3DRocketBooster(canvas, topAnchor, botAnchor),
        ));
      }
    }

    // Dual 3D wheels + suspension legs
    for (final side in [-1.0, 1.0]) {
      final wInner = projBody(_Vec3(side * 16, -12, 0));
      final wOuter = projBody(_Vec3(side * 26, -12, 0));
      final strutTop = projBody(_Vec3(side * 15, -22, 0));
      final foreshorten =
          (0.62 + side * math.sin(baseBodyYaw) * 0.24).clamp(0.45, 0.90);
      backItems.add((
        z: (wInner.z + wOuter.z) * 0.5 - 3.0,
        draw: () => _draw3DWheelAssembly(
          canvas,
          strutTop: strutTop,
          wInner: wInner,
          wOuter: wOuter,
          wheelRot: wheelRot,
          sideSquash: foreshorten,
        ),
      ));
    }

    if (leftArmAvgZ < -2.0) {
      backItems.add((
        z: leftArmAvgZ,
        draw: () => _draw3DCartoonArm(
          canvas,
          shoulder: pLShoulder,
          elbow: pLElbow,
          wrist: pLWrist,
          openWave: mood == RobotMood.greeting || mood == RobotMood.excited || isDancing,
          pointOut: false,
          nearChin: false,
          isLeft: true,
        ),
      ));
    }

    if (rightArmAvgZ < -2.0) {
      backItems.add((
        z: rightArmAvgZ,
        draw: () => _draw3DCartoonArm(
          canvas,
          shoulder: pRShoulder,
          elbow: pRElbow,
          wrist: pRWrist,
          openWave: mood == RobotMood.excited || isDancing,
          pointOut: mood == RobotMood.explaining,
          nearChin: mood == RobotMood.thinking,
          isLeft: false,
        ),
      ));
    }

    backItems.sort((a, b) => a.z.compareTo(b.z));
    for (final item in backItems) {
      item.draw();
    }

    // ------------------------------------------------------------
    // LAYER 2: 3D PELVIS BELT & CHUBBY EXTRUDED TORSO
    // ------------------------------------------------------------
    _draw3DPelvis(canvas, projBody);
    _draw3DRoundedBox(
      canvas: canvas,
      project: projBody,
      centerY: -40,
      hw: 26,
      hh: 20,
      radius: 10,
      backZ: -16,
      frontZ: 16,
      chamferInset: 2.2,
      chamferDepth: 3.2,
      yaw: baseBodyYaw,
      pitch: baseBodyPitch,
      roll: bodyRoll,
      highlightColor: paintStyle.torsoHighlight,
      midColor: paintStyle.torsoColor,
      darkColor: paintStyle.torsoShadow,
      rimGlowColor: paintStyle.neonColor,
    );

    // 3D Chest Core Window + Extruded Spinning Cog + Glowing Heart Crystal
    _draw3DChestCore(canvas, projBody, baseBodyYaw, baseBodyPitch, bodyRoll);

    // Accordion Chrome Neck Bellows + Under-Chin Cast Shadow
    _draw3DNeck(canvas, projBody);

    // ------------------------------------------------------------
    // LAYER 3: HEAD, FAR/NEAR EARPODS, VISOR GLASS, CARTOON FACE & HAT
    // ------------------------------------------------------------
    // Hat parts that peek behind head (Back crown wall / brim back)
    if (hat == RobotHat.crown) {
      _draw3DCrownBack(canvas, projHead, headYaw, headPitch);
    }

    final pEarLeftIn = projHead(const _Vec3(-33, -96, 0));
    final pEarLeftOut = projHead(const _Vec3(-41, -96, 0));
    final pEarRightIn = projHead(const _Vec3(33, -96, 0));
    final pEarRightOut = projHead(const _Vec3(41, -96, 0));

    // Draw far earpod BEHIND the head!
    if (pEarLeftOut.z < 0) {
      _draw3DEarpod(canvas, pEarLeftIn, pEarLeftOut, isLeft: true);
    }
    if (pEarRightOut.z < 0) {
      _draw3DEarpod(canvas, pEarRightIn, pEarRightOut, isLeft: false);
    }

    // Spring Antenna behind/atop crown (when none or visor)
    if (hat == RobotHat.none || hat == RobotHat.visor) {
      _draw3DSpringAntenna(canvas, projHead, headYaw);
    }

    // Main Chubby 3D Cartoon Head Helmet!
    _draw3DRoundedBox(
      canvas: canvas,
      project: projHead,
      centerY: -96,
      hw: 33,
      hh: 24,
      radius: 13,
      backZ: -19,
      frontZ: 19,
      chamferInset: 2.6,
      chamferDepth: 3.6,
      yaw: headYaw,
      pitch: headPitch,
      roll: headRoll,
      highlightColor: paintStyle.headHighlight,
      midColor: paintStyle.headColor,
      darkColor: paintStyle.headShadow,
      rimGlowColor: paintStyle.neonColor,
    );

    // 3D Glossy Sapphire Visor & Big Expressive Cartoon Face!
    _draw3DVisorAndFace(
      canvas,
      projHead,
      headYaw: headYaw,
      headPitch: headPitch,
      headRoll: headRoll,
    );

    // Near earpod(s) in FRONT of head sides!
    if (pEarLeftOut.z >= 0) {
      _draw3DEarpod(canvas, pEarLeftIn, pEarLeftOut, isLeft: true);
    }
    if (pEarRightOut.z >= 0) {
      _draw3DEarpod(canvas, pEarRightIn, pEarRightOut, isLeft: false);
    }

    // 3D Hats on Crown / Over Eyes
    _draw3DHatFront(canvas, projHead, headYaw, headPitch, headRoll);

    // ------------------------------------------------------------
    // LAYER 4: NEAR / FOREGROUND ARMS & PUFFY CARTOON GLOVES
    // ------------------------------------------------------------
    final List<({double z, VoidCallback draw})> frontArms = [];
    if (leftArmAvgZ >= -2.0) {
      frontArms.add((
        z: leftArmAvgZ,
        draw: () => _draw3DCartoonArm(
          canvas,
          shoulder: pLShoulder,
          elbow: pLElbow,
          wrist: pLWrist,
          openWave: mood == RobotMood.greeting || mood == RobotMood.excited || isDancing,
          pointOut: false,
          nearChin: false,
          isLeft: true,
        ),
      ));
    }
    if (rightArmAvgZ >= -2.0) {
      frontArms.add((
        z: rightArmAvgZ,
        draw: () => _draw3DCartoonArm(
          canvas,
          shoulder: pRShoulder,
          elbow: pRElbow,
          wrist: pRWrist,
          openWave: mood == RobotMood.excited || isDancing,
          pointOut: mood == RobotMood.explaining,
          nearChin: mood == RobotMood.thinking,
          isLeft: false,
        ),
      ));
    }
    frontArms.sort((a, b) => a.z.compareTo(b.z));
    for (final a in frontArms) {
      a.draw();
    }

    canvas.restore();
  }

  // ------------------------------------------------------------------
  // 3D PROJECTION & ROTATION MATH
  // ------------------------------------------------------------------
  _ProjPt _project(_Vec3 v, _Vec3 pivot, double yaw, double pitch, double roll) {
    final dx = v.x - pivot.x;
    final dy = v.y - pivot.y;
    final dz = v.z - pivot.z;

    // 1. Z Roll
    final cosR = math.cos(roll);
    final sinR = math.sin(roll);
    final xr = dx * cosR - dy * sinR;
    final yr = dx * sinR + dy * cosR;

    // 2. Y Yaw (+yaw turns front toward +x right)
    final cosY = math.cos(yaw);
    final sinY = math.sin(yaw);
    final xy = xr * cosY + dz * sinY;
    final zy = -xr * sinY + dz * cosY;

    // 3. X Pitch (+pitch nods forward/down)
    final cosP = math.cos(pitch);
    final sinP = math.sin(pitch);
    final yp = yr * cosP + zy * sinP;
    final zp = -yr * sinP + zy * cosP;

    final pScale = _fov / (_fov - zp).clamp(130.0, 900.0);
    return _ProjPt(
      Offset(pivot.x + xy * pScale, pivot.y + yp * pScale),
      zp,
      pScale,
    );
  }

  _Vec3 _rotateNormal(double nx, double ny, double nz, double yaw, double pitch, double roll) {
    final cosR = math.cos(roll);
    final sinR = math.sin(roll);
    final xr = nx * cosR - ny * sinR;
    final yr = nx * sinR + ny * cosR;

    final cosY = math.cos(yaw);
    final sinY = math.sin(yaw);
    final xy = xr * cosY + nz * sinY;
    final zy = -xr * sinY + nz * cosY;

    final cosP = math.cos(pitch);
    final sinP = math.sin(pitch);
    final yp = yr * cosP + zy * sinP;
    final zp = -yr * sinP + zy * cosP;
    return _Vec3(xy, yp, zp);
  }

  // Generate 24 perimeter points around a rounded rectangle + outward normals
  List<_RingSample> _sampleRoundedRect(double hw, double hh, double r) {
    final cr = r.clamp(2.0, math.min(hw, hh) - 0.5);
    const stepsPerCorner = 5;
    final List<_RingSample> pts = [];

    final corners = [
      (cx: hw - cr, cy: -hh + cr, startA: -math.pi / 2),
      (cx: hw - cr, cy: hh - cr, startA: 0.0),
      (cx: -hw + cr, cy: hh - cr, startA: math.pi / 2),
      (cx: -hw + cr, cy: -hh + cr, startA: math.pi),
    ];

    for (final c in corners) {
      for (int s = 0; s <= stepsPerCorner; s++) {
        final a = c.startA + (s / stepsPerCorner) * (math.pi / 2);
        final nx = math.cos(a);
        final ny = math.sin(a);
        pts.add(_RingSample(c.cx + nx * cr, c.cy + ny * cr, nx, ny));
      }
    }
    return pts;
  }

  // ------------------------------------------------------------------
  // 3D SCULPTED CHASSIS (HEAD & TORSO WITH BEVEL + TOON INK HULL)
  // ------------------------------------------------------------------
  void _draw3DRoundedBox({
    required Canvas canvas,
    required _ProjPt Function(_Vec3) project,
    required double centerY,
    required double hw,
    required double hh,
    required double radius,
    required double backZ,
    required double frontZ,
    required double chamferInset,
    required double chamferDepth,
    required double yaw,
    required double pitch,
    required double roll,
    required Color highlightColor,
    required Color midColor,
    required Color darkColor,
    required Color rimGlowColor,
  }) {
    final outerRing = _sampleRoundedRect(hw, hh, radius);
    final frontRing = _sampleRoundedRect(
      hw - chamferInset,
      hh - chamferInset,
      (radius - chamferInset * 0.7).clamp(2.0, 20.0),
    );
    final n = outerRing.length;
    final midZ = frontZ - chamferDepth;

    final backPts = [
      for (final s in outerRing) project(_Vec3(s.x, centerY + s.y, backZ)),
    ];
    final midPts = [
      for (final s in outerRing) project(_Vec3(s.x, centerY + s.y, midZ)),
    ];
    final frontPts = [
      for (final s in frontRing) project(_Vec3(s.x, centerY + s.y, frontZ)),
    ];

    final List<_FaceQuad> sideQuads = [];
    final List<_FaceQuad> bevelQuads = [];

    for (int i = 0; i < n; i++) {
      final j = (i + 1) % n;
      final nAvgX = (outerRing[i].nx + outerRing[j].nx) * 0.5;
      final nAvgY = (outerRing[i].ny + outerRing[j].ny) * 0.5;

      // Deep extruded side wall
      final rotSide = _rotateNormal(nAvgX, nAvgY, 0.0, yaw, pitch, roll);
      final ndotl = (rotSide.x * -0.45 + rotSide.y * -0.58 + rotSide.z * 0.68)
          .clamp(-0.2, 1.0);
      final sideTone = _shade3DTone(ndotl, highlightColor, midColor, darkColor);

      final avgSideZ =
          (backPts[i].z + backPts[j].z + midPts[j].z + midPts[i].z) * 0.25;
      sideQuads.add(
        _FaceQuad(backPts[i].p, backPts[j].p, midPts[j].p, midPts[i].p, avgSideZ, sideTone),
      );

      // 45-degree specular bevel chamfer rim
      final rotBevel = _rotateNormal(nAvgX * 0.72, nAvgY * 0.72, 0.70, yaw, pitch, roll);
      final bevelL = (rotBevel.x * -0.45 + rotBevel.y * -0.58 + rotBevel.z * 0.68)
          .clamp(0.0, 1.0);
      final bevelTone = Color.lerp(
        midColor,
        Color.lerp(highlightColor, Colors.white, 0.42)!,
        math.pow(bevelL, 0.85).toDouble(),
      )!;
      final avgBevelZ =
          (midPts[i].z + midPts[j].z + frontPts[j].z + frontPts[i].z) * 0.25;
      bevelQuads.add(
        _FaceQuad(midPts[i].p, midPts[j].p, frontPts[j].p, frontPts[i].p, avgBevelZ, bevelTone),
      );
    }

    sideQuads.sort((a, b) => a.avgZ.compareTo(b.avgZ));
    bevelQuads.sort((a, b) => a.avgZ.compareTo(b.avgZ));

    final frontPath = Path()..moveTo(frontPts.first.p.dx, frontPts.first.p.dy);
    for (int i = 1; i < n; i++) {
      frontPath.lineTo(frontPts[i].p.dx, frontPts[i].p.dy);
    }
    frontPath.close();

    final backPath = Path()..moveTo(backPts.first.p.dx, backPts.first.p.dy);
    for (int i = 1; i < n; i++) {
      backPath.lineTo(backPts[i].p.dx, backPts[i].p.dy);
    }
    backPath.close();

    // PASS 1: Inverted-hull seamless bold cartoon ink silhouette!
    final inkFill = Paint()..color = _inkColor;
    final inkStroke = Paint()
      ..color = _inkColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.8
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(backPath, inkFill);
    canvas.drawPath(backPath, inkStroke);
    for (final q in sideQuads) {
      final qp = _quadPath(q);
      canvas.drawPath(qp, inkFill);
      canvas.drawPath(qp, inkStroke);
    }
    for (final q in bevelQuads) {
      final qp = _quadPath(q);
      canvas.drawPath(qp, inkFill);
      canvas.drawPath(qp, inkStroke);
    }
    canvas.drawPath(frontPath, inkFill);
    canvas.drawPath(frontPath, inkStroke);

    // PASS 2: Shaded 3D Side Quads + Glossy Bevel Rim
    for (final q in sideQuads) {
      final qp = _quadPath(q);
      canvas.drawPath(qp, Paint()..color = q.color);
      canvas.drawPath(
        qp,
        Paint()
          ..color = q.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.85,
      );
    }
    for (final q in bevelQuads) {
      final qp = _quadPath(q);
      canvas.drawPath(qp, Paint()..color = q.color);
      canvas.drawPath(
        qp,
        Paint()
          ..color = q.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.85,
      );
    }

    // PASS 3: Domed Vinyl Front Surface with Volumetric Studio Radial Lighting
    final bounds = frontPath.getBounds();
    final frontCenter = project(_Vec3(0, centerY, frontZ)).p;
    final frontGrad = RadialGradient(
      center: Alignment(
        -0.42 + math.sin(yaw) * 0.16,
        -0.52 + math.sin(pitch) * 0.12,
      ),
      radius: 1.15,
      colors: [
        Color.lerp(highlightColor, Colors.white, 0.36)!,
        midColor,
        darkColor,
      ],
      stops: const [0.0, 0.56, 1.0],
    ).createShader(bounds.inflate(4));

    canvas.drawPath(frontPath, Paint()..shader = frontGrad);

    // Subtle specular rim catch around front inner bevel
    canvas.drawPath(
      frontPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.34)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.25,
    );

    // Bottom bounce sheen inside front shell
    final rimArc = project(_Vec3(0, centerY + hh * 0.65, frontZ)).p;
    canvas.drawCircle(
      Offset(rimArc.dx + (frontCenter.dx - rimArc.dx) * 0.1, rimArc.dy),
      hw * 0.32,
      Paint()
        ..shader = RadialGradient(
          colors: [
            rimGlowColor.withValues(alpha: 0.18),
            rimGlowColor.withValues(alpha: 0.0),
          ],
        ).createShader(
          Rect.fromCircle(center: rimArc, radius: hw * 0.45),
        ),
    );
  }

  Color _shade3DTone(double ndotl, Color highlight, Color mid, Color dark) {
    if (ndotl >= 0.45) {
      final t = ((ndotl - 0.45) / 0.55).clamp(0.0, 1.0);
      return Color.lerp(mid, highlight, t)!;
    } else {
      final t = ((ndotl + 0.2) / 0.65).clamp(0.0, 1.0);
      return Color.lerp(dark, mid, t)!;
    }
  }

  Path _quadPath(_FaceQuad q) {
    return Path()
      ..moveTo(q.a.dx, q.a.dy)
      ..lineTo(q.b.dx, q.b.dy)
      ..lineTo(q.c.dx, q.c.dy)
      ..lineTo(q.d.dx, q.d.dy)
      ..close();
  }

  // ------------------------------------------------------------------
  // 3D PELVIS & NECK BELLOWS
  // ------------------------------------------------------------------
  void _draw3DPelvis(Canvas canvas, _ProjPt Function(_Vec3) project) {
    final leftHip = project(const _Vec3(-16, -21, 0));
    final rightHip = project(const _Vec3(16, -21, 0));
    _draw3DCapsule(
      canvas,
      leftHip.p,
      rightHip.p,
      6.2 * ((leftHip.scale + rightHip.scale) * 0.5),
      const Color(0xFF475569),
      const Color(0xFF0F172A),
      highlightColor: const Color(0xFF94A3B8),
    );
    // Belt buckle neon light
    final buckle = project(const _Vec3(0, -21, 7));
    canvas.drawCircle(buckle.p, 3.6 * buckle.scale, Paint()..color = _inkColor);
    canvas.drawCircle(
      buckle.p,
      2.6 * buckle.scale,
      Paint()..color = paintStyle.trimColor,
    );
  }

  void _draw3DNeck(Canvas canvas, _ProjPt Function(_Vec3) project) {
    // 3 stacked rubber/chrome bellows rings between chest & head
    for (int r = 0; r < 3; r++) {
      final y = -61.5 - r * 3.8;
      final c = project(_Vec3(0, y, 0));
      final rad = (8.8 - r * 0.5) * c.scale;
      final ringRect = Rect.fromCenter(center: c.p, width: rad * 2.1, height: 6.2 * c.scale);
      canvas.drawOval(
        ringRect.inflate(1.4),
        Paint()..color = _inkColor,
      );
      canvas.drawOval(
        ringRect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: const [
              Color(0xFFCBD5E1),
              Color(0xFF94A3B8),
              Color(0xFF475569),
            ],
          ).createShader(ringRect),
      );
    }

    // Soft ambient shadow cast onto top of torso under head!
    final chinShadow = project(const _Vec3(0, -59, 6));
    canvas.drawOval(
      Rect.fromCenter(
        center: chinShadow.p,
        width: 34 * chinShadow.scale,
        height: 7 * chinShadow.scale,
      ),
      Paint()..color = _inkColor.withValues(alpha: 0.28),
    );
  }

  // ------------------------------------------------------------------
  // 3D CHEST CORE: RECESSED PORTHOLE, 3D SPINNING COG & HEART CRYSTAL
  // ------------------------------------------------------------------
  void _draw3DChestCore(
    Canvas canvas,
    _ProjPt Function(_Vec3) project,
    double yaw,
    double pitch,
    double roll,
  ) {
    final screenPts = _sampleRoundedRect(18, 12.5, 7);
    final outer = [
      for (final s in screenPts) project(_Vec3(s.x, -40 + s.y, 17.5)),
    ];
    final inner = [
      for (final s in screenPts)
        project(_Vec3(s.x * 0.90, -40 + s.y * 0.88, 18.6)),
    ];

    final outerPath = Path()..moveTo(outer.first.p.dx, outer.first.p.dy);
    final innerPath = Path()..moveTo(inner.first.p.dx, inner.first.p.dy);
    for (int i = 1; i < outer.length; i++) {
      outerPath.lineTo(outer[i].p.dx, outer[i].p.dy);
      innerPath.lineTo(inner[i].p.dx, inner[i].p.dy);
    }
    outerPath.close();
    innerPath.close();

    // Metallic bezel
    canvas.drawPath(
      outerPath,
      Paint()
        ..color = _inkColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4,
    );
    canvas.drawPath(
      outerPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.92),
            paintStyle.trimColor,
            const Color(0xFF475569),
          ],
        ).createShader(outerPath.getBounds()),
    );

    // Smoked glass interior
    final glassBounds = innerPath.getBounds();
    canvas.drawPath(
      innerPath,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.25, -0.35),
          colors: const [Color(0xFF1E293B), Color(0xFF090D16)],
        ).createShader(glassBounds),
    );

    // Clip animated cog + heart pulse neatly inside porthole
    canvas.save();
    canvas.clipPath(innerPath);

    final gearAngle = idle *
        2 *
        math.pi *
        (overchargeProgress > 0.05
            ? 3.6
            : (isTalking || isDancing ? 2.4 : 1.0));
    // 3D Extruded shadow layer of cog
    final gearBack = project(const _Vec3(-5.8, -39.5, 18.8));
    _draw3DGear(
      canvas,
      gearBack.p,
      8.8 * gearBack.scale,
      gearAngle,
      const Color(0xFF92400E),
      isDarkExtrude: true,
    );
    // 3D Front gold cog
    final gearFront = project(const _Vec3(-6.2, -40.3, 20.6));
    _draw3DGear(
      canvas,
      gearFront.p,
      8.8 * gearFront.scale,
      gearAngle,
      paintStyle.trimColor,
    );

    // Glowing Power Heart / Core Gem on right of chest panel!
    final ledPulse = 0.65 + 0.35 * math.sin(idle * 6 * math.pi);
    final gemCenter = project(const _Vec3(8.5, -40.0, 20.5));
    final gemR = 4.6 * gemCenter.scale * (0.94 + 0.1 * ledPulse);
    final gemColor = overchargeProgress > 0.05
        ? const Color(0xFFFDE047)
        : (isRainbowMode
            ? _activeNeon
            : (mood == RobotMood.excited || isDancing
                ? const Color(0xFF34D399)
                : paintStyle.neonColor));
    canvas.drawCircle(
      gemCenter.p,
      gemR * 2.1,
      Paint()..color = gemColor.withValues(alpha: 0.25 * ledPulse),
    );
    _drawGlossySphere(
      canvas,
      gemCenter.p,
      gemR,
      Color.lerp(gemColor, Colors.white, 0.55)!,
      gemColor,
      const Color(0xFF0F172A),
      drawOutline: true,
    );

    // Curved glass reflection sheen across chest window
    final sheenP1 = project(const _Vec3(-16, -49, 21.0)).p;
    final sheenP2 = project(const _Vec3(2, -50, 21.0)).p;
    final sheenP3 = project(const _Vec3(-15, -35, 21.0)).p;
    final sheenPath = Path()
      ..moveTo(sheenP1.dx, sheenP1.dy)
      ..lineTo(sheenP2.dx, sheenP2.dy)
      ..lineTo(sheenP3.dx, sheenP3.dy)
      ..close();
    canvas.drawPath(
      sheenPath,
      Paint()..color = Colors.white.withValues(alpha: 0.14),
    );

    canvas.restore();

    canvas.drawPath(
      innerPath,
      Paint()
        ..color = _inkColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
  }

  void _draw3DGear(
    Canvas canvas,
    Offset c,
    double r,
    double angle,
    Color color, {
    bool isDarkExtrude = false,
  }) {
    final path = Path();
    const teeth = 8;
    for (int i = 0; i < teeth * 2; i++) {
      final a = angle + i * (math.pi / teeth);
      final rad = i.isEven ? r : r * 0.72;
      final pt = Offset(c.dx + math.cos(a) * rad, c.dy + math.sin(a) * rad);
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    path.close();

    if (isDarkExtrude) {
      canvas.drawPath(path, Paint()..color = color);
      return;
    }

    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, color, Color.lerp(color, _inkColor, 0.4)!],
          stops: const [0.0, 0.4, 1.0],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    canvas.drawCircle(c, r * 0.30, Paint()..color = const Color(0xFF090D16));
  }

  // ------------------------------------------------------------------
  // 3D GLOSSY CRT VISOR & PIXAR-STYLE CARTOON FACE
  // ------------------------------------------------------------------
  void _draw3DVisorAndFace(
    Canvas canvas,
    _ProjPt Function(_Vec3) project, {
    required double headYaw,
    required double headPitch,
    required double headRoll,
  }) {
    final bezelRing = _sampleRoundedRect(26.5, 18.0, 10);
    final outerBezel = [
      for (final s in bezelRing) project(_Vec3(s.x, -95.5 + s.y, 19.6)),
    ];
    final screenPts = [
      for (final s in bezelRing)
        project(_Vec3(s.x * 0.92, -95.5 + s.y * 0.90, 21.2)),
    ];

    final bezelPath = Path()..moveTo(outerBezel.first.p.dx, outerBezel.first.p.dy);
    final screenPath = Path()..moveTo(screenPts.first.p.dx, screenPts.first.p.dy);
    for (int i = 1; i < outerBezel.length; i++) {
      bezelPath.lineTo(outerBezel[i].p.dx, outerBezel[i].p.dy);
      screenPath.lineTo(screenPts[i].p.dx, screenPts[i].p.dy);
    }
    bezelPath.close();
    screenPath.close();

    // Recessed glossy metallic visor frame
    canvas.drawPath(
      bezelPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.78),
            paintStyle.headShadow,
          ],
        ).createShader(bezelPath.getBounds()),
    );
    canvas.drawPath(
      bezelPath,
      Paint()
        ..color = _inkColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // Rich CRT sapphire visor interior
    final sBounds = screenPath.getBounds();
    canvas.drawPath(
      screenPath,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.0, -0.2),
          radius: 0.95,
          colors: const [Color(0xFF1E293B), Color(0xFF080D1A)],
        ).createShader(sBounds),
    );

    canvas.save();
    canvas.clipPath(screenPath);

    // Subtle facial glow pool inside visor
    final glowCenter = project(const _Vec3(0, -96, 21.6)).p;
    canvas.drawCircle(
      glowCenter,
      24,
      Paint()
        ..shader = RadialGradient(
          colors: [
            paintStyle.neonColor.withValues(alpha: 0.16),
            paintStyle.neonColor.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: glowCenter, radius: 24)),
    );

    // 1. Warm Coral Blush Cheeks (soft cartoon charm!)
    for (final side in [-1.0, 1.0]) {
      final cheek = project(_Vec3(side * 15.5, -88.0, 22.0));
      final cw = 8.2 * cheek.scale;
      final ch = 5.0 * cheek.scale;
      final cRect = Rect.fromCenter(center: cheek.p, width: cw, height: ch);
      canvas.drawOval(
        cRect,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFB7185).withValues(alpha: 0.62),
              const Color(0xFFFB7185).withValues(alpha: 0.0),
            ],
          ).createShader(cRect),
      );
    }

    // 2. Big Expressive 3D Glossy Cartoon Eyes!
    final isWinkingNow = winkProgress > 0.06 && winkProgress < 0.94;
    final isBlinking = !isWinkingNow &&
        idle > 0.92 &&
        !isTalking &&
        !isDancing &&
        tapBounce < 0.05;
    final isJoySquint =
        mood == RobotMood.excited || isDancing || tapBounce > 0.15;

    final pupilShiftX = mood == RobotMood.explaining
        ? 1.8
        : (mood == RobotMood.thinking ? 1.5 : math.sin(headYaw) * 1.4);
    final pupilShiftY = mood == RobotMood.thinking ? -1.8 : 0.0;

    final eyeGlowColor = isRainbowMode || overchargeProgress > 0.05
        ? _activeNeon
        : (isJoySquint || isWinkingNow ? const Color(0xFF34D399) : paintStyle.neonColor);

    for (final side in [-1.0, 1.0]) {
      final eyeCenter = project(_Vec3(side * 10.6, -96.5, 22.4));
      final ex = eyeCenter.p.dx;
      final ey = eyeCenter.p.dy;
      final es = eyeCenter.scale;
      final thisEyeWinks = isWinkingNow && side > 0;

      if (boostThrust > 0.3) {
        // Hyped turbo star eyes during rocket flight!
        final starR = 7.2 * es;
        final star = Path()
          ..moveTo(ex, ey - starR)
          ..quadraticBezierTo(ex, ey, ex + starR, ey)
          ..quadraticBezierTo(ex, ey, ex, ey + starR)
          ..quadraticBezierTo(ex, ey, ex - starR, ey)
          ..quadraticBezierTo(ex, ey, ex, ey - starR)
          ..close();
        canvas.drawCircle(
          Offset(ex, ey),
          starR * 1.15,
          Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.35),
        );
        canvas.drawPath(star, Paint()..color = const Color(0xFFFDE047));
        canvas.drawCircle(
          Offset(ex, ey),
          2.2 * es,
          Paint()..color = Colors.white,
        );
      } else if (isBlinking || thisEyeWinks) {
        // Gentle curved happy blink / cute wink lash
        final blinkPath = Path()
          ..moveTo(ex - 5.5 * es, ey)
          ..quadraticBezierTo(
            ex,
            ey + (thisEyeWinks ? -4.2 : 3.2) * es,
            ex + 5.5 * es,
            ey,
          );
        canvas.drawPath(
          blinkPath,
          Paint()
            ..color = thisEyeWinks ? const Color(0xFFFDE047) : eyeGlowColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = (thisEyeWinks ? 3.2 : 2.6) * es
            ..strokeCap = StrokeCap.round,
        );
      } else if (isJoySquint) {
        // Cute thick smiling ^ ^ cartoon eyes with sparkling glint!
        final happyArc = Path()
          ..moveTo(ex - 5.8 * es, ey + 1.8 * es)
          ..quadraticBezierTo(ex, ey - 6.5 * es, ex + 5.8 * es, ey + 1.8 * es);
        canvas.drawPath(
          happyArc,
          Paint()
            ..color = eyeGlowColor.withValues(alpha: 0.35)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 5.6 * es
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawPath(
          happyArc,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.7 * es
            ..strokeCap = StrokeCap.round,
        );
      } else {
        // Giant Glossy Cartoon Eyes with Iris + Deep Pupil + Double Catchlights!
        final ew = 10.6 * es;
        final eh = 13.6 * es;
        final eyeRect = Rect.fromCenter(center: Offset(ex, ey), width: ew, height: eh);

        // Outer neon eyeball halo
        canvas.drawOval(
          eyeRect.inflate(2.2 * es),
          Paint()..color = eyeGlowColor.withValues(alpha: 0.25),
        );

        // Eyeball glossy fill (pure bright ice-white + cyan/neon edge)
        canvas.drawOval(
          eyeRect,
          Paint()
            ..shader = RadialGradient(
              center: const Alignment(-0.2, -0.3),
              colors: [
                Colors.white,
                Color.lerp(Colors.white, eyeGlowColor, 0.38)!,
                eyeGlowColor,
              ],
              stops: const [0.0, 0.65, 1.0],
            ).createShader(eyeRect),
        );

        // Animated Iris + Deep Pupil tracking mood/tilt
        final px = ex + pupilShiftX * es;
        final py = ey + pupilShiftY * es + 0.5 * es;
        canvas.drawOval(
          Rect.fromCenter(center: Offset(px, py), width: 6.0 * es, height: 7.4 * es),
          Paint()..color = const Color(0xFF0F172A),
        );

        // Pixar sparkle catchlights!
        canvas.drawCircle(
          Offset(px - 1.6 * es, py - 2.0 * es),
          1.75 * es,
          Paint()..color = Colors.white,
        );
        canvas.drawCircle(
          Offset(px + 1.3 * es, py + 1.7 * es),
          0.85 * es,
          Paint()..color = Colors.white.withValues(alpha: 0.85),
        );
      }

      // 3. Expressive Floating Cartoon Eyebrows!
      double browLift = 0.0;
      double browTilt = 0.0;
      if (mood == RobotMood.thinking) {
        browLift = side > 0 ? -3.0 : 0.8;
        browTilt = side > 0 ? -0.24 : 0.14;
      } else if (mood == RobotMood.excited || isDancing) {
        browLift = -2.2 - math.sin(idle * 6 * math.pi).abs() * 1.2;
        browTilt = side * -0.15;
      } else if (mood == RobotMood.greeting) {
        browLift = -1.5;
        browTilt = side * -0.14;
      } else if (mood == RobotMood.explaining) {
        browLift = side > 0 ? -1.6 : -0.6;
        browTilt = side * -0.10;
      }

      final browP = project(_Vec3(side * 10.6, -106.2 + browLift, 22.8));
      canvas.save();
      canvas.translate(browP.p.dx, browP.p.dy);
      canvas.rotate(browTilt + headRoll * 0.3);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: 9.2 * browP.scale,
            height: 2.8 * browP.scale,
          ),
          Radius.circular(2.0 * browP.scale),
        ),
        Paint()..color = const Color(0xFFFEF08A),
      );
      canvas.restore();
    }

    // 4. Sculpted Expressive Cartoon Mouth (D-grin / lip-sync vowel / hmm smirk!)
    _drawCartoonMouth(canvas, project);

    // 5. Diagonal Curved CRT Acrylic Glass Reflection
    final gTopL = project(const _Vec3(-23, -110, 22.8)).p;
    final gTopR = project(const _Vec3(4, -112, 22.8)).p;
    final gBotL = project(const _Vec3(-23, -89, 22.8)).p;
    final glassHighlight = Path()
      ..moveTo(gTopL.dx, gTopL.dy)
      ..lineTo(gTopR.dx, gTopR.dy)
      ..quadraticBezierTo(
        (gTopR.dx + gBotL.dx) * 0.42,
        (gTopR.dy + gBotL.dy) * 0.42,
        gBotL.dx,
        gBotL.dy,
      )
      ..close();
    canvas.drawPath(
      glassHighlight,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.24),
            Colors.white.withValues(alpha: 0.02),
          ],
        ).createShader(sBounds),
    );

    canvas.restore(); // unclip screen

    // Inner visor ink edge
    canvas.drawPath(
      screenPath,
      Paint()
        ..color = _inkColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
  }

  void _drawCartoonMouth(Canvas canvas, _ProjPt Function(_Vec3) project) {
    final mouthCenter = project(const _Vec3(0, -83.8, 22.8));
    final mx = mouthCenter.p.dx;
    final my = mouthCenter.p.dy;
    final ms = mouthCenter.scale;

    if (isTalking || isDancing) {
      // Bouncy phoneme open mouth + cute pink cartoon tongue!
      final beat = (math.sin(idle * 16 * math.pi) + 1.0) * 0.5;
      final mw = (10.5 + 3.0 * (1.0 - beat)) * ms;
      final mh = (5.2 + 4.4 * beat) * ms;
      final mRect = RRect.fromRectAndCorners(
        Rect.fromCenter(center: Offset(mx, my + 0.5 * ms), width: mw, height: mh),
        topLeft: Radius.circular(3.0 * ms),
        topRight: Radius.circular(3.0 * ms),
        bottomLeft: Radius.circular(mh * 0.7),
        bottomRight: Radius.circular(mh * 0.7),
      );
      canvas.save();
      canvas.clipRRect(mRect);
      canvas.drawRRect(mRect, Paint()..color = const Color(0xFF450A0A));
      // White top tooth rim
      canvas.drawRect(
        Rect.fromLTWH(mx - mw * 0.5, my - mh * 0.5, mw, mh * 0.34),
        Paint()..color = Colors.white,
      );
      // Pink tongue!
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(mx, my + mh * 0.36),
          width: mw * 0.72,
          height: mh * 0.65,
        ),
        Paint()..color = const Color(0xFFFB7185),
      );
      canvas.restore();
      canvas.drawRRect(
        mRect,
        Paint()
          ..color = paintStyle.neonColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6 * ms,
      );
    } else if (mood == RobotMood.thinking) {
      // Cute skewed pondering smirk
      final smirk = Path()
        ..moveTo(mx - 5.5 * ms, my + 1.2 * ms)
        ..quadraticBezierTo(mx - 1.5 * ms, my - 2.0 * ms, mx + 2.0 * ms, my + 0.5 * ms)
        ..quadraticBezierTo(mx + 4.5 * ms, my + 2.2 * ms, mx + 6.5 * ms, my - 0.8 * ms);
      canvas.drawPath(
        smirk,
        Paint()
          ..color = const Color(0xFFFDE047)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4 * ms
          ..strokeCap = StrokeCap.round,
      );
    } else {
      // Big beaming Cartoon D-Smile with cheek-upturned lip & tongue!
      final smileW = (mood == RobotMood.excited || tapBounce > 0.1) ? 16.5 * ms : 14.5 * ms;
      final smileH = (mood == RobotMood.excited || tapBounce > 0.1) ? 9.2 * ms : 7.4 * ms;

      final smilePath = Path()
        ..moveTo(mx - smileW * 0.5, my - smileH * 0.34)
        ..quadraticBezierTo(
          mx,
          my - smileH * 0.08,
          mx + smileW * 0.5,
          my - smileH * 0.34,
        )
        ..quadraticBezierTo(
          mx + smileW * 0.44,
          my + smileH * 0.80,
          mx,
          my + smileH * 0.80,
        )
        ..quadraticBezierTo(
          mx - smileW * 0.44,
          my + smileH * 0.80,
          mx - smileW * 0.5,
          my - smileH * 0.34,
        )
        ..close();

      canvas.save();
      canvas.clipPath(smilePath);
      canvas.drawPath(smilePath, Paint()..color = const Color(0xFF450A0A));
      // Top grin band following upper smile curve
      canvas.drawPath(
        Path()
          ..moveTo(mx - smileW * 0.55, my - smileH * 0.42)
          ..quadraticBezierTo(mx, my - smileH * 0.10, mx + smileW * 0.55, my - smileH * 0.42)
          ..lineTo(mx + smileW * 0.55, my + smileH * 0.16)
          ..quadraticBezierTo(mx, my + smileH * 0.28, mx - smileW * 0.55, my + smileH * 0.16)
          ..close(),
        Paint()..color = Colors.white,
      );
      // Warm rosy tongue
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(mx, my + smileH * 0.54),
          width: smileW * 0.58,
          height: smileH * 0.62,
        ),
        Paint()..color = const Color(0xFFFB7185),
      );
      canvas.restore();

      canvas.drawPath(
        smilePath,
        Paint()
          ..color = const Color(0xFFFDE047)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6 * ms
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  // ------------------------------------------------------------------
  // 3D EARPODS / HEADPHONES, COIL ANTENNA, AND HATS
  // ------------------------------------------------------------------
  void _draw3DEarpod(
    Canvas canvas,
    _ProjPt innerP,
    _ProjPt outerP, {
    required bool isLeft,
  }) {
    final s = (innerP.scale + outerP.scale) * 0.5;
    final cupR = 11.2 * s;

    // 3D Extruded cylinder stem from helmet side to outer earcup
    _draw3DCapsule(
      canvas,
      innerP.p,
      outerP.p,
      cupR * 0.72,
      paintStyle.trimColor,
      Color.lerp(paintStyle.trimColor, _inkColor, 0.38)!,
      highlightColor: Colors.white,
    );

    // Outer foreshortened elliptical dome cap
    final squashW = (1.0 - (outerP.p.dx - innerP.p.dx).abs() / (16 * s)).clamp(0.45, 0.92);
    final domeRect = Rect.fromCenter(
      center: outerP.p,
      width: cupR * 1.55 * squashW,
      height: cupR * 1.85,
    );
    canvas.drawOval(domeRect.inflate(1.8), Paint()..color = _inkColor);
    canvas.drawOval(
      domeRect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.4),
          colors: [
            Colors.white,
            paintStyle.trimColor,
            Color.lerp(paintStyle.trimColor, _inkColor, 0.35)!,
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(domeRect),
    );
    // Glowing inner core ring on earcup
    canvas.drawOval(
      domeRect.deflate(3.5 * s),
      Paint()
        ..color = paintStyle.neonColor.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 * s,
    );
  }

  void _draw3DSpringAntenna(
    Canvas canvas,
    _ProjPt Function(_Vec3) project,
    double headYaw,
  ) {
    final base = project(const _Vec3(0, -119, 0));
    final lag = (isDancing ? math.sin(idle * 6 * math.pi) * 4.5 : -math.sin(headYaw) * 3.0) +
        tapBounce * 3.0;
    final mid1 = project(_Vec3(lag * 0.4, -126, 0));
    final mid2 = project(_Vec3(lag * 0.75, -132, 0));
    final tip = project(_Vec3(lag, -138, 0));

    // Spring mount collar
    canvas.drawOval(
      Rect.fromCenter(center: base.p, width: 12 * base.scale, height: 5.5 * base.scale)
          .inflate(1.2),
      Paint()..color = _inkColor,
    );
    canvas.drawOval(
      Rect.fromCenter(center: base.p, width: 12 * base.scale, height: 5.5 * base.scale),
      Paint()..color = const Color(0xFF94A3B8),
    );

    // Chrome spring rod
    _draw3DCapsule(
      canvas,
      base.p,
      tip.p,
      2.3 * tip.scale,
      const Color(0xFFCBD5E1),
      const Color(0xFF475569),
      highlightColor: Colors.white,
    );

    // Coiled spring rings along shaft!
    for (final cPt in [mid1, mid2]) {
      final coilRect = Rect.fromCenter(
        center: cPt.p,
        width: 8.5 * cPt.scale,
        height: 3.4 * cPt.scale,
      );
      canvas.drawOval(
        coilRect,
        Paint()
          ..color = _inkColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.8 * cPt.scale,
      );
      canvas.drawOval(
        coilRect,
        Paint()
          ..color = const Color(0xFFE2E8F0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6 * cPt.scale,
      );
    }

    // Glowing 3D Candy Orb Beacon
    final beaconColor = isTalking || isDancing
        ? (math.sin(idle * 12 * math.pi) > 0
            ? paintStyle.neonColor
            : AppColors.emerald)
        : (mood == RobotMood.thinking ? AppColors.amber : AppColors.emerald);

    canvas.drawCircle(
      tip.p,
      10.5 * tip.scale,
      Paint()..color = beaconColor.withValues(alpha: 0.30),
    );
    _drawGlossySphere(
      canvas,
      tip.p,
      6.4 * tip.scale,
      Color.lerp(beaconColor, Colors.white, 0.72)!,
      beaconColor,
      Color.lerp(beaconColor, _inkColor, 0.45)!,
      drawOutline: true,
    );
  }

  void _draw3DCrownBack(
    Canvas canvas,
    _ProjPt Function(_Vec3) project,
    double yaw,
    double pitch,
  ) {
    // Back peaks peeking cleanly behind helmet crest
    final p1 = project(const _Vec3(-20, -118, -10));
    final p2 = project(const _Vec3(-12, -135, -12));
    final p3 = project(const _Vec3(0, -124, -14));
    final p4 = project(const _Vec3(12, -135, -12));
    final p5 = project(const _Vec3(20, -118, -10));
    final backCrown = Path()
      ..moveTo(p1.p.dx, p1.p.dy)
      ..lineTo(p2.p.dx, p2.p.dy)
      ..lineTo(p3.p.dx, p3.p.dy)
      ..lineTo(p4.p.dx, p4.p.dy)
      ..lineTo(p5.p.dx, p5.p.dy)
      ..close();
    canvas.drawPath(
      backCrown,
      Paint()
        ..color = _inkColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawPath(backCrown, Paint()..color = const Color(0xFFB45309));
  }

  void _draw3DHatFront(
    Canvas canvas,
    _ProjPt Function(_Vec3) project,
    double yaw,
    double pitch,
    double roll,
  ) {
    switch (hat) {
      case RobotHat.none:
        return;

      case RobotHat.cap:
        // Plump 3D Red Maker Cap + Curved Extruded Brim + Gold Lightning Emblem
        final cL = project(const _Vec3(-29, -115, 4));
        final cR = project(const _Vec3(29, -115, 4));
        final cTop = project(const _Vec3(0, -142, 4));
        final domePath = Path()
          ..moveTo(cL.p.dx, cL.p.dy)
          ..quadraticBezierTo(cTop.p.dx - 22 * cTop.scale, cTop.p.dy + 4 * cTop.scale, cTop.p.dx, cTop.p.dy)
          ..quadraticBezierTo(cTop.p.dx + 22 * cTop.scale, cTop.p.dy + 4 * cTop.scale, cR.p.dx, cR.p.dy)
          ..quadraticBezierTo(
            project(const _Vec3(0, -113, 18)).p.dx,
            project(const _Vec3(0, -113, 18)).p.dy,
            cL.p.dx,
            cL.p.dy,
          )
          ..close();

        canvas.drawPath(
          domePath,
          Paint()
            ..color = _inkColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.4
            ..strokeJoin = StrokeJoin.round,
        );
        canvas.drawPath(
          domePath,
          Paint()
            ..shader = RadialGradient(
              center: const Alignment(-0.35, -0.4),
              colors: const [Color(0xFFFCA5A5), Color(0xFFEF4444), Color(0xFF991B1B)],
              stops: const [0.0, 0.55, 1.0],
            ).createShader(domePath.getBounds()),
        );

        // Top button sphere
        _drawGlossySphere(
          canvas,
          cTop.p,
          3.4 * cTop.scale,
          Colors.white,
          const Color(0xFFFDE047),
          const Color(0xFFB45309),
        );

        // 3D Projecting Visor Brim curved toward +Z / right
        final bL = project(const _Vec3(-20, -116, 17));
        final bTip = project(const _Vec3(12, -115, 36));
        final bR = project(const _Vec3(27, -115, 16));
        final brimPath = Path()
          ..moveTo(bL.p.dx, bL.p.dy)
          ..quadraticBezierTo(bTip.p.dx - 16 * bTip.scale, bTip.p.dy + 3 * bTip.scale, bTip.p.dx, bTip.p.dy)
          ..quadraticBezierTo(bR.p.dx + 2 * bR.scale, bTip.p.dy, bR.p.dx, bR.p.dy)
          ..quadraticBezierTo(
            project(const _Vec3(4, -119, 20)).p.dx,
            project(const _Vec3(4, -119, 20)).p.dy,
            bL.p.dx,
            bL.p.dy,
          )
          ..close();
        canvas.drawPath(
          brimPath,
          Paint()
            ..color = _inkColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.0
            ..strokeJoin = StrokeJoin.round,
        );
        canvas.drawPath(
          brimPath,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [Color(0xFFF87171), Color(0xFFB91C1C)],
            ).createShader(brimPath.getBounds()),
        );

        // Front Circular Emblem
        final badge = project(const _Vec3(0, -128, 17));
        _drawGlossySphere(
          canvas,
          badge.p,
          5.2 * badge.scale,
          Colors.white,
          const Color(0xFFFACC15),
          const Color(0xFFB45309),
        );
        return;

      case RobotHat.crown:
        // Chubby 3D Gold Royal Crown wrapping Helmet Front + Jeweled Facets!
        final cL = project(const _Vec3(-23, -117, 13));
        final p1 = project(const _Vec3(-26, -137, 11));
        final v1 = project(const _Vec3(-11, -124, 16));
        final pC = project(const _Vec3(0, -142, 16));
        final v2 = project(const _Vec3(11, -124, 16));
        final p2 = project(const _Vec3(26, -137, 11));
        final cR = project(const _Vec3(23, -117, 13));
        final cMid = project(const _Vec3(0, -114, 18));

        final crownPath = Path()
          ..moveTo(cL.p.dx, cL.p.dy)
          ..lineTo(p1.p.dx, p1.p.dy)
          ..lineTo(v1.p.dx, v1.p.dy)
          ..lineTo(pC.p.dx, pC.p.dy)
          ..lineTo(v2.p.dx, v2.p.dy)
          ..lineTo(p2.p.dx, p2.p.dy)
          ..lineTo(cR.p.dx, cR.p.dy)
          ..quadraticBezierTo(cMid.p.dx, cMid.p.dy, cL.p.dx, cL.p.dy)
          ..close();

        canvas.drawPath(
          crownPath,
          Paint()
            ..color = _inkColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.4
            ..strokeJoin = StrokeJoin.round,
        );
        canvas.drawPath(
          crownPath,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Color(0xFFFEF08A),
                Color(0xFFFACC15),
                Color(0xFFD97706),
              ],
            ).createShader(crownPath.getBounds()),
        );

        // Specular center facet crease line
        canvas.drawLine(
          pC.p,
          cMid.p,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.45)
            ..strokeWidth = 1.6,
        );

        // Three jeweled orbs
        _drawGlossySphere(
          canvas,
          project(const _Vec3(0, -124, 18)).p,
          4.2 * pC.scale,
          const Color(0xFFFBCFE8),
          const Color(0xFFEC4899),
          const Color(0xFF9D174D),
        );
        _drawGlossySphere(
          canvas,
          project(const _Vec3(-13, -121, 16)).p,
          3.2 * p1.scale,
          const Color(0xFFBAE6FD),
          const Color(0xFF38BDF8),
          const Color(0xFF0369A1),
        );
        _drawGlossySphere(
          canvas,
          project(const _Vec3(13, -121, 16)).p,
          3.2 * p2.scale,
          const Color(0xFFA7F3D0),
          const Color(0xFF10B981),
          const Color(0xFF065F46),
        );
        return;

      case RobotHat.topHat:
        // Jaunty 3D Tilted Velvet Magic Top Hat with Oval Brim & Satin Gold Band!
        final brimCenter = project(const _Vec3(1, -118, 4));
        final s = brimCenter.scale;
        final hatTilt = -0.10 + roll + math.sin(yaw) * 0.05;

        canvas.save();
        canvas.translate(brimCenter.p.dx, brimCenter.p.dy);
        canvas.rotate(hatTilt);

        // Curved 3D brim oval
        final brimRect = Rect.fromCenter(
          center: Offset.zero,
          width: 62 * s,
          height: 15 * s,
        );
        canvas.drawOval(brimRect.inflate(1.6), Paint()..color = _inkColor);
        canvas.drawOval(
          brimRect,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [Color(0xFF475569), Color(0xFF0F172A)],
            ).createShader(brimRect),
        );

        // Sculpted tapered cylinder crown body (zero StrokeCap spikes!)
        const halfBaseW = 16.5;
        const halfTopW = 18.2;
        const crownH = 24.0;
        final crownPath = Path()
          ..moveTo(-halfBaseW * s, -2 * s)
          ..lineTo(-halfTopW * s, -crownH * s)
          ..lineTo(halfTopW * s, -crownH * s)
          ..lineTo(halfBaseW * s, -2 * s)
          ..quadraticBezierTo(0, 3.2 * s, -halfBaseW * s, -2 * s)
          ..close();

        canvas.drawPath(
          crownPath,
          Paint()
            ..color = _inkColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.2 * s
            ..strokeJoin = StrokeJoin.round,
        );
        canvas.drawPath(
          crownPath,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFF64748B),
                Color(0xFF1E293B),
                Color(0xFF090D16),
              ],
              stops: const [0.0, 0.55, 1.0],
            ).createShader(crownPath.getBounds()),
        );

        // Satin Gold Ribbon Band wrapping lower cylinder curve
        final bandPath = Path()
          ..moveTo(-16.8 * s, -6.5 * s)
          ..quadraticBezierTo(0, -2.5 * s, 16.8 * s, -6.5 * s)
          ..lineTo(17.1 * s, -1.8 * s)
          ..quadraticBezierTo(0, 2.5 * s, -17.1 * s, -1.8 * s)
          ..close();
        canvas.drawPath(
          bandPath,
          Paint()
            ..shader = LinearGradient(
              colors: const [
                Color(0xFFFEF08A),
                Color(0xFFF59E0B),
                Color(0xFFB45309),
              ],
            ).createShader(bandPath.getBounds()),
        );

        // Elliptical top crown lid with crisp outline & subtle gleam
        final lidRect = Rect.fromCenter(
          center: Offset(0, -crownH * s),
          width: halfTopW * 2 * s,
          height: 8.4 * s,
        );
        canvas.drawOval(lidRect.inflate(1.5 * s), Paint()..color = _inkColor);
        canvas.drawOval(
          lidRect,
          Paint()
            ..shader = LinearGradient(
              colors: const [Color(0xFF64748B), Color(0xFF1E293B)],
            ).createShader(lidRect),
        );

        canvas.restore();
        return;

      case RobotHat.visor:
        // Bold 3D Wrap-Around Cyber Shades hovering forward (+z) over the eyes!
        final nose = project(const _Vec3(0, -97.5, 29.5));
        final templeL = project(const _Vec3(-28, -98, 17));
        final templeR = project(const _Vec3(28, -98, 17));
        final outerL = project(const _Vec3(-22, -97.5, 27));
        final outerR = project(const _Vec3(22, -97.5, 27));

        // Side ear bridge bars back to helmet!
        for (final pair in [(outerL, templeL), (outerR, templeR)]) {
          canvas.drawLine(
            pair.$1.p,
            pair.$2.p,
            Paint()
              ..color = _inkColor
              ..strokeWidth = 4.5 * nose.scale
              ..strokeCap = StrokeCap.round,
          );
          canvas.drawLine(
            pair.$1.p,
            pair.$2.p,
            Paint()
              ..color = paintStyle.trimColor
              ..strokeWidth = 2.4 * nose.scale
              ..strokeCap = StrokeCap.round,
          );
        }

        // Two 3D bevelled reflective lenses
        for (final side in [-1.0, 1.0]) {
          final c = project(_Vec3(side * 11.8, -96.5, 29.2));
          final lensRect = RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: c.p,
              width: 20 * c.scale,
              height: 12.8 * c.scale,
            ),
            Radius.circular(4.2 * c.scale),
          );
          canvas.drawRRect(
            lensRect,
            Paint()
              ..shader = LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0F172A).withValues(alpha: 0.92),
                  const Color(0xFF020617).withValues(alpha: 0.96),
                ],
              ).createShader(lensRect.outerRect),
          );
          // Neon lens border
          canvas.drawRRect(
            lensRect,
            Paint()
              ..color = paintStyle.neonColor
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.0 * c.scale,
          );
          // Diagonal reflective glare stripe
          canvas.drawLine(
            Offset(c.p.dx - 5.5 * c.scale, c.p.dy - 4.0 * c.scale),
            Offset(c.p.dx - 0.5 * c.scale, c.p.dy + 4.0 * c.scale),
            Paint()
              ..color = Colors.white.withValues(alpha: 0.68)
              ..strokeWidth = 2.2 * c.scale
              ..strokeCap = StrokeCap.round,
          );
        }

        // Top bridge connecting lenses
        canvas.drawLine(
          Offset(nose.p.dx - 4.5 * nose.scale, nose.p.dy),
          Offset(nose.p.dx + 4.5 * nose.scale, nose.p.dy),
          Paint()
            ..color = paintStyle.trimColor
            ..strokeWidth = 3.0 * nose.scale
            ..strokeCap = StrokeCap.round,
        );
        return;
    }
  }

  // ------------------------------------------------------------------
  // 3D ARTICULATED CARTOON ARMS & PUFFY GLOVE HANDS
  // ------------------------------------------------------------------
  void _draw3DCartoonArm(
    Canvas canvas, {
    required _ProjPt shoulder,
    required _ProjPt elbow,
    required _ProjPt wrist,
    required bool openWave,
    required bool pointOut,
    required bool nearChin,
    required bool isLeft,
  }) {
    final limbR = 4.4 * ((shoulder.scale + wrist.scale) * 0.5);

    // Shoulder chrome joint sphere
    _drawGlossySphere(
      canvas,
      shoulder.p,
      limbR * 1.15,
      Colors.white,
      const Color(0xFF94A3B8),
      const Color(0xFF334155),
    );

    // Upper Arm Capsule
    _draw3DCapsule(
      canvas,
      shoulder.p,
      elbow.p,
      limbR * 0.92,
      paintStyle.headColor,
      paintStyle.headShadow,
      highlightColor: paintStyle.headHighlight,
    );

    // Elbow glowing joint ring
    _drawGlossySphere(
      canvas,
      elbow.p,
      limbR * 1.05,
      Colors.white,
      paintStyle.trimColor,
      Color.lerp(paintStyle.trimColor, _inkColor, 0.45)!,
    );

    // Forearm Capsule
    _draw3DCapsule(
      canvas,
      elbow.p,
      wrist.p,
      limbR,
      paintStyle.headColor,
      paintStyle.headShadow,
      highlightColor: paintStyle.headHighlight,
    );

    // Puffy 3D Cartoon Mechanic Mitten / Glove!
    final dirVec = wrist.p - elbow.p;
    final dirAngle = math.atan2(dirVec.dy, dirVec.dx);
    final ws = wrist.scale;

    // Gold/Trim Cuff Collar
    final cuffPos = wrist.p - Offset.fromDirection(dirAngle, 2.2 * ws);
    canvas.save();
    canvas.translate(cuffPos.dx, cuffPos.dy);
    canvas.rotate(dirAngle + math.pi / 2);
    final cuffRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: 12.2 * ws, height: 5.4 * ws),
      Radius.circular(2.7 * ws),
    );
    canvas.drawRRect(
      cuffRect,
      Paint()
        ..color = _inkColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0 * ws,
    );
    canvas.drawRRect(
      cuffRect,
      Paint()
        ..shader = LinearGradient(
          colors: [Colors.white, paintStyle.trimColor, Color.lerp(paintStyle.trimColor, _inkColor, 0.35)!],
        ).createShader(cuffRect.outerRect),
    );
    canvas.restore();

    // Puffy Pearly-Cream Cartoon Glove Palm + Fingers + Thumb
    final gloveCenter = wrist.p + Offset.fromDirection(dirAngle, 3.2 * ws);
    final palmR = 6.6 * ws;

    // Curled or waving fingers around palm
    final thumbSign = isLeft ? 1.0 : -1.0;
    final fingerSpread = openWave ? 0.44 : (pointOut ? 0.25 : 0.30);
    for (int f = -1; f <= 1; f++) {
      final fAngle = dirAngle + f * fingerSpread;
      final fDist = (f == 0 && pointOut) ? palmR * 1.45 : (openWave ? palmR * 1.25 : palmR * 0.96);
      final fPos = gloveCenter + Offset.fromDirection(fAngle, fDist);
      _drawGlossySphere(
        canvas,
        fPos,
        (f == 0 ? 3.2 : 2.8) * ws,
        Colors.white,
        const Color(0xFFF1F5F9),
        const Color(0xFF94A3B8),
      );
    }

    // Opposable thumb!
    final thumbPos = gloveCenter +
        Offset.fromDirection(dirAngle + thumbSign * 1.05, palmR * 1.05);
    _drawGlossySphere(
      canvas,
      thumbPos,
      3.0 * ws,
      Colors.white,
      const Color(0xFFF1F5F9),
      const Color(0xFF94A3B8),
    );

    // Main palm dome on top
    _drawGlossySphere(
      canvas,
      gloveCenter,
      palmR,
      Colors.white,
      const Color(0xFFF8FAFC),
      const Color(0xFF94A3B8),
    );
  }

  // ------------------------------------------------------------------
  // 3D SUSPENSION WHEELS & TWIN JETPACK ROCKET BOOSTERS
  // ------------------------------------------------------------------
  void _draw3DWheelAssembly(
    Canvas canvas, {
    required _ProjPt strutTop,
    required _ProjPt wInner,
    required _ProjPt wOuter,
    required double wheelRot,
    required double sideSquash,
  }) {
    final s = (wInner.scale + wOuter.scale) * 0.5;
    final wheelCenter = Offset(
      (wInner.p.dx + wOuter.p.dx) * 0.5,
      (wInner.p.dy + wOuter.p.dy) * 0.5,
    );

    // Coiled Suspension Strut connecting Pelvis to Wheel Axle!
    _draw3DCapsule(
      canvas,
      strutTop.p,
      wInner.p,
      2.6 * s,
      const Color(0xFFE2E8F0),
      const Color(0xFF64748B),
      highlightColor: Colors.white,
    );

    // Chunky 3D Extruded Rubber Tire!
    final wheelR = 11.4 * s;
    final tireShift = wOuter.p - wInner.p;

    // Back disc
    final innerTire = Rect.fromCenter(
      center: wInner.p,
      width: wheelR * 2 * sideSquash,
      height: wheelR * 2,
    );
    // Front disc
    final outerTire = Rect.fromCenter(
      center: wOuter.p,
      width: wheelR * 2 * sideSquash,
      height: wheelR * 2,
    );

    // 4-point quad tread connecting inner top/bottom to outer top/bottom
    final treadPath = Path()
      ..moveTo(wInner.p.dx, wInner.p.dy - wheelR)
      ..lineTo(wOuter.p.dx, wOuter.p.dy - wheelR)
      ..lineTo(wOuter.p.dx, wOuter.p.dy + wheelR)
      ..lineTo(wInner.p.dx, wInner.p.dy + wheelR)
      ..close();

    // Ink silhouette behind tire band
    canvas.drawOval(innerTire.inflate(1.8), Paint()..color = _inkColor);
    canvas.drawPath(
      treadPath,
      Paint()
        ..color = _inkColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.4 * s
        ..strokeJoin = StrokeJoin.round,
    );

    // Thick rubber tire tread barrel connecting inner -> outer tire ovals
    canvas.drawOval(innerTire, Paint()..color = const Color(0xFF1E293B));
    canvas.drawPath(
      treadPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            Color(0xFF475569),
            Color(0xFF1E293B),
            Color(0xFF090D16),
          ],
        ).createShader(treadPath.getBounds()),
    );

    // Outer wheel wall face
    canvas.drawOval(outerTire.inflate(1.4), Paint()..color = _inkColor);
    canvas.drawOval(
      outerTire,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.35),
          colors: const [Color(0xFF334155), Color(0xFF0F172A)],
        ).createShader(outerTire),
    );

    // Neon rim glow ring
    final rimRect = outerTire.deflate(2.8 * s);
    canvas.drawOval(
      rimRect,
      Paint()
        ..color = paintStyle.neonColor.withValues(alpha: 0.72)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6 * s,
    );

    // Metallic Hubcap + Rotating Spokes
    final hubRect = outerTire.deflate(5.0 * s);
    canvas.drawOval(
      hubRect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [Colors.white, paintStyle.trimColor, const Color(0xFF92400E)],
        ).createShader(hubRect),
    );

    final spokePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 1.5 * s
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 4; i++) {
      final a = wheelRot + i * math.pi / 2 + tireShift.dx * 0.01;
      canvas.drawLine(
        wOuter.p,
        Offset(
          wOuter.p.dx + math.cos(a) * wheelR * 0.62 * sideSquash,
          wOuter.p.dy + math.sin(a) * wheelR * 0.62,
        ),
        spokePaint,
      );
    }

    // Center axle pin
    canvas.drawCircle(wheelCenter.translate(tireShift.dx * 0.5, 0), 1.6 * s, Paint()..color = _inkColor);
  }

  void _draw3DRocketBooster(
    Canvas canvas,
    _ProjPt topP,
    _ProjPt botP,
  ) {
    final s = (topP.scale + botP.scale) * 0.5;

    // Nose cone dome cap
    _drawGlossySphere(
      canvas,
      topP.p,
      6.0 * s,
      Colors.white,
      paintStyle.trimColor,
      Color.lerp(paintStyle.trimColor, _inkColor, 0.45)!,
    );

    // Metallic rocket canister cylinder
    _draw3DCapsule(
      canvas,
      topP.p,
      botP.p,
      6.0 * s,
      const Color(0xFF64748B),
      const Color(0xFF1E293B),
      highlightColor: Colors.white,
      flatEnds: true,
    );

    // Racing stripe band around middle
    final midP = Offset.lerp(topP.p, botP.p, 0.45)!;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: midP, width: 12.2 * s, height: 4.5 * s),
        Radius.circular(2 * s),
      ),
      Paint()..color = paintStyle.trimColor,
    );

    // Flared Nozzle Cone
    final nozzlePath = Path()
      ..moveTo(botP.p.dx - 4.2 * s, botP.p.dy - 1 * s)
      ..lineTo(botP.p.dx + 4.2 * s, botP.p.dy - 1 * s)
      ..lineTo(botP.p.dx + 6.2 * s, botP.p.dy + 5.5 * s)
      ..lineTo(botP.p.dx - 6.2 * s, botP.p.dy + 5.5 * s)
      ..close();
    canvas.drawPath(
      nozzlePath,
      Paint()
        ..color = _inkColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6 * s,
    );
    canvas.drawPath(nozzlePath, Paint()..color = const Color(0xFF1E293B));

    // Volumetric Layered Rocket Plasma Flame!
    final thrustExtra = boostThrust.clamp(0.0, 1.5);
    final flameLen = (14.0 +
            math.sin(idle * 18 * math.pi).abs() * 11.0 +
            (isDancing || tapBounce > 0.02 ? 7.0 : 0.0) +
            thrustExtra * 22.0) *
        s;
    final flameBase = Offset(botP.p.dx, botP.p.dy + 5.2 * s);
    final halfW = (5.8 + thrustExtra * 2.4) * s;

    if (thrustExtra > 0.2) {
      canvas.drawCircle(
        Offset(flameBase.dx, flameBase.dy + flameLen * 0.28),
        halfW * 2.1,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFF38BDF8).withValues(alpha: 0.38 * (thrustExtra / 1.5)),
              const Color(0xFFF97316).withValues(alpha: 0.22 * (thrustExtra / 1.5)),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(flameBase.dx, flameBase.dy + flameLen * 0.28),
              radius: halfW * 2.1,
            ),
          ),
      );
    }

    final outerFlame = Path()
      ..moveTo(flameBase.dx - halfW, flameBase.dy)
      ..quadraticBezierTo(
        flameBase.dx - halfW * 0.72,
        flameBase.dy + flameLen * 0.62,
        flameBase.dx,
        flameBase.dy + flameLen,
      )
      ..quadraticBezierTo(
        flameBase.dx + halfW * 0.72,
        flameBase.dy + flameLen * 0.62,
        flameBase.dx + halfW,
        flameBase.dy,
      )
      ..close();
    canvas.drawPath(
      outerFlame,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: thrustExtra > 0.3
              ? const [Color(0xFF38BDF8), Color(0xFFF97316), Color(0x88EF4444)]
              : const [Color(0xFFF97316), Color(0xFFEF4444), Color(0x66EF4444)],
        ).createShader(outerFlame.getBounds()),
    );

    final innerFlame = Path()
      ..moveTo(flameBase.dx - 2.8 * s, flameBase.dy)
      ..lineTo(flameBase.dx, flameBase.dy + flameLen * 0.68)
      ..lineTo(flameBase.dx + 2.8 * s, flameBase.dy)
      ..close();
    canvas.drawPath(
      innerFlame,
      Paint()
        ..color = thrustExtra > 0.3
            ? const Color(0xFFE0F2FE)
            : const Color(0xFFFEF08A),
    );

    if (thrustExtra > 0.45) {
      // Mach shock-diamond thruster rings during overdrive boost
      for (int r = 1; r <= 2; r++) {
        final ringY = flameBase.dy + flameLen * (0.28 * r);
        final ringW = (11.5 - r * 2.5) * s;
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(flameBase.dx, ringY),
            width: ringW,
            height: 3.4 * s,
          ),
          Paint()
            ..color = Colors.white.withValues(alpha: 0.62 - r * 0.14)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6 * s,
        );
      }
    }
  }

  // ------------------------------------------------------------------
  // SHARED 3D CAPSULE, SPHERE & CELEBRATION HELPERS
  // ------------------------------------------------------------------
  void _draw3DCapsule(
    Canvas canvas,
    Offset a,
    Offset b,
    double radius,
    Color midColor,
    Color darkColor, {
    required Color highlightColor,
    bool flatEnds = false,
  }) {
    final delta = b - a;
    final len = delta.distance;
    if (len < 0.01) {
      _drawGlossySphere(canvas, a, radius, highlightColor, midColor, darkColor);
      return;
    }

    final ux = delta.dx / len;
    final uy = delta.dy / len;
    // Perpendicular vector
    final px = -uy;
    final py = ux;

    // 1. Cartoon ink silhouette
    canvas.drawLine(
      a,
      b,
      Paint()
        ..color = _inkColor
        ..strokeWidth = radius * 2 + 3.4
        ..strokeCap = flatEnds ? StrokeCap.butt : StrokeCap.round,
    );

    // 2. Cylindrical cross-gradient across limb thickness!
    final rect = Rect.fromPoints(
      Offset(a.dx - radius, a.dy - radius),
      Offset(b.dx + radius, b.dy + radius),
    ).inflate(radius);

    canvas.drawLine(
      a,
      b,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment(-0.7, -0.7),
          end: Alignment(0.7, 0.7),
          colors: [highlightColor, midColor, darkColor],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(rect)
        ..strokeWidth = radius * 2
        ..strokeCap = flatEnds ? StrokeCap.butt : StrokeCap.round,
    );

    // 3. Crisp white glossy shine streak along top-left edge
    final shineOffset = Offset(px * radius * 0.38, py * radius * 0.38);
    // Ensure shine lies on top/left side visually
    final correctedShine = (shineOffset.dx + shineOffset.dy) > 0
        ? -shineOffset
        : shineOffset;
    canvas.drawLine(
      a + correctedShine + Offset(ux * radius * 0.25, uy * radius * 0.25),
      b + correctedShine - Offset(ux * radius * 0.25, uy * radius * 0.25),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.48)
        ..strokeWidth = (radius * 0.38).clamp(1.0, 3.0)
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawGlossySphere(
    Canvas canvas,
    Offset center,
    double radius,
    Color light,
    Color mid,
    Color dark, {
    bool drawOutline = true,
  }) {
    if (drawOutline) {
      canvas.drawCircle(center, radius + 1.5, Paint()..color = _inkColor);
    }
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.36, -0.40),
          radius: 1.05,
          colors: [light, mid, dark],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(rect),
    );
    // Crisp white specular jellybean glint
    canvas.drawCircle(
      Offset(center.dx - radius * 0.32, center.dy - radius * 0.34),
      (radius * 0.24).clamp(0.8, 3.2),
      Paint()..color = Colors.white.withValues(alpha: 0.78),
    );
  }

  void _drawConfettiAndSparkles(Canvas canvas) {
    if (confettiProgress > 0.01 && confettiProgress < 0.99) {
      const palette = [
        Color(0xFFF59E0B),
        Color(0xFFEC4899),
        Color(0xFF38BDF8),
        Color(0xFF34D399),
        Color(0xFFA855F7),
      ];
      final fade = (1.0 - confettiProgress).clamp(0.0, 1.0);
      for (int i = 0; i < 16; i++) {
        final angle = -math.pi * 0.95 + (i / 15.0) * math.pi * 0.9;
        final radius = 38 + confettiProgress * (48 + (i % 3) * 14);
        final drop = confettiProgress * confettiProgress * 28;
        final px = math.cos(angle) * radius;
        final py = -74 + math.sin(angle) * radius + drop;
        canvas.save();
        canvas.translate(px, py);
        canvas.rotate(confettiProgress * 6.5 + i);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-3.5, -2, 7, 4),
            const Radius.circular(1.5),
          ),
          Paint()..color = palette[i % palette.length].withValues(alpha: fade),
        );
        canvas.restore();
      }
    }

    if (overchargeProgress > 0.02) {
      final pulseAlpha = (math.sin(overchargeProgress * math.pi)).clamp(0.25, 1.0);
      final sparkPaint = Paint()
        ..color = const Color(0xFFFDE047).withValues(alpha: pulseAlpha * 0.92)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round;
      for (int i = 0; i < 4; i++) {
        final a0 = idle * 6 * math.pi + i * (math.pi * 0.5);
        final r = 46.0 + math.sin(idle * 12 * math.pi + i) * 5.0;
        final p1 = Offset(math.cos(a0) * r, -64 + math.sin(a0) * r * 1.15);
        final pMid = Offset(
          math.cos(a0 + 0.22) * (r + 10),
          -64 + math.sin(a0 + 0.22) * (r + 10) * 1.15,
        );
        final p2 = Offset(
          math.cos(a0 + 0.44) * r,
          -64 + math.sin(a0 + 0.44) * r * 1.15,
        );
        final bolt = Path()
          ..moveTo(p1.dx, p1.dy)
          ..lineTo(pMid.dx, pMid.dy)
          ..lineTo(p2.dx, p2.dy);
        canvas.drawPath(bolt, sparkPaint);
      }
    }

    if (tapBounce > 0.02 || mood == RobotMood.excited || isDancing || isRainbowMode) {
      final burstPhase = tapBounce > 0.02 ? tapBounce : idle;
      for (int i = 0; i < 6; i++) {
        final ang = -math.pi * 0.88 + (i * math.pi * 0.35);
        final dist = 56 + math.sin(burstPhase * math.pi) * 16;
        final sx = math.cos(ang) * dist;
        final sy = -84 + math.sin(ang) * dist * 0.68;
        final alpha = tapBounce > 0.02
            ? (1.0 - tapBounce).clamp(0.0, 1.0)
            : (0.45 + 0.4 * math.sin(idle * 2 * math.pi + i));
        final c = (i.isEven ? paintStyle.trimColor : paintStyle.neonColor)
            .withValues(alpha: alpha);
        // 4-point cartoon twinkle star!
        const r = 4.6;
        final star = Path()
          ..moveTo(sx, sy - r)
          ..quadraticBezierTo(sx, sy, sx + r, sy)
          ..quadraticBezierTo(sx, sy, sx, sy + r)
          ..quadraticBezierTo(sx, sy, sx - r, sy)
          ..quadraticBezierTo(sx, sy, sx, sy - r)
          ..close();
        canvas.drawPath(star, Paint()..color = c);
      }
    }
  }

  @override
  bool shouldRepaint(covariant TalkingRobot3DCartoonPainter oldDelegate) {
    return oldDelegate.idle != idle ||
        oldDelegate.entrance != entrance ||
        oldDelegate.rawEntrance != rawEntrance ||
        oldDelegate.tapBounce != tapBounce ||
        oldDelegate.confettiProgress != confettiProgress ||
        oldDelegate.mood != mood ||
        oldDelegate.isTalking != isTalking ||
        oldDelegate.paintStyle != paintStyle ||
        oldDelegate.hat != hat ||
        oldDelegate.hasBoosters != hasBoosters ||
        oldDelegate.isDancing != isDancing ||
        oldDelegate.userYaw != userYaw ||
        oldDelegate.userPitch != userPitch ||
        oldDelegate.showGroundShadow != showGroundShadow ||
        oldDelegate.boostThrust != boostThrust ||
        oldDelegate.isRainbowMode != isRainbowMode ||
        oldDelegate.overchargeProgress != overchargeProgress ||
        oldDelegate.flipProgress != flipProgress ||
        oldDelegate.spinProgress != spinProgress ||
        oldDelegate.winkProgress != winkProgress;
  }
}
