// Interactive Free-Flight Arcade Mini-Game Overlay for Bolts
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/sound_effects.dart';
import '../theme/app_theme.dart';
import 'robot_3d_cartoon_painter.dart';

bool get _isRunningTests =>
    WidgetsBinding.instance.runtimeType.toString().contains('Test');

class BoltsFreeFlightOverlay extends StatefulWidget {
  final Offset initialCenter;
  final RobotPaint paintStyle;
  final RobotHat hat;
  final bool isRainbowMode;
  final void Function(int collectedCount, bool allCollected) onExit;
  final void Function(int totalCollected)? onGearCollected;

  const BoltsFreeFlightOverlay({
    super.key,
    required this.initialCenter,
    required this.paintStyle,
    required this.hat,
    required this.isRainbowMode,
    required this.onExit,
    this.onGearCollected,
  });

  @override
  State<BoltsFreeFlightOverlay> createState() => _BoltsFreeFlightOverlayState();
}

class _BoltsFreeFlightOverlayState extends State<BoltsFreeFlightOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _loopController;
  late Offset _boltsPos;
  double _velocityTilt = 0.0;
  double _lastStageW = 600.0;
  double _lastStageH = 420.0;
  int _secondsLeft = 15;
  Timer? _countdownTimer;
  bool _exited = false;
  final FocusNode _focusNode = FocusNode();

  // Normalized (x, y) anchor points for 5 collectible gears
  static const List<Offset> _gearAnchors = [
    Offset(0.18, 0.24),
    Offset(0.82, 0.22),
    Offset(0.50, 0.48),
    Offset(0.22, 0.78),
    Offset(0.80, 0.76),
  ];
  final Set<int> _collected = {};
  final List<Offset> _trailHistory = [];

  @override
  void initState() {
    super.initState();
    _boltsPos = widget.initialCenter;
    _loopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    if (_isRunningTests) {
      _loopController.value = 0.35;
    } else {
      _loopController.repeat();
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        if (_secondsLeft <= 1) {
          timer.cancel();
          _finishFlight();
        } else {
          setState(() => _secondsLeft--);
        }
      });
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _loopController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _finishFlight() {
    if (_exited) return;
    _exited = true;
    _countdownTimer?.cancel();
    widget.onExit(_collected.length, _collected.length == _gearAnchors.length);
  }

  void _moveBoltsBy(Offset delta, double stageW, double stageH) {
    final double maxX = math.max(56.0, stageW - 44.0);
    final double maxY = math.max(72.0, stageH - 44.0);
    final double nextX = (_boltsPos.dx + delta.dx).clamp(44.0, maxX).toDouble();
    final double nextY = (_boltsPos.dy + delta.dy).clamp(58.0, maxY).toDouble();
    final next = Offset(nextX, nextY);

    setState(() {
      _boltsPos = next;
      _velocityTilt = (delta.dx * 0.032).clamp(-0.48, 0.48);
      _trailHistory.add(next);
      if (_trailHistory.length > 14) {
        _trailHistory.removeAt(0);
      }
      _checkGearCollisions(stageW, stageH);
    });
  }

  void _flyToward(Offset targetPos, double stageW, double stageH) {
    final delta = targetPos - _boltsPos;
    final step = delta.distance > 1.0 ? delta * 0.42 : delta;
    _moveBoltsBy(step, stageW, stageH);
  }

  void _checkGearCollisions(double stageW, double stageH) {
    for (int i = 0; i < _gearAnchors.length; i++) {
      if (_collected.contains(i)) continue;
      final gPos = Offset(
        _gearAnchors[i].dx * stageW,
        _gearAnchors[i].dy * stageH,
      );
      if ((gPos - _boltsPos).distance <= 48.0) {
        _collected.add(i);
        HapticFeedback.lightImpact();
        widget.onGearCollected?.call(_collected.length);
        if (_collected.length == _gearAnchors.length) {
          SoundEffects.playFanfare();
        } else {
          SoundEffects.playChime();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stageW = constraints.maxWidth.isFinite ? constraints.maxWidth : 600.0;
        final stageH = constraints.maxHeight.isFinite ? constraints.maxHeight : 420.0;
        _lastStageW = stageW;
        _lastStageH = stageH;

        return KeyboardListener(
          focusNode: _focusNode,
          autofocus: !_isRunningTests,
          onKeyEvent: (event) {
            if (event is! KeyDownEvent && event is! KeyRepeatEvent) return;
            const speed = 22.0;
            if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
                event.logicalKey == LogicalKeyboardKey.keyD) {
              _moveBoltsBy(const Offset(speed, 0), _lastStageW, _lastStageH);
            } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
                event.logicalKey == LogicalKeyboardKey.keyA) {
              _moveBoltsBy(const Offset(-speed, 0), _lastStageW, _lastStageH);
            } else if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
                event.logicalKey == LogicalKeyboardKey.keyW) {
              _moveBoltsBy(const Offset(0, -speed), _lastStageW, _lastStageH);
            } else if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
                event.logicalKey == LogicalKeyboardKey.keyS) {
              _moveBoltsBy(const Offset(0, speed), _lastStageW, _lastStageH);
            }
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => _flyToward(d.localPosition, stageW, stageH),
            onPanUpdate: (d) => _moveBoltsBy(d.delta, stageW, stageH),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Subtle translucent sky arena wash
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                ),

                // Collectible golden gears + plasma trail
                Positioned.fill(
                  child: RepaintBoundary(
                    child: AnimatedBuilder(
                      animation: _loopController,
                      builder: (context, _) {
                        return CustomPaint(
                          painter: _FreeFlightArenaPainter(
                            spinPhase: _loopController.value,
                            gearAnchors: _gearAnchors,
                            collected: _collected,
                            trail: _trailHistory,
                            neonColor: widget.paintStyle.neonColor,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Airborne interactive Bolts sprite
                Positioned(
                  left: _boltsPos.dx - 52,
                  top: _boltsPos.dy - 54,
                  width: 104,
                  height: 108,
                  child: IgnorePointer(
                    child: Transform.rotate(
                      angle: _velocityTilt,
                      child: AnimatedBuilder(
                        animation: _loopController,
                        builder: (context, _) {
                          return CustomPaint(
                            painter: TalkingRobot3DCartoonPainter(
                              idle: _loopController.value,
                              entrance: 1.0,
                              rawEntrance: 1.0,
                              tapBounce: 0.0,
                              confettiProgress:
                                  _collected.length == _gearAnchors.length
                                      ? _loopController.value
                                      : 0.0,
                              mood: RobotMood.excited,
                              isTalking: false,
                              paintStyle: widget.paintStyle,
                              hat: widget.hat,
                              hasBoosters: true,
                              isDancing: false,
                              userYaw: _velocityTilt * 0.9,
                              userPitch: -0.06,
                              showGroundShadow: false,
                              boostThrust: 1.32,
                              isRainbowMode: widget.isRainbowMode,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Top HUD bar (Score, Time & Land Button)
                Positioned(
                  top: 8,
                  left: 8,
                  right: 8,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: widget.paintStyle.neonColor.withValues(alpha: 0.8),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.22),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.center,
                        children: [
                          const Text(
                            '✈️ DRAG OR TAP TO STEER BOLTS!',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.amber.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '⚙️ ${_collected.length}/${_gearAnchors.length} Gears',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFFDE047),
                              ),
                            ),
                          ),
                          Text(
                            '⏱ ${_secondsLeft}s',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF7DD3FC),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _finishFlight,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.emerald,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Land Bolts ⬇',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FreeFlightArenaPainter extends CustomPainter {
  final double spinPhase;
  final List<Offset> gearAnchors;
  final Set<int> collected;
  final List<Offset> trail;
  final Color neonColor;

  const _FreeFlightArenaPainter({
    required this.spinPhase,
    required this.gearAnchors,
    required this.collected,
    required this.trail,
    required this.neonColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Plasma flight trail behind Bolts
    for (int i = 0; i < trail.length - 1; i++) {
      final frac = (i + 1) / trail.length;
      canvas.drawLine(
        trail[i],
        trail[i + 1],
        Paint()
          ..color = neonColor.withValues(alpha: 0.55 * frac)
          ..strokeWidth = 10.0 * frac
          ..strokeCap = StrokeCap.round,
      );
    }

    // 2. Spinning collectible golden gears
    for (int i = 0; i < gearAnchors.length; i++) {
      if (collected.contains(i)) continue;
      final c = Offset(
        gearAnchors[i].dx * size.width,
        gearAnchors[i].dy * size.height +
            math.sin(spinPhase * 2 * math.pi + i) * 6.0,
      );
      canvas.drawCircle(
        c,
        22,
        Paint()
          ..color = const Color(0xFFFDE047).withValues(alpha: 0.24),
      );
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(spinPhase * 2 * math.pi + i * 0.8);
      final gearPath = Path();
      const teeth = 8;
      for (int t = 0; t < teeth * 2; t++) {
        final a = t * (math.pi / teeth);
        final r = t.isEven ? 14.0 : 9.8;
        final pt = Offset(math.cos(a) * r, math.sin(a) * r);
        if (t == 0) {
          gearPath.moveTo(pt.dx, pt.dy);
        } else {
          gearPath.lineTo(pt.dx, pt.dy);
        }
      }
      gearPath.close();
      canvas.drawPath(gearPath, Paint()..color = const Color(0xFFF59E0B));
      canvas.drawPath(
        gearPath,
        Paint()
          ..color = const Color(0xFF78350F)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
      canvas.drawCircle(Offset.zero, 4.5, Paint()..color = Colors.white);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _FreeFlightArenaPainter oldDelegate) {
    return oldDelegate.spinPhase != spinPhase ||
        oldDelegate.collected.length != collected.length ||
        oldDelegate.trail.length != trail.length;
  }
}
