// Bolts Arcade Shelf, 3D Trick Controller, Circuit Snapper, Trivia Duel & Boombox Beat Lab
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/sound_effects.dart';
import '../theme/app_theme.dart';
import 'frosted_glass_background.dart';
import 'robot_3d_cartoon_painter.dart';

bool get _isRunningTests =>
    WidgetsBinding.instance.runtimeType.toString().contains('Test');

/// Compact frosted shelf placed below the main Bolts stage housing extra
/// 3D robot tricks, studio themes, and 4 interactive arcade launchers.
class BoltsArcadeShelf extends StatelessWidget {
  final Color accentColor;
  final String sceneTheme;
  final ValueChanged<String> onSelectTheme;
  final VoidCallback onTriggerSpin;
  final VoidCallback onTriggerWink;
  final VoidCallback onTriggerConfetti;
  final VoidCallback onOpenSandbox;
  final VoidCallback onOpenCircuitGame;
  final VoidCallback onOpenTriviaGame;
  final VoidCallback onOpenBoomboxGame;
  final Set<String> clearedMilestones;

  const BoltsArcadeShelf({
    super.key,
    required this.accentColor,
    required this.sceneTheme,
    required this.onSelectTheme,
    required this.onTriggerSpin,
    required this.onTriggerWink,
    required this.onTriggerConfetti,
    required this.onOpenSandbox,
    required this.onOpenCircuitGame,
    required this.onOpenTriviaGame,
    required this.onOpenBoomboxGame,
    this.clearedMilestones = const {},
  });

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    final isTiny = screenW < 420;

    return GlassSurface(
      borderRadius: 22,
      blurSigma: 14,
      tintColor: accentColor,
      topOpacity: 0.74,
      bottomOpacity: 0.54,
      borderColor: Colors.white.withValues(alpha: 0.90),
      borderWidth: 1.4,
      padding: EdgeInsets.all(isTiny ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row 1: Robot Trick Studio + Scene Switcher
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'TRICK LAB:',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.9,
                      color: AppColors.textDim,
                    ),
                  ),
                  _trickPill('🌀 360° Spin', onTriggerSpin),
                  _trickPill('😉 Wink & Wave', onTriggerWink),
                  _trickPill('🎉 Confetti Pop', onTriggerConfetti),
                ],
              ),
              Wrap(
                spacing: 5,
                runSpacing: 5,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'SCENE:',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      color: AppColors.textDim,
                    ),
                  ),
                  _sceneChip('☁️ Cloud', 'cloud'),
                  _sceneChip('🌌 Orbit', 'space'),
                  _sceneChip('🌅 Sunset', 'sunset'),
                  _sceneChip('🔋 Cyber', 'cyber'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 2: 4 Interactive Mini-Game & Sandbox Launchers
          LayoutBuilder(
            builder: (context, constraints) {
              final maxW = constraints.maxWidth;
              final cols = maxW >= 780 ? 4 : (maxW >= 480 ? 2 : 1);
              final tileW = (maxW - (cols - 1) * 10.0) / cols;

              final tiles = [
                _arcadeTile(
                  width: tileW,
                  icon: '🛠️',
                  title: 'Inventor Sandbox',
                  subtitle: 'Snap parts & test on 3 tracks',
                  xpTag: '+20 XP',
                  cleared: clearedMilestones.contains('sandbox_win'),
                  color: const Color(0xFF0284C7),
                  onTap: onOpenSandbox,
                ),
                _arcadeTile(
                  width: tileW,
                  icon: '💡',
                  title: 'Circuit Snapper',
                  subtitle: 'Wire copper tape to light LEDs',
                  xpTag: '+15 XP',
                  cleared: clearedMilestones.contains('circuit_snap'),
                  color: const Color(0xFFF59E0B),
                  onTap: onOpenCircuitGame,
                ),
                _arcadeTile(
                  width: tileW,
                  icon: '🧠',
                  title: 'STEM Trivia Duel',
                  subtitle: 'Beat Bolts in 5 physics picks',
                  xpTag: '+15 XP',
                  cleared: clearedMilestones.contains('trivia_ace'),
                  color: const Color(0xFF7C3AED),
                  onTap: onOpenTriviaGame,
                ),
                _arcadeTile(
                  width: tileW,
                  icon: '🎵',
                  title: 'Boombox Beat Lab',
                  subtitle: 'Drop live synth beats & dance',
                  xpTag: '+10 XP',
                  cleared: clearedMilestones.contains('boombox_dj'),
                  color: const Color(0xFFEC4899),
                  onTap: onOpenBoomboxGame,
                ),
              ];

              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: tiles,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _trickPill(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color: AppColors.textMain,
          ),
        ),
      ),
    );
  }

  Widget _sceneChip(String label, String themeId) {
    final active = sceneTheme == themeId;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        SoundEffects.playPop();
        onSelectTheme(themeId);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.white.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: active ? Colors.white : AppColors.textMain,
          ),
        ),
      ),
    );
  }

  Widget _arcadeTile({
    required double width,
    required String icon,
    required String title,
    required String subtitle,
    required String xpTag,
    required bool cleared,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: cleared
                  ? AppColors.emerald.withValues(alpha: 0.7)
                  : color.withValues(alpha: 0.28),
              width: cleared ? 1.6 : 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 19)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textMain,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: cleared
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            cleared ? '✓ Done' : xpTag,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: cleared
                                  ? const Color(0xFF15803D)
                                  : const Color(0xFF92400E),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// MINI-GAME 1: CIRCUIT SNAPPER 💡
// ══════════════════════════════════════════════════════════════════════════
class CircuitSnapDialog extends StatefulWidget {
  final VoidCallback onSolved;

  const CircuitSnapDialog({super.key, required this.onSolved});

  @override
  State<CircuitSnapDialog> createState() => _CircuitSnapDialogState();
}

class _CircuitSnapDialogState extends State<CircuitSnapDialog>
    with SingleTickerProviderStateMixin {
  bool _positiveRightSideUp = false;
  bool _topTapeClosed = false;
  bool _bottomTapeClosed = true;
  bool _shortBypassClosed = false;
  bool _tested = false;
  bool _won = false;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (_isRunningTests) {
      _pulseCtrl.value = 0.5;
    } else {
      _pulseCtrl.repeat();
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _testCircuit() {
    HapticFeedback.mediumImpact();
    final isShort = _shortBypassClosed;
    final complete = _positiveRightSideUp &&
        _topTapeClosed &&
        _bottomTapeClosed &&
        !isShort;
    setState(() {
      _tested = true;
      _won = complete;
    });
    if (complete) {
      SoundEffects.playFanfare();
      widget.onSolved();
    } else {
      SoundEffects.playBoing();
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final compact = w < 440;

    final statusMsg = !_tested
        ? 'Connect both Copper Tapes, align Battery Polarity (+ Up), and keep Short Bypass OFF!'
        : (_shortBypassClosed
            ? 'ZAP! Bypass bridge created a SHORT CIRCUIT! Turn Bypass OFF so electrons flow through the LED!'
            : (!_positiveRightSideUp
                ? 'LED blocked! Current only flows forward — flip Battery Polarity to (+ Up)!'
                : (!_topTapeClosed || !_bottomTapeClosed
                    ? 'Open loop! Snap both Top and Bottom Copper Tapes closed!'
                    : 'BEACON LIT! Closed loop powered cleanly (+15 Starter XP)!')));

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: compact ? 12 : 28, vertical: 16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: GlassSurface(
          borderRadius: 24,
          blurSigma: 18,
          tintColor: const Color(0xFFF59E0B),
          padding: EdgeInsets.all(compact ? 14 : 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Text('💡 ', style: TextStyle(fontSize: 22)),
                    const Expanded(
                      child: Text(
                        'Copper-Tape Circuit Snapper',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textMain,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 146,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _won ? AppColors.emerald : const Color(0xFF334155),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedBuilder(
                      animation: _pulseCtrl,
                      builder: (context, _) {
                        return CustomPaint(
                          painter: _CircuitBoardPainter(
                            polarityOk: _positiveRightSideUp,
                            topClosed: _topTapeClosed,
                            bottomClosed: _bottomTapeClosed,
                            shortClosed: _shortBypassClosed,
                            lit: _won,
                            pulse: _pulseCtrl.value,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _won
                        ? const Color(0xFFDCFCE7)
                        : (_tested
                            ? const Color(0xFFFEF2F2)
                            : Colors.white.withValues(alpha: 0.78)),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _won ? AppColors.emerald : AppColors.border,
                    ),
                  ),
                  child: Text(
                    statusMsg,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: _won ? const Color(0xFF065F46) : AppColors.textMain,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _switchChip(
                      _positiveRightSideUp ? '🔋 Polarity: + Up' : '🔋 Polarity: - Up',
                      _positiveRightSideUp,
                      () => setState(() {
                        SoundEffects.playPop();
                        _positiveRightSideUp = !_positiveRightSideUp;
                        _tested = false;
                        _won = false;
                      }),
                    ),
                    _switchChip(
                      _topTapeClosed ? '⚡ Top Tape: Closed' : '⚡ Top Tape: Open',
                      _topTapeClosed,
                      () => setState(() {
                        SoundEffects.playPop();
                        _topTapeClosed = !_topTapeClosed;
                        _tested = false;
                        _won = false;
                      }),
                    ),
                    _switchChip(
                      _bottomTapeClosed ? '〰️ Bottom Tape: Closed' : '〰️ Bottom Tape: Open',
                      _bottomTapeClosed,
                      () => setState(() {
                        SoundEffects.playPop();
                        _bottomTapeClosed = !_bottomTapeClosed;
                        _tested = false;
                        _won = false;
                      }),
                    ),
                    _switchChip(
                      _shortBypassClosed ? '⚠️ Bypass: ON (Short)' : '🛡️ Bypass: Safe OFF',
                      !_shortBypassClosed,
                      () => setState(() {
                        SoundEffects.playPop();
                        _shortBypassClosed = !_shortBypassClosed;
                        _tested = false;
                        _won = false;
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _testCircuit,
                  icon: const Icon(Icons.bolt_rounded, size: 18),
                  label: Text(
                    _won ? 'Circuit Lit! 🎉' : 'Test Circuit ⚡',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _won ? AppColors.emerald : AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _switchChip(String label, bool good, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: good ? const Color(0xFFECFDF5) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: good ? AppColors.emerald : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: good ? const Color(0xFF065F46) : AppColors.textMain,
          ),
        ),
      ),
    );
  }
}

class _CircuitBoardPainter extends CustomPainter {
  final bool polarityOk;
  final bool topClosed;
  final bool bottomClosed;
  final bool shortClosed;
  final bool lit;
  final double pulse;

  _CircuitBoardPainter({
    required this.polarityOk,
    required this.topClosed,
    required this.bottomClosed,
    required this.shortClosed,
    required this.lit,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final leftX = 48.0;
    final rightX = w - 52.0;
    final topY = 34.0;
    final botY = h - 34.0;

    final copper = Paint()
      ..color = const Color(0xFFF59E0B)
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;
    final gapPaint = Paint()
      ..color = const Color(0xFF475569)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Left vertical trace + Coin Cell Battery
    canvas.drawLine(Offset(leftX, topY), Offset(leftX, botY), copper);
    canvas.drawCircle(
      Offset(leftX, h * 0.5),
      18,
      Paint()..color = const Color(0xFFE2E8F0),
    );
    canvas.drawCircle(
      Offset(leftX, h * 0.5),
      18,
      Paint()
        ..color = polarityOk ? AppColors.emerald : AppColors.rose
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Top horizontal trace with switch gap in middle
    final midX = (leftX + rightX) * 0.5;
    canvas.drawLine(Offset(leftX, topY), Offset(midX - 24, topY), copper);
    canvas.drawLine(Offset(midX + 24, topY), Offset(rightX, topY), copper);
    if (topClosed) {
      canvas.drawLine(Offset(midX - 24, topY), Offset(midX + 24, topY), copper);
    } else {
      canvas.drawLine(
        Offset(midX - 24, topY),
        Offset(midX + 14, topY - 16),
        gapPaint,
      );
    }

    // Bottom horizontal trace with switch gap
    canvas.drawLine(Offset(leftX, botY), Offset(midX - 24, botY), copper);
    canvas.drawLine(Offset(midX + 24, botY), Offset(rightX, botY), copper);
    if (bottomClosed) {
      canvas.drawLine(Offset(midX - 24, botY), Offset(midX + 24, botY), copper);
    } else {
      canvas.drawLine(
        Offset(midX - 24, botY),
        Offset(midX + 14, botY + 14),
        gapPaint,
      );
    }

    // Center short bypass line
    if (shortClosed) {
      canvas.drawLine(
        Offset(midX, topY),
        Offset(midX, botY),
        Paint()
          ..color = AppColors.rose
          ..strokeWidth = 4,
      );
    }

    // Right trace + Glowing LED Beacon
    canvas.drawLine(Offset(rightX, topY), Offset(rightX, botY), copper);
    final ledPos = Offset(rightX, h * 0.5);
    if (lit) {
      canvas.drawCircle(
        ledPos,
        28 + math.sin(pulse * 2 * math.pi) * 4,
        Paint()..color = const Color(0xFFFDE047).withValues(alpha: 0.35),
      );
    }
    canvas.drawCircle(
      ledPos,
      14,
      Paint()..color = lit ? const Color(0xFFFDE047) : const Color(0xFF334155),
    );
    canvas.drawCircle(
      ledPos,
      14,
      Paint()
        ..color = Colors.white70
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Animated Electron beads when circuit is lit!
    if (lit) {
      final dotX = leftX + (rightX - leftX) * pulse;
      canvas.drawCircle(
        Offset(dotX, topY),
        4.2,
        Paint()..color = const Color(0xFF38BDF8),
      );
      canvas.drawCircle(
        Offset(rightX - (rightX - leftX) * pulse, botY),
        4.2,
        Paint()..color = const Color(0xFF38BDF8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CircuitBoardPainter oldDelegate) {
    return oldDelegate.polarityOk != polarityOk ||
        oldDelegate.topClosed != topClosed ||
        oldDelegate.bottomClosed != bottomClosed ||
        oldDelegate.shortClosed != shortClosed ||
        oldDelegate.lit != lit ||
        oldDelegate.pulse != pulse;
  }
}

// ══════════════════════════════════════════════════════════════════════════
// MINI-GAME 2: BEAT-BOLTS STEM TRIVIA DUEL 🧠
// ══════════════════════════════════════════════════════════════════════════
class BoltsTriviaDialog extends StatefulWidget {
  final VoidCallback onWon;

  const BoltsTriviaDialog({super.key, required this.onWon});

  @override
  State<BoltsTriviaDialog> createState() => _BoltsTriviaDialogState();
}

class _BoltsTriviaDialogState extends State<BoltsTriviaDialog> {
  static const List<({String q, List<String> opts, int ans, String why})> _questions = [
    (
      q: 'Why should cardboard struts be cut with flutes running LENGTHWISE?',
      opts: ['Looks shinier', '300% stronger against bending', 'Easier to fold sideways'],
      ans: 1,
      why: 'Aligned corrugation ribs act like miniature I-beams along the bar!',
    ),
    (
      q: 'Why slide wooden skewer axles inside plastic drinking straws?',
      opts: ['Reduces sliding friction by ~60%', 'Adds extra weight', 'Stops wheels from turning'],
      ans: 0,
      why: 'Smooth straw sleeves prevent skewers from chewing into rough cardboard holes!',
    ),
    (
      q: 'Pushing 3 criss-cross scissor tiers together multiplies lift height by:',
      opts: ['0.5×', '1×', 'Up to 4× higher'],
      ans: 2,
      why: 'Each pantograph X-stage adds together vertically in a single smooth push!',
    ),
    (
      q: 'What keeps a fast marble from flying off a Cardboard Roller Coaster curve?',
      opts: ['20° inward banked walls', 'Flat cardboard floor', 'Sandpaper brakes'],
      ans: 0,
      why: 'Banked walls redirect centrifugal push back down toward the track center!',
    ),
    (
      q: 'What energy does a twisted rubber band store inside a Torque Racer?',
      opts: ['Magnetic flux', 'Elastic potential energy', 'Thermal energy'],
      ans: 1,
      why: 'Coiling rubber molecules stores elastic energy that snaps into forward kinetic motion!',
    ),
  ];

  int _idx = 0;
  int _score = 0;
  int? _picked;
  bool _finished = false;
  bool _awarded = false;

  void _pickAnswer(int choice) {
    if (_picked != null) return;
    HapticFeedback.selectionClick();
    final isRight = choice == _questions[_idx].ans;
    if (isRight) {
      SoundEffects.playChime();
    } else {
      SoundEffects.playBoing();
    }
    setState(() {
      _picked = choice;
      if (isRight) _score++;
    });
  }

  void _next() {
    SoundEffects.playPop();
    if (_idx + 1 < _questions.length) {
      setState(() {
        _idx++;
        _picked = null;
      });
    } else {
      setState(() {
        _finished = true;
      });
      if (_score >= 3 && !_awarded) {
        _awarded = true;
        SoundEffects.playFanfare();
        widget.onWon();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final compact = w < 440;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: compact ? 12 : 28, vertical: 16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: GlassSurface(
          borderRadius: 24,
          blurSigma: 18,
          tintColor: const Color(0xFF7C3AED),
          padding: EdgeInsets.all(compact ? 14 : 20),
          child: SingleChildScrollView(
            child: _finished
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_score >= 3 ? '🏆' : '🤖', style: const TextStyle(fontSize: 44)),
                      const SizedBox(height: 8),
                      Text(
                        'Score: $_score / ${_questions.length}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textMain,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _score >= 3
                            ? 'MASTER CADET! You outsmarted Bolts (+15 Starter XP unlocked)!'
                            : 'Good warmup! Score 3+ out of 5 to unlock +15 Starter XP!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          OutlinedButton(
                            onPressed: () => setState(() {
                              _idx = 0;
                              _score = 0;
                              _picked = null;
                              _finished = false;
                            }),
                            child: const Text('Play Again'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Done'),
                          ),
                        ],
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Text('🧠 ', style: TextStyle(fontSize: 20)),
                          Expanded(
                            child: Text(
                              'Beat-Bolts Trivia (${_idx + 1}/${_questions.length})',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textMain,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Score: $_score',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _questions[_idx].q,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMain,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(_questions[_idx].opts.length, (i) {
                        final q = _questions[_idx];
                        final isSelected = _picked == i;
                        final isRight = i == q.ans;
                        Color bg = Colors.white;
                        Color border = AppColors.border;
                        if (_picked != null) {
                          if (isRight) {
                            bg = const Color(0xFFDCFCE7);
                            border = AppColors.emerald;
                          } else if (isSelected) {
                            bg = const Color(0xFFFEE2E2);
                            border = AppColors.rose;
                          }
                        }
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: () => _pickAnswer(i),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: bg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: border, width: 1.4),
                              ),
                              child: Text(
                                q.opts[i],
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMain,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                      if (_picked != null) ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '🤖 Bolts: ${_questions[_idx].why}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _next,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.emerald,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 11),
                          ),
                          child: Text(
                            _idx + 1 < _questions.length
                                ? 'Next Question →'
                                : 'See Final Score 🏆',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// MINI-GAME 3: BOOMBOX BEAT LAB 🎵
// ══════════════════════════════════════════════════════════════════════════
class BoomboxBeatDialog extends StatefulWidget {
  final RobotPaint paintStyle;
  final VoidCallback onBeatDropped;

  const BoomboxBeatDialog({
    super.key,
    required this.paintStyle,
    required this.onBeatDropped,
  });

  @override
  State<BoomboxBeatDialog> createState() => _BoomboxBeatDialogState();
}

class _BoomboxBeatDialogState extends State<BoomboxBeatDialog> {
  final List<List<bool>> _grid = [
    [true, false, false, false, true, false, false, false],
    [false, false, true, false, false, false, true, false],
    [false, true, false, true, false, true, false, false],
    [true, false, false, false, false, false, true, false],
  ];

  static const List<({String icon, String label, Color color})> _tracks = [
    (icon: '🥁', label: 'Box Kick', color: Color(0xFFF59E0B)),
    (icon: '👏', label: 'Clack', color: Color(0xFF38BDF8)),
    (icon: '⚡', label: 'Zap', color: Color(0xFFEC4899)),
    (icon: '🎹', label: 'Chord', color: Color(0xFF10B981)),
  ];

  int _step = 0;
  bool _playing = false;
  Timer? _timer;
  int _padHits = 0;
  bool _awarded = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _togglePlay() {
    HapticFeedback.lightImpact();
    if (_playing) {
      _timer?.cancel();
      setState(() => _playing = false);
      return;
    }
    setState(() => _playing = true);
    if (_isRunningTests) {
      _markDjCredit();
      return;
    }
    _timer = Timer.periodic(const Duration(milliseconds: 220), (_) {
      if (!mounted) return;
      final next = (_step + 1) % 8;
      setState(() => _step = next);
      for (int r = 0; r < _grid.length; r++) {
        if (_grid[r][next]) {
          SoundEffects.playBeatPad(r);
        }
      }
    });
    _markDjCredit();
  }

  void _hitPad(int padIdx) {
    HapticFeedback.lightImpact();
    SoundEffects.playBeatPad(padIdx);
    setState(() => _padHits++);
    if (_padHits >= 3) _markDjCredit();
  }

  void _markDjCredit() {
    if (_awarded) return;
    _awarded = true;
    widget.onBeatDropped();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final compact = w < 440;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: compact ? 12 : 28, vertical: 16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: GlassSurface(
          borderRadius: 24,
          blurSigma: 18,
          tintColor: const Color(0xFFEC4899),
          padding: EdgeInsets.all(compact ? 14 : 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Text('🎵 ', style: TextStyle(fontSize: 22)),
                    const Expanded(
                      child: Text(
                        'Bolts Boombox Beat Lab',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textMain,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Center(
                  child: SizedBox(
                    height: 112,
                    width: 130,
                    child: CustomPaint(
                      painter: TalkingRobot3DCartoonPainter(
                        idle: (_step / 8.0),
                        entrance: 1.0,
                        rawEntrance: 1.0,
                        tapBounce: _playing && _step.isEven ? 0.35 : 0.0,
                        confettiProgress: 0.0,
                        mood: RobotMood.dancing,
                        isTalking: false,
                        paintStyle: widget.paintStyle,
                        hat: RobotHat.none,
                        hasBoosters: false,
                        isDancing: _playing || _padHits > 0,
                        isRainbowMode: _playing,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: List.generate(_tracks.length, (i) {
                    final tr = _tracks[i];
                    return InkWell(
                      onTap: () => _hitPad(i),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: tr.color.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: tr.color),
                        ),
                        child: Text(
                          '${tr.icon} ${tr.label}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMain,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                // 4x8 Step Sequencer Grid
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: List.generate(_grid.length, (r) {
                      final c = _tracks[r].color;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 24,
                              child: Text(
                                _tracks[r].icon,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            ...List.generate(8, (col) {
                              final active = _grid[r][col];
                              final isPlayhead = _playing && _step == col;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setState(() {
                                      _grid[r][col] = !_grid[r][col];
                                    });
                                    if (_grid[r][col]) {
                                      SoundEffects.playBeatPad(r);
                                    }
                                    _markDjCredit();
                                  },
                                  child: Container(
                                    height: 22,
                                    margin: const EdgeInsets.symmetric(horizontal: 2),
                                    decoration: BoxDecoration(
                                      color: active
                                          ? c
                                          : const Color(0xFF1E293B),
                                      borderRadius: BorderRadius.circular(5),
                                      border: isPlayhead
                                          ? Border.all(color: Colors.white, width: 2)
                                          : null,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _togglePlay,
                  icon: Icon(_playing ? Icons.stop_rounded : Icons.play_arrow_rounded),
                  label: Text(
                    _playing ? 'Stop Beat ⏹' : 'Play Disco Loop ▶️ (+10 XP)',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _playing ? AppColors.rose : const Color(0xFFEC4899),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
