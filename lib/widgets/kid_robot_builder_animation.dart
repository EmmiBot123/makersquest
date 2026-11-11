// Kid & Robot Interactive Maker Animations for MakerQuest
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/sound_effects.dart';
import '../theme/app_theme.dart';

/// Interactive Hero Animation: A kid and robot co-building a kinetic cardboard machine.
class KidRobotWorkshopHeroAnimation extends StatefulWidget {
  const KidRobotWorkshopHeroAnimation({super.key});

  @override
  State<KidRobotWorkshopHeroAnimation> createState() => _KidRobotWorkshopHeroAnimationState();
}

class _KidRobotWorkshopHeroAnimationState extends State<KidRobotWorkshopHeroAnimation>
    with TickerProviderStateMixin {
  late AnimationController _mainAnimController;
  late AnimationController _robotTapController;
  late AnimationController _testDriveController;

  int _currentBuildIndex = 0;
  final List<({String name, String icon, String action})> _buildProjects = [
    (name: 'Kinetic Scissor Lift', icon: '✂️', action: 'Elevating 4x Stroke!'),
    (name: 'Rubber-Band Speed Racer', icon: '🏎️', action: 'Winding Axle Torque!'),
    (name: 'Articulated Robot Gripper', icon: '🦾', action: 'Calibrating Pinch Force!'),
    (name: 'Gravity Marble Coaster', icon: '🎢', action: 'Banking 30° Curves!'),
  ];

  int _speechIndex = 0;
  final List<String> _kidSpeeches = [
    'Aligning 0° flutes for 300% strength! 📦',
    'Adding drinking straw bushings! 🥤',
    'Checking bamboo axle rotation! 🪵',
    'Ready for the physics stress test! 🚀',
  ];

  final List<String> _robotSpeeches = [
    'Beep-boop! Mechanical Advantage = 3.0! 🤖',
    'Elastic torque efficiency: 98.4%! ⚡',
    'Friction coefficient reduced by 60%! 🧪',
    'Cadet engineering intuition: 100%! 🏆',
  ];

  bool get _isTesting => WidgetsBinding.instance.runtimeType.toString().contains('Test');

  @override
  void initState() {
    super.initState();
    _mainAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    if (_isTesting) {
      _mainAnimController.forward();
    } else {
      _mainAnimController.repeat();
    }

    _robotTapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _testDriveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _mainAnimController.addListener(() {
      final step = (_mainAnimController.value * _kidSpeeches.length).floor();
      if (step != _speechIndex) {
        if (mounted) setState(() => _speechIndex = step % _kidSpeeches.length);
      }
    });
  }

  @override
  void dispose() {
    _mainAnimController.dispose();
    _robotTapController.dispose();
    _testDriveController.dispose();
    super.dispose();
  }

  void _onTapRobot() {
    SoundEffects.playPop();
    _robotTapController.forward(from: 0.0);
  }

  void _onSwitchProject() {
    SoundEffects.playPop();
    setState(() {
      _currentBuildIndex = (_currentBuildIndex + 1) % _buildProjects.length;
    });
  }

  void _onTestDrive() {
    SoundEffects.playChime();
    _testDriveController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final activeBuild = _buildProjects[_currentBuildIndex];
    final isCompact = MediaQuery.sizeOf(context).width < 600;

    return Container(
      constraints: const BoxConstraints(maxWidth: 960),
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          children: [
            // Workshop Stage Header Ribbon
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 16, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
              ),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.emerald.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.emerald.withValues(alpha: 0.5)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('🛠️', style: TextStyle(fontSize: 11)),
                            SizedBox(width: 4),
                            Text('LIVE WORKSHOP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF6EE7B7), letterSpacing: 0.8)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Building: ${activeBuild.name}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      InkWell(
                        onTap: _onSwitchProject,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF334155)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.swap_horiz_rounded, size: 14, color: AppColors.primaryLight),
                              SizedBox(width: 4),
                              Text('Switch Machine', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: _onTestDrive,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFFEC4899)]),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.play_arrow_rounded, size: 14, color: Colors.white),
                              SizedBox(width: 2),
                              Text('Test Run ⚡', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Animated Workshop Canvas (Tap Robot to Bounce!)
            GestureDetector(
              onTap: _onTapRobot,
              child: AnimatedBuilder(
                animation: Listenable.merge([_mainAnimController, _robotTapController, _testDriveController]),
                builder: (context, _) {
                  return CustomPaint(
                    size: const Size(double.infinity, 220),
                    painter: _KidRobotWorkshopPainter(
                      mainProgress: _mainAnimController.value,
                      tapBounce: _robotTapController.value,
                      testProgress: _testDriveController.value,
                      buildIndex: _currentBuildIndex,
                    ),
                  );
                },
              ),
            ),

            // Kid & Robot Live Speech Bubbles (Stacked cleanly on mobile)
            Container(
              padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 16, vertical: 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: isCompact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFBFDBFE)),
                          ),
                          child: Row(
                            children: [
                              const Text('🧑‍🔧', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _kidSpeeches[_speechIndex],
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF1E3A8A)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: Row(
                            children: [
                              const Text('🤖', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _robotSpeeches[_speechIndex],
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF065F46)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        // Kid speech
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFBFDBFE)),
                            ),
                            child: Row(
                              children: [
                                const Text('🧑‍🔧', style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _kidSpeeches[_speechIndex],
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF1E3A8A)),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Robot speech
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFA7F3D0)),
                            ),
                            child: Row(
                              children: [
                                const Text('🤖', style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _robotSpeeches[_speechIndex],
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF065F46)),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter rendering animated kid, robot, workbench, gears, sparks, and machines
class _KidRobotWorkshopPainter extends CustomPainter {
  final double mainProgress;
  final double tapBounce;
  final double testProgress;
  final int buildIndex;

  _KidRobotWorkshopPainter({
    required this.mainProgress,
    required this.tapBounce,
    required this.testProgress,
    required this.buildIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Background Grid & Workshop Wall
    final bgPaint = Paint()..color = const Color(0xFFF1F5F9);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    // Blueprint grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1.0;
    for (double x = 0; x < w; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }
    for (double y = 0; y < h; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // 2. Workbench surface
    final benchY = h * 0.75;
    final benchPaint = Paint()..color = const Color(0xFFD97706); // Warm cardboard wood
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.15, benchY, w * 0.7, 18), const Radius.circular(6)),
      benchPaint,
    );
    // Bench top ruler markings
    final rulerPaint = Paint()..color = Colors.white.withValues(alpha: 0.6)..strokeWidth = 1.5;
    for (double rx = w * 0.16; rx < w * 0.84; rx += 15) {
      canvas.drawLine(Offset(rx, benchY), Offset(rx, benchY + 5), rulerPaint);
    }

    // Bench legs
    final legPaint = Paint()..color = const Color(0xFF92400E)..strokeWidth = 8;
    canvas.drawLine(Offset(w * 0.22, benchY + 18), Offset(w * 0.22, h), legPaint);
    canvas.drawLine(Offset(w * 0.78, benchY + 18), Offset(w * 0.78, h), legPaint);

    // 3. Floating Engineering Sparks & Math Particles
    _drawSparks(canvas, w, h);

    // 4. Draw Kid Inventor (Left Side)
    final kidX = math.max(38.0, w * 0.16);
    final kidY = benchY - 10;
    _drawKid(canvas, kidX, kidY);

    // 5. Draw Robot Assistant (Right Side)
    final robotX = math.min(w - 38.0, w * 0.84);
    final robotY = benchY - 10;
    _drawRobot(canvas, robotX, robotY);

    // 6. Draw Machine Being Built on the Center Workbench
    final centerX = w * 0.5;
    final centerY = benchY - 10;
    _drawCenterMachine(canvas, centerX, centerY);
  }

  void _drawSparks(Canvas canvas, double w, double h) {
    final sparkPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 6; i++) {
      final phase = (mainProgress + (i / 6.0)) % 1.0;
      final sx = w * 0.35 + (i * 45) % (w * 0.3);
      final sy = h * 0.65 - (phase * 90);
      final alpha = (1.0 - phase) * 0.8;
      sparkPaint.color = (i % 2 == 0 ? AppColors.amber : AppColors.cyan).withValues(alpha: alpha);

      // Draw star spark
      canvas.drawCircle(Offset(sx, sy), 3.0 + math.sin(phase * math.pi) * 2.5, sparkPaint);
    }
  }

  void _drawKid(Canvas canvas, double kx, double ky) {
    // Breathing/bobbing animation
    final bob = math.sin(mainProgress * 2 * math.pi) * 3.0;
    final cy = ky + bob;

    // Kid Torso / Maker Apron (Teal)
    final apronPaint = Paint()..color = const Color(0xFF0284C7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(kx - 18, cy - 50, 36, 44), const Radius.circular(10)),
      apronPaint,
    );
    // Apron Pocket
    final pocketPaint = Paint()..color = const Color(0xFF0369A1);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(kx - 10, cy - 28, 20, 16), const Radius.circular(4)),
      pocketPaint,
    );
    // Small ruler in pocket
    final miniRulerPaint = Paint()..color = AppColors.amber;
    canvas.drawRect(Rect.fromLTWH(kx - 6, cy - 36, 4, 12), miniRulerPaint);

    // Kid Head
    final skinPaint = Paint()..color = const Color(0xFFFDBA74);
    canvas.drawCircle(Offset(kx, cy - 70), 20, skinPaint);

    // Hair (Spiky dark brown)
    final hairPaint = Paint()..color = const Color(0xFF451A03);
    final hairPath = Path()
      ..moveTo(kx - 22, cy - 74)
      ..quadraticBezierTo(kx, cy - 95, kx + 22, cy - 74)
      ..lineTo(kx + 16, cy - 65)
      ..lineTo(kx - 16, cy - 65)
      ..close();
    canvas.drawPath(hairPath, hairPaint);

    // Safety Goggles (Orange glass + strap)
    final goggleStrap = Paint()..color = const Color(0xFF1E293B)..strokeWidth = 3;
    canvas.drawLine(Offset(kx - 20, cy - 72), Offset(kx + 20, cy - 72), goggleStrap);
    final goggleLens = Paint()..color = const Color(0xFFF59E0B).withValues(alpha: 0.85);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(kx - 14, cy - 77, 12, 10), const Radius.circular(3)),
      goggleLens,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(kx + 2, cy - 77, 12, 10), const Radius.circular(3)),
      goggleLens,
    );

    // Smile
    final smilePaint = Paint()..color = const Color(0xFF451A03)..style = PaintingStyle.stroke..strokeWidth = 2;
    canvas.drawArc(Rect.fromCircle(center: Offset(kx, cy - 64), radius: 6), 0.2, math.pi - 0.4, false, smilePaint);

    // Animated Kid Arm holding Glue Gun / Tool
    final armAngle = math.sin(mainProgress * 4 * math.pi) * 0.25;
    final armPaint = Paint()..color = const Color(0xFFFDBA74)..strokeWidth = 6..strokeCap = StrokeCap.round;
    final handX = kx + 24 + math.cos(armAngle) * 10;
    final handY = cy - 30 + math.sin(armAngle) * 10;
    canvas.drawLine(Offset(kx + 14, cy - 40), Offset(handX, handY), armPaint);

    // Glue Gun / Tool in hand
    final toolPaint = Paint()..color = const Color(0xFFE11D48);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(handX - 2, handY - 6, 14, 8), const Radius.circular(3)),
      toolPaint,
    );
    final tipPaint = Paint()..color = const Color(0xFFFACC15)..strokeWidth = 3;
    canvas.drawLine(Offset(handX + 12, handY - 2), Offset(handX + 18, handY - 2), tipPaint);
  }

  void _drawRobot(Canvas canvas, double rx, double ry) {
    // Robot bounce on tap or idle
    final tapOffset = math.sin(tapBounce * math.pi) * 16.0;
    final idleBob = math.cos(mainProgress * 2 * math.pi) * 2.5;
    final cy = ry - tapOffset + idleBob;

    // Robot Antenna with blinking LED
    final antennaPaint = Paint()..color = const Color(0xFF64748B)..strokeWidth = 4;
    canvas.drawLine(Offset(rx, cy - 70), Offset(rx, cy - 88), antennaPaint);
    final ledPaint = Paint()
      ..color = (math.sin(mainProgress * 6 * math.pi) > 0 ? const Color(0xFF34D399) : const Color(0xFFF59E0B));
    canvas.drawCircle(Offset(rx, cy - 90), 5, ledPaint);

    // Robot Head (Curved metallic rectangle)
    final botBodyPaint = Paint()..color = const Color(0xFF475569);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(rx - 22, cy - 70, 44, 32), const Radius.circular(8)),
      botBodyPaint,
    );

    // Robot Digital Screen (Cyan matrix)
    final screenPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(rx - 16, cy - 64, 32, 20), const Radius.circular(4)),
      screenPaint,
    );
    // Expressive glowing eyes `( ^ _ ^ )` or digital blocks
    final eyePaint = Paint()..color = const Color(0xFF38BDF8);
    canvas.drawCircle(Offset(rx - 8, cy - 54), 3.5, eyePaint);
    canvas.drawCircle(Offset(rx + 8, cy - 54), 3.5, eyePaint);
    // Mouth line
    final mouthPaint = Paint()..color = const Color(0xFF38BDF8)..strokeWidth = 2;
    canvas.drawLine(Offset(rx - 5, cy - 48), Offset(rx + 5, cy - 48), mouthPaint);

    // Robot Neck
    canvas.drawRect(Rect.fromLTWH(rx - 6, cy - 38, 12, 6), Paint()..color = const Color(0xFF94A3B8));

    // Robot Torso
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(rx - 24, cy - 32, 48, 40), const Radius.circular(10)),
      Paint()..color = const Color(0xFF334155),
    );

    // Rotating chest gear on robot
    final gearAngle = mainProgress * 4 * math.pi;
    _drawSmallGear(canvas, Offset(rx, cy - 14), 10, gearAngle, const Color(0xFFF59E0B));

    // Robot Arm holding blueprint tablet / screwdriver
    final armAngle = -math.sin(mainProgress * 3 * math.pi) * 0.2;
    final armPaint = Paint()..color = const Color(0xFF64748B)..strokeWidth = 6..strokeCap = StrokeCap.round;
    final handX = rx - 24 + math.sin(armAngle) * 8;
    final handY = cy - 12 + math.cos(armAngle) * 8;
    canvas.drawLine(Offset(rx - 20, cy - 22), Offset(handX, handY), armPaint);

    // Tablet in hand
    final tabPaint = Paint()..color = const Color(0xFF6366F1);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(handX - 16, handY - 10, 16, 22), const Radius.circular(3)),
      tabPaint,
    );
    // Tablet glowing screen
    canvas.drawRect(
      Rect.fromLTWH(handX - 14, handY - 8, 12, 18),
      Paint()..color = const Color(0xFFA5B4FC),
    );
  }

  void _drawCenterMachine(Canvas canvas, double cx, double cy) {
    switch (buildIndex) {
      case 0: // Scissor Lift
        _drawScissorLift(canvas, cx, cy);
        break;
      case 1: // Speed Racer
        _drawSpeedRacer(canvas, cx, cy);
        break;
      case 2: // Robot Gripper
        _drawGripper(canvas, cx, cy);
        break;
      case 3: // Marble Coaster
        _drawMarbleCoaster(canvas, cx, cy);
        break;
      default:
        _drawScissorLift(canvas, cx, cy);
    }
  }

  void _drawScissorLift(Canvas canvas, double cx, double cy) {
    // Lift height animates up and down
    final testBounce = math.sin(testProgress * math.pi) * 35.0;
    final idleHeight = 18.0 + math.sin(mainProgress * 2 * math.pi) * 12.0;
    final totalHeight = idleHeight + testBounce;

    final strutPaint = Paint()
      ..color = const Color(0xFFD97706)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final pinPaint = Paint()..color = const Color(0xFFFDE68A);

    // Bottom Base
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx - 36, cy - 4, 72, 8), const Radius.circular(3)),
      Paint()..color = const Color(0xFF78350F),
    );

    // Tier 1 Scissor X
    final t1Top = cy - 4 - (totalHeight * 0.5);
    canvas.drawLine(Offset(cx - 24, cy - 4), Offset(cx + 24, t1Top), strutPaint);
    canvas.drawLine(Offset(cx + 24, cy - 4), Offset(cx - 24, t1Top), strutPaint);
    canvas.drawCircle(Offset(cx, (cy - 4 + t1Top) / 2), 3, pinPaint);

    // Tier 2 Scissor X
    final t2Top = cy - 4 - totalHeight;
    canvas.drawLine(Offset(cx - 24, t1Top), Offset(cx + 24, t2Top), strutPaint);
    canvas.drawLine(Offset(cx + 24, t1Top), Offset(cx - 24, t2Top), strutPaint);
    canvas.drawCircle(Offset(cx, (t1Top + t2Top) / 2), 3, pinPaint);

    // Top Platform
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx - 32, t2Top - 8, 64, 8), const Radius.circular(3)),
      Paint()..color = AppColors.primary,
    );

    // Cargo on top
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx - 10, t2Top - 22, 20, 14), const Radius.circular(3)),
      Paint()..color = AppColors.emerald,
    );
  }

  void _drawSpeedRacer(Canvas canvas, double cx, double cy) {
    // Racer moves left and right or spins wheels
    final testDriveOffset = math.sin(testProgress * 2 * math.pi) * 40.0;
    final rx = cx + testDriveOffset;

    // Chassis Box (Cardboard Brown)
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(rx - 38, cy - 22, 76, 18), const Radius.circular(4)),
      Paint()..color = const Color(0xFFB45309),
    );

    // Spoiler
    final spoilerPath = Path()
      ..moveTo(rx - 36, cy - 22)
      ..lineTo(rx - 44, cy - 34)
      ..lineTo(rx - 30, cy - 34)
      ..close();
    canvas.drawPath(spoilerPath, Paint()..color = AppColors.rose);

    // Drinking straw axles
    final strawPaint = Paint()..color = AppColors.cyan..strokeWidth = 3;
    canvas.drawLine(Offset(rx - 26, cy - 8), Offset(rx - 26, cy - 2), strawPaint);
    canvas.drawLine(Offset(rx + 26, cy - 8), Offset(rx + 26, cy - 2), strawPaint);

    // Rubber band winch in middle
    final bandPaint = Paint()..color = const Color(0xFFF59E0B)..strokeWidth = 3;
    canvas.drawLine(Offset(rx - 10, cy - 14), Offset(rx + 15, cy - 14), bandPaint);

    // Wheels (Spinning with spokes)
    final wheelRot = (mainProgress * 6 * math.pi) + (testProgress * 10 * math.pi);
    _drawWheel(canvas, Offset(rx - 26, cy - 4), 12, wheelRot);
    _drawWheel(canvas, Offset(rx + 26, cy - 4), 12, wheelRot);

    // Speed streaks when test running
    if (testProgress > 0.05) {
      final streakPaint = Paint()..color = AppColors.primaryLight.withValues(alpha: 0.6)..strokeWidth = 2;
      canvas.drawLine(Offset(rx - 55, cy - 16), Offset(rx - 42, cy - 16), streakPaint);
      canvas.drawLine(Offset(rx - 60, cy - 10), Offset(rx - 45, cy - 10), streakPaint);
    }
  }

  void _drawGripper(Canvas canvas, double cx, double cy) {
    // Gripper pinch action
    final pinch = 0.5 + math.sin(mainProgress * 3 * math.pi) * 0.4 + (testProgress * 0.4);
    final openAngle = (1.0 - pinch) * 0.4;

    // Handle / Base
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx - 8, cy - 10, 16, 32), const Radius.circular(4)),
      Paint()..color = const Color(0xFF78350F),
    );

    // Left Jaw
    final leftJaw = Path()
      ..moveTo(cx - 4, cy - 10)
      ..lineTo(cx - 28 - math.sin(openAngle) * 12, cy - 40)
      ..lineTo(cx - 14, cy - 42)
      ..close();
    canvas.drawPath(leftJaw, Paint()..color = const Color(0xFFD97706));

    // Right Jaw
    final rightJaw = Path()
      ..moveTo(cx + 4, cy - 10)
      ..lineTo(cx + 28 + math.sin(openAngle) * 12, cy - 40)
      ..lineTo(cx + 14, cy - 42)
      ..close();
    canvas.drawPath(rightJaw, Paint()..color = const Color(0xFFD97706));

    // Clamped object between jaws
    if (pinch > 0.5) {
      canvas.drawCircle(Offset(cx, cy - 38), 7, Paint()..color = AppColors.emerald);
    }
  }

  void _drawMarbleCoaster(Canvas canvas, double cx, double cy) {
    // Coaster Track Ramp
    final trackPath = Path()
      ..moveTo(cx - 50, cy - 45)
      ..quadraticBezierTo(cx - 20, cy - 5, cx + 10, cy - 25)
      ..quadraticBezierTo(cx + 35, cy - 40, cx + 55, cy - 4);

    final trackPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawPath(trackPath, trackPaint);

    // Animated rolling marble
    final marblePhase = (mainProgress * 1.5 + testProgress) % 1.0;
    final mx = cx - 48 + (marblePhase * 98);
    final my = cy - 35 + math.sin(marblePhase * math.pi * 2) * 14;

    canvas.drawCircle(Offset(mx, my), 5.5, Paint()..color = const Color(0xFFEC4899));
    canvas.drawCircle(Offset(mx - 1.5, my - 1.5), 2.0, Paint()..color = Colors.white);
  }

  void _drawWheel(Canvas canvas, Offset center, double radius, double angle) {
    final tirePaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawCircle(center, radius, tirePaint);

    final hubPaint = Paint()..color = const Color(0xFFFDE68A);
    canvas.drawCircle(center, radius * 0.4, hubPaint);

    // Spokes
    final spokePaint = Paint()..color = Colors.white..strokeWidth = 1.5;
    for (int i = 0; i < 4; i++) {
      final sa = angle + (i * math.pi / 2);
      canvas.drawLine(
        center,
        Offset(center.dx + math.cos(sa) * radius, center.dy + math.sin(sa) * radius),
        spokePaint,
      );
    }
  }

  void _drawSmallGear(Canvas canvas, Offset center, double radius, double angle, Color color) {
    final gearPaint = Paint()..color = color;
    canvas.drawCircle(center, radius * 0.75, gearPaint);
    canvas.drawCircle(center, radius * 0.3, Paint()..color = const Color(0xFF1E293B));

    // Teeth
    const teeth = 8;
    for (int i = 0; i < teeth; i++) {
      final ta = angle + (i * 2 * math.pi / teeth);
      final tx = center.dx + math.cos(ta) * radius;
      final ty = center.dy + math.sin(ta) * radius;
      canvas.drawCircle(Offset(tx, ty), 2.5, gearPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _KidRobotWorkshopPainter oldDelegate) {
    return oldDelegate.mainProgress != mainProgress ||
        oldDelegate.tapBounce != tapBounce ||
        oldDelegate.testProgress != testProgress ||
        oldDelegate.buildIndex != buildIndex;
  }
}

/// Dynamic Animated Robot Architect Blueprint Drafting Widget.
/// Displayed when a student clicks "Analyze Maker Capability & Generate Plan 🚀".
class RobotPlanDraftingAnimation extends StatefulWidget {
  final String studentName;
  final VoidCallback onComplete;

  const RobotPlanDraftingAnimation({
    super.key,
    required this.studentName,
    required this.onComplete,
  });

  @override
  State<RobotPlanDraftingAnimation> createState() => _RobotPlanDraftingAnimationState();
}

class _RobotPlanDraftingAnimationState extends State<RobotPlanDraftingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _draftingController;
  int _stepIndex = 0;

  final List<({String icon, String title, String detail})> _steps = [
    (
      icon: '🤖',
      title: 'Bot "Bolts" Scanning Aptitude Profile...',
      detail: 'Analyzing spatial cognition, tactile motor readiness & interest parameters'
    ),
    (
      icon: '📐',
      title: 'Drafting 3D Kinematic Linkages...',
      detail: 'Aligning 0° corrugated cardboard flutes for 300% maximum bending strength'
    ),
    (
      icon: '⚙️',
      title: 'Simulating Axle Friction & Torque Curves...',
      detail: 'Testing straw-bearing rotation with Hooke\'s Law stored elastic potential'
    ),
    (
      icon: '📦',
      title: 'Curating 4 Personalized Blueprint Missions...',
      detail: 'Packaging chapter progression, checkpoint quizzes, and printable scales'
    ),
    (
      icon: '✨',
      title: 'Master Cadet Odyssey Plan Approved!',
      detail: 'Issuing Junior Robotics accreditation path & unlocking workshop blueprints'
    ),
  ];

  @override
  void initState() {
    super.initState();
    final bool isTesting = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    _draftingController = AnimationController(
      vsync: this,
      duration: isTesting ? const Duration(milliseconds: 500) : const Duration(milliseconds: 2800),
    );

    _draftingController.addListener(() {
      final newStep = (_draftingController.value * _steps.length).floor().clamp(0, _steps.length - 1);
      if (newStep != _stepIndex) {
        SoundEffects.playPop();
        if (mounted) setState(() => _stepIndex = newStep);
      }
    });

    _draftingController.forward().then((_) {
      SoundEffects.playFanfare();
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _draftingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = _steps[_stepIndex];
    final progress = _draftingController.value;
    final screenW = MediaQuery.sizeOf(context).width;
    final isCompact = screenW < 480;

    return Container(
      constraints: const BoxConstraints(maxWidth: 860),
      margin: const EdgeInsets.symmetric(vertical: 24),
      padding: EdgeInsets.all(isCompact ? 16 : 28),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⚡', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'ROBOT ARCHITECT AT WORK FOR ${widget.studentName.toUpperCase()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF93C5FD), letterSpacing: 1.0),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Synthesizing Cadet Capability Blueprint',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
          ),
          const SizedBox(height: 6),
          Text(
            'Chief Architect Bot "Bolts" is generating ${widget.studentName}\'s personalized 12-chapter STEM trajectory...',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 24),

          // Glowing Holographic Drafting Board Canvas
          AnimatedBuilder(
            animation: _draftingController,
            builder: (context, _) {
              return Container(
                height: 170,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF020617),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1E293B), width: 1.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: CustomPaint(
                    painter: _RobotDraftingBlueprintPainter(progress: _draftingController.value),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Dynamic Step Indicator Card
          Container(
            padding: EdgeInsets.all(isCompact ? 12 : 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                  ),
                  child: Center(
                    child: Text(currentStep.icon, style: const TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              currentStep.title,
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Step ${_stepIndex + 1} of ${_steps.length}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF38BDF8)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentStep.detail,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Progress Bar with sliding robot icon
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFF1E293B),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF38BDF8)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the animated holographic blueprint drafting screen
class _RobotDraftingBlueprintPainter extends CustomPainter {
  final double progress;

  _RobotDraftingBlueprintPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Glowing blueprint grid
    final gridPaint = Paint()
      ..color = const Color(0xFF0369A1).withValues(alpha: 0.25)
      ..strokeWidth = 1.0;
    for (double x = 0; x < w; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }
    for (double y = 0; y < h; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // Laser scanning beam sweeping across
    final scanX = (progress * 1.5 % 1.0) * w;
    final scanPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF38BDF8).withValues(alpha: 0.8),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(scanX - 20, 0, 40, h));
    canvas.drawRect(Rect.fromLTWH(scanX - 20, 0, 40, h), scanPaint);
    canvas.drawLine(Offset(scanX, 0), Offset(scanX, h), Paint()..color = const Color(0xFF38BDF8)..strokeWidth = 2);

    // 1. Robot Chassis Blueprint Lines being drawn
    final penProgress = progress.clamp(0.0, 1.0);
    final drawPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Center Chassis Outline
    final cx = w * 0.5;
    final cy = h * 0.5;
    final chassisW = w < 240 ? 72.0 : 90.0;
    final chassisH = w < 240 ? 58.0 : 70.0;
    final gearOffset = math.min(80.0, w * 0.28);
    if (penProgress > 0.1) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy), width: chassisW, height: chassisH), const Radius.circular(8)),
        drawPaint,
      );
    }

    // Rotating Mechanism Gear on blueprint
    if (penProgress > 0.25) {
      final gearAngle = progress * 6 * math.pi;
      final r1 = w < 240 ? 18.0 : 24.0;
      final r2 = w < 240 ? 14.0 : 18.0;
      _drawHoloGear(canvas, Offset(cx - gearOffset, cy), r1, gearAngle);
      _drawHoloGear(canvas, Offset(cx + gearOffset, cy), r2, -gearAngle);
    }

    // Kinematic vectors & dimensions
    if (penProgress > 0.4) {
      final vectorPaint = Paint()..color = const Color(0xFF34D399)..strokeWidth = 1.5;
      canvas.drawLine(Offset(cx - 45, cy - 42), Offset(cx + 45, cy - 42), vectorPaint);
      canvas.drawLine(Offset(cx - 45, cy - 46), Offset(cx - 45, cy - 38), vectorPaint);
      canvas.drawLine(Offset(cx + 45, cy - 46), Offset(cx + 45, cy - 38), vectorPaint);
    }

    // Stylus drawing point with glowing particle
    if (penProgress < 0.95) {
      final stylusX = cx + math.cos(progress * 8 * math.pi) * 35;
      final stylusY = cy + math.sin(progress * 6 * math.pi) * 25;
      canvas.drawCircle(Offset(stylusX, stylusY), 4, Paint()..color = const Color(0xFFFDE047));
      canvas.drawCircle(Offset(stylusX, stylusY), 8, Paint()..color = const Color(0xFFFDE047).withValues(alpha: 0.3));
    }
  }

  void _drawHoloGear(Canvas canvas, Offset center, double radius, double angle) {
    final gearPaint = Paint()
      ..color = const Color(0xFF67E8F9).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(center, radius * 0.8, gearPaint);
    canvas.drawCircle(center, radius * 0.3, gearPaint);

    const teeth = 8;
    for (int i = 0; i < teeth; i++) {
      final ta = angle + (i * 2 * math.pi / teeth);
      final p1 = Offset(center.dx + math.cos(ta) * radius * 0.8, center.dy + math.sin(ta) * radius * 0.8);
      final p2 = Offset(center.dx + math.cos(ta) * radius, center.dy + math.sin(ta) * radius);
      canvas.drawLine(p1, p2, gearPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RobotDraftingBlueprintPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Animated micro-canvas preview for the 4 tangible outcome machines:
/// 'scissor_lift', 'speed_racer', 'marble_coaster', 'robot_gripper'.
class AnimatedMechanismMiniPreview extends StatefulWidget {
  final String mechanicType;
  final double height;

  const AnimatedMechanismMiniPreview({
    super.key,
    required this.mechanicType,
    this.height = 84.0,
  });

  @override
  State<AnimatedMechanismMiniPreview> createState() => _AnimatedMechanismMiniPreviewState();
}

class _AnimatedMechanismMiniPreviewState extends State<AnimatedMechanismMiniPreview>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  bool get _isTesting => WidgetsBinding.instance.runtimeType.toString().contains('Test');

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    if (_isTesting) {
      _animController.forward();
    } else {
      _animController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, _) {
            return CustomPaint(
              painter: _MiniMechanismPainter(
                mechanicType: widget.mechanicType,
                progress: _animController.value,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MiniMechanismPainter extends CustomPainter {
  final String mechanicType;
  final double progress;

  _MiniMechanismPainter({required this.mechanicType, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Subtle mini blueprint grid background
    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1.0;
    for (double x = 0; x < w; x += 16) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }
    for (double y = 0; y < h; y += 16) {
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    switch (mechanicType) {
      case 'scissor_lift':
        _paintScissor(canvas, w, h);
        break;
      case 'speed_racer':
        _paintRacer(canvas, w, h);
        break;
      case 'marble_coaster':
        _paintCoaster(canvas, w, h);
        break;
      case 'robot_gripper':
        _paintGripper(canvas, w, h);
        break;
      default:
        _paintScissor(canvas, w, h);
    }
  }

  void _paintScissor(Canvas canvas, double w, double h) {
    final cx = w * 0.5;
    final baseY = h * 0.82;
    final liftH = 14.0 + (progress * 26.0); // Expands up and down

    // Base runner
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx - 32, baseY, 64, 6), const Radius.circular(2)),
      Paint()..color = const Color(0xFF78350F),
    );

    final strutPaint = Paint()
      ..color = const Color(0xFFD97706)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final pinPaint = Paint()..color = const Color(0xFFFDE68A);

    // Tier 1 X
    final t1Top = baseY - (liftH * 0.5);
    canvas.drawLine(Offset(cx - 20, baseY), Offset(cx + 20, t1Top), strutPaint);
    canvas.drawLine(Offset(cx + 20, baseY), Offset(cx - 20, t1Top), strutPaint);
    canvas.drawCircle(Offset(cx, (baseY + t1Top) / 2), 2.5, pinPaint);

    // Tier 2 X
    final t2Top = baseY - liftH;
    canvas.drawLine(Offset(cx - 20, t1Top), Offset(cx + 20, t2Top), strutPaint);
    canvas.drawLine(Offset(cx + 20, t1Top), Offset(cx - 20, t2Top), strutPaint);
    canvas.drawCircle(Offset(cx, (t1Top + t2Top) / 2), 2.5, pinPaint);

    // Top elevated platform
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx - 26, t2Top - 6, 52, 6), const Radius.circular(2)),
      Paint()..color = AppColors.primary,
    );
  }

  void _paintRacer(Canvas canvas, double w, double h) {
    final cx = w * 0.5;
    final cy = h * 0.56;

    // Speed dashes flying backward
    final dashPaint = Paint()
      ..color = AppColors.cyan.withValues(alpha: 0.6)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final dashOffset = (progress * 24.0);
    canvas.drawLine(Offset(cx - 36 - dashOffset, cy - 8), Offset(cx - 48 - dashOffset, cy - 8), dashPaint);
    canvas.drawLine(Offset(cx - 32 - dashOffset, cy + 4), Offset(cx - 46 - dashOffset, cy + 4), dashPaint);

    // Chassis Box
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx - 28, cy - 14, 56, 14), const Radius.circular(3)),
      Paint()..color = const Color(0xFFB45309),
    );

    // Mini Spoiler
    canvas.drawRect(Rect.fromLTWH(cx - 26, cy - 20, 8, 6), Paint()..color = AppColors.rose);

    // Rubber band winch tension
    canvas.drawLine(
      Offset(cx - 6, cy - 8),
      Offset(cx + 12, cy - 8),
      Paint()..color = const Color(0xFFF59E0B)..strokeWidth = 2.5,
    );

    // Wheels rotating
    final angle = progress * 6 * math.pi;
    _drawMiniWheel(canvas, Offset(cx - 18, cy + 2), 9, angle);
    _drawMiniWheel(canvas, Offset(cx + 18, cy + 2), 9, angle);
  }

  void _paintCoaster(Canvas canvas, double w, double h) {
    final cx = w * 0.5;
    final cy = h * 0.5;

    // Banked Coaster Curve
    final curvePath = Path()
      ..moveTo(cx - 45, cy - 25)
      ..quadraticBezierTo(cx - 15, cy + 22, cx + 15, cy - 6)
      ..quadraticBezierTo(cx + 35, cy - 25, cx + 48, cy + 18);

    canvas.drawPath(
      curvePath,
      Paint()
        ..color = const Color(0xFF64748B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5,
    );

    // Rolling Glowing Marble
    final mx = cx - 42 + (progress * 86);
    final my = cy - 20 + math.sin(progress * math.pi * 2) * 16;

    canvas.drawCircle(Offset(mx, my), 5.5, Paint()..color = const Color(0xFFEC4899));
    canvas.drawCircle(Offset(mx - 1.5, my - 1.5), 1.8, Paint()..color = Colors.white);
  }

  void _paintGripper(Canvas canvas, double w, double h) {
    final cx = w * 0.5;
    final cy = h * 0.65;
    final pinch = 0.2 + (progress * 0.8);
    final spread = (1.0 - pinch) * 16.0;

    // Handle
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx - 6, cy - 4, 12, 22), const Radius.circular(3)),
      Paint()..color = const Color(0xFF78350F),
    );

    // Left Jaw
    final leftJaw = Path()
      ..moveTo(cx - 3, cy - 4)
      ..lineTo(cx - 14 - spread, cy - 28)
      ..lineTo(cx - 4, cy - 30)
      ..close();
    canvas.drawPath(leftJaw, Paint()..color = const Color(0xFFD97706));

    // Right Jaw
    final rightJaw = Path()
      ..moveTo(cx + 3, cy - 4)
      ..lineTo(cx + 14 + spread, cy - 28)
      ..lineTo(cx + 4, cy - 30)
      ..close();
    canvas.drawPath(rightJaw, Paint()..color = const Color(0xFFD97706));

    // Target block being clamped
    if (pinch > 0.6) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy - 26), width: 12, height: 12), const Radius.circular(2)),
        Paint()..color = AppColors.emerald,
      );
    }
  }

  void _drawMiniWheel(Canvas canvas, Offset center, double radius, double angle) {
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFF1E293B));
    canvas.drawCircle(center, radius * 0.35, Paint()..color = const Color(0xFFFDE68A));
    final spoke = Paint()..color = Colors.white..strokeWidth = 1.2;
    for (int i = 0; i < 4; i++) {
      final a = angle + (i * math.pi / 2);
      canvas.drawLine(center, Offset(center.dx + math.cos(a) * radius, center.dy + math.sin(a) * radius), spoke);
    }
  }

  @override
  bool shouldRepaint(covariant _MiniMechanismPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.mechanicType != mechanicType;
  }
}

/// Gold shimmer certificate diploma seal and border shimmer widget
class AnimatedGoldShimmerDiplomaSeal extends StatefulWidget {
  const AnimatedGoldShimmerDiplomaSeal({super.key});

  @override
  State<AnimatedGoldShimmerDiplomaSeal> createState() => _AnimatedGoldShimmerDiplomaSealState();
}

class _AnimatedGoldShimmerDiplomaSealState extends State<AnimatedGoldShimmerDiplomaSeal>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  bool get _isTesting => WidgetsBinding.instance.runtimeType.toString().contains('Test');

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    if (_isTesting) {
      _shimmerController.forward();
    } else {
      _shimmerController.repeat();
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, _) {
        final rot = _shimmerController.value * 2 * math.pi;
        return Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFFFDE68A),
                const Color(0xFFD4AF37),
                const Color(0xFF92400E),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Transform.rotate(
              angle: rot,
              child: const Text('⭐', style: TextStyle(fontSize: 24)),
            ),
          ),
        );
      },
    );
  }
}

/// 1. Live Marquee Ticker with Pulsing Radar Beacon
class AnimatedCadetMarqueeTicker extends StatefulWidget {
  final List<({String who, String action})> items;
  const AnimatedCadetMarqueeTicker({super.key, required this.items});

  @override
  State<AnimatedCadetMarqueeTicker> createState() => _AnimatedCadetMarqueeTickerState();
}

class _AnimatedCadetMarqueeTickerState extends State<AnimatedCadetMarqueeTicker>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  final ScrollController _scrollController = ScrollController();
  bool get _isTesting => WidgetsBinding.instance.runtimeType.toString().contains('Test');

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (_isTesting) {
      _pulseController.forward();
    } else {
      _pulseController.repeat(reverse: true);
      WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
    }
  }

  void _startAutoScroll() async {
    while (mounted && !_isTesting) {
      await Future.delayed(const Duration(milliseconds: 35));
      if (!mounted || !_scrollController.hasClients) break;
      final max = _scrollController.position.maxScrollExtent;
      if (max > 0) {
        final next = _scrollController.offset + 0.8;
        if (next >= max) {
          _scrollController.jumpTo(0);
        } else {
          _scrollController.jumpTo(next);
        }
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    final isCompact = screenW < 420;
    final repeated = [...widget.items, ...widget.items];
    return Container(
      color: const Color(0xFF0F172A),
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 10 : 16, vertical: 9),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) {
              final scale = 0.85 + (_pulseController.value * 0.35);
              return Container(
                padding: EdgeInsets.symmetric(horizontal: isCompact ? 7 : 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.rose.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.rose.withValues(alpha: 0.4 + _pulseController.value * 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFB7185),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.rose.withValues(alpha: 0.7),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isCompact ? 'LIVE CADETS' : 'LIVE CADET ACTIVITY',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFDA4AF),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(width: isCompact ? 8 : 14),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                children: repeated.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.who,
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '• ${item.action}',
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 2. Parent Screen-Time vs MakerQuest Transformation Meters
class AnimatedParentImpactMeters extends StatefulWidget {
  final bool isPositive;
  const AnimatedParentImpactMeters({super.key, required this.isPositive});

  @override
  State<AnimatedParentImpactMeters> createState() => _AnimatedParentImpactMetersState();
}

class _AnimatedParentImpactMetersState extends State<AnimatedParentImpactMeters>
    with SingleTickerProviderStateMixin {
  late AnimationController _meterController;
  bool get _isTesting => WidgetsBinding.instance.runtimeType.toString().contains('Test');

  @override
  void initState() {
    super.initState();
    _meterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    if (_isTesting) {
      _meterController.value = 1.0;
    } else {
      _meterController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _meterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metrics = widget.isPositive
        ? [
            (label: 'Spatial & Creative Focus', targetPct: 0.94, valText: '+310%', color: AppColors.emerald),
            (label: 'CBSE / ICSE Physics Intuition', targetPct: 0.97, valText: '97%', color: AppColors.primary),
          ]
        : [
            (label: 'Active Brain Engagement', targetPct: 0.14, valText: '14% Low', color: AppColors.rose),
            (label: 'Eye Fatigue & Restlessness', targetPct: 0.88, valText: '88% High', color: const Color(0xFFE11D48)),
          ];

    return AnimatedBuilder(
      animation: _meterController,
      builder: (context, _) {
        final wave = _isTesting ? 0.0 : math.sin(_meterController.value * math.pi) * 0.04;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.isPositive ? const Color(0xFFF0FDF4) : const Color(0xFFFFE4E6).withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isPositive ? AppColors.emerald.withValues(alpha: 0.35) : AppColors.rose.withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            children: metrics.map((m) {
              final fill = (m.targetPct + (widget.isPositive ? wave : -wave)).clamp(0.05, 1.0);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            m.label,
                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.textMain),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          m.valText,
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: m.color),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: fill,
                        minHeight: 7,
                        backgroundColor: Colors.white,
                        valueColor: AlwaysStoppedAnimation<Color>(m.color),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

/// 3. Animated Step Icon with gentle bobbing and glow ring
class AnimatedStepIconBadge extends StatefulWidget {
  final String emoji;
  final Color color;
  final int staggerIndex;

  const AnimatedStepIconBadge({
    super.key,
    required this.emoji,
    required this.color,
    required this.staggerIndex,
  });

  @override
  State<AnimatedStepIconBadge> createState() => _AnimatedStepIconBadgeState();
}

class _AnimatedStepIconBadgeState extends State<AnimatedStepIconBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  bool get _isTesting => WidgetsBinding.instance.runtimeType.toString().contains('Test');

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2200 + widget.staggerIndex * 350),
    );
    if (_isTesting) {
      _ctrl.forward();
    } else {
      _ctrl.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final offset = _isTesting ? 0.0 : math.sin(_ctrl.value * 2 * math.pi) * 3.5;
        final scale = 1.0 + (_ctrl.value * 0.06);
        return Transform.translate(
          offset: Offset(0, offset),
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: widget.color.withValues(alpha: 0.35), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.15 + _ctrl.value * 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(child: Text(widget.emoji, style: const TextStyle(fontSize: 24))),
            ),
          ),
        );
      },
    );
  }
}

/// 4. Interactive Cardboard-to-Robot Transformation & Gamified Badge Rocket Playground
class AnimatedScrapToRobotShowcase extends StatefulWidget {
  const AnimatedScrapToRobotShowcase({super.key});

  @override
  State<AnimatedScrapToRobotShowcase> createState() => _AnimatedScrapToRobotShowcaseState();
}

class _AnimatedScrapToRobotShowcaseState extends State<AnimatedScrapToRobotShowcase>
    with SingleTickerProviderStateMixin {
  late AnimationController _loopController;
  int _selectedBadgeIndex = 0;
  int _xpPoints = 240;

  bool get _isTesting => WidgetsBinding.instance.runtimeType.toString().contains('Test');

  final List<({String icon, String title, String bonus, Color color})> _badges = [
    (icon: '📦', title: 'Cardboard Pioneer', bonus: '+120 XP', color: Color(0xFFD97706)),
    (icon: '⚙️', title: 'Mechanism Maestro', bonus: '+240 XP', color: Color(0xFF0284C7)),
    (icon: '🏎️', title: 'Torque Architect', bonus: '+380 XP', color: Color(0xFFE11D48)),
    (icon: '📐', title: 'CAD Genius', bonus: '+520 XP', color: Color(0xFF7C3AED)),
    (icon: '🏆', title: 'Grand Inventor', bonus: '+1000 XP', color: Color(0xFF059669)),
  ];

  @override
  void initState() {
    super.initState();
    _loopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    );
    if (_isTesting) {
      _loopController.forward();
    } else {
      _loopController.repeat();
    }
  }

  @override
  void dispose() {
    _loopController.dispose();
    super.dispose();
  }

  void _selectBadge(int idx) {
    SoundEffects.playPop();
    setState(() {
      _selectedBadgeIndex = idx;
      _xpPoints = (idx + 1) * 200;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    final isDesktop = screenW >= 820;
    final isTiny = screenW < 420;
    final rocketPct = (_selectedBadgeIndex + 1) / _badges.length;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 28 : (isTiny ? 14 : 18)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.45), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.45)),
                      ),
                      child: const Text(
                        '✨ KID-POWERED GAMIFIED LAB • TAP BADGES BELOW!',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF7DD3FC), letterSpacing: 0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'From Delivery Box to Animated Robot Inventor',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ],
                ),
              ),
              if (isDesktop)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.emerald.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🚀', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        'Cadet XP: $_xpPoints',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF6EE7B7)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Live Assembly Pipeline Canvas
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF020617),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: AnimatedBuilder(
                animation: _loopController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _ScrapToRobotPipelinePainter(progress: _loopController.value),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Interactive XP Rocket Bar
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      'Rank Lv.${_selectedBadgeIndex + 1}: ${_badges[_selectedBadgeIndex].title}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                    ),
                    Text(
                      '${(rocketPct * 100).toInt()}% Mastery Streak',
                      style: const TextStyle(color: Color(0xFFFDE047), fontWeight: FontWeight.w900, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: rocketPct.clamp(0.15, 1.0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        height: 12,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF38BDF8), Color(0xFF10B981), Color(0xFFFACC15)]),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFF38BDF8).withValues(alpha: 0.5), blurRadius: 8),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(_badges.length, (i) {
                    final b = _badges[i];
                    final selected = _selectedBadgeIndex == i;
                    return InkWell(
                      onTap: () => _selectBadge(i),
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? b.color.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected ? b.color : Colors.white.withValues(alpha: 0.14),
                            width: selected ? 1.8 : 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedScale(
                              scale: selected ? 1.2 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              child: Text(b.icon, style: const TextStyle(fontSize: 16)),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                b.title,
                                style: TextStyle(
                                  color: selected ? Colors.white : const Color(0xFFCBD5E1),
                                  fontSize: 11,
                                  fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScrapToRobotPipelinePainter extends CustomPainter {
  final double progress;
  _ScrapToRobotPipelinePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Subtle Blueprint Grid
    final gridPaint = Paint()
      ..color = const Color(0xFF0EA5E9).withValues(alpha: 0.12)
      ..strokeWidth = 1;
    for (double x = 0; x < w; x += 24) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }
    for (double y = 0; y < h; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // Pipeline Energy Beam
    final beamY = h * 0.56;
    canvas.drawLine(
      Offset(w * 0.18, beamY),
      Offset(w * 0.82, beamY),
      Paint()..color = const Color(0xFF1E293B)..strokeWidth = 4,
    );

    // Animated flowing sparks along the track
    for (int i = 0; i < 4; i++) {
      final p = (progress + i * 0.25) % 1.0;
      final px = w * 0.18 + (w * 0.64 * p);
      canvas.drawCircle(Offset(px, beamY), 4.0, Paint()..color = const Color(0xFF38BDF8));
      canvas.drawCircle(Offset(px, beamY), 8.0, Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.25));
    }

    // Stage 1 (Left): Raw Delivery Cardboard Box bouncing
    final boxX = w * 0.2;
    final boxBob = math.sin(progress * 2 * math.pi) * 4;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(boxX, beamY + boxBob), width: 46, height: 38), const Radius.circular(5)),
      Paint()..color = const Color(0xFFB45309),
    );
    // Box tape & flaps
    canvas.drawRect(Rect.fromCenter(center: Offset(boxX, beamY + boxBob - 10), width: 46, height: 6), Paint()..color = const Color(0xFFFDE68A));
    canvas.drawLine(
      Offset(boxX, beamY + boxBob - 19),
      Offset(boxX, beamY + boxBob + 19),
      Paint()..color = const Color(0xFF78350F)..strokeWidth = 2,
    );

    // Stage 2 (Center): Holographic CAD Scanner + Spinning Gear
    final centerX = w * 0.5;
    final gearAngle = progress * 4 * math.pi;
    final gearPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    canvas.drawCircle(Offset(centerX, beamY), 22, gearPaint);
    canvas.drawCircle(Offset(centerX, beamY), 9, gearPaint);
    for (int i = 0; i < 8; i++) {
      final a = gearAngle + i * math.pi / 4;
      canvas.drawLine(
        Offset(centerX + math.cos(a) * 22, beamY + math.sin(a) * 22),
        Offset(centerX + math.cos(a) * 28, beamY + math.sin(a) * 28),
        gearPaint,
      );
    }
    // Vertical scanning laser
    final scanOffset = math.sin(progress * 6 * math.pi) * 26;
    canvas.drawLine(
      Offset(centerX + scanOffset, beamY - 34),
      Offset(centerX + scanOffset, beamY + 34),
      Paint()..color = const Color(0xFF34D399)..strokeWidth = 2.5,
    );

    // Stage 3 (Right): Finished Working Cardboard Robot Waving!
    final botX = w * 0.8;
    final botBob = math.cos(progress * 2 * math.pi) * 4;
    final botY = beamY + botBob;
    // Antenna + blinking beacon
    canvas.drawLine(Offset(botX, botY - 30), Offset(botX, botY - 42), Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 2.5);
    canvas.drawCircle(
      Offset(botX, botY - 44),
      4,
      Paint()..color = (math.sin(progress * 8 * math.pi) > 0 ? const Color(0xFF10B981) : const Color(0xFFFACC15)),
    );
    // Robot Head
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(botX, botY - 18), width: 34, height: 22), const Radius.circular(6)),
      Paint()..color = const Color(0xFF475569),
    );
    // Cyan eyes
    canvas.drawCircle(Offset(botX - 7, botY - 19), 2.5, Paint()..color = const Color(0xFF38BDF8));
    canvas.drawCircle(Offset(botX + 7, botY - 19), 2.5, Paint()..color = const Color(0xFF38BDF8));
    // Cardboard Robot Body
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(botX, botY + 12), width: 40, height: 34), const Radius.circular(6)),
      Paint()..color = const Color(0xFFD97706),
    );
    // Waving Robot Arm!
    final waveAngle = -0.6 + math.sin(progress * 6 * math.pi) * 0.45;
    canvas.drawLine(
      Offset(botX + 20, botY + 6),
      Offset(botX + 20 + math.cos(waveAngle) * 18, botY + 6 + math.sin(waveAngle) * 18),
      Paint()..color = const Color(0xFFFDE68A)..strokeWidth = 4..strokeCap = StrokeCap.round,
    );
    // Rolling Wheels
    canvas.drawCircle(Offset(botX - 12, botY + 32), 6, Paint()..color = const Color(0xFF334155));
    canvas.drawCircle(Offset(botX + 12, botY + 32), 6, Paint()..color = const Color(0xFF334155));
  }

  @override
  bool shouldRepaint(covariant _ScrapToRobotPipelinePainter oldDelegate) => oldDelegate.progress != progress;
}

