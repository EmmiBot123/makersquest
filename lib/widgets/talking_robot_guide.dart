// Talking Robot Host "Bolts" & Interactive Minimal Example Playgrounds
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/sound_effects.dart';
import '../theme/app_theme.dart';

enum RobotMood {
  greeting,
  explaining,
  thinking,
  excited,
}

bool get _isRunningTests =>
    WidgetsBinding.instance.runtimeType.toString().contains('Test');

/// Expressive animated robot companion ("Bolts") that rolls onto the stage,
/// blinks, gestures toward interactive examples, and animates a voice equalizer
/// mouth while speaking.
class TalkingRobotCharacter extends StatefulWidget {
  final RobotMood mood;
  final bool isTalking;
  final int entranceKey;
  final double height;
  final VoidCallback? onTap;

  const TalkingRobotCharacter({
    super.key,
    required this.mood,
    required this.isTalking,
    this.entranceKey = 0,
    this.height = 176,
    this.onTap,
  });

  @override
  State<TalkingRobotCharacter> createState() => _TalkingRobotCharacterState();
}

class _TalkingRobotCharacterState extends State<TalkingRobotCharacter>
    with TickerProviderStateMixin {
  late AnimationController _idleController;
  late AnimationController _entranceController;
  late AnimationController _tapController;

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    if (_isRunningTests) {
      _idleController.value = 0.25;
    } else {
      _idleController.repeat();
    }

    _entranceController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _isRunningTests ? 50 : 900),
    );
    _entranceController.forward();

    _tapController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _isRunningTests ? 50 : 650),
    );
  }

  @override
  void didUpdateWidget(covariant TalkingRobotCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entranceKey != widget.entranceKey) {
      _entranceController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _idleController.dispose();
    _entranceController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  void _handleTap() {
    SoundEffects.playPop();
    _tapController.forward(from: 0.0);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: Tooltip(
        message: 'Tap Bolts to say hi!',
        child: SizedBox(
          height: widget.height,
          width: widget.height * 1.05,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _idleController,
              _entranceController,
              _tapController,
            ]),
            builder: (context, _) {
              return CustomPaint(
                painter: _TalkingRobotPainter(
                  idle: _idleController.value,
                  entrance: Curves.easeOutBack.transform(
                    _entranceController.value.clamp(0.0, 1.0),
                  ),
                  rawEntrance: _entranceController.value,
                  tapBounce: _tapController.value,
                  mood: widget.mood,
                  isTalking: widget.isTalking,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TalkingRobotPainter extends CustomPainter {
  final double idle;
  final double entrance;
  final double rawEntrance;
  final double tapBounce;
  final RobotMood mood;
  final bool isTalking;

  _TalkingRobotPainter({
    required this.idle,
    required this.entrance,
    required this.rawEntrance,
    required this.tapBounce,
    required this.mood,
    required this.isTalking,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final scale = (h / 176.0).clamp(0.55, 1.35);

    canvas.save();
    // Roll in cleanly from left edge on entry
    final slideX = (1.0 - entrance) * (-w * 0.42);
    final groundY = h - 14 * scale;

    // Ground glow pad & rolling shadow
    final shadowWidth = 84 * scale;
    final shadowCenterX = (w * 0.5) + slideX * 0.85;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(shadowCenterX, groundY),
        width: shadowWidth,
        height: 14 * scale,
      ),
      Paint()..color = AppColors.primary.withValues(alpha: 0.14),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(shadowCenterX, groundY),
        width: shadowWidth * 0.65,
        height: 7 * scale,
      ),
      Paint()..color = const Color(0xFF0F172A).withValues(alpha: 0.16),
    );

    final jumpOffset = math.sin(tapBounce * math.pi) * 18 * scale;
    final bobOffset = math.sin(idle * 2 * math.pi) * 2.5 * scale;
    final cx = (w * 0.5) + slideX;
    final baseY = groundY - 6 * scale - jumpOffset + bobOffset;

    canvas.translate(cx, baseY);
    canvas.scale(scale);

    // Subtle celebratory sparkles on tap or excited state
    if (tapBounce > 0.02 || mood == RobotMood.excited) {
      final burstPhase = tapBounce > 0.02 ? tapBounce : idle;
      for (int i = 0; i < 5; i++) {
        final ang = -math.pi * 0.85 + (i * math.pi * 0.42);
        final dist = 58 + math.sin(burstPhase * math.pi) * 18;
        final sx = math.cos(ang) * dist;
        final sy = -76 + math.sin(ang) * dist * 0.7;
        final alpha = tapBounce > 0.02
            ? (1.0 - tapBounce).clamp(0.0, 1.0)
            : (0.4 + 0.4 * math.sin(idle * 2 * math.pi + i));
        canvas.drawCircle(
          Offset(sx, sy),
          3.4,
          Paint()
            ..color = (i.isEven ? AppColors.amber : const Color(0xFF38BDF8))
                .withValues(alpha: alpha),
        );
      }
    }

    // Drive Wheels / Treads at base
    final wheelRot = (1.0 - rawEntrance) * 6 * math.pi + tapBounce * 4 * math.pi;
    _drawWheel(canvas, const Offset(-20, -4), 10, wheelRot);
    _drawWheel(canvas, const Offset(20, -4), 10, wheelRot);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-22, -13, 44, 8),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF1E293B),
    );

    // Torso
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-27, -58, 54, 46),
        const Radius.circular(12),
      ),
      Paint()..color = const Color(0xFF334155),
    );
    // Crisp slate highlight border
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-27, -58, 54, 46),
        const Radius.circular(12),
      ),
      Paint()
        ..color = const Color(0xFF64748B).withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    // Chest badge + spinning gear
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-18, -50, 36, 30),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFF0F172A),
    );
    final gearAngle = idle * 2 * math.pi * (isTalking ? 2.0 : 1.0);
    _drawGear(canvas, const Offset(-5, -35), 9.5, gearAngle, AppColors.amber);
    // Heartbeat LED pill
    final ledPulse = 0.5 + 0.5 * math.sin(idle * 6 * math.pi);
    canvas.drawCircle(
      const Offset(10, -35),
      3.5,
      Paint()
        ..color = mood == RobotMood.excited
            ? AppColors.emerald
            : AppColors.cyan.withValues(alpha: 0.55 + 0.45 * ledPulse),
    );

    // Arms (dynamic gestures based on mood!)
    final armPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    // Left arm (waves during greeting, cheers in excited)
    double leftEndX = -38;
    double leftEndY = -28;
    if (mood == RobotMood.greeting) {
      final wave = math.sin(idle * 6 * math.pi) * 0.45;
      leftEndX = -40 + math.sin(wave) * 10;
      leftEndY = -66 + math.cos(wave) * 6;
    } else if (mood == RobotMood.excited) {
      leftEndX = -42;
      leftEndY = -68 - math.sin(idle * 4 * math.pi) * 5;
    } else {
      leftEndY = -28 + math.sin(idle * 2 * math.pi) * 4;
    }
    canvas.drawLine(const Offset(-27, -46), Offset(leftEndX, leftEndY), armPaint);
    canvas.drawCircle(
      Offset(leftEndX, leftEndY),
      5.2,
      Paint()..color = AppColors.amber,
    );

    // Right arm (points right toward interactive demo when explaining/thinking!)
    double rightEndX = 40;
    double rightEndY = -30;
    if (mood == RobotMood.explaining) {
      rightEndX = 48 + math.sin(idle * 4 * math.pi) * 4;
      rightEndY = -44;
    } else if (mood == RobotMood.excited) {
      rightEndX = 42;
      rightEndY = -68 - math.cos(idle * 4 * math.pi) * 5;
    } else if (mood == RobotMood.thinking) {
      rightEndX = 34;
      rightEndY = -68; // chin/head scratch pose!
    } else {
      rightEndY = -30 - math.sin(idle * 2 * math.pi) * 4;
    }
    canvas.drawLine(const Offset(27, -46), Offset(rightEndX, rightEndY), armPaint);
    canvas.drawCircle(
      Offset(rightEndX, rightEndY),
      5.2,
      Paint()
        ..color = mood == RobotMood.explaining
            ? const Color(0xFF38BDF8)
            : AppColors.amber,
    );

    // Neck
    canvas.drawRect(
      const Rect.fromLTWH(-7, -65, 14, 7),
      Paint()..color = const Color(0xFF94A3B8),
    );

    // Antenna
    canvas.drawLine(
      const Offset(0, -109),
      const Offset(0, -126),
      Paint()
        ..color = const Color(0xFF64748B)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    final beaconColor = isTalking
        ? (math.sin(idle * 12 * math.pi) > 0
            ? const Color(0xFF38BDF8)
            : AppColors.emerald)
        : (mood == RobotMood.thinking ? AppColors.amber : AppColors.emerald);
    canvas.drawCircle(
      const Offset(0, -130),
      6.5,
      Paint()..color = beaconColor.withValues(alpha: 0.28),
    );
    canvas.drawCircle(
      const Offset(0, -130),
      4.5,
      Paint()..color = beaconColor,
    );

    // Earpods / bolts on side of head
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-36, -95, 6, 18),
        const Radius.circular(3),
      ),
      Paint()..color = AppColors.amber,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(30, -95, 6, 18),
        const Radius.circular(3),
      ),
      Paint()..color = AppColors.amber,
    );

    // Head outer chassis
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-31, -110, 62, 46),
        const Radius.circular(14),
      ),
      Paint()..color = const Color(0xFF475569),
    );

    // Visor screen
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-24, -103, 48, 32),
        const Radius.circular(9),
      ),
      Paint()..color = const Color(0xFF0F172A),
    );

    // Expressive eyes
    final isBlinking = idle > 0.93 && !isTalking;
    final eyePaint = Paint()
      ..color = mood == RobotMood.excited
          ? const Color(0xFF34D399)
          : const Color(0xFF38BDF8)
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..style = mood == RobotMood.excited || isBlinking
          ? PaintingStyle.stroke
          : PaintingStyle.fill;

    if (isBlinking) {
      canvas.drawLine(const Offset(-15, -91), const Offset(-7, -91), eyePaint);
      canvas.drawLine(const Offset(7, -91), const Offset(15, -91), eyePaint);
    } else if (mood == RobotMood.excited) {
      // Happy `^ ^` eyes
      final leftArc = Path()
        ..moveTo(-16, -89)
        ..quadraticBezierTo(-11, -97, -6, -89);
      final rightArc = Path()
        ..moveTo(6, -89)
        ..quadraticBezierTo(11, -97, 16, -89);
      canvas.drawPath(leftArc, eyePaint);
      canvas.drawPath(rightArc, eyePaint);
    } else {
      final lookShift = mood == RobotMood.explaining ? 1.8 : 0.0;
      canvas.drawCircle(Offset(-11 + lookShift, -91), 4.2, eyePaint);
      canvas.drawCircle(Offset(11 + lookShift, -91), 4.2, eyePaint);
      // Tiny white catchlight in eyes
      canvas.drawCircle(
        Offset(-12 + lookShift, -92.5),
        1.4,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        Offset(10 + lookShift, -92.5),
        1.4,
        Paint()..color = Colors.white,
      );
    }

    // Animated Talking Equalizer Mouth OR Calm Smile
    if (isTalking) {
      final barPaint = Paint()
        ..color = const Color(0xFF38BDF8)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2.6;
      for (int b = 0; b < 5; b++) {
        final bx = -10.0 + b * 5.0;
        final amp = (0.35 + 0.65 * math.sin(idle * 14 * math.pi + b * 1.3).abs());
        final halfH = 1.5 + amp * 4.2;
        canvas.drawLine(Offset(bx, -78 - halfH), Offset(bx, -78 + halfH), barPaint);
      }
    } else {
      final smile = Path()
        ..moveTo(-9, -79)
        ..quadraticBezierTo(0, -73, 9, -79);
      canvas.drawPath(
        smile,
        Paint()
          ..color = const Color(0xFF38BDF8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round,
      );
    }

    canvas.restore();
  }

  void _drawWheel(Canvas canvas, Offset center, double radius, double rot) {
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFF0F172A));
    canvas.drawCircle(
      center,
      radius * 0.45,
      Paint()..color = AppColors.amber,
    );
    final spoke = Paint()
      ..color = Colors.white70
      ..strokeWidth = 1.4;
    for (int i = 0; i < 4; i++) {
      final a = rot + i * math.pi / 2;
      canvas.drawLine(
        center,
        Offset(
          center.dx + math.cos(a) * radius * 0.85,
          center.dy + math.sin(a) * radius * 0.85,
        ),
        spoke,
      );
    }
  }

  void _drawGear(
    Canvas canvas,
    Offset center,
    double radius,
    double angle,
    Color color,
  ) {
    final p = Paint()..color = color;
    canvas.drawCircle(center, radius * 0.72, p);
    canvas.drawCircle(
      center,
      radius * 0.3,
      Paint()..color = const Color(0xFF0F172A),
    );
    for (int i = 0; i < 8; i++) {
      final a = angle + i * math.pi / 4;
      canvas.drawCircle(
        Offset(center.dx + math.cos(a) * radius, center.dy + math.sin(a) * radius),
        2.1,
        p,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TalkingRobotPainter oldDelegate) {
    return oldDelegate.idle != idle ||
        oldDelegate.entrance != entrance ||
        oldDelegate.tapBounce != tapBounce ||
        oldDelegate.mood != mood ||
        oldDelegate.isTalking != isTalking;
  }
}

/// Conversational typewriter speech bubble synced with Bolts' talking indicator.
class RobotSpeechBubble extends StatefulWidget {
  final String message;
  final String speakerTag;
  final Color accentColor;
  final ValueChanged<bool>? onTalkingChanged;

  const RobotSpeechBubble({
    super.key,
    required this.message,
    this.speakerTag = 'BOLTS',
    this.accentColor = AppColors.primary,
    this.onTalkingChanged,
  });

  @override
  State<RobotSpeechBubble> createState() => _RobotSpeechBubbleState();
}

class _RobotSpeechBubbleState extends State<RobotSpeechBubble> {
  Timer? _typingTimer;
  int _visibleChars = 0;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  @override
  void didUpdateWidget(covariant RobotSpeechBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message != widget.message) {
      _startTyping();
    }
  }

  void _startTyping() {
    _typingTimer?.cancel();
    if (_isRunningTests) {
      _visibleChars = widget.message.length;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onTalkingChanged?.call(false);
      });
      return;
    }

    _visibleChars = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onTalkingChanged?.call(true);
    });

    _typingTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_visibleChars >= widget.message.length) {
        timer.cancel();
        widget.onTalkingChanged?.call(false);
      } else {
        setState(() {
          _visibleChars = math.min(widget.message.length, _visibleChars + 2);
        });
      }
    });
  }

  void _skipTyping() {
    _typingTimer?.cancel();
    if (_visibleChars < widget.message.length) {
      setState(() => _visibleChars = widget.message.length);
      widget.onTalkingChanged?.call(false);
    }
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayed = widget.message.substring(
      0,
      _visibleChars.clamp(0, widget.message.length),
    );
    final isTyping = _visibleChars < widget.message.length;

    return GestureDetector(
      onTap: _skipTyping,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: widget.accentColor.withValues(alpha: 0.35),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.accentColor.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: widget.accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🤖', style: TextStyle(fontSize: 11)),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          widget.speakerTag,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: widget.accentColor,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isTyping)
                  Text(
                    'talking...',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: widget.accentColor.withValues(alpha: 0.75),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              displayed.isEmpty ? ' ' : displayed,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textMain,
                height: 1.42,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stage 1 Interactive Workbench: Tap everyday scraps (Box, Straws, Rubber Band)
/// to snap together a working cardboard machine right in front of Bolts.
class ScrapToRobotWorkbench extends StatefulWidget {
  final void Function(String message, {bool complete}) onReaction;

  const ScrapToRobotWorkbench({
    super.key,
    required this.onReaction,
  });

  @override
  State<ScrapToRobotWorkbench> createState() => _ScrapToRobotWorkbenchState();
}

class _ScrapToRobotWorkbenchState extends State<ScrapToRobotWorkbench>
    with SingleTickerProviderStateMixin {
  final Set<String> _addedScraps = {};
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    if (_isRunningTests) {
      _pulseController.value = 0.4;
    } else {
      _pulseController.repeat();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleScrap(String id) {
    SoundEffects.playPop();
    setState(() {
      if (_addedScraps.contains(id)) {
        _addedScraps.remove(id);
      } else {
        _addedScraps.add(id);
      }
    });

    if (_addedScraps.length == 3) {
      SoundEffects.playFanfare();
      widget.onReaction(
        'Boom! You just built a rolling kinetic bot out of zero-cost scraps! Ready to play with 4 live machines?',
        complete: true,
      );
    } else if (_addedScraps.contains('box') && _addedScraps.length == 1) {
      widget.onReaction(
        'Nice! A plain delivery box gives us the super-strong chassis. Tap Straws & Rubber Band next!',
      );
    } else if (_addedScraps.contains('straws') && _addedScraps.length == 1) {
      widget.onReaction(
        'Smart choice! Drinking straws make low-friction spinning axle sleeves. Add the Box & Rubber Band!',
      );
    } else if (_addedScraps.contains('band') && _addedScraps.length == 1) {
      widget.onReaction(
        'Ooh! A rubber band acts as our coiled spring motor. Snap on the Box & Straws too!',
      );
    } else {
      widget.onReaction(
        'Almost there! Tap the last scrap piece to power up your cardboard robot!',
      );
    }
  }

  void _assembleAll() {
    SoundEffects.playFanfare();
    setState(() {
      _addedScraps
        ..clear()
        ..addAll({'box', 'straws', 'band'});
    });
    widget.onReaction(
      'All 3 scraps locked in! Just like that, cardboard + straws + rubber band becomes a real moving robot!',
      complete: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final allReady = _addedScraps.length == 3;
    final hasBox = _addedScraps.contains('box');
    final hasStraws = _addedScraps.contains('straws');
    final hasBand = _addedScraps.contains('band');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: allReady ? AppColors.emerald : const Color(0xFF334155),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Text(
                allReady
                    ? '✅ RUNNING FROM SCRAPS (₹0 HARDWARE)'
                    : 'TAP SCRAPS TO ASSEMBLE (${_addedScraps.length}/3)',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.9,
                  color: allReady ? const Color(0xFF6EE7B7) : const Color(0xFF93C5FD),
                ),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFDE047),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.auto_fix_high_rounded, size: 14),
                label: Text(
                  allReady ? 'Re-run Spark' : 'Quick Assemble ✨',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                ),
                onPressed: _assembleAll,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 155,
            decoration: BoxDecoration(
              color: const Color(0xFF020617),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _ScrapAssemblyPainter(
                      progress: _pulseController.value,
                      hasBox: hasBox,
                      hasStraws: hasStraws,
                      hasBand: hasBand,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _scrapChip(
                id: 'box',
                icon: '📦',
                label: 'Delivery Box',
                active: hasBox,
              ),
              _scrapChip(
                id: 'straws',
                icon: '🥤',
                label: 'Straws',
                active: hasStraws,
              ),
              _scrapChip(
                id: 'band',
                icon: '🪢',
                label: 'Rubber Band',
                active: hasBand,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _scrapChip({
    required String id,
    required String icon,
    required String label,
    required bool active,
  }) {
    return InkWell(
      onTap: () => _toggleScrap(id),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: active
              ? AppColors.emerald.withValues(alpha: 0.22)
              : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? AppColors.emerald : const Color(0xFF475569),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: active ? const Color(0xFF6EE7B7) : Colors.white,
              ),
            ),
            if (active) ...[
              const SizedBox(width: 5),
              const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF34D399)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScrapAssemblyPainter extends CustomPainter {
  final double progress;
  final bool hasBox;
  final bool hasStraws;
  final bool hasBand;

  _ScrapAssemblyPainter({
    required this.progress,
    required this.hasBox,
    required this.hasStraws,
    required this.hasBand,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final benchY = h * 0.78;

    // Blueprint grid
    final grid = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.1)
      ..strokeWidth = 1;
    for (double x = 0; x < w; x += 22) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), grid);
    }
    for (double y = 0; y < h; y += 22) {
      canvas.drawLine(Offset(0, y), Offset(w, y), grid);
    }

    // Workbench line
    canvas.drawLine(
      Offset(20, benchY),
      Offset(w - 20, benchY),
      Paint()
        ..color = const Color(0xFF475569)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    final allReady = hasBox && hasStraws && hasBand;
    final driveOffset = allReady ? math.sin(progress * 2 * math.pi) * 26 : 0.0;
    final botX = cx + driveOffset;
    final bounce = allReady ? math.sin(progress * 8 * math.pi).abs() * 2.0 : 0.0;

    // Ghost target outline if incomplete
    if (!hasBox) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(botX, benchY - 38), width: 92, height: 42),
          const Radius.circular(8),
        ),
        Paint()
          ..color = const Color(0xFF38BDF8).withValues(alpha: 0.28)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
    } else {
      // Cardboard body
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(botX, benchY - 38 - bounce),
            width: 92,
            height: 42,
          ),
          const Radius.circular(8),
        ),
        Paint()..color = const Color(0xFFD97706),
      );
      // Corrugation flute stripe
      canvas.drawLine(
        Offset(botX - 42, benchY - 38 - bounce),
        Offset(botX + 42, benchY - 38 - bounce),
        Paint()
          ..color = const Color(0xFFFDE68A).withValues(alpha: 0.5)
          ..strokeWidth = 2,
      );
      // Friendly painted eyes on cardboard
      canvas.drawCircle(
        Offset(botX + 24, benchY - 42 - bounce),
        4,
        Paint()..color = const Color(0xFF0F172A),
      );
    }

    // Straws & wheels
    if (hasStraws) {
      final wheelRot = allReady ? progress * 6 * math.pi : 0.4;
      canvas.drawLine(
        Offset(botX - 28, benchY - 14),
        Offset(botX + 28, benchY - 14),
        Paint()
          ..color = const Color(0xFF38BDF8)
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
      for (final wx in [botX - 28, botX + 28]) {
        canvas.drawCircle(
          Offset(wx, benchY - 14),
          13,
          Paint()..color = const Color(0xFF1E293B),
        );
        canvas.drawCircle(
          Offset(wx, benchY - 14),
          5,
          Paint()..color = const Color(0xFFFDE68A),
        );
        for (int s = 0; s < 3; s++) {
          final a = wheelRot + s * (2 * math.pi / 3);
          canvas.drawLine(
            Offset(wx, benchY - 14),
            Offset(wx + math.cos(a) * 11, benchY - 14 + math.sin(a) * 11),
            Paint()
              ..color = Colors.white70
              ..strokeWidth = 1.6,
          );
        }
      }
    }

    // Rubber band motor + power spark!
    if (hasBand) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(botX - 28, benchY - 26 - bounce, 56, 7),
          const Radius.circular(3.5),
        ),
        Paint()..color = const Color(0xFFFACC15),
      );
      if (allReady) {
        canvas.drawCircle(
          Offset(botX - 54, benchY - 24),
          4,
          Paint()..color = const Color(0xFF34D399).withValues(alpha: 0.7),
        );
        canvas.drawCircle(
          Offset(botX - 64, benchY - 30),
          2.5,
          Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.6),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ScrapAssemblyPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.hasBox != hasBox ||
        oldDelegate.hasStraws != hasStraws ||
        oldDelegate.hasBand != hasBand;
  }
}

/// Stage 2 Interactive Examples: 4 playable physics cardboard demos with live
/// sliders & action buttons so kids experience every mechanism first-hand.
class InteractiveMachinePlayground extends StatefulWidget {
  final int activeIndex;
  final ValueChanged<int> onSelectMachine;
  final ValueChanged<String> onBoltsComment;

  const InteractiveMachinePlayground({
    super.key,
    required this.activeIndex,
    required this.onSelectMachine,
    required this.onBoltsComment,
  });

  @override
  State<InteractiveMachinePlayground> createState() =>
      _InteractiveMachinePlaygroundState();
}

class _InteractiveMachinePlaygroundState
    extends State<InteractiveMachinePlayground> with SingleTickerProviderStateMixin {
  double _scissorLift = 0.45;
  double _racerWind = 3.0;
  double _clawGrip = 0.65;
  double _rampAngle = 26.0;

  late AnimationController _actionController;

  static const List<({String icon, String label, String badge})> _machines = [
    (icon: '✂️', label: 'Scissor Lift', badge: '4x Height'),
    (icon: '🏎️', label: 'Torque Racer', badge: '5m+ Sprint'),
    (icon: '🦾', label: 'Claw Gripper', badge: '250g Pinch'),
    (icon: '🎢', label: 'Gravity Coaster', badge: 'Banked Track'),
  ];

  @override
  void initState() {
    super.initState();
    _actionController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _isRunningTests ? 50 : 1200),
    );
  }

  @override
  void dispose() {
    _actionController.dispose();
    super.dispose();
  }

  void _triggerAction() {
    SoundEffects.playChime();
    _actionController.forward(from: 0.0);

    switch (widget.activeIndex) {
      case 0:
        final next = _scissorLift > 0.75 ? 0.25 : 0.95;
        setState(() => _scissorLift = next);
        widget.onBoltsComment(
          next > 0.75
              ? 'Full extension! 3 criss-cross cardboard stages turned 1 push into 4.0× vertical lift!'
              : 'Compressed flat! That tiny 3 cm scissor fold is ready to spring sky-high.',
        );
        break;
      case 1:
        widget.onBoltsComment(
          'Vroom! ${_racerWind.toInt()} rubber-band winds launched the racer ${(1.2 + _racerWind * 0.85).toStringAsFixed(1)} meters on straw bearings!',
        );
        break;
      case 2:
        final next = _clawGrip > 0.6 ? 0.15 : 0.92;
        setState(() => _clawGrip = next);
        widget.onBoltsComment(
          next > 0.6
              ? 'Snapped shut! Opposing cardboard levers pinched the cube without a single electronic servo!'
              : 'Released! Letting go of the trigger resets both jaws cleanly.',
        );
        break;
      case 3:
        widget.onBoltsComment(
          'Dropped at ${_rampAngle.toInt()}°! Banked cardboard guardrails convert gravity speed around every turn!',
        );
        break;
    }
  }

  String _telemetryLabel() {
    switch (widget.activeIndex) {
      case 0:
        final mult = (1.0 + _scissorLift * 3.0).toStringAsFixed(1);
        return 'Lift Height: ${mult}x';
      case 1:
        final dist = (1.2 + _racerWind * 0.85).toStringAsFixed(1);
        return 'Sprint Range: ${dist}m';
      case 2:
        final g = (_clawGrip * 260).round();
        return 'Pinch Force: ${g}g';
      default:
        final spd = (1.4 + (_rampAngle - 10) * 0.09).toStringAsFixed(1);
        return 'Exit Speed: $spd m/s';
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeIdx = widget.activeIndex;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Machine selector chips
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(_machines.length, (i) {
              final m = _machines[i];
              final selected = i == activeIdx;
              return InkWell(
                onTap: () {
                  SoundEffects.playPop();
                  widget.onSelectMachine(i);
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(m.icon, style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: 5),
                      Text(
                        m.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: selected ? Colors.white : AppColors.textMain,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),

          // Live interactive simulation canvas + floating metric pill
          Stack(
            children: [
              Container(
                height: 176,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: AnimatedBuilder(
                    animation: _actionController,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: _InteractiveExamplePainter(
                          machineIndex: activeIdx,
                          scissorLift: _scissorLift,
                          racerWind: _racerWind,
                          clawGrip: _clawGrip,
                          rampAngle: _rampAngle,
                          actionProgress: _actionController.value,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _telemetryLabel(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF38BDF8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Interactive Control Bar (Slider + Play button)
          _buildControlBar(activeIdx),
        ],
      ),
    );
  }

  Widget _buildControlBar(int idx) {
    String sliderTitle;
    double value;
    double min;
    double max;
    String actionLabel;
    ValueChanged<double> onChanged;

    switch (idx) {
      case 0:
        sliderTitle = 'Push Handle';
        value = _scissorLift;
        min = 0.05;
        max = 1.0;
        actionLabel = _scissorLift > 0.7 ? 'Lower ⬇' : 'Lift 4× ⬆';
        onChanged = (v) => setState(() => _scissorLift = v);
        break;
      case 1:
        sliderTitle = 'Rubber Band Winds';
        value = _racerWind;
        min = 1.0;
        max = 5.0;
        actionLabel = 'Launch Racer 🚀';
        onChanged = (v) => setState(() => _racerWind = v);
        break;
      case 2:
        sliderTitle = 'Trigger Pull';
        value = _clawGrip;
        min = 0.0;
        max = 1.0;
        actionLabel = _clawGrip > 0.6 ? 'Open Jaws' : 'Pinch Cube 🦾';
        onChanged = (v) => setState(() => _clawGrip = v);
        break;
      default:
        sliderTitle = 'Ramp Angle';
        value = _rampAngle;
        min = 12.0;
        max = 45.0;
        actionLabel = 'Drop Marble 🔮';
        onChanged = (v) => setState(() => _rampAngle = v);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stackControls = constraints.maxWidth < 340;
          final sliderRow = Row(
            children: [
              Text(
                sliderTitle,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                  ),
                  child: Slider(
                    value: value,
                    min: min,
                    max: max,
                    activeColor: AppColors.primary,
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          );

          final actionBtn = ElevatedButton(
            onPressed: _triggerAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emerald,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
              elevation: 0,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionLabel,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
            ),
          );

          if (stackControls) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                sliderRow,
                const SizedBox(height: 6),
                actionBtn,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: sliderRow),
              const SizedBox(width: 8),
              actionBtn,
            ],
          );
        },
      ),
    );
  }
}

class _InteractiveExamplePainter extends CustomPainter {
  final int machineIndex;
  final double scissorLift;
  final double racerWind;
  final double clawGrip;
  final double rampAngle;
  final double actionProgress;

  _InteractiveExamplePainter({
    required this.machineIndex,
    required this.scissorLift,
    required this.racerWind,
    required this.clawGrip,
    required this.rampAngle,
    required this.actionProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Blueprint Grid
    final grid = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1;
    for (double x = 0; x < w; x += 24) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), grid);
    }
    for (double y = 0; y < h; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(w, y), grid);
    }

    final groundY = h - 22;
    canvas.drawLine(
      Offset(16, groundY),
      Offset(w - 16, groundY),
      Paint()
        ..color = const Color(0xFFCBD5E1)
        ..strokeWidth = 3,
    );

    switch (machineIndex) {
      case 0:
        _paintScissor(canvas, w, groundY);
        break;
      case 1:
        _paintRacer(canvas, w, groundY);
        break;
      case 2:
        _paintGripper(canvas, w, groundY);
        break;
      default:
        _paintCoaster(canvas, w, h, groundY);
    }
  }

  void _paintScissor(Canvas canvas, double w, double groundY) {
    final cx = w * 0.5;
    final liftPx = 22.0 + scissorLift * 84.0;
    final halfSpan = 48.0 - scissorLift * 18.0;

    final strut = Paint()
      ..color = const Color(0xFFD97706)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    final pin = Paint()..color = const Color(0xFFFDE68A);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 56, groundY - 6, 112, 8),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF78350F),
    );

    final y1 = groundY - liftPx * 0.5;
    final y2 = groundY - liftPx;
    canvas.drawLine(Offset(cx - halfSpan, groundY - 4), Offset(cx + halfSpan, y1), strut);
    canvas.drawLine(Offset(cx + halfSpan, groundY - 4), Offset(cx - halfSpan, y1), strut);
    canvas.drawCircle(Offset(cx, (groundY - 4 + y1) / 2), 3.5, pin);

    canvas.drawLine(Offset(cx - halfSpan, y1), Offset(cx + halfSpan, y2), strut);
    canvas.drawLine(Offset(cx + halfSpan, y1), Offset(cx - halfSpan, y2), strut);
    canvas.drawCircle(Offset(cx, (y1 + y2) / 2), 3.5, pin);

    // Payload platform + cargo box
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 42, y2 - 9, 84, 9),
        const Radius.circular(3),
      ),
      Paint()..color = AppColors.primary,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 13, y2 - 27, 26, 18),
        const Radius.circular(4),
      ),
      Paint()..color = AppColors.emerald,
    );
  }

  void _paintRacer(Canvas canvas, double w, double groundY) {
    final travel = math.sin(actionProgress * math.pi) *
        (w * 0.25) *
        (racerWind / 5.0);
    final rx = (w * 0.42) + travel;

    // Distance ticks on floor
    for (int i = 0; i <= 5; i++) {
      final tx = 24 + (w - 48) * (i / 5.0);
      canvas.drawLine(
        Offset(tx, groundY),
        Offset(tx, groundY + 6),
        Paint()
          ..color = AppColors.textDim
          ..strokeWidth = 1.5,
      );
    }

    // Chassis
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rx - 44, groundY - 30, 88, 18),
        const Radius.circular(5),
      ),
      Paint()..color = const Color(0xFFB45309),
    );
    // Spoiler
    final spoiler = Path()
      ..moveTo(rx - 40, groundY - 30)
      ..lineTo(rx - 50, groundY - 44)
      ..lineTo(rx - 32, groundY - 44)
      ..close();
    canvas.drawPath(spoiler, Paint()..color = AppColors.rose);

    // Rubber band stretched on chassis proportionally to wind
    final bandStretch = 14 + racerWind * 4.5;
    canvas.drawLine(
      Offset(rx - 14, groundY - 21),
      Offset(rx - 14 + bandStretch, groundY - 21),
      Paint()
        ..color = AppColors.amber
        ..strokeWidth = 3.5,
    );

    // Wheels
    final rot = actionProgress * 10 * math.pi * (racerWind / 3.0);
    for (final wx in [rx - 28, rx + 28]) {
      canvas.drawCircle(
        Offset(wx, groundY - 12),
        13,
        Paint()..color = const Color(0xFF1E293B),
      );
      canvas.drawCircle(
        Offset(wx, groundY - 12),
        5,
        Paint()..color = const Color(0xFFFDE68A),
      );
      for (int s = 0; s < 4; s++) {
        final a = rot + s * math.pi / 2;
        canvas.drawLine(
          Offset(wx, groundY - 12),
          Offset(wx + math.cos(a) * 11, groundY - 12 + math.sin(a) * 11),
          Paint()
            ..color = Colors.white70
            ..strokeWidth = 1.6,
        );
      }
    }
  }

  void _paintGripper(Canvas canvas, double w, double groundY) {
    final cx = w * 0.5;
    final openAmt = (1.0 - clawGrip) * 28.0;

    // Handle shaft
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 10, groundY - 48, 20, 48),
        const Radius.circular(5),
      ),
      Paint()..color = const Color(0xFF78350F),
    );

    // Left jaw
    final left = Path()
      ..moveTo(cx - 6, groundY - 48)
      ..lineTo(cx - 26 - openAmt, groundY - 94)
      ..lineTo(cx - 12 - openAmt * 0.35, groundY - 114)
      ..lineTo(cx - 6 - openAmt * 0.2, groundY - 110)
      ..close();
    canvas.drawPath(left, Paint()..color = const Color(0xFFD97706));

    // Right jaw
    final right = Path()
      ..moveTo(cx + 6, groundY - 48)
      ..lineTo(cx + 26 + openAmt, groundY - 94)
      ..lineTo(cx + 12 + openAmt * 0.35, groundY - 114)
      ..lineTo(cx + 6 + openAmt * 0.2, groundY - 110)
      ..close();
    canvas.drawPath(right, Paint()..color = const Color(0xFFD97706));

    // Pivot pin
    canvas.drawCircle(
      Offset(cx, groundY - 48),
      5,
      Paint()..color = const Color(0xFFFDE68A),
    );

    // Target payload block
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, groundY - 96), width: 24, height: 24),
        const Radius.circular(5),
      ),
      Paint()..color = clawGrip > 0.65 ? AppColors.emerald : AppColors.primary,
    );
  }

  void _paintCoaster(Canvas canvas, double w, double h, double groundY) {
    final startY = groundY - 36 - (rampAngle * 1.6);
    final p0 = Offset(32, startY);
    final p1 = Offset(w * 0.36, groundY - 6);
    final p2 = Offset(w * 0.65, groundY - 46);
    final p3 = Offset(w - 32, groundY - 8);

    final path = Path()
      ..moveTo(p0.dx, p0.dy)
      ..quadraticBezierTo(p1.dx, p1.dy, p2.dx, p2.dy)
      ..quadraticBezierTo((p2.dx + p3.dx) / 2, groundY + 4, p3.dx, p3.dy);

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF475569)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );

    // Support pillars
    canvas.drawLine(
      Offset(p0.dx + 4, p0.dy),
      Offset(p0.dx + 4, groundY),
      Paint()
        ..color = const Color(0xFFD97706)
        ..strokeWidth = 5,
    );

    // Sample point along track using actionProgress (or resting at top when 0)
    final t = actionProgress == 0 ? 0.08 : actionProgress;
    final metrics = path.computeMetrics().toList();
    Offset ballPos = p0;
    if (metrics.isNotEmpty) {
      final tangent = metrics.first.getTangentForOffset(
        metrics.first.length * t.clamp(0.0, 1.0),
      );
      if (tangent != null) {
        ballPos = tangent.position;
      }
    }
    canvas.drawCircle(
      ballPos,
      8.5,
      Paint()..color = const Color(0xFFEC4899),
    );
    canvas.drawCircle(
      Offset(ballPos.dx - 2.5, ballPos.dy - 2.5),
      2.6,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _InteractiveExamplePainter oldDelegate) {
    return oldDelegate.machineIndex != machineIndex ||
        oldDelegate.scissorLift != scissorLift ||
        oldDelegate.racerWind != racerWind ||
        oldDelegate.clawGrip != clawGrip ||
        oldDelegate.rampAngle != rampAngle ||
        oldDelegate.actionProgress != actionProgress;
  }
}
