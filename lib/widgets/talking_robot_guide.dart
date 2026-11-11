// Talking Robot Host "Bolts" & Interactive Minimal Example Playgrounds
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/sound_effects.dart';
import '../theme/app_theme.dart';
import 'frosted_glass_background.dart';
import 'robot_3d_cartoon_painter.dart';

export 'robot_3d_cartoon_painter.dart'
    show
        RobotMood,
        RobotHat,
        RobotHatX,
        RobotPaint,
        RobotPaintX,
        TalkingRobot3DCartoonPainter;

bool get _isRunningTests =>
    WidgetsBinding.instance.runtimeType.toString().contains('Test');

/// Expressive 3D Pixar/vinyl-style customizable cartoon robot ("Bolts") that rolls
/// onto the stage, tracks cursor/touch in 3D, wears 3D hats & paint, fires rocket
/// boosters, dances, bursts confetti on high-fives, and animates a cartoon face.
class TalkingRobotCharacter extends StatefulWidget {
  final RobotMood mood;
  final bool isTalking;
  final int entranceKey;
  final int confettiBurstKey;
  final int overchargeKey;
  final int backflipKey;
  final int spinKey;
  final int winkKey;
  final double height;
  final RobotPaint paintStyle;
  final RobotHat hat;
  final bool hasBoosters;
  final bool isDancing;
  final bool isRainbowMode;
  final VoidCallback? onTap;
  final VoidCallback? onFeedPowerCell;

  const TalkingRobotCharacter({
    super.key,
    required this.mood,
    required this.isTalking,
    this.entranceKey = 0,
    this.confettiBurstKey = 0,
    this.overchargeKey = 0,
    this.backflipKey = 0,
    this.spinKey = 0,
    this.winkKey = 0,
    this.height = 176,
    this.paintStyle = RobotPaint.cobalt,
    this.hat = RobotHat.none,
    this.hasBoosters = false,
    this.isDancing = false,
    this.isRainbowMode = false,
    this.onTap,
    this.onFeedPowerCell,
  });

  @override
  State<TalkingRobotCharacter> createState() => _TalkingRobotCharacterState();
}

class _TalkingRobotCharacterState extends State<TalkingRobotCharacter>
    with TickerProviderStateMixin {
  late AnimationController _idleController;
  late AnimationController _entranceController;
  late AnimationController _tapController;
  late AnimationController _confettiController;
  late AnimationController _tiltSpringController;
  late AnimationController _overchargeController;
  late AnimationController _flipController;
  late AnimationController _spinController;
  late AnimationController _winkController;

  double _userYaw = 0.0;
  double _userPitch = 0.0;
  double _springStartYaw = 0.0;
  double _springStartPitch = 0.0;
  bool _isSpringingBack = false;
  bool _isDragging3D = false;

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
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

    _confettiController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _isRunningTests ? 50 : 900),
    );

    _tiltSpringController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _isRunningTests ? 50 : 480),
    );

    _overchargeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _isRunningTests ? 60 : 1400),
    );

    _flipController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _isRunningTests ? 60 : 820),
    );

    _spinController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _isRunningTests ? 60 : 960),
    );

    _winkController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _isRunningTests ? 60 : 1200),
    );
  }

  @override
  void didUpdateWidget(covariant TalkingRobotCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entranceKey != widget.entranceKey) {
      _entranceController.forward(from: 0.0);
    }
    if (oldWidget.confettiBurstKey != widget.confettiBurstKey) {
      _confettiController.forward(from: 0.0);
    }
    if (oldWidget.overchargeKey != widget.overchargeKey) {
      _overchargeController.forward(from: 0.0);
      _confettiController.forward(from: 0.0);
    }
    if (oldWidget.backflipKey != widget.backflipKey) {
      _flipController.forward(from: 0.0);
      _confettiController.forward(from: 0.0);
    }
    if (oldWidget.spinKey != widget.spinKey) {
      _spinController.forward(from: 0.0);
      _confettiController.forward(from: 0.0);
    }
    if (oldWidget.winkKey != widget.winkKey) {
      _winkController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _idleController.dispose();
    _entranceController.dispose();
    _tapController.dispose();
    _confettiController.dispose();
    _tiltSpringController.dispose();
    _overchargeController.dispose();
    _flipController.dispose();
    _spinController.dispose();
    _winkController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    SoundEffects.playRobotBeep();
    _tapController.forward(from: 0.0);
    _confettiController.forward(from: 0.0);
    widget.onTap?.call();
  }

  void _beginSpringBack() {
    _isDragging3D = false;
    _springStartYaw = _userYaw;
    _springStartPitch = _userPitch;
    _isSpringingBack = true;
    _tiltSpringController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.height * 1.08;
    return DragTarget<String>(
      onWillAcceptWithDetails: (details) => details.data == 'power_cell',
      onAcceptWithDetails: (_) {
        _overchargeController.forward(from: 0.0);
        _confettiController.forward(from: 0.0);
        widget.onFeedPowerCell?.call();
      },
      builder: (context, candidateData, rejectedData) {
        final isDropHovering = candidateData.isNotEmpty;
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onHover: (event) {
            if (_isDragging3D || _isRunningTests) return;
            final nx = ((event.localPosition.dx / width) - 0.5) * 2.0;
            final ny = ((event.localPosition.dy / widget.height) - 0.5) * 2.0;
            setState(() {
              _isSpringingBack = false;
              _userYaw = (nx * 0.45).clamp(-0.55, 0.55);
              _userPitch = (ny * 0.22).clamp(-0.26, 0.26);
            });
          },
          onExit: (_) {
            if (!_isDragging3D && !_isRunningTests) {
              _beginSpringBack();
            }
          },
          child: GestureDetector(
            onTap: _handleTap,
            onHorizontalDragStart: (_) {
              _isDragging3D = true;
              _isSpringingBack = false;
            },
            onHorizontalDragUpdate: (details) {
              setState(() {
                _isSpringingBack = false;
                _userYaw =
                    (_userYaw + details.delta.dx * 0.015).clamp(-0.68, 0.68);
              });
            },
            onHorizontalDragEnd: (_) => _beginSpringBack(),
            onHorizontalDragCancel: _beginSpringBack,
            behavior: HitTestBehavior.opaque,
            child: Tooltip(
              message: 'Tap Bolts for a high-five!',
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                height: widget.height,
                width: width,
                decoration: isDropHovering
                    ? BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFACC15),
                          width: 2.5,
                        ),
                        color: const Color(0xFFFEF08A).withValues(alpha: 0.24),
                      )
                    : null,
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _idleController,
                    _entranceController,
                    _tapController,
                    _confettiController,
                    _tiltSpringController,
                    _overchargeController,
                    _flipController,
                    _spinController,
                    _winkController,
                  ]),
                  builder: (context, _) {
                    double effectiveYaw = _userYaw;
                    double effectivePitch = _userPitch;
                    if (_isSpringingBack) {
                      final spring = Curves.easeOutBack.transform(
                        _tiltSpringController.value.clamp(0.0, 1.0),
                      );
                      effectiveYaw = _springStartYaw * (1.0 - spring);
                      effectivePitch = _springStartPitch * (1.0 - spring);
                    }

                    return CustomPaint(
                      painter: TalkingRobot3DCartoonPainter(
                        idle: _idleController.value,
                        entrance: Curves.easeOutBack.transform(
                          _entranceController.value.clamp(0.0, 1.0),
                        ),
                        rawEntrance: _entranceController.value,
                        tapBounce: _tapController.value,
                        confettiProgress: _confettiController.value,
                        mood: widget.mood,
                        isTalking: widget.isTalking,
                        paintStyle: widget.paintStyle,
                        hat: widget.hat,
                        hasBoosters: widget.hasBoosters,
                        isDancing: widget.isDancing,
                        userYaw: effectiveYaw,
                        userPitch: effectivePitch,
                        isRainbowMode: widget.isRainbowMode,
                        overchargeProgress: _overchargeController.isAnimating
                            ? _overchargeController.value
                            : 0.0,
                        flipProgress: _flipController.isAnimating
                            ? _flipController.value
                            : 0.0,
                        spinProgress: _spinController.isAnimating
                            ? _spinController.value
                            : 0.0,
                        winkProgress: _winkController.isAnimating
                            ? _winkController.value
                            : 0.0,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Tactile minimal toy dock letting kids customize Bolts (paint, hats, rocket
/// boosters, dance mode, Power Cell charge, Free Flight, voice & sound toggles).
class BoltsCustomizeToyBar extends StatelessWidget {
  final RobotPaint paintStyle;
  final ValueChanged<RobotPaint> onSelectPaint;
  final RobotHat hat;
  final VoidCallback onCycleHat;
  final bool hasBoosters;
  final VoidCallback onToggleBoosters;
  final bool isDancing;
  final VoidCallback onToggleDance;
  final bool soundEnabled;
  final VoidCallback onToggleSound;
  final int highFiveCount;
  final bool voiceEnabled;
  final VoidCallback? onToggleVoice;
  final VoidCallback? onFeedPowerCell;
  final VoidCallback? onEnterFreeFlight;

  const BoltsCustomizeToyBar({
    super.key,
    required this.paintStyle,
    required this.onSelectPaint,
    required this.hat,
    required this.onCycleHat,
    required this.hasBoosters,
    required this.onToggleBoosters,
    required this.isDancing,
    required this.onToggleDance,
    required this.soundEnabled,
    required this.onToggleSound,
    required this.highFiveCount,
    this.voiceEnabled = false,
    this.onToggleVoice,
    this.onFeedPowerCell,
    this.onEnterFreeFlight,
  });

  @override
  Widget build(BuildContext context) {
    final powerCellChip = _toyPill(
      icon: '🔋',
      label: 'Charge',
      active: false,
      activeColor: const Color(0xFFEAB308),
      onTap: onFeedPowerCell ?? () {},
    );

    return GlassSurface(
      borderRadius: 16,
      blurSigma: 10,
      tintColor: paintStyle.swatch,
      topOpacity: 0.72,
      bottomOpacity: 0.50,
      borderColor: Colors.white.withValues(alpha: 0.88),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // 4 Paint color swatches
          ...RobotPaint.values.map((p) {
            final selected = p == paintStyle;
            return Tooltip(
              message: 'Paint Bolts: ${p.label}',
              child: InkWell(
                onTap: () => onSelectPaint(p),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: p.swatch,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? const Color(0xFF0F172A) : Colors.white,
                      width: selected ? 2.5 : 1.5,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: p.swatch.withValues(alpha: 0.4),
                              blurRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                  child: selected
                      ? const Icon(Icons.check_rounded, size: 12, color: Colors.white)
                      : null,
                ),
              ),
            );
          }),
          // Cycle Hat
          _toyPill(
            icon: hat.emoji,
            label: hat == RobotHat.none ? 'Hat' : hat.label,
            active: hat != RobotHat.none,
            activeColor: AppColors.primary,
            onTap: onCycleHat,
          ),
          // Rocket Boosters
          _toyPill(
            icon: '🚀',
            label: 'Boost',
            active: hasBoosters,
            activeColor: const Color(0xFFF97316),
            onTap: onToggleBoosters,
          ),
          // Dance Mode
          _toyPill(
            icon: '💃',
            label: isDancing ? 'Dancing' : 'Dance',
            active: isDancing,
            activeColor: const Color(0xFFEC4899),
            onTap: onToggleDance,
          ),
          // Tap OR drag Power Cell onto Bolts!
          if (onFeedPowerCell != null)
            Tooltip(
              message: 'Tap or drag onto Bolts to supercharge!',
              child: Draggable<String>(
                data: 'power_cell',
                feedback: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF08A),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFEAB308), width: 2),
                    ),
                    child: const Text(
                      '🔋⚡',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                child: powerCellChip,
              ),
            ),
          // Free-Flight Arcade Mode
          if (onEnterFreeFlight != null)
            _toyPill(
              icon: '✈️',
              label: 'Fly',
              active: false,
              activeColor: const Color(0xFF0284C7),
              onTap: onEnterFreeFlight!,
            ),
          // High-five combo pill
          if (highFiveCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFF59E0B)),
              ),
              child: Text(
                '✋ $highFiveCount×',
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF92400E),
                ),
              ),
            ),
          // Real spoken robot voice toggle
          if (onToggleVoice != null)
            Tooltip(
              message: voiceEnabled ? 'Turn Off Bolts Voice' : 'Turn On Bolts Voice',
              child: InkWell(
                onTap: onToggleVoice,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                  decoration: BoxDecoration(
                    color: voiceEnabled ? const Color(0xFFDCFCE7) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: voiceEnabled ? AppColors.emerald : AppColors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🗣️', style: TextStyle(fontSize: 11)),
                      const SizedBox(width: 3),
                      Text(
                        voiceEnabled ? 'Voice On' : 'Voice',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: voiceEnabled ? AppColors.emerald : AppColors.textMain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Sound Effects toggle
          Tooltip(
            message: soundEnabled ? 'Mute Robot Sounds' : 'Enable Robot Sounds',
            child: InkWell(
              onTap: onToggleSound,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                decoration: BoxDecoration(
                  color: soundEnabled ? const Color(0xFFE0F2FE) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: soundEnabled ? const Color(0xFF38BDF8) : AppColors.border,
                  ),
                ),
                child: Icon(
                  soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                  size: 14,
                  color: soundEnabled ? const Color(0xFF0284C7) : AppColors.textDim,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toyPill({
    required String icon,
    required String label,
    required bool active,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: active ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? activeColor : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: active ? Colors.white : AppColors.textMain,
              ),
            ),
          ],
        ),
      ),
    );
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
      child: GlassSurface(
        borderRadius: 18,
        blurSigma: 10,
        tintColor: widget.accentColor,
        topOpacity: 0.82,
        bottomOpacity: 0.62,
        borderColor: widget.accentColor.withValues(alpha: 0.35),
        borderWidth: 1.5,
        padding: const EdgeInsets.all(12),
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
    with TickerProviderStateMixin {
  final Set<String> _addedScraps = {};
  late AnimationController _pulseController;
  late AnimationController _trickController;
  bool _turboSpin = false;

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

    _trickController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _isRunningTests ? 50 : 700),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _trickController.dispose();
    super.dispose();
  }

  void _triggerWheelie({bool honk = false}) {
    if (_addedScraps.length < 3) {
      SoundEffects.playPop();
      _trickController.forward(from: 0.0);
      widget.onReaction(
        'Tap Box, Straws & Rubber Band below (or Quick Assemble ✨) first to bring me to life!',
      );
      return;
    }
    if (honk) {
      SoundEffects.playRobotBeep();
    } else {
      SoundEffects.playBoing();
    }
    setState(() => _turboSpin = !_turboSpin);
    _trickController.forward(from: 0.0);
    widget.onReaction(
      honk
          ? 'Beep-boop! Cardboard horn honked! Straw wheel bearings spinning silky-smooth!'
          : 'Wheee! Check out that zero-rupee rubber-band wheelie hop!',
      complete: true,
    );
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
      _trickController.forward(from: 0.0);
      widget.onReaction(
        'Boom! You just built a rolling kinetic bot out of zero-cost scraps! Try Wheelie or Honk on it!',
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
    _trickController.forward(from: 0.0);
    widget.onReaction(
      'All 3 scraps locked in! Tap the arena or hit Wheelie Jump 🚀 to play with your mini bot!',
      complete: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final allReady = _addedScraps.length == 3;
    final hasBox = _addedScraps.contains('box');
    final hasStraws = _addedScraps.contains('straws');
    final hasBand = _addedScraps.contains('band');

    return GlassSurface(
      isDark: true,
      borderRadius: 20,
      blurSigma: 14,
      borderColor: allReady
          ? AppColors.emerald.withValues(alpha: 0.72)
          : Colors.white.withValues(alpha: 0.24),
      borderWidth: 1.5,
      padding: const EdgeInsets.all(16),
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
          GestureDetector(
            onTap: () => _triggerWheelie(honk: false),
            child: Container(
              height: 155,
              decoration: BoxDecoration(
                color: const Color(0xFF020617),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: AnimatedBuilder(
                  animation: Listenable.merge([_pulseController, _trickController]),
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _ScrapAssemblyPainter(
                        progress: _pulseController.value,
                        trickProgress: _trickController.value,
                        turboDirection: _turboSpin,
                        hasBox: hasBox,
                        hasStraws: hasStraws,
                        hasBand: hasBand,
                      ),
                    );
                  },
                ),
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
              if (allReady) ...[
                _toyActionChip(
                  icon: '🚀',
                  label: 'Wheelie Jump',
                  color: const Color(0xFFF59E0B),
                  onTap: () => _triggerWheelie(honk: false),
                ),
                _toyActionChip(
                  icon: '📯',
                  label: 'Honk!',
                  color: const Color(0xFF38BDF8),
                  onTap: () => _triggerWheelie(honk: true),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _toyActionChip({
    required String icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
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
  final double trickProgress;
  final bool turboDirection;
  final bool hasBox;
  final bool hasStraws;
  final bool hasBand;

  _ScrapAssemblyPainter({
    required this.progress,
    required this.trickProgress,
    required this.turboDirection,
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
    final trickHop = math.sin(trickProgress * math.pi) * 28.0;
    final driveOffset = allReady
        ? math.sin(progress * 2 * math.pi) * 28 * (turboDirection ? -1 : 1)
        : 0.0;
    final botX = cx + driveOffset;
    final bounce = (allReady ? math.sin(progress * 8 * math.pi).abs() * 2.0 : 0.0) + trickHop;
    final wheelieAngle = trickProgress > 0.01 && trickProgress < 0.99
        ? -math.sin(trickProgress * math.pi) * 0.24
        : 0.0;

    canvas.save();
    canvas.translate(botX, benchY - 14 - trickHop);
    canvas.rotate(wheelieAngle);
    canvas.translate(-botX, -(benchY - 14 - trickHop));

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
      // Tiny celebratory antenna on assembled cardboard bot
      if (allReady) {
        canvas.drawLine(
          Offset(botX, benchY - 59 - bounce),
          Offset(botX, benchY - 70 - bounce),
          Paint()
            ..color = const Color(0xFF38BDF8)
            ..strokeWidth = 2.5,
        );
        canvas.drawCircle(
          Offset(botX, benchY - 72 - bounce),
          3.2,
          Paint()..color = const Color(0xFF34D399),
        );
      }
    }

    // Straws & wheels
    if (hasStraws) {
      final wheelRot = allReady
          ? (progress * 6 * math.pi + trickProgress * 8 * math.pi)
          : 0.4;
      canvas.drawLine(
        Offset(botX - 28, benchY - 14 - trickHop * 0.4),
        Offset(botX + 28, benchY - 14 - trickHop * 0.4),
        Paint()
          ..color = const Color(0xFF38BDF8)
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
      for (final wx in [botX - 28, botX + 28]) {
        final wy = benchY - 14 - trickHop * 0.4;
        canvas.drawCircle(
          Offset(wx, wy),
          13,
          Paint()..color = const Color(0xFF1E293B),
        );
        canvas.drawCircle(
          Offset(wx, wy),
          5,
          Paint()..color = const Color(0xFFFDE68A),
        );
        for (int s = 0; s < 3; s++) {
          final a = wheelRot + s * (2 * math.pi / 3);
          canvas.drawLine(
            Offset(wx, wy),
            Offset(wx + math.cos(a) * 11, wy + math.sin(a) * 11),
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
          Offset(botX - 54, benchY - 24 - bounce * 0.5),
          4,
          Paint()..color = const Color(0xFF34D399).withValues(alpha: 0.7),
        );
        canvas.drawCircle(
          Offset(botX - 64, benchY - 30 - bounce * 0.5),
          2.5,
          Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.6),
        );
      }
    }

    // Celebratory star burst during trick/jump!
    if (trickProgress > 0.02 && trickProgress < 0.98) {
      final fade = (1.0 - trickProgress).clamp(0.0, 1.0);
      for (int i = 0; i < 6; i++) {
        final a = -math.pi * 0.9 + i * 0.36;
        final r = 36 + trickProgress * 30;
        canvas.drawCircle(
          Offset(botX + math.cos(a) * r, (benchY - 40) + math.sin(a) * r),
          3.2,
          Paint()
            ..color = (i.isEven ? const Color(0xFFFACC15) : const Color(0xFF34D399))
                .withValues(alpha: fade),
        );
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ScrapAssemblyPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trickProgress != trickProgress ||
        oldDelegate.turboDirection != turboDirection ||
        oldDelegate.hasBox != hasBox ||
        oldDelegate.hasStraws != hasStraws ||
        oldDelegate.hasBand != hasBand;
  }
}

/// Stage 2 Interactive Examples: 5 playable physics & arcade cardboard mini-games
/// with live sliders, target goals & action buttons so kids experience every mechanism first-hand.
class InteractiveMachinePlayground extends StatefulWidget {
  final int activeIndex;
  final ValueChanged<int> onSelectMachine;
  final ValueChanged<String> onBoltsComment;
  final Set<String> clearedChallenges;
  final void Function(String challengeId)? onChallengeCleared;
  final double initialRacerBest;
  final ValueChanged<double>? onRacerBestChanged;
  final ValueChanged<int>? onCatapultStreakChanged;

  const InteractiveMachinePlayground({
    super.key,
    required this.activeIndex,
    required this.onSelectMachine,
    required this.onBoltsComment,
    this.clearedChallenges = const {},
    this.onChallengeCleared,
    this.initialRacerBest = 0.0,
    this.onRacerBestChanged,
    this.onCatapultStreakChanged,
  });

  @override
  State<InteractiveMachinePlayground> createState() =>
      _InteractiveMachinePlaygroundState();
}

class _InteractiveMachinePlaygroundState
    extends State<InteractiveMachinePlayground> with SingleTickerProviderStateMixin {
  double _scissorLift = 0.45;
  double _racerWind = 3.2;
  double _clawGrip = 0.65;
  int _clawCargoIdx = 0; // 0: Cube 📦, 1: Fragile Paper Cup 🥤, 2: Space Egg 🥚
  double _rampAngle = 26.0;
  double _catapultPower = 0.64;
  int _catapultHits = 0;
  bool _catapultHitLast = false;
  late double _racerBestMeters;
  String? _lastGoalBadge;

  late AnimationController _actionController;

  static const List<({String id, String icon, String label, String goal})> _machines = [
    (id: 'scissor', icon: '✂️', label: 'Scissor Lift', goal: 'Reach Target Shelf (3.1×–4.0×)'),
    (id: 'racer', icon: '🏎️', label: 'Torque Racer', goal: 'Sweet-Spot Winds (2.8–4.5)'),
    (id: 'claw', icon: '🦾', label: 'Claw Gripper', goal: 'Gentle Lift Without Crushing (55–85%)'),
    (id: 'coaster', icon: '🎢', label: 'Gravity Coaster', goal: 'Land Marble in Bucket (22°–34°)'),
    (id: 'catapult', icon: '🎯', label: 'Catapult', goal: 'Score Basket Bullseye (50–78%)'),
  ];

  static const List<({String icon, String name})> _clawCargos = [
    (icon: '📦', name: 'Cube'),
    (icon: '🥤', name: 'Cup'),
    (icon: '🥚', name: 'Egg'),
  ];

  @override
  void initState() {
    super.initState();
    _racerBestMeters = widget.initialRacerBest;
    _actionController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _isRunningTests ? 50 : 1100),
    );
  }

  @override
  void dispose() {
    _actionController.dispose();
    super.dispose();
  }

  void _triggerAction() {
    HapticFeedback.lightImpact();
    _actionController.forward(from: 0.0);

    switch (widget.activeIndex) {
      case 0:
        final next = _scissorLift > 0.72 ? 0.25 : 0.88;
        final rescued = next >= 0.70;
        setState(() {
          _scissorLift = next;
          _lastGoalBadge = rescued ? 'RESCUED! ✓' : null;
        });
        if (rescued) {
          SoundEffects.playFanfare();
          widget.onChallengeCleared?.call('scissor');
          widget.onBoltsComment(
            'CRATE RESCUED at ${(1.0 + next * 3.0).toStringAsFixed(1)}×! 3 criss-cross cardboard stages turned 1 push into sky-high lift!',
          );
        } else {
          SoundEffects.playChime();
          widget.onBoltsComment(
            'Compressed flat! Slide Push Handle up or tap Lift 4× to reach the target shelf!',
          );
        }
        break;

      case 1:
        final overWound = _racerWind >= 4.65;
        final sweetSpot = _racerWind >= 2.8 && _racerWind <= 4.55;
        final dist = overWound ? 1.9 : (1.2 + _racerWind * 0.92);
        if (!overWound && dist > _racerBestMeters) {
          setState(() => _racerBestMeters = dist);
          widget.onRacerBestChanged?.call(dist);
        }
        if (overWound) {
          SoundEffects.playBoing();
          setState(() => _lastGoalBadge = 'BAND SPINOUT!');
          widget.onBoltsComment(
            'WHOOPS! $_racerWind winds overloaded the rubber band spinout! Aim inside 2.8–4.5 winds for maximum Sprint Range!',
          );
        } else if (sweetSpot) {
          SoundEffects.playFanfare();
          setState(() => _lastGoalBadge = 'NITRO SPRINT! ✓');
          widget.onChallengeCleared?.call('racer');
          widget.onBoltsComment(
            'TURBO SPRINT! ${dist.toStringAsFixed(1)}m launched cleanly on straw bearings (Best: ${_racerBestMeters.toStringAsFixed(1)}m)!',
          );
        } else {
          SoundEffects.playBoing();
          setState(() => _lastGoalBadge = null);
          widget.onBoltsComment(
            'Nice cruise (${dist.toStringAsFixed(1)}m)! Wind a little higher (2.8–4.5) to hit the Nitro Sprint Challenge!',
          );
        }
        break;

      case 2:
        final closing = _clawGrip <= 0.60;
        final next = closing ? 0.74 : 0.15;
        final gentleSuccess = next >= 0.52 && next <= 0.86;
        final crushed = next > 0.86 && _clawCargos[_clawCargoIdx].name != 'Cube';
        setState(() {
          _clawGrip = next;
          _lastGoalBadge = gentleSuccess ? 'GENTLE LIFT! ✓' : (crushed ? 'SQUISHED!' : null);
        });
        if (gentleSuccess) {
          SoundEffects.playFanfare();
          widget.onChallengeCleared?.call('claw');
          widget.onBoltsComment(
            'PRECISION GRIP on the ${_clawCargos[_clawCargoIdx].name}! Opposing cardboard levers hoisted cleanly without crushing!',
          );
        } else if (crushed) {
          SoundEffects.playBoing();
          widget.onBoltsComment(
            'Oops, too tight on the fragile ${_clawCargos[_clawCargoIdx].name}! Keep Trigger Pull in the green 55–85% zone!',
          );
        } else {
          SoundEffects.playChime();
          widget.onBoltsComment(
            'Released! Pulling the trigger gently clamps onto delicate cargo using pure lever physics!',
          );
        }
        break;

      case 3:
        final inBucket = _rampAngle >= 22.0 && _rampAngle <= 34.0;
        setState(() {
          _lastGoalBadge = inBucket ? 'BUCKET GOAL! ✓' : null;
        });
        if (inBucket) {
          SoundEffects.playFanfare();
          widget.onChallengeCleared?.call('coaster');
          widget.onBoltsComment(
            'BUCKET GOAL at ${_rampAngle.toInt()}°! Banked cardboard rails converted gravity right into the finish bucket!',
          );
        } else {
          SoundEffects.playBoing();
          widget.onBoltsComment(
            _rampAngle < 22.0
                ? 'Dropped at ${_rampAngle.toInt()}° — too shallow! Steepen Ramp Angle to 22°–34° to roll into the bucket!'
                : 'Dropped at ${_rampAngle.toInt()}° — flew right over the bucket! Dial Ramp Angle back between 22°–34°!',
          );
        }
        break;

      case 4:
        final isBullseye = _catapultPower >= 0.50 && _catapultPower <= 0.78;
        setState(() {
          _catapultHitLast = isBullseye;
          if (isBullseye) _catapultHits++;
          _lastGoalBadge = isBullseye ? 'BULLSEYE! ✓' : null;
        });
        if (isBullseye) {
          SoundEffects.playFanfare();
          widget.onChallengeCleared?.call('catapult');
          widget.onCatapultStreakChanged?.call(_catapultHits);
          widget.onBoltsComment(
            'BULLSEYE! Streak: $_catapultHits hit${_catapultHits == 1 ? '' : 's'}! Elastic rubber-band potential energy nailed the target!',
          );
        } else {
          SoundEffects.playBoing();
          widget.onBoltsComment(
            _catapultPower < 0.50
                ? 'So close — landed short! Slide Launch Power into the green sweet-spot (50–78%) and fire again!'
                : 'WHOOSH — overshot the basket! Ease Launch Power back a little bit and take aim!',
          );
        }
        break;
    }
  }

  String _telemetryLabel() {
    switch (widget.activeIndex) {
      case 0:
        final mult = (1.0 + _scissorLift * 3.0).toStringAsFixed(1);
        return 'Lift Height: ${mult}x';
      case 1:
        final dist = (_racerWind >= 4.65 ? 1.9 : 1.2 + _racerWind * 0.92).toStringAsFixed(1);
        final bestStr = _racerBestMeters > 0 ? ' • Best: ${_racerBestMeters.toStringAsFixed(1)}m' : '';
        return 'Sprint Range: ${dist}m$bestStr';
      case 2:
        final g = (_clawGrip * 260).round();
        return 'Pinch Force: ${g}g';
      case 3:
        final spd = (1.4 + (_rampAngle - 10) * 0.09).toStringAsFixed(1);
        return 'Exit Speed: $spd m/s';
      default:
        final pct = (_catapultPower * 100).round();
        return 'Power: $pct% • Hits: $_catapultHits';
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeIdx = widget.activeIndex;
    final clearedCount = _machines.where((m) => widget.clearedChallenges.contains(m.id)).length;
    final currentMachine = _machines[activeIdx];

    return GlassSurface(
      borderRadius: 20,
      blurSigma: 12,
      tintColor: AppColors.primary,
      borderColor: Colors.white.withValues(alpha: 0.90),
      borderWidth: 1.5,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Machine selector chips + cleared indicator dot
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(_machines.length, (i) {
              final m = _machines[i];
              final selected = i == activeIdx;
              final cleared = widget.clearedChallenges.contains(m.id);
              return InkWell(
                onTap: () {
                  SoundEffects.playPop();
                  setState(() => _lastGoalBadge = null);
                  widget.onSelectMachine(i);
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary
                        : (cleared ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(10),
                    border: cleared && !selected
                        ? Border.all(color: AppColors.emerald.withValues(alpha: 0.5))
                        : null,
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
                      if (cleared) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.check_circle_rounded,
                          size: 12,
                          color: selected ? Colors.white : AppColors.emerald,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),

          // Mini-Game Goal + Progress Strip
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🎮 ', style: TextStyle(fontSize: 12)),
                  Flexible(
                    child: Text(
                      'Goal: ${currentMachine.goal}',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: clearedCount == 5
                      ? const Color(0xFFDCFCE7)
                      : Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: clearedCount == 5 ? AppColors.emerald : AppColors.border,
                  ),
                ),
                child: Text(
                  'Cleared: $clearedCount/5 🎯',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: clearedCount == 5 ? AppColors.emerald : AppColors.textMain,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

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
                          clawCargoIdx: _clawCargoIdx,
                          rampAngle: _rampAngle,
                          catapultPower: _catapultPower,
                          catapultHit: _catapultHitLast,
                          actionProgress: _actionController.value,
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Claw cargo selector toggle on top-left when on Claw Gripper
              if (activeIdx == 2)
                Positioned(
                  top: 8,
                  left: 8,
                  child: InkWell(
                    onTap: () {
                      SoundEffects.playPop();
                      setState(() {
                        _clawCargoIdx = (_clawCargoIdx + 1) % _clawCargos.length;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        'Target: ${_clawCargos[_clawCargoIdx].icon} ${_clawCargos[_clawCargoIdx].name} ↻',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMain,
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 8,
                right: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
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
                    if (_lastGoalBadge != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _lastGoalBadge!.contains('✓')
                              ? AppColors.emerald
                              : AppColors.amber,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _lastGoalBadge!,
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
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
        actionLabel = _scissorLift > 0.72 ? 'Lower ⬇' : 'Lift 4× ⬆';
        onChanged = (v) => setState(() => _scissorLift = v);
        break;
      case 1:
        sliderTitle = 'Band Winds';
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
      case 3:
        sliderTitle = 'Ramp Angle';
        value = _rampAngle;
        min = 12.0;
        max = 45.0;
        actionLabel = 'Drop Marble 🔮';
        onChanged = (v) => setState(() => _rampAngle = v);
        break;
      default:
        sliderTitle = 'Launch Power';
        value = _catapultPower;
        min = 0.25;
        max = 1.0;
        actionLabel = 'Launch Block 🎯';
        onChanged = (v) => setState(() => _catapultPower = v);
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
              Flexible(
                flex: 0,
                child: Text(
                  sliderTitle,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMain,
                  ),
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
  final int clawCargoIdx;
  final double rampAngle;
  final double catapultPower;
  final bool catapultHit;
  final double actionProgress;

  _InteractiveExamplePainter({
    required this.machineIndex,
    required this.scissorLift,
    required this.racerWind,
    required this.clawGrip,
    required this.clawCargoIdx,
    required this.rampAngle,
    required this.catapultPower,
    required this.catapultHit,
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
      case 3:
        _paintCoaster(canvas, w, h, groundY);
        break;
      default:
        _paintCatapult(canvas, w, h, groundY);
    }
  }

  void _paintScissor(Canvas canvas, double w, double groundY) {
    final cx = w * 0.44;
    final liftPx = 22.0 + scissorLift * 84.0;
    final halfSpan = 48.0 - scissorLift * 18.0;

    // Rescue Shelf Target Zone on right
    final shelfY = groundY - (22.0 + 0.78 * 84.0);
    final inZone = scissorLift >= 0.70;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + 56, shelfY - 4, 62, 8),
        const Radius.circular(3),
      ),
      Paint()..color = inZone ? AppColors.emerald : const Color(0xFF94A3B8),
    );
    canvas.drawCircle(
      Offset(cx + 87, shelfY - 14),
      6,
      Paint()..color = inZone ? AppColors.emerald : AppColors.amber,
    );

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

    // Payload platform + rescue crate
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
      Paint()..color = inZone ? AppColors.emerald : AppColors.amber,
    );
  }

  void _paintRacer(Canvas canvas, double w, double groundY) {
    final overWound = racerWind >= 4.65;
    final sweetSpot = racerWind >= 2.8 && racerWind <= 4.55;
    final travel = overWound
        ? math.sin(actionProgress * 6 * math.pi) * 14.0
        : math.sin(actionProgress * math.pi) * (w * 0.30) * (racerWind / 5.0);
    final rx = (w * 0.34) + travel;

    // Sweet-spot finish flag on right!
    final flagX = w * 0.80;
    canvas.drawLine(
      Offset(flagX, groundY),
      Offset(flagX, groundY - 48),
      Paint()
        ..color = sweetSpot ? AppColors.emerald : const Color(0xFF64748B)
        ..strokeWidth = 3,
    );
    canvas.drawRect(
      Rect.fromLTWH(flagX, groundY - 48, 22, 13),
      Paint()..color = sweetSpot ? AppColors.emerald : AppColors.amber,
    );

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
    canvas.drawPath(
      spoiler,
      Paint()..color = overWound ? AppColors.rose : AppColors.primary,
    );

    // Rubber band stretched on chassis (turns rose if over-wound!)
    final bandStretch = 14 + racerWind * 4.5;
    canvas.drawLine(
      Offset(rx - 14, groundY - 21),
      Offset(rx - 14 + bandStretch, groundY - 21),
      Paint()
        ..color = overWound ? AppColors.rose : AppColors.amber
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
    final gentleLift = clawGrip >= 0.52 && clawGrip <= 0.86;
    final crushed = clawGrip > 0.86 && clawCargoIdx != 0;
    final hoistLift = gentleLift ? math.sin(actionProgress * math.pi) * 20.0 : 0.0;
    final baseBottom = groundY - hoistLift;

    // Handle shaft
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 10, baseBottom - 48, 20, 48),
        const Radius.circular(5),
      ),
      Paint()..color = const Color(0xFF78350F),
    );

    // Left jaw
    final left = Path()
      ..moveTo(cx - 6, baseBottom - 48)
      ..lineTo(cx - 26 - openAmt, baseBottom - 94)
      ..lineTo(cx - 12 - openAmt * 0.35, baseBottom - 114)
      ..lineTo(cx - 6 - openAmt * 0.2, baseBottom - 110)
      ..close();
    canvas.drawPath(left, Paint()..color = const Color(0xFFD97706));

    // Right jaw
    final right = Path()
      ..moveTo(cx + 6, baseBottom - 48)
      ..lineTo(cx + 26 + openAmt, baseBottom - 94)
      ..lineTo(cx + 12 + openAmt * 0.35, baseBottom - 114)
      ..lineTo(cx + 6 + openAmt * 0.2, baseBottom - 110)
      ..close();
    canvas.drawPath(right, Paint()..color = const Color(0xFFD97706));

    // Pivot pin
    canvas.drawCircle(
      Offset(cx, baseBottom - 48),
      5,
      Paint()..color = const Color(0xFFFDE68A),
    );

    // Target payload shape (Cube / Paper Cup / Space Egg), squishes if crushed!
    final pinchWidth = crushed ? 13.0 : 24.0;
    final cargoColor = crushed
        ? AppColors.rose
        : (gentleLift ? AppColors.emerald : AppColors.primary);
    if (clawCargoIdx == 2) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, baseBottom - 96),
          width: pinchWidth * 0.9,
          height: 28,
        ),
        Paint()..color = cargoColor,
      );
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, baseBottom - 96),
            width: pinchWidth,
            height: 24,
          ),
          Radius.circular(clawCargoIdx == 1 ? 8 : 5),
        ),
        Paint()..color = cargoColor,
      );
    }
  }

  void _paintCoaster(Canvas canvas, double w, double h, double groundY) {
    final inBucketRange = rampAngle >= 22.0 && rampAngle <= 34.0;
    final startY = groundY - 36 - (rampAngle * 1.6);
    final p0 = Offset(32, startY);
    final p1 = Offset(w * 0.36, groundY - 6);
    final p2 = Offset(w * 0.62, groundY - 46);
    final p3 = Offset(w - 68, groundY - 12);

    // Finish Catch Bucket on right!
    final bucketCenter = Offset(w - 38, groundY - 12);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: bucketCenter, width: 34, height: 22),
        const Radius.circular(6),
      ),
      Paint()
        ..color = inBucketRange && actionProgress > 0.7
            ? AppColors.emerald
            : const Color(0xFF0F172A),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(bucketCenter.dx, bucketCenter.dy - 11),
          width: 38,
          height: 5,
        ),
        const Radius.circular(2.5),
      ),
      Paint()..color = const Color(0xFF38BDF8),
    );

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

    // Marble along track, landing inside bucket if 22°–34°
    final t = actionProgress == 0 ? 0.08 : actionProgress;
    Offset ballPos = p0;
    if (t <= 0.82) {
      final metrics = path.computeMetrics().toList();
      if (metrics.isNotEmpty) {
        final tangent = metrics.first.getTangentForOffset(
          metrics.first.length * (t / 0.82).clamp(0.0, 1.0),
        );
        if (tangent != null) ballPos = tangent.position;
      }
    } else {
      final u = ((t - 0.82) / 0.18).clamp(0.0, 1.0);
      final target = inBucketRange
          ? bucketCenter - const Offset(0, 6)
          : (rampAngle < 22.0
              ? Offset(p3.dx + 6, groundY - 8)
              : Offset(w - 10, groundY - 28));
      ballPos = Offset.lerp(p3, target, u)! - Offset(0, math.sin(u * math.pi) * 14);
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

  void _paintCatapult(Canvas canvas, double w, double h, double groundY) {
    final pivot = Offset(48, groundY - 24);
    final basketX = w * 0.77;
    final basketY = groundY - 14;

    // Target Basket hoop on right side
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(basketX, basketY), width: 48, height: 22),
        const Radius.circular(6),
      ),
      Paint()
        ..color = catapultHit && actionProgress > 0.7
            ? AppColors.emerald
            : const Color(0xFF0F172A),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(basketX, basketY - 12), width: 54, height: 6),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF38BDF8),
    );

    // Catapult fulcrum triangle
    final base = Path()
      ..moveTo(pivot.dx - 18, groundY)
      ..lineTo(pivot.dx, pivot.dy)
      ..lineTo(pivot.dx + 18, groundY)
      ..close();
    canvas.drawPath(base, Paint()..color = const Color(0xFF78350F));

    // Spoon arm swings smoothly up on launch!
    final armSwing = actionProgress > 0.01 ? math.min(1.0, actionProgress * 3.0) : 0.0;
    final armAngle = -0.35 - armSwing * 1.15;
    final cupX = pivot.dx + math.cos(armAngle) * 34;
    final cupY = pivot.dy + math.sin(armAngle) * 34;

    canvas.drawLine(
      Offset(pivot.dx - math.cos(armAngle) * 14, pivot.dy - math.sin(armAngle) * 14),
      Offset(cupX, cupY),
      Paint()
        ..color = const Color(0xFFD97706)
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(pivot, 4.5, Paint()..color = const Color(0xFFFDE68A));

    // Projectile parabolic arc proportional to catapultPower
    final landingX = (w * 0.25) + catapultPower * (w * 0.74);
    Offset ballPos;
    if (actionProgress == 0.0) {
      ballPos = Offset(cupX, cupY - 8);
    } else {
      final t = actionProgress.clamp(0.0, 1.0);
      final bx = cupX + (landingX - cupX) * t;
      final peakLift = 52 + catapultPower * 54;
      final by = (cupY - 8) * (1 - t) + (groundY - 10) * t - math.sin(t * math.pi) * peakLift;
      ballPos = Offset(bx, by);
    }

    canvas.drawCircle(ballPos, 9, Paint()..color = AppColors.amber);
    canvas.drawCircle(
      Offset(ballPos.dx - 2.5, ballPos.dy - 2.5),
      2.6,
      Paint()..color = Colors.white,
    );

    // Bullseye celebration stars if landed cleanly!
    if (catapultHit && actionProgress > 0.72) {
      for (int i = 0; i < 6; i++) {
        final a = -math.pi * 0.9 + i * 0.36;
        final sx = basketX + math.cos(a) * 28;
        final sy = basketY - 22 + math.sin(a) * 20;
        canvas.drawCircle(
          Offset(sx, sy),
          3.2,
          Paint()..color = i.isEven ? AppColors.emerald : const Color(0xFFFACC15),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _InteractiveExamplePainter oldDelegate) {
    return oldDelegate.machineIndex != machineIndex ||
        oldDelegate.scissorLift != scissorLift ||
        oldDelegate.racerWind != racerWind ||
        oldDelegate.clawGrip != clawGrip ||
        oldDelegate.clawCargoIdx != clawCargoIdx ||
        oldDelegate.rampAngle != rampAngle ||
        oldDelegate.catapultPower != catapultPower ||
        oldDelegate.catapultHit != catapultHit ||
        oldDelegate.actionProgress != actionProgress;
  }
}
