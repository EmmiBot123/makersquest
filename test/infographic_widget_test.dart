import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:makerquest/widgets/stem_infographics.dart';
import 'package:makerquest/widgets/step_infographic_painter.dart';

void main() {
  testWidgets('StepInfographicWidget renders and toggles stages and modes cleanly', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: StepInfographicWidget(
              visualType: 'struts_cutting',
              title: 'Measure & Cut Cardboard Struts',
              stepNumber: 1,
              instruction: 'Use a ruler to cut 18 cm struts.',
              tip: 'Align flutes lengthwise.',
            ),
          ),
        ),
      ),
    );

    // Initial render: Step 1 Blueprint exists
    expect(find.text('STEP 1 INFOGRAPHIC BLUEPRINT'), findsOneWidget);
    expect(find.text('Stage 1: Measure 15 cm'), findsOneWidget);
    expect(find.text('Stage 2: Check Flutes 0°'), findsOneWidget);
    expect(find.text('Stage 3: Stack & Align'), findsOneWidget);

    // Tap Stage 2
    await tester.tap(find.text('Stage 2: Check Flutes 0°'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Stage 2 Action:'), findsOneWidget);

    // Tap Stage 3
    await tester.tap(find.text('Stage 3: Stack & Align'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Stage 3 Action:'), findsOneWidget);

    // Switch mode to 3D Assembly
    await tester.tap(find.text('🎨 3D Assembly'));
    await tester.pumpAndSettle();

    // Switch mode to Physics Forces
    await tester.tap(find.text('⚡ Physics Forces'));
    await tester.pumpAndSettle();

    // Tap Animate Motion button
    await tester.tap(find.text('Animate Motion'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
  });

  test('StepInfographicPainter paints all visualTypes without error', () {
    final visualTypes = [
      'struts_cutting',
      'hole_marking',
      'x_assembly',
      'lift_complete',
      'straw_bearings',
      'wheel_cutting',
      'wheel_assembly',
      'cart_rollout',
      'axle_notch',
      'chassis_window',
      'traction_tires',
      'rubber_launch',
      'tube_cutting',
      'angle_testing',
      'banked_turns',
      'marble_finish',
      'pulley_wheel',
      'a_frame',
      'crane_complete',
      'schematic_trace',
      'tape_laying',
      'led_mounting',
      'circuit_card_finish',
      'unknown_type',
    ];

    for (final vt in visualTypes) {
      for (final mode in InfographicMode.values) {
        for (int stage = 0; stage < 3; stage++) {
          final painter = StepInfographicPainter(
            visualType: vt,
            mode: mode,
            stageIndex: stage,
            animationProgress: 0.5,
          );

          final recorder = PictureRecorder();
          final canvas = Canvas(recorder);
          painter.paint(canvas, const Size(400, 220));
          final picture = recorder.endRecording();
          expect(picture, isNotNull);
        }
      }
    }
  });
}
