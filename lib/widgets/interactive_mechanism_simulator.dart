// Interactive STEM Mechanism Simulator & Physics Playground for MakerQuest Students
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/project.dart';
import '../theme/app_theme.dart';
import '../services/sound_effects.dart';
import 'frosted_glass_background.dart';

class InteractiveMechanismSimulator extends StatefulWidget {
  final Project project;

  const InteractiveMechanismSimulator({
    super.key,
    required this.project,
  });

  @override
  State<InteractiveMechanismSimulator> createState() => _InteractiveMechanismSimulatorState();
}

class _InteractiveMechanismSimulatorState extends State<InteractiveMechanismSimulator>
    with SingleTickerProviderStateMixin {
  // Scissor lift state
  double _scissorSqueeze = 0.5; // 0.0 to 1.0
  String _scissorCargo = '🪙 Penny';

  // Test cart state (Ch. 3)
  bool _strawBearing = true;
  bool _cardboardWashers = true;
  double _wheelOffset = 0.0; // 0.0 = centered, 1.0 = heavy wobble
  double _cartRollProgress = 0.0;
  bool _cartRolling = false;

  // Marble coaster state
  double _rampHeight = 60.0; // cm
  bool _bankedCurve = true;
  bool _marbleRolling = false;

  // Pulley crane state
  int _pulleyCount = 2; // 1 or 2
  double _cargoWeight = 500.0; // grams
  double _winchRotation = 0.0;

  // Cam & Gear Automaton state (Ch. 7)
  double _camAngle = 0.0; // 0.0 to 360.0 degrees
  String _camType = 'Egg Cam'; // 'Round Eccentric', 'Egg Cam', 'Twin-Lobe'

  // Moving jaws state (Ch. 5 & 8)
  double _jawSqueeze = 0.5; // 0.0 to 1.0
  bool _foamPads = true;
  String _clampedObject = '🧃 Juice Box';

  // Paper circuit state
  bool _batteryPlaced = true;
  bool _correctPolarity = true;
  bool _switchPressed = false;

  // Wiggle bot state
  double _motorRpm = 2800.0;
  double _bristleAngle = 15.0; // degrees
  bool _botActive = false;
  double _botX = 0.0;
  double _botY = 0.0;

  // Solar tracker state
  double _sunPosition = 0.0; // -1.0 (Left) to 1.0 (Right)
  double _flowerAngle = 0.0;

  late AnimationController _simAnimController;

  @override
  void initState() {
    super.initState();
    _simAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void dispose() {
    _simAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    final isNarrow = MediaQuery.sizeOf(context).width < 420;

    return GlassSurface(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: EdgeInsets.all(isNarrow ? 12 : 18),
      borderRadius: 20,
      blurSigma: 12,
      tintColor: AppColors.cyan,
      borderColor: AppColors.cyan.withValues(alpha: 0.42),
      borderWidth: 1.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Playground Header
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.cyanSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.videogame_asset_rounded, color: AppColors.cyan, size: 22),
                  ),
                  const SizedBox(width: 10),
                  const Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'INTERACTIVE MECHANISM LAB',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AppColors.cyan,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          'Virtual Physics Playground',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMain,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.amberSoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('⚡', style: TextStyle(fontSize: 12)),
                    SizedBox(width: 4),
                    Text(
                      'Live Simulator',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.amber),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Render appropriate mechanism simulator based on project id
          if (p.id == 'proj_scissor_lift')
            _buildScissorLiftSimulator()
          else if (p.id == 'proj_test_cart')
            _buildTestCartSimulator()
          else if (p.id == 'proj_marble_coaster')
            _buildMarbleCoasterSimulator()
          else if (p.id == 'proj_pulley_crane')
            _buildPulleyCraneSimulator()
          else if (p.id == 'proj_gear_automaton')
            _buildCamAutomatonSimulator()
          else if (p.id == 'proj_moving_jaws')
            _buildMovingJawsSimulator()
          else if (p.id == 'proj_paper_circuit')
            _buildPaperCircuitSimulator()
          else if (p.id == 'proj_wiggle_bot')
            _buildWiggleBotSimulator()
          else if (p.id == 'proj_solar_tracker')
            _buildSolarTrackerSimulator()
          else
            _buildGenericMechanismSimulator(p),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // SIMULATOR 1: SCISSOR LIFT PANTOGRAPH
  // ══════════════════════════════════════════════════════════════════
  Widget _buildScissorLiftSimulator() {
    final heightCm = (10 + _scissorSqueeze * 30).toStringAsFixed(1);
    final pushDistCm = (_scissorSqueeze * 8).toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Drag the slider to push the scissor base pins together and watch horizontal force multiply into vertical elevation!',
          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        const SizedBox(height: 16),

        // Animated Scissor Lift Canvas
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: CustomPaint(
            painter: _ScissorLiftCanvasPainter(
              squeezeProgress: _scissorSqueeze,
              cargoEmoji: _scissorCargo.split(' ').first,
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Live Telemetry Readout Cards
        _buildTelemetryGroup([
          _buildTelemetryCard(
            title: 'INPUT SQUEEZE',
            value: '$pushDistCm cm',
            subtitle: 'Horizontal push',
            color: AppColors.primary,
          ),
          _buildTelemetryCard(
            title: 'VERTICAL LIFT',
            value: '$heightCm cm',
            subtitle: 'Platform height',
            color: AppColors.emerald,
          ),
          _buildTelemetryCard(
            title: 'RATIO',
            value: '3.75x',
            subtitle: 'Mechanical motion',
            color: AppColors.amber,
          ),
        ]),

        const SizedBox(height: 14),

        // Slider control
        _buildRangeSlider(
          minLabel: const Text('Collapsed', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
          maxLabel: const Text('Elevated 🚀', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
          slider: Slider(
            value: _scissorSqueeze,
            min: 0.05,
            max: 0.95,
            activeColor: AppColors.primary,
            onChanged: (val) {
              setState(() => _scissorSqueeze = val);
              SoundEffects.playPop();
            },
          ),
        ),

        const SizedBox(height: 8),

        // Cargo selector
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            const Text('Platform Cargo:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMain)),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: ['🪙 Penny', '🍎 Apple', '📚 Book'].map((c) {
                final isSelected = _scissorCargo == c;
                return ChoiceChip(
                  label: Text(c, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : AppColors.textMain)),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.bgSurface,
                  onSelected: (val) {
                    if (val) {
                      setState(() => _scissorCargo = c);
                      SoundEffects.playPop();
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // SIMULATOR: SMOOTH-ROLLING TEST CART (Ch. 3)
  // ══════════════════════════════════════════════════════════════════
  Widget _buildTestCartSimulator() {
    double frictionCoeff = 0.05;
    if (!_strawBearing) frictionCoeff += 0.22;
    if (!_cardboardWashers) frictionCoeff += 0.12;
    if (_wheelOffset > 0.1) frictionCoeff += _wheelOffset * 0.15;

    final rolloutDist = (3.8 / (1.0 + 8.0 * (frictionCoeff - 0.05))).toStringAsFixed(1);
    final trackingStatus = _wheelOffset > 0.3
        ? 'Wobble Drift! ⚠️'
        : (_strawBearing ? 'Straight Line 🎯' : 'Sluggish Drag 🐢');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Toggle straw bearings and cardboard donut spacers to diagnose axle friction! Adjust wheel center alignment to eliminate eccentric wheel hop from Chapter 3.',
          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        const SizedBox(height: 14),

        // Animated Test Cart Track Canvas
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: CustomPaint(
            painter: _TestCartPainter(
              rollProgress: _cartRollProgress,
              strawBearing: _strawBearing,
              cardboardWashers: _cardboardWashers,
              wheelOffset: _wheelOffset,
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Telemetry Meters
        _buildTelemetryGroup([
          _buildTelemetryCard(
            title: 'FRICTION COEFFICIENT',
            value: 'μ = ${frictionCoeff.toStringAsFixed(2)}',
            subtitle: _strawBearing ? 'Straw sleeve bearing' : 'High cardboard rub!',
            color: _strawBearing ? AppColors.emerald : AppColors.rose,
          ),
          _buildTelemetryCard(
            title: 'ROLLOUT DISTANCE',
            value: '$rolloutDist m',
            subtitle: 'Single push momentum',
            color: AppColors.primary,
          ),
          _buildTelemetryCard(
            title: 'TRACKING ALIGNMENT',
            value: trackingStatus,
            subtitle: 'Parallel wheelbase',
            color: _wheelOffset > 0.3 ? AppColors.amber : AppColors.cyan,
          ),
        ]),

        const SizedBox(height: 12),

        // Controls
        Wrap(
          spacing: 12,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: _strawBearing,
                  activeColor: AppColors.emerald,
                  onChanged: (val) {
                    setState(() => _strawBearing = val ?? true);
                    SoundEffects.playPop();
                  },
                ),
                const Text('Straw Bearing', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: _cardboardWashers,
                  activeColor: AppColors.emerald,
                  onChanged: (val) {
                    setState(() => _cardboardWashers = val ?? true);
                    SoundEffects.playPop();
                  },
                ),
                const Text('Donut Spacers', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),

        _buildRangeSlider(
          minLabel: const Text('Centered Hole', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
          maxLabel: const Text('Eccentric Wobble', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.amber)),
          slider: Slider(
            value: _wheelOffset,
            min: 0.0,
            max: 1.0,
            activeColor: AppColors.amber,
            onChanged: (val) {
              setState(() => _wheelOffset = val);
              SoundEffects.playPop();
            },
          ),
        ),

        const SizedBox(height: 6),

        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.emerald,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: _cartRolling
              ? null
              : () {
                  SoundEffects.playChime();
                  setState(() {
                    _cartRolling = true;
                    _cartRollProgress = 0.0;
                  });
                  _simAnimController.reset();
                  _simAnimController.forward().then((_) {
                    if (mounted) {
                      setState(() {
                        _cartRollProgress = 1.0;
                        _cartRolling = false;
                      });
                    }
                  });
                },
          icon: const Icon(Icons.directions_car_filled_rounded, size: 18),
          label: Text(_cartRolling ? 'Rolling Along Track...' : 'Test 3-Meter Push Rollout 🏎️', style: const TextStyle(fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // SIMULATOR 2: GRAVITY MARBLE COASTER
  // ══════════════════════════════════════════════════════════════════
  Widget _buildMarbleCoasterSimulator() {
    // Speed = sqrt(2 * g * h)
    final speed = math.sqrt(2 * 980 * _rampHeight).round();
    final potentialPct = (_rampHeight).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Tune the ramp starting elevation and curve banking. Click "Launch Marble" to simulate potential energy converting to kinetic speed!',
          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        const SizedBox(height: 14),

        // Coaster Visual Track
        Container(
          height: 170,
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Stack(
            children: [
              CustomPaint(
                size: const Size(double.infinity, 170),
                painter: _MarbleCoasterPainter(
                  rampHeight: _rampHeight,
                  banked: _bankedCurve,
                  marbleProgress: _marbleRolling ? _simAnimController.value : 0.0,
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      _marbleRolling
                          ? (_bankedCurve || _rampHeight < 70)
                              ? '🏎️ Smooth Run! Marble cleared banked curve!'
                              : '⚠️ Spin-out warning! Too fast without banked turns!'
                          : 'Ready to launch',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: (_bankedCurve || _rampHeight < 70) ? AppColors.emerald : AppColors.rose,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Telemetry Meters
        _buildTelemetryGroup([
          _buildTelemetryCard(
            title: 'POTENTIAL ENERGY',
            value: '$potentialPct%',
            subtitle: 'Stored at start drop',
            color: AppColors.amber,
          ),
          _buildTelemetryCard(
            title: 'MAX SPEED',
            value: '$speed cm/s',
            subtitle: 'Velocity at finish',
            color: AppColors.cyan,
          ),
          _buildTelemetryCard(
            title: 'BANKING FORCE',
            value: _bankedCurve ? 'Normal Inward' : 'Flat (Zero)',
            subtitle: 'Centripetal turn',
            color: _bankedCurve ? AppColors.emerald : AppColors.rose,
          ),
        ]),

        const SizedBox(height: 12),

        // Controls
        LayoutBuilder(
          builder: (context, constraints) {
            final dropControl = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Starting Drop Height: ${_rampHeight.round()} cm', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                Slider(
                  value: _rampHeight,
                  min: 20.0,
                  max: 100.0,
                  activeColor: AppColors.amber,
                  onChanged: (val) {
                    setState(() => _rampHeight = val);
                    SoundEffects.playPop();
                  },
                ),
              ],
            );
            final bankToggle = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Banked Curve', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                const SizedBox(width: 6),
                Switch(
                  value: _bankedCurve,
                  activeThumbColor: AppColors.emerald,
                  activeTrackColor: AppColors.emerald.withValues(alpha: 0.35),
                  onChanged: (val) {
                    setState(() => _bankedCurve = val);
                    SoundEffects.playPop();
                  },
                ),
              ],
            );
            if (constraints.maxWidth < 340) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  dropControl,
                  Align(alignment: Alignment.centerLeft, child: bankToggle),
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: dropControl),
                const SizedBox(width: 12),
                Column(
                  children: [
                    const Text('Banked Curve', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                    Switch(
                      value: _bankedCurve,
                      activeThumbColor: AppColors.emerald,
                      activeTrackColor: AppColors.emerald.withValues(alpha: 0.35),
                      onChanged: (val) {
                        setState(() => _bankedCurve = val);
                        SoundEffects.playPop();
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 6),

        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.emerald,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: () {
            SoundEffects.playChime();
            setState(() => _marbleRolling = true);
            _simAnimController.forward(from: 0.0).then((_) {
              if (mounted) setState(() => _marbleRolling = false);
            });
          },
          icon: const Icon(Icons.play_circle_fill_rounded, size: 18),
          label: const Text('Release Marble 🔮', style: TextStyle(fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // SIMULATOR 3: DUAL-PULLEY CRANE
  // ══════════════════════════════════════════════════════════════════
  Widget _buildPulleyCraneSimulator() {
    final effortGrams = (_cargoWeight / _pulleyCount).round();
    final cablePulled = (_winchRotation * 20).toStringAsFixed(1);
    final liftHeight = (_winchRotation * 20 / _pulleyCount).toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Toggle between 1 fixed pulley and 2 compound pulleys. Notice how adding a movable pulley cuts your pulling effort exactly in half!',
          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        const SizedBox(height: 14),

        // Telemetry
        _buildTelemetryGroup([
          _buildTelemetryCard(
            title: 'CARGO LOAD',
            value: '${_cargoWeight.round()}g',
            subtitle: 'Actual weight',
            color: AppColors.rose,
          ),
          _buildTelemetryCard(
            title: 'YOUR EFFORT',
            value: '${effortGrams}g',
            subtitle: _pulleyCount == 2 ? '50% EASIER! 🎉' : '100% effort',
            color: _pulleyCount == 2 ? AppColors.emerald : AppColors.amber,
          ),
          _buildTelemetryCard(
            title: 'LIFT HEIGHT',
            value: '$liftHeight cm',
            subtitle: 'Cable pulled: $cablePulled cm',
            color: AppColors.primary,
          ),
        ]),

        const SizedBox(height: 14),

        // Interactive Pulley Toggle
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('1 Fixed Pulley (1x Effort)', style: TextStyle(fontSize: 12)),
              selected: _pulleyCount == 1,
              selectedColor: AppColors.amber,
              onSelected: (val) {
                if (val) {
                  setState(() => _pulleyCount = 1);
                  SoundEffects.playPop();
                }
              },
            ),
            ChoiceChip(
              label: const Text('2 Compound Pulleys (2x Advantage)', style: TextStyle(fontSize: 12)),
              selected: _pulleyCount == 2,
              selectedColor: AppColors.emerald,
              onSelected: (val) {
                if (val) {
                  setState(() => _pulleyCount = 2);
                  SoundEffects.playPop();
                }
              },
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Cargo Weight Adjuster
        _buildLabeledSlider(
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.fitness_center_rounded, color: AppColors.rose, size: 18),
              const SizedBox(width: 8),
              Text('Cargo Load: ${_cargoWeight.round()}g', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
          slider: Slider(
            value: _cargoWeight,
            min: 100.0,
            max: 1000.0,
            divisions: 9,
            activeColor: AppColors.rose,
            onChanged: (val) {
              setState(() => _cargoWeight = val);
              SoundEffects.playPop();
            },
          ),
        ),

        // Winch Hand Crank Drag Controller
        _buildLabeledSlider(
          leading: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.handyman_rounded, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text('Turn Winch Crank:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
          trailing: Text('${(_winchRotation * 100).round()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary)),
          slider: Slider(
            value: _winchRotation,
            min: 0.0,
            max: 1.0,
            activeColor: AppColors.primary,
            onChanged: (val) {
              setState(() => _winchRotation = val);
              SoundEffects.playPop();
            },
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // SIMULATOR: CAM & GEAR AUTOMATON (Ch. 7)
  // ══════════════════════════════════════════════════════════════════
  Widget _buildCamAutomatonSimulator() {
    final rad = _camAngle * math.pi / 180.0;
    double lift = 0.0;
    if (_camType == 'Round Eccentric') {
      lift = (math.sin(rad) + 1.0) * 0.5;
    } else if (_camType == 'Twin-Lobe') {
      lift = (math.sin(2 * rad) + 1.0) * 0.5;
    } else {
      final norm = (_camAngle % 360.0) / 360.0;
      lift = norm < 0.75 ? (norm / 0.75) : (1.0 - (norm - 0.75) / 0.25);
    }
    final puppetHeightMm = (lift * 28).toStringAsFixed(1);
    final cyclesPerRev = _camType == 'Twin-Lobe' ? '2 Cycles/Rev' : '1 Cycle/Rev';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Turn the hand-crank to rotate the camshaft. Switch between eccentric, egg-shaped, and twin-lobe cams from Chapter 7 to observe different harmonic puppet motions!',
          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        const SizedBox(height: 14),

        // Camshaft Canvas
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: CustomPaint(
            painter: _CamAutomatonPainter(
              camAngleRad: rad,
              camType: _camType,
              liftProgress: lift,
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Telemetry
        _buildTelemetryGroup([
          _buildTelemetryCard(
            title: 'CRANK ANGLE',
            value: '${_camAngle.round()}°',
            subtitle: 'Driveshaft rotation',
            color: AppColors.primary,
          ),
          _buildTelemetryCard(
            title: 'PUPPET ELEVATION',
            value: '$puppetHeightMm mm',
            subtitle: 'Linear follower rise',
            color: AppColors.emerald,
          ),
          _buildTelemetryCard(
            title: 'FREQUENCY',
            value: cyclesPerRev,
            subtitle: _camType,
            color: AppColors.amber,
          ),
        ]),

        const SizedBox(height: 12),

        // Cam Profile Selector
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            const Text('Cam Lobe Profile:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: ['Round Eccentric', 'Egg Cam', 'Twin-Lobe'].map((type) {
                final isSelected = _camType == type;
                return ChoiceChip(
                  label: Text(type, style: TextStyle(fontSize: 10, color: isSelected ? Colors.white : AppColors.textMain)),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.bgSurface,
                  onSelected: (val) {
                    if (val) {
                      setState(() => _camType = type);
                      SoundEffects.playPop();
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Crank Dial Slider
        _buildLabeledSlider(
          leading: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.rotate_right_rounded, color: AppColors.primary, size: 20),
              SizedBox(width: 6),
              Text('Turn Crank: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            ],
          ),
          trailing: Text('${_camAngle.round()}°', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary)),
          slider: Slider(
            value: _camAngle,
            min: 0.0,
            max: 360.0,
            activeColor: AppColors.primary,
            onChanged: (val) {
              setState(() => _camAngle = val);
              SoundEffects.playPop();
            },
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // SIMULATOR: MOVING JAWS & SPRINGY CLAW (Ch. 5 & 8)
  // ══════════════════════════════════════════════════════════════════
  Widget _buildMovingJawsSimulator() {
    final clampForceN = (_jawSqueeze * 12.0).toStringAsFixed(1);
    final gripSecure = _jawSqueeze > 0.4 && (_foamPads || _jawSqueeze > 0.85);
    final jawOpeningCm = ((1.0 - _jawSqueeze) * 8.0).toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Pull the central slider handle to actuate the mirrored cross-linkage jaws from Chapter 5 & 8. Toggle foam friction grip pads to test holding power without slippage!',
          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        const SizedBox(height: 14),

        // Moving Jaws Custom Canvas
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: CustomPaint(
            painter: _MovingJawsPainter(
              squeeze: _jawSqueeze,
              foamPads: _foamPads,
              targetObject: _clampedObject.split(' ').first,
              isGripped: gripSecure,
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Telemetry
        _buildTelemetryGroup([
          _buildTelemetryCard(
            title: 'JAW APERTURE',
            value: '$jawOpeningCm cm',
            subtitle: 'Opening gap',
            color: AppColors.primary,
          ),
          _buildTelemetryCard(
            title: 'CLAMPING FORCE',
            value: '$clampForceN N',
            subtitle: 'Four-bar leverage',
            color: AppColors.emerald,
          ),
          _buildTelemetryCard(
            title: 'GRIP SECURITY',
            value: gripSecure ? 'Firm Hold! 🔒' : (_jawSqueeze > 0.4 ? 'Slipping! ⚠️' : 'Open'),
            subtitle: _foamPads ? 'High-friction foam' : 'Raw cardboard',
            color: gripSecure ? AppColors.emerald : AppColors.rose,
          ),
        ]),

        const SizedBox(height: 12),

        // Squeeze Slider
        _buildRangeSlider(
          minLabel: const Text('Open', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
          maxLabel: const Text('Clamped 🦀', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
          slider: Slider(
            value: _jawSqueeze,
            min: 0.05,
            max: 0.95,
            activeColor: AppColors.primary,
            onChanged: (val) {
              setState(() => _jawSqueeze = val);
              SoundEffects.playPop();
            },
          ),
        ),

        const SizedBox(height: 6),

        // Controls
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: _foamPads,
                  activeThumbColor: AppColors.emerald,
                  onChanged: (val) {
                    setState(() => _foamPads = val);
                    SoundEffects.playPop();
                  },
                ),
                const Text('Foam Grip Pads', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              ],
            ),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: ['🧃 Juice Box', '🥫 Soup Can', '🥚 Egg'].map((obj) {
                final isSelected = _clampedObject == obj;
                return ChoiceChip(
                  label: Text(obj, style: TextStyle(fontSize: 10, color: isSelected ? Colors.white : AppColors.textMain)),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.bgSurface,
                  onSelected: (val) {
                    if (val) {
                      setState(() => _clampedObject = obj);
                      SoundEffects.playPop();
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // SIMULATOR 4: PAPER CIRCUIT & LED CARD
  // ══════════════════════════════════════════════════════════════════
  Widget _buildPaperCircuitSimulator() {
    final isLit = _batteryPlaced && _correctPolarity && _switchPressed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Tap and hold the push-button flap to close the electric circuit loop. Toggle LED polarity to discover why diodes only glow in one direction!',
          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        const SizedBox(height: 16),

        // Interactive Circuit Board
        Container(
          height: 170,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isLit ? const Color(0xFFFEF3C7) : AppColors.bgSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: isLit ? AppColors.amber : AppColors.border, width: 2),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Conductive copper tape line
              Positioned(
                left: 40,
                right: 40,
                top: 70,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD97706),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              // Glowing LED Light in Center
              Positioned(
                top: 25,
                child: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isLit ? Colors.amber : const Color(0xFF94A3B8),
                        boxShadow: isLit
                            ? [
                                const BoxShadow(
                                  color: Colors.amber,
                                  blurRadius: 30,
                                  spreadRadius: 10,
                                )
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          isLit ? '💡' : '🔘',
                          style: const TextStyle(fontSize: 26),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isLit ? '✨ ILLUMINATED! (3V Closed Loop)' : 'LED Dark (Circuit Open)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isLit ? AppColors.amberGlow : AppColors.textDim,
                      ),
                    ),
                  ],
                ),
              ),

              // Battery on left
              Positioned(
                left: 20,
                bottom: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: const Text('🔋 3V', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Controls
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: () {
                setState(() => _batteryPlaced = !_batteryPlaced);
                SoundEffects.playPop();
              },
              icon: Icon(_batteryPlaced ? Icons.battery_charging_full_rounded : Icons.battery_alert_rounded, size: 16),
              label: Text(_batteryPlaced ? 'Battery: 3V Inserted' : 'Battery: Removed ❌'),
            ),
            OutlinedButton.icon(
              onPressed: () {
                setState(() => _correctPolarity = !_correctPolarity);
                SoundEffects.playPop();
              },
              icon: const Icon(Icons.swap_horiz_rounded, size: 16),
              label: Text(_correctPolarity ? 'Polarity: Correct (+ to +)' : 'Polarity: Reversed (- to +)'),
            ),
            GestureDetector(
              onTapDown: (_) {
                setState(() => _switchPressed = true);
                if (_batteryPlaced && _correctPolarity) {
                  SoundEffects.playChime();
                } else {
                  SoundEffects.playPop();
                }
              },
              onTapUp: (_) => setState(() => _switchPressed = false),
              onTapCancel: () => setState(() => _switchPressed = false),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: _switchPressed ? AppColors.emerald : AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: (_switchPressed ? AppColors.emerald : AppColors.primary).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  _switchPressed ? 'Flap Pressed! ⚡' : 'Press & Hold Switch 👆',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // SIMULATOR 5: BRISTLE WIGGLE-BOT
  // ══════════════════════════════════════════════════════════════════
  Widget _buildWiggleBotSimulator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Adjust motor vibration frequency and bristle slant. Watch asymmetric directional friction convert chaotic buzzing into forward locomotion!',
          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        const SizedBox(height: 14),

        Container(
          height: 160,
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxTravel = math.max(10.0, constraints.maxWidth - 150.0);
              final clampedX = 12.0 + (_botX / 160.0).clamp(0.0, 1.0) * maxTravel;
              return Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 150),
                    left: clampedX,
                    top: 40 + _botY,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🤖', style: TextStyle(fontSize: 26)),
                          const SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Wiggle-Bot', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                              Text('${_motorRpm.round()} RPM Buzz', style: const TextStyle(fontSize: 9, color: AppColors.emerald)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        LayoutBuilder(
          builder: (context, constraints) {
            final motorCtrl = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Motor: ${_motorRpm.round()} RPM', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                Slider(
                  value: _motorRpm,
                  min: 1000.0,
                  max: 4500.0,
                  activeColor: AppColors.cyan,
                  onChanged: (val) {
                    setState(() => _motorRpm = val);
                    SoundEffects.playPop();
                  },
                ),
              ],
            );
            final bristleCtrl = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bristle Slant: ${_bristleAngle.round()}°', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                Slider(
                  value: _bristleAngle,
                  min: 5.0,
                  max: 40.0,
                  activeColor: AppColors.amber,
                  onChanged: (val) {
                    setState(() => _bristleAngle = val);
                    SoundEffects.playPop();
                  },
                ),
              ],
            );
            final actionBtn = ElevatedButton(
              onPressed: () {
                SoundEffects.playChime();
                setState(() {
                  _botActive = !_botActive;
                  if (_botActive) {
                    final forwardStep = (_bristleAngle / 10.0) * (_motorRpm / 2000.0) * 15.0;
                    _botX += forwardStep;
                    _botY = math.sin(_botX / 8.0) * 10.0;
                    if (_botX > 160) _botX = 0;
                  }
                });
              },
              child: Text(_botActive ? 'Buzzing! ⚡' : 'Start Motor 🚀'),
            );

            if (constraints.maxWidth < 420) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  motorCtrl,
                  bristleCtrl,
                  const SizedBox(height: 6),
                  actionBtn,
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: motorCtrl),
                const SizedBox(width: 8),
                Expanded(child: bristleCtrl),
                const SizedBox(width: 8),
                actionBtn,
              ],
            );
          },
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // SIMULATOR 6: BIO-MIMETIC SOLAR SUNFLOWER TRACKER
  // ══════════════════════════════════════════════════════════════════
  Widget _buildSolarTrackerSimulator() {
    // Flower tracks sun angle smoothly
    final efficiency = (100 - (_sunPosition - _flowerAngle).abs() * 30).clamp(50, 99).round();
    final voltage = (efficiency * 0.05).toStringAsFixed(2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Drag the sun across the sky! The shadow divider fin casts a shadow on one photoresistor, commanding the servo to swivel the flower directly toward the light!',
          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        const SizedBox(height: 14),

        // Interactive Sky & Sunflower
        Container(
          height: 170,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFBAE6FD), Color(0xFFE0F2FE)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cyan.withValues(alpha: 0.5)),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final sunLeft = ((w * 0.5 - 18) + _sunPosition * (w * 0.34)).clamp(12.0, math.max(12.0, w - 50.0)).toDouble();
              final flowerLeft = (w * 0.5 - 26).clamp(12.0, math.max(12.0, w - 60.0)).toDouble();
              return Stack(
                children: [
                  // Draggable Sun
                  Positioned(
                    top: 28,
                    left: sunLeft,
                    child: const Text('☀️', style: TextStyle(fontSize: 34)),
                  ),

                  // Sunflower Head
                  Positioned(
                    bottom: 20,
                    left: flowerLeft,
                    child: Transform.rotate(
                      angle: _flowerAngle * 0.6,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: const Text('🌻', style: TextStyle(fontSize: 32)),
                          ),
                          Container(
                            width: 8,
                            height: 35,
                            color: Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Efficiency overlay
                  Positioned(
                    top: 10,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('Solar Output: ${voltage}V ($efficiency%)', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.amberGlow)),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        _buildRangeSlider(
          minLabel: const Text('East (Morning)', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
          maxLabel: const Text('West (Evening)', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
          slider: Slider(
            value: _sunPosition,
            min: -1.0,
            max: 1.0,
            activeColor: Colors.amber,
            onChanged: (val) {
              setState(() {
                _sunPosition = val;
                // Servo tracks sun
                _flowerAngle = val * 0.85;
              });
              SoundEffects.playPop();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGenericMechanismSimulator(Project p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.biotech_rounded, size: 36, color: AppColors.cyan),
          const SizedBox(height: 8),
          Text(
            'STEM Science Concept: ${p.stemConcept}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            p.scienceExplanation,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryGroup(List<Widget> cards) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 360 && cards.length >= 3) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: cards[0]),
                  const SizedBox(width: 8),
                  Expanded(child: cards[1]),
                ],
              ),
              const SizedBox(height: 8),
              cards[2],
            ],
          );
        }
        return Row(
          children: [
            for (int i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(child: cards[i]),
            ],
          ],
        );
      },
    );
  }

  Widget _buildRangeSlider({
    required Widget minLabel,
    required Widget maxLabel,
    required Widget slider,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 340) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              slider,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(child: minLabel),
                    const SizedBox(width: 8),
                    Flexible(
                      child: DefaultTextStyle.merge(
                        textAlign: TextAlign.right,
                        child: maxLabel,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
        return Row(
          children: [
            minLabel,
            Expanded(child: slider),
            maxLabel,
          ],
        );
      },
    );
  }

  Widget _buildLabeledSlider({
    required Widget leading,
    Widget? trailing,
    required Widget slider,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 350) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(child: leading),
                  if (trailing != null) ...[
                    const SizedBox(width: 8),
                    trailing,
                  ],
                ],
              ),
              slider,
            ],
          );
        }
        return Row(
          children: [
            leading,
            Expanded(child: slider),
            if (trailing != null) trailing,
          ],
        );
      },
    );
  }

  Widget _buildTelemetryCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: color, letterSpacing: 0.5),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// CUSTOM PAINTERS FOR SIMULATORS
// ══════════════════════════════════════════════════════════════════════
class _ScissorLiftCanvasPainter extends CustomPainter {
  final double squeezeProgress;
  final String cargoEmoji;

  _ScissorLiftCanvasPainter({
    required this.squeezeProgress,
    required this.cargoEmoji,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final strutPaint = Paint()
      ..color = const Color(0xFFD97706)
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final pinPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;

    final basePaint = Paint()
      ..color = const Color(0xFF64748B)
      ..strokeWidth = 5.0;

    // Ground line
    canvas.drawLine(Offset(w * 0.1, h * 0.9), Offset(w * 0.9, h * 0.9), basePaint);

    final centerX = w * 0.5;
    // Base width scales proportionally so platform fits narrow viewports
    final spanScale = math.min(1.0, (w - 40.0) / 210.0).clamp(0.45, 1.0);
    final halfBase = ((1.0 - squeezeProgress) * 70.0 + 25.0) * spanScale;
    // Platform height rises from 30px to 130px
    final liftH = (squeezeProgress * 100.0) + 25.0;

    final b1 = Offset(centerX - halfBase, h * 0.9);
    final b2 = Offset(centerX + halfBase, h * 0.9);

    final mid = Offset(centerX, h * 0.9 - (liftH * 0.5));

    final t1 = Offset(centerX - halfBase, h * 0.9 - liftH);
    final t2 = Offset(centerX + halfBase, h * 0.9 - liftH);

    // Draw X struts
    canvas.drawLine(b1, t2, strutPaint);
    canvas.drawLine(b2, t1, strutPaint);

    // Draw center pivot pin
    canvas.drawCircle(mid, 5.0, pinPaint);
    canvas.drawCircle(b1, 4.0, pinPaint);
    canvas.drawCircle(b2, 4.0, pinPaint);
    canvas.drawCircle(t1, 4.0, pinPaint);
    canvas.drawCircle(t2, 4.0, pinPaint);

    // Top Platform
    final platformPaint = Paint()
      ..color = const Color(0xFF4F46E5)
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(centerX - halfBase - 15, h * 0.9 - liftH), Offset(centerX + halfBase + 15, h * 0.9 - liftH), platformPaint);

    // Cargo Text Painter
    final textPainter = TextPainter(
      text: TextSpan(text: cargoEmoji, style: const TextStyle(fontSize: 22)),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(centerX - 11, h * 0.9 - liftH - 26));
  }

  @override
  bool shouldRepaint(covariant _ScissorLiftCanvasPainter oldDelegate) {
    return oldDelegate.squeezeProgress != squeezeProgress || oldDelegate.cargoEmoji != cargoEmoji;
  }
}

class _MarbleCoasterPainter extends CustomPainter {
  final double rampHeight;
  final bool banked;
  final double marbleProgress;

  _MarbleCoasterPainter({
    required this.rampHeight,
    required this.banked,
    required this.marbleProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final trackPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    final startY = (h * 0.9 - (rampHeight * 1.1)).clamp(16.0, h * 0.75);
    path.moveTo(24, startY);
    path.cubicTo(w * 0.35, h * 0.85, w * 0.6, h * 0.88, w - 36, h * 0.88);

    canvas.drawPath(path, trackPaint);

    // Draw catch cup
    final cupPaint = Paint()..color = AppColors.primary;
    canvas.drawRect(Rect.fromLTWH(w - 50, h * 0.8, 30, 25), cupPaint);

    // Marble
    final progress = marbleProgress.clamp(0.0, 1.0);
    for (final metric in path.computeMetrics()) {
      final tangent = metric.getTangentForOffset(metric.length * progress);
      if (tangent != null) {
        final marblePaint = Paint()..color = Colors.amber;
        canvas.drawCircle(tangent.position, 8.0, marblePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MarbleCoasterPainter oldDelegate) {
    return oldDelegate.rampHeight != rampHeight ||
        oldDelegate.banked != banked ||
        oldDelegate.marbleProgress != marbleProgress;
  }
}

class _TestCartPainter extends CustomPainter {
  final double rollProgress;
  final bool strawBearing;
  final bool cardboardWashers;
  final double wheelOffset;

  _TestCartPainter({
    required this.rollProgress,
    required this.strawBearing,
    required this.cardboardWashers,
    required this.wheelOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Track line
    final trackPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..strokeWidth = 4.0;
    canvas.drawLine(Offset(20, h * 0.85), Offset(w - 20, h * 0.85), trackPaint);

    // Track distance markings
    final markPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 2.0;
    for (double x = 40; x < w - 30; x += 50) {
      canvas.drawLine(Offset(x, h * 0.85), Offset(x, h * 0.85 + 6), markPaint);
    }

    // Cart position: starts at 16, rolls safely inside canvas bounds
    final maxTravel = math.max(20.0, w - 120.0);
    final cartX = 16.0 + (rollProgress * maxTravel);
    // Wobble vertical bump based on eccentric offset
    final wobbleY = wheelOffset * math.sin(cartX * 0.2) * 6.0;
    final cartY = h * 0.65 + wobbleY;

    // Cardboard Chassis plate
    final chassisPaint = Paint()..color = const Color(0xFFD97706);
    final chassisRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cartX, cartY, 80, 20),
      const Radius.circular(4),
    );
    canvas.drawRRect(chassisRect, chassisPaint);

    // Straw Bearings (underneath chassis)
    final strawPaint = Paint()
      ..color = strawBearing ? const Color(0xFF06B6D4) : const Color(0xFFB45309)
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cartX + 15, cartY + 22), Offset(cartX + 25, cartY + 22), strawPaint);
    canvas.drawLine(Offset(cartX + 55, cartY + 22), Offset(cartX + 65, cartY + 22), strawPaint);

    // Wooden Axles & Cardboard Wheels
    final wheelRadius = 16.0;
    final wheelPaint = Paint()
      ..color = const Color(0xFF78350F)
      ..style = PaintingStyle.fill;
    final rimPaint = Paint()
      ..color = const Color(0xFF451A03)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final pinPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;

    // Front & rear wheel positions
    final wheelCenters = [
      Offset(cartX + 20, h * 0.85 - wheelRadius),
      Offset(cartX + 60, h * 0.85 - wheelRadius),
    ];

    for (final wc in wheelCenters) {
      canvas.drawCircle(wc, wheelRadius, wheelPaint);
      canvas.drawCircle(wc, wheelRadius, rimPaint);

      // Cardboard Donut Washer
      if (cardboardWashers) {
        final washerPaint = Paint()
          ..color = const Color(0xFFFDE68A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0;
        canvas.drawCircle(wc, 6.0, washerPaint);
      }

      // Axle pin with eccentric offset
      final pinOffset = Offset(
        wc.dx + (wheelOffset * 5.0 * math.cos(cartX * 0.2)),
        wc.dy + (wheelOffset * 5.0 * math.sin(cartX * 0.2)),
      );
      canvas.drawCircle(pinOffset, 3.5, pinPaint);
    }

    // Mascot Cadet in the driver seat!
    final textPainter = TextPainter(
      text: const TextSpan(text: '🏎️', style: TextStyle(fontSize: 26)),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(cartX + 20, cartY - 26));
  }

  @override
  bool shouldRepaint(covariant _TestCartPainter oldDelegate) {
    return oldDelegate.rollProgress != rollProgress ||
        oldDelegate.strawBearing != strawBearing ||
        oldDelegate.cardboardWashers != cardboardWashers ||
        oldDelegate.wheelOffset != wheelOffset;
  }
}

class _CamAutomatonPainter extends CustomPainter {
  final double camAngleRad;
  final String camType;
  final double liftProgress;

  _CamAutomatonPainter({
    required this.camAngleRad,
    required this.camType,
    required this.liftProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final cy = h * 0.65;

    // Horizontal Driveshaft Skewer
    final halfShaft = math.min(90.0, w * 0.38);
    final shaftPaint = Paint()
      ..color = const Color(0xFFB45309)
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - halfShaft, cy), Offset(cx + halfShaft, cy), shaftPaint);

    // Cam Disc
    final camPaint = Paint()
      ..color = const Color(0xFFD97706)
      ..style = PaintingStyle.fill;
    final camBorderPaint = Paint()
      ..color = const Color(0xFF78350F)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(camAngleRad);

    final camPath = Path();
    if (camType == 'Round Eccentric') {
      // Off-center circular cam: radius 26, offset center 12px
      camPath.addOval(Rect.fromCircle(center: const Offset(0, -12), radius: 26));
    } else if (camType == 'Twin-Lobe') {
      // Two-lobe butterfly / peanut shape
      for (double a = 0; a <= 2 * math.pi; a += 0.1) {
        final r = 24.0 + 10.0 * math.cos(2 * a);
        final px = r * math.cos(a);
        final py = r * math.sin(a);
        if (a == 0) {
          camPath.moveTo(px, py);
        } else {
          camPath.lineTo(px, py);
        }
      }
      camPath.close();
    } else {
      // Egg Cam: pear shape
      camPath.moveTo(0, -36);
      camPath.cubicTo(26, -20, 24, 20, 0, 24);
      camPath.cubicTo(-24, 20, -26, -20, 0, -36);
      camPath.close();
    }

    canvas.drawPath(camPath, camPaint);
    canvas.drawPath(camPath, camBorderPaint);

    // Center shaft hole
    final holePaint = Paint()..color = const Color(0xFF1E1B4B);
    canvas.drawCircle(Offset.zero, 4.0, holePaint);
    canvas.restore();

    // Straw Guide Bushing (top frame)
    final strawGuidePaint = Paint()
      ..color = const Color(0xFF06B6D4)
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.square;
    canvas.drawLine(Offset(cx, 30), Offset(cx, 65), strawGuidePaint);

    // Vertical Follower Rod (skewer) & Follower Disc
    final followerH = 45.0 - (liftProgress * 30.0);
    final rodPaint = Paint()
      ..color = const Color(0xFFD97706)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, followerH), Offset(cx, cy - 25 - (liftProgress * 15.0)), rodPaint);

    // Follower Disc resting on cam
    final discPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx - 15, cy - 25 - (liftProgress * 15.0)),
      Offset(cx + 15, cy - 25 - (liftProgress * 15.0)),
      discPaint,
    );

    // Puppet Character Head (Rises with follower)
    final puppetY = followerH - 24;
    final puppetPainter = TextPainter(
      text: const TextSpan(text: '🦊', style: TextStyle(fontSize: 28)),
      textDirection: TextDirection.ltr,
    )..layout();
    puppetPainter.paint(canvas, Offset(cx - 14, puppetY));
  }

  @override
  bool shouldRepaint(covariant _CamAutomatonPainter oldDelegate) {
    return oldDelegate.camAngleRad != camAngleRad ||
        oldDelegate.camType != camType ||
        oldDelegate.liftProgress != liftProgress;
  }
}

class _MovingJawsPainter extends CustomPainter {
  final double squeeze;
  final bool foamPads;
  final String targetObject;
  final bool isGripped;

  _MovingJawsPainter({
    required this.squeeze,
    required this.foamPads,
    required this.targetObject,
    required this.isGripped,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;

    // Base handle & slider guide
    final handlePaint = Paint()
      ..color = const Color(0xFF64748B)
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, h * 0.88), Offset(cx, h * 0.45), handlePaint);

    // Slide actuator position: moves from h * 0.85 up to h * 0.55 as squeeze increases
    final slideY = h * 0.85 - (squeeze * 45.0);
    final pinPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, slideY), 6.0, pinPaint);

    final jawSpread = (1.0 - squeeze) * 35.0 + 12.0;

    // Jaw blades (Symmetrical curved cardboard levers)
    final jawPaint = Paint()
      ..color = const Color(0xFFD97706)
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;

    final leftPivot = Offset(cx - 20, h * 0.48);
    final rightPivot = Offset(cx + 20, h * 0.48);

    final leftTip = Offset(cx - jawSpread, h * 0.22);
    final rightTip = Offset(cx + jawSpread, h * 0.22);

    // Cross-link push struts from slide actuator to jaw blades
    final linkPaint = Paint()
      ..color = const Color(0xFFFBBF24)
      ..strokeWidth = 4.0;
    canvas.drawLine(Offset(cx, slideY), Offset(cx - 25, h * 0.55), linkPaint);
    canvas.drawLine(Offset(cx, slideY), Offset(cx + 25, h * 0.55), linkPaint);

    // Draw Jaws
    canvas.drawLine(leftPivot, leftTip, jawPaint);
    canvas.drawLine(rightPivot, rightTip, jawPaint);

    // Draw Pivot Pins
    canvas.drawCircle(leftPivot, 4.5, pinPaint);
    canvas.drawCircle(rightPivot, 4.5, pinPaint);

    // High-Friction Foam Grip Pads on inner jaw tips
    if (foamPads) {
      final foamPaint = Paint()
        ..color = const Color(0xFF10B981)
        ..strokeWidth = 5.0
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(leftTip.dx + 4, leftTip.dy), Offset(leftTip.dx + 4, leftTip.dy + 18), foamPaint);
      canvas.drawLine(Offset(rightTip.dx - 4, rightTip.dy), Offset(rightTip.dx - 4, rightTip.dy + 18), foamPaint);
    }

    // Target object emoji positioned between jaws
    final objectPainter = TextPainter(
      text: TextSpan(text: targetObject, style: const TextStyle(fontSize: 26)),
      textDirection: TextDirection.ltr,
    )..layout();
    objectPainter.paint(canvas, Offset(cx - 13, h * 0.16));

    // Grip status badge
    if (isGripped) {
      final lockPainter = TextPainter(
        text: const TextSpan(
          text: '🔒 SECURE GRIP',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF10B981), letterSpacing: 0.8),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      lockPainter.paint(canvas, Offset(cx - 36, h * 0.05));
    }
  }

  @override
  bool shouldRepaint(covariant _MovingJawsPainter oldDelegate) {
    return oldDelegate.squeeze != squeeze ||
        oldDelegate.foamPads != foamPads ||
        oldDelegate.targetObject != targetObject ||
        oldDelegate.isGripped != isGripped;
  }
}
