// Interactive Cardboard Machine Inventor Sandbox & Live Physics Test Track
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/sound_effects.dart';
import '../theme/app_theme.dart';
import 'frosted_glass_background.dart';

bool get _isRunningTests =>
    WidgetsBinding.instance.runtimeType.toString().contains('Test');

enum SandboxBody { box, tube, truss }
enum SandboxEngine { bands, balloon, weight }
enum SandboxWheel { straws, caps, legs }
enum SandboxGadget { claw, catapult, plow }
enum SandboxTrack { drag, ramp, smash }

extension SandboxBodyX on SandboxBody {
  String get label {
    switch (this) {
      case SandboxBody.box:
        return '📦 Box';
      case SandboxBody.tube:
        return '🧻 Tube';
      case SandboxBody.truss:
        return '🔺 Truss';
    }
  }
}

extension SandboxEngineX on SandboxEngine {
  String get label {
    switch (this) {
      case SandboxEngine.bands:
        return '🟡 Bands';
      case SandboxEngine.balloon:
        return '🎈 Balloon';
      case SandboxEngine.weight:
        return '⚖️ Weight';
    }
  }
}

extension SandboxWheelX on SandboxWheel {
  String get label {
    switch (this) {
      case SandboxWheel.straws:
        return '🥤 Straws';
      case SandboxWheel.caps:
        return '🍾 Caps';
      case SandboxWheel.legs:
        return '🕷️ Hex Legs';
    }
  }
}

extension SandboxGadgetX on SandboxGadget {
  String get label {
    switch (this) {
      case SandboxGadget.claw:
        return '✂️ Claw';
      case SandboxGadget.catapult:
        return '🎯 Catapult';
      case SandboxGadget.plow:
        return '🛡️ Plow';
    }
  }
}

extension SandboxTrackX on SandboxTrack {
  String get label {
    switch (this) {
      case SandboxTrack.drag:
        return '🏁 Speed Drag';
      case SandboxTrack.ramp:
        return '⛰️ Ramp Jump';
      case SandboxTrack.smash:
        return '🧱 Crate Smash';
    }
  }
}

class SandboxPerformance {
  final double speedMs;
  final double distanceM;
  final int efficiencyPct;
  final int stars;
  final String verdict;

  const SandboxPerformance({
    required this.speedMs,
    required this.distanceM,
    required this.efficiencyPct,
    required this.stars,
    required this.verdict,
  });
}

class InventorSandboxWidget extends StatefulWidget {
  final int bestStars;
  final void Function(String boltsComment, int stars, bool earnedXp) onTestResult;

  const InventorSandboxWidget({
    super.key,
    this.bestStars = 0,
    required this.onTestResult,
  });

  @override
  State<InventorSandboxWidget> createState() => _InventorSandboxWidgetState();
}

class _InventorSandboxWidgetState extends State<InventorSandboxWidget>
    with SingleTickerProviderStateMixin {
  SandboxBody _body = SandboxBody.box;
  SandboxEngine _engine = SandboxEngine.bands;
  SandboxWheel _wheel = SandboxWheel.straws;
  SandboxGadget _gadget = SandboxGadget.plow;
  SandboxTrack _track = SandboxTrack.drag;

  late AnimationController _runController;
  final math.Random _rng = math.Random(7);
  SandboxPerformance? _lastResult;
  bool _hasLaunched = false;

  @override
  void initState() {
    super.initState();
    _runController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _isRunningTests ? 70 : 1550),
    );
  }

  @override
  void dispose() {
    _runController.dispose();
    super.dispose();
  }

  SandboxPerformance _evaluateBuild() {
    double speed = 2.4;
    double distance = 3.2;
    int eff = 62;

    if (_body == SandboxBody.tube) {
      speed += 0.9;
      eff += 5;
    }
    if (_body == SandboxBody.truss) eff += 12;
    if (_body == SandboxBody.box) distance += 0.6;

    if (_engine == SandboxEngine.balloon) {
      speed += 1.4;
      distance += 1.2;
    } else if (_engine == SandboxEngine.bands) {
      speed += 1.0;
      eff += 10;
    } else {
      distance += 0.9;
      eff += 8;
    }

    if (_wheel == SandboxWheel.straws) {
      speed += 0.8;
      distance += 1.0;
    } else if (_wheel == SandboxWheel.caps) {
      eff += 14;
      distance += 0.5;
    } else {
      eff += 16;
    }

    // Track synergy bonuses
    late String verdict;
    if (_track == SandboxTrack.drag) {
      if (_body == SandboxBody.tube || _wheel == SandboxWheel.straws) {
        speed += 1.1;
        eff += 12;
      }
      if (_engine == SandboxEngine.balloon && _wheel == SandboxWheel.straws) {
        eff += 12;
        verdict =
            'SUPERSONIC! Aero Tube + Straw Rollers glided ${distance.toStringAsFixed(1)}m with near-zero friction!';
      } else {
        verdict =
            'Clocked ${speed.toStringAsFixed(1)} m/s across the Speed Drag strip using ${_engine.label}!';
      }
    } else if (_track == SandboxTrack.ramp) {
      if (_wheel == SandboxWheel.caps || _engine == SandboxEngine.balloon) {
        distance += 1.1;
        eff += 14;
      }
      if (_gadget == SandboxGadget.catapult) {
        eff += 10;
        verdict =
            'AIRBORNE BULLSEYE! Ramp boost + mid-air Catapult fired straight through the star ring!';
      } else {
        verdict =
            'Soared off the 28° Ramp for ${distance.toStringAsFixed(1)}m at ${speed.toStringAsFixed(1)} m/s!';
      }
    } else {
      if (_gadget == SandboxGadget.plow || _gadget == SandboxGadget.claw) {
        eff += 18;
      }
      if (_wheel == SandboxWheel.caps || _wheel == SandboxWheel.legs) {
        eff += 10;
      }
      verdict = _gadget == SandboxGadget.plow
          ? 'CRATE SMASH VICTORY! Reinforced Plow Wedge blasted every cardboard block cleanly!'
          : (_gadget == SandboxGadget.claw
              ? 'SCISSOR SNATCH! Your claw lunged out mid-sprint and rescued the target!'
              : 'DIRECT HIT! Catapult shelled the crate stack from across the workbench!');
    }

    final clampedEff = eff.clamp(45, 99);
    final stars = clampedEff >= 86 ? 3 : (clampedEff >= 68 ? 2 : 1);
    return SandboxPerformance(
      speedMs: speed,
      distanceM: distance,
      efficiencyPct: clampedEff,
      stars: stars,
      verdict: verdict,
    );
  }

  void _applyPreset({
    required SandboxBody body,
    required SandboxEngine engine,
    required SandboxWheel wheel,
    required SandboxGadget gadget,
    SandboxTrack? track,
    required String comment,
  }) {
    HapticFeedback.selectionClick();
    SoundEffects.playPop();
    setState(() {
      _body = body;
      _engine = engine;
      _wheel = wheel;
      _gadget = gadget;
      if (track != null) _track = track;
      _lastResult = null;
      _hasLaunched = false;
      _runController.value = 0.0;
    });
    widget.onTestResult(comment, 0, false);
  }

  void _randomizeWild() {
    HapticFeedback.mediumImpact();
    SoundEffects.playBoing();
    setState(() {
      _body = SandboxBody.values[_rng.nextInt(SandboxBody.values.length)];
      _engine = SandboxEngine.values[_rng.nextInt(SandboxEngine.values.length)];
      _wheel = SandboxWheel.values[_rng.nextInt(SandboxWheel.values.length)];
      _gadget = SandboxGadget.values[_rng.nextInt(SandboxGadget.values.length)];
      _lastResult = null;
      _hasLaunched = false;
      _runController.value = 0.0;
    });
    widget.onTestResult(
      'Wild Mix generated: ${_body.label} + ${_engine.label} + ${_wheel.label} + ${_gadget.label}! Hit Test-Drive Build!',
      0,
      false,
    );
  }

  void _launchBuild() {
    HapticFeedback.mediumImpact();
    final res = _evaluateBuild();
    if (res.stars == 3) {
      SoundEffects.playFanfare();
    } else {
      SoundEffects.playBoostFlight();
    }
    setState(() {
      _hasLaunched = true;
      _lastResult = res;
    });
    _runController.forward(from: 0.0);
    widget.onTestResult(
      '${res.stars}⭐ (${res.efficiencyPct}% eff): ${res.verdict}',
      res.stars,
      res.stars >= 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    final res = _lastResult;
    final shownStars = math.max(widget.bestStars, res?.stars ?? 0);

    return GlassSurface(
      borderRadius: 20,
      blurSigma: 12,
      tintColor: const Color(0xFF0EA5E9),
      borderColor: Colors.white.withValues(alpha: 0.90),
      borderWidth: 1.5,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header + Best Star Rating + Randomizer
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🛠️ ', style: TextStyle(fontSize: 13)),
                  Text(
                    'INVENTOR SANDBOX',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.9,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (shownStars > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFF59E0B)),
                      ),
                      child: Text(
                        'Best: ${'⭐' * shownStars}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ),
                  InkWell(
                    onTap: _randomizeWild,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F3FF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.35),
                        ),
                      ),
                      child: const Text(
                        '🎲 Wild Mix',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Quick Presets Row
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _presetChip(
                '🏎️ Dragster',
                () => _applyPreset(
                  body: SandboxBody.tube,
                  engine: SandboxEngine.bands,
                  wheel: SandboxWheel.straws,
                  gadget: SandboxGadget.plow,
                  track: SandboxTrack.drag,
                  comment:
                      'Dragster blueprint loaded: Tube + Twin Bands + Straw Rollers!',
                ),
              ),
              _presetChip(
                '🕷️ Walker',
                () => _applyPreset(
                  body: SandboxBody.truss,
                  engine: SandboxEngine.weight,
                  wheel: SandboxWheel.legs,
                  gadget: SandboxGadget.claw,
                  track: SandboxTrack.smash,
                  comment:
                      'Hex Walker loaded: Truss Frame + 6 Cardboard Strider Legs + Claw!',
                ),
              ),
              _presetChip(
                '🎈 Balloon Jet',
                () => _applyPreset(
                  body: SandboxBody.tube,
                  engine: SandboxEngine.balloon,
                  wheel: SandboxWheel.straws,
                  gadget: SandboxGadget.catapult,
                  track: SandboxTrack.ramp,
                  comment:
                      'Balloon Jet loaded: Thrust Engine + Ramp Jump Trajectory!',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Live Test Arena Canvas
          Stack(
            children: [
              Container(
                height: 174,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: AnimatedBuilder(
                    animation: _runController,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: _SandboxArenaPainter(
                          body: _body,
                          engine: _engine,
                          wheel: _wheel,
                          gadget: _gadget,
                          track: _track,
                          progress: _hasLaunched ? _runController.value : 0.0,
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF020617).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    res == null
                        ? '${_track.label} • Ready'
                        : '${res.speedMs.toStringAsFixed(1)} m/s • ${res.distanceM.toStringAsFixed(1)}m • ${res.efficiencyPct}%',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF38BDF8),
                    ),
                  ),
                ),
              ),
              if (res != null)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: res.stars >= 2
                          ? AppColors.emerald
                          : AppColors.amber,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${'⭐' * res.stars} ${res.stars >= 2 ? '+20 XP' : 'Try Tuning!'}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Track Selector Strip
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: SandboxTrack.values.map((t) {
              final sel = _track == t;
              return _selectPill(
                t.label,
                sel,
                activeColor: const Color(0xFF0284C7),
                onTap: () {
                  HapticFeedback.selectionClick();
                  SoundEffects.playPop();
                  setState(() {
                    _track = t;
                    _hasLaunched = false;
                    _lastResult = null;
                    _runController.value = 0.0;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 8),

          // 4 Modular Part Pickers
          _partGroup<SandboxBody>(
            'BODY',
            SandboxBody.values,
            _body,
            (b) => b.label,
            (b) => _selectPart(() => _body = b),
          ),
          _partGroup<SandboxEngine>(
            'MOTOR',
            SandboxEngine.values,
            _engine,
            (e) => e.label,
            (e) => _selectPart(() => _engine = e),
          ),
          _partGroup<SandboxWheel>(
            'MOVE',
            SandboxWheel.values,
            _wheel,
            (w) => w.label,
            (w) => _selectPart(() => _wheel = w),
          ),
          _partGroup<SandboxGadget>(
            'GADGET',
            SandboxGadget.values,
            _gadget,
            (g) => g.label,
            (g) => _selectPart(() => _gadget = g),
          ),
          const SizedBox(height: 6),

          ElevatedButton.icon(
            onPressed: _launchBuild,
            icon: const Icon(Icons.play_arrow_rounded, size: 18),
            label: const Text(
              'Test-Drive Build 🚀',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emerald,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectPart(VoidCallback update) {
    HapticFeedback.selectionClick();
    SoundEffects.playPop();
    setState(() {
      update();
      _hasLaunched = false;
      _lastResult = null;
      _runController.value = 0.0;
    });
  }

  Widget _presetChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(8),
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

  Widget _partGroup<T>(
    String label,
    List<T> items,
    T current,
    String Function(T) labelOf,
    ValueChanged<T> onPick,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 5,
        runSpacing: 5,
        children: [
          SizedBox(
            width: 50,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                color: AppColors.textDim,
                letterSpacing: 0.6,
              ),
            ),
          ),
          ...items.map(
            (item) => _selectPill(
              labelOf(item),
              item == current,
              activeColor: AppColors.primary,
              onTap: () => onPick(item),
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectPill(
    String label,
    bool selected, {
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? activeColor : Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: selected ? activeColor : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color: selected ? Colors.white : AppColors.textMain,
          ),
        ),
      ),
    );
  }
}

class _SandboxArenaPainter extends CustomPainter {
  final SandboxBody body;
  final SandboxEngine engine;
  final SandboxWheel wheel;
  final SandboxGadget gadget;
  final SandboxTrack track;
  final double progress;

  _SandboxArenaPainter({
    required this.body,
    required this.engine,
    required this.wheel,
    required this.gadget,
    required this.track,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final groundY = h - 24.0;

    // Dark blueprint grid
    final gridPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.11)
      ..strokeWidth = 1;
    for (double x = 0; x < w; x += 22) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }
    for (double y = 0; y < h; y += 22) {
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // Track Floor
    canvas.drawLine(
      Offset(12, groundY),
      Offset(w - 12, groundY),
      Paint()
        ..color = const Color(0xFF64748B)
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round,
    );

    // Track-specific scenery / obstacles
    final goalX = w * 0.82;
    if (track == SandboxTrack.drag) {
      for (int i = 1; i <= 5; i++) {
        final mx = 46 + (w - 84) * (i / 5.0);
        canvas.drawLine(
          Offset(mx, groundY),
          Offset(mx, groundY + 6),
          Paint()
            ..color = const Color(0xFF38BDF8)
            ..strokeWidth = 1.8,
        );
      }
      // Checker Flag
      canvas.drawLine(
        Offset(goalX, groundY),
        Offset(goalX, groundY - 56),
        Paint()
          ..color = Colors.white70
          ..strokeWidth = 2.5,
      );
      canvas.drawRect(
        Rect.fromLTWH(goalX, groundY - 56, 22, 14),
        Paint()..color = progress > 0.72 ? AppColors.emerald : AppColors.amber,
      );
    } else if (track == SandboxTrack.ramp) {
      final rampStart = w * 0.36;
      final rampEnd = w * 0.56;
      final rampTopY = groundY - 34;
      final rampPath = Path()
        ..moveTo(rampStart, groundY)
        ..lineTo(rampEnd, rampTopY)
        ..lineTo(rampEnd, groundY)
        ..close();
      canvas.drawPath(rampPath, Paint()..color = const Color(0xFFB45309));
      canvas.drawLine(
        Offset(rampStart, groundY),
        Offset(rampEnd, rampTopY),
        Paint()
          ..color = const Color(0xFFFDE68A)
          ..strokeWidth = 3,
      );
      // Aerial hoop at peak!
      canvas.drawCircle(
        Offset(w * 0.70, groundY - 76),
        16,
        Paint()
          ..color = progress > 0.68 ? AppColors.emerald : const Color(0xFFFACC15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.2,
      );
    } else {
      // Crate Smash Stack!
      final scattered = progress > 0.68 ? ((progress - 0.68) / 0.32) : 0.0;
      for (int c = 0; c < 3; c++) {
        final dx = c == 2 ? scattered * 18 : (c == 1 ? scattered * 28 : 0.0);
        final dy = c == 2 ? scattered * 22 : (c == 1 ? scattered * 8 : 0.0);
        canvas.save();
        canvas.translate(goalX + dx, groundY - 12 - c * 22 + dy);
        canvas.rotate(scattered * (c.isEven ? 0.6 : -0.8));
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-12, -11, 24, 22),
            const Radius.circular(3),
          ),
          Paint()..color = c == 2 ? AppColors.emerald : const Color(0xFFD97706),
        );
        canvas.restore();
      }
    }

    // Machine kinematics along chosen track
    final t = progress;
    final startX = 56.0;
    final maxX = w * 0.80;
    final mx = startX + (maxX - startX) * Curves.easeInOut.transform(t);
    double lift = 0.0;
    double pitch = 0.0;

    if (track == SandboxTrack.ramp && t > 0.32) {
      if (t < 0.56) {
        final u = (t - 0.32) / 0.24;
        lift = u * 34.0;
        pitch = -0.34;
      } else {
        final u = (t - 0.56) / 0.44;
        lift = math.sin((1.0 - u) * math.pi * 0.8) * 58.0;
        pitch = -0.25 + u * 0.42;
      }
    } else if (wheel == SandboxWheel.legs && t > 0.01 && t < 0.99) {
      lift = math.sin(t * 16 * math.pi).abs() * 4.5;
    }

    canvas.save();
    canvas.translate(mx, groundY - lift);
    canvas.rotate(pitch);

    // 1. Wheels / Hex Legs
    if (wheel == SandboxWheel.legs) {
      for (int i = -1; i <= 1; i++) {
        final phase = t * 14 * math.pi + i * 2.1;
        final footX = i * 20.0 + math.cos(phase) * 7.0;
        final footY = -math.max(0.0, math.sin(phase) * 8.0);
        canvas.drawLine(
          Offset(i * 14.0, -20),
          Offset(footX, footY),
          Paint()
            ..color = const Color(0xFF38BDF8)
            ..strokeWidth = 3.5
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawCircle(
          Offset(footX, footY),
          3.2,
          Paint()..color = const Color(0xFFFACC15),
        );
      }
    } else {
      final isCap = wheel == SandboxWheel.caps;
      final r = isCap ? 13.5 : 11.5;
      final rot = t * 16 * math.pi;
      for (final wx in [-24.0, 24.0]) {
        canvas.drawCircle(
          Offset(wx, -r),
          r,
          Paint()
            ..color = isCap ? const Color(0xFF059669) : const Color(0xFF1E293B),
        );
        canvas.drawCircle(
          Offset(wx, -r),
          r * 0.45,
          Paint()..color = const Color(0xFFFDE68A),
        );
        for (int s = 0; s < 3; s++) {
          final a = rot + s * (math.pi * 2 / 3);
          canvas.drawLine(
            Offset(wx, -r),
            Offset(wx + math.cos(a) * (r - 2), -r + math.sin(a) * (r - 2)),
            Paint()
              ..color = Colors.white70
              ..strokeWidth = 1.6,
          );
        }
      }
    }

    // 2. Body Chassis
    final bodyBottom = -16.0;
    if (body == SandboxBody.box) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-36, bodyBottom - 28, 72, 28),
          const Radius.circular(6),
        ),
        Paint()..color = const Color(0xFFD97706),
      );
      canvas.drawLine(
        Offset(-30, bodyBottom - 14),
        Offset(30, bodyBottom - 14),
        Paint()
          ..color = const Color(0xFFFDE68A).withValues(alpha: 0.45)
          ..strokeWidth = 2,
      );
    } else if (body == SandboxBody.tube) {
      final tubePath = Path()
        ..moveTo(-36, bodyBottom - 26)
        ..lineTo(24, bodyBottom - 26)
        ..lineTo(44, bodyBottom - 13)
        ..lineTo(24, bodyBottom)
        ..lineTo(-36, bodyBottom)
        ..close();
      canvas.drawPath(tubePath, Paint()..color = const Color(0xFF2563EB));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-20, bodyBottom - 22, 34, 8),
          const Radius.circular(4),
        ),
        Paint()..color = const Color(0xFF93C5FD),
      );
    } else {
      final truss = Paint()
        ..color = const Color(0xFFF59E0B)
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(-34, bodyBottom), Offset(34, bodyBottom), truss);
      canvas.drawLine(Offset(-34, bodyBottom), Offset(0, bodyBottom - 30), truss);
      canvas.drawLine(Offset(0, bodyBottom - 30), Offset(34, bodyBottom), truss);
      canvas.drawLine(Offset(-16, bodyBottom - 15), Offset(16, bodyBottom - 15), truss);
    }

    // 3. Engine Motor
    if (engine == SandboxEngine.bands) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-22, bodyBottom - 35, 44, 7),
          const Radius.circular(3.5),
        ),
        Paint()..color = const Color(0xFFFACC15),
      );
    } else if (engine == SandboxEngine.balloon) {
      final bRadius = 11.0 + (1.0 - t) * 7.0;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(-40 - bRadius * 0.5, bodyBottom - 28),
          width: bRadius * 2.1,
          height: bRadius * 1.45,
        ),
        Paint()..color = const Color(0xFFEC4899),
      );
      if (t > 0.02 && t < 0.96) {
        for (int p = 0; p < 3; p++) {
          canvas.drawCircle(
            Offset(-56 - p * 12.0, bodyBottom - 24 + (p.isEven ? -4 : 4)),
            3.5 - p * 0.6,
            Paint()..color = Colors.white54,
          );
        }
      }
    } else {
      // Gravity Weight Tower
      canvas.drawLine(
        Offset(-6, bodyBottom - 26),
        Offset(-6, bodyBottom - 54),
        Paint()
          ..color = const Color(0xFF94A3B8)
          ..strokeWidth = 3.5,
      );
      final dropY = (bodyBottom - 50) + t * 22.0;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(-6, dropY), width: 16, height: 12),
          const Radius.circular(3),
        ),
        Paint()..color = const Color(0xFFF59E0B),
      );
    }

    // 4. Special Gadget
    if (gadget == SandboxGadget.plow) {
      final wedge = Path()
        ..moveTo(32, bodyBottom + 6)
        ..lineTo(50, bodyBottom + 6)
        ..lineTo(32, bodyBottom - 22)
        ..close();
      canvas.drawPath(wedge, Paint()..color = const Color(0xFF38BDF8));
    } else if (gadget == SandboxGadget.claw) {
      final reach = 14.0 + math.sin(t * math.pi) * 24.0;
      canvas.drawLine(
        Offset(24, bodyBottom - 14),
        Offset(24 + reach, bodyBottom - 24),
        Paint()
          ..color = const Color(0xFF34D399)
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawArc(
        Rect.fromCircle(center: Offset(28 + reach, bodyBottom - 24), radius: 8),
        0.5,
        5.0,
        false,
        Paint()
          ..color = const Color(0xFFFACC15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    } else {
      // Mini Catapult + Launched Shot!
      final swing = t > 0.2 ? math.min(1.0, (t - 0.2) * 3.0) : 0.0;
      final tipX = math.cos(-0.6 - swing * 1.1) * 24;
      final tipY = bodyBottom - 26 + math.sin(-0.6 - swing * 1.1) * 24;
      canvas.drawLine(
        Offset(0, bodyBottom - 26),
        Offset(tipX, tipY),
        Paint()
          ..color = const Color(0xFFF59E0B)
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
      if (t > 0.24) {
        final u = ((t - 0.24) / 0.76).clamp(0.0, 1.0);
        canvas.drawCircle(
          Offset(tipX + u * 64, tipY - math.sin(u * math.pi) * 44),
          5.5,
          Paint()..color = const Color(0xFFFACC15),
        );
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SandboxArenaPainter oldDelegate) {
    return oldDelegate.body != body ||
        oldDelegate.engine != engine ||
        oldDelegate.wheel != wheel ||
        oldDelegate.gadget != gadget ||
        oldDelegate.track != track ||
        oldDelegate.progress != progress;
  }
}
