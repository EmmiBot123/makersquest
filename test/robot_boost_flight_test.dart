// Tests for Bolts' jetpack boost & fly-into-page stage transitions
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:makerquest/main.dart';
import 'package:makerquest/widgets/robot_boost_flight_overlay.dart';
import 'package:makerquest/widgets/talking_robot_guide.dart';

void main() {
  test('BoostFlightKinematics curves smoothly into target portal and lands back at start', () {
    const start = Offset(190, 120);
    const target = Offset(660, 190);

    final launch = BoostFlightKinematics.evaluate(
      t: 0.05,
      start: start,
      target: target,
      isWideStage: true,
      stageWidth: 960,
    );
    expect(launch.boostThrust, greaterThan(0.9));
    expect(launch.opacity, 1.0);
    expect(launch.position.dy, lessThan(start.dy));

    final midDive = BoostFlightKinematics.evaluate(
      t: 0.27,
      start: start,
      target: target,
      isWideStage: true,
      stageWidth: 960,
    );
    expect(midDive.position.dx, greaterThan(start.dx));
    expect(midDive.position.dx, lessThan(target.dx));
    expect(midDive.boostThrust, greaterThan(1.2));

    final portalFlash = BoostFlightKinematics.evaluate(
      t: 0.47,
      start: start,
      target: target,
      isWideStage: true,
      stageWidth: 960,
    );
    expect(portalFlash.position, target);
    expect(portalFlash.opacity, 0.0);

    final returnFlight = BoostFlightKinematics.evaluate(
      t: 0.72,
      start: start,
      target: target,
      isWideStage: true,
      stageWidth: 960,
    );
    expect(returnFlight.opacity, 1.0);
    expect(returnFlight.scale, greaterThan(0.5));

    final landed = BoostFlightKinematics.evaluate(
      t: 1.0,
      start: start,
      target: target,
      isWideStage: true,
      stageWidth: 960,
    );
    expect(landed.position.dx, closeTo(start.dx, 0.01));
    expect(landed.position.dy, closeTo(start.dy, 0.01));
    expect(landed.scale, closeTo(1.0, 0.01));
    expect(landed.tiltAngle, closeTo(0.0, 0.01));

    final preSwapPane = BoostFlightKinematics.evaluatePaneTransition(0.32);
    expect(preSwapPane.scale, lessThan(1.0));
    final settledPane = BoostFlightKinematics.evaluatePaneTransition(1.0);
    expect(settledPane.scale, closeTo(1.0, 0.01));
    expect(settledPane.opacity, closeTo(1.0, 0.01));
  });

  testWidgets('Clicking Examples triggers jetpack boost overlay and swoops cleanly into Examples on desktop',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MakerQuestApp());
    await tester.pumpAndSettle();

    // Tap "Try Live Examples" with idle boosters OFF
    await tester.tap(find.text('Try Live Examples'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 18)); // t ≈ 0.30 (mid-air dive!)

    expect(find.byType(BoostFlightStageOverlay), findsOneWidget);

    final trailFinder = find.byWidgetPredicate(
      (w) => w is CustomPaint && w.painter is BoostFlightTrailPainter,
    );
    expect(trailFinder, findsOneWidget);

    final flyingRobotFinder = find.byWidgetPredicate((w) {
      if (w is! CustomPaint) return false;
      final p = w.painter;
      return p is TalkingRobot3DCartoonPainter &&
          !p.showGroundShadow &&
          p.hasBoosters &&
          p.boostThrust > 0.5;
    });
    expect(flyingRobotFinder, findsOneWidget);

    // Advance past portal swap (t >= 0.44 -> ~0.60)
    await tester.pump(const Duration(milliseconds: 18));
    expect(find.text('Scissor Lift'), findsOneWidget);

    // Finish return flight & verify clean handoff back to docked Bolts
    await tester.pumpAndSettle();
    expect(find.byType(BoostFlightStageOverlay), findsNothing);
    expect(find.text('Scissor Lift'), findsOneWidget);
    expect(find.byTooltip('Tap Bolts for a high-five!'), findsOneWidget);

    // Navigate to Plan -> then trigger boost flight via "← Back to Examples"
    await tester.ensureVisible(find.text('Pick Builds For Me'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pick Builds For Me'));
    await tester.pumpAndSettle();
    expect(find.text('← Back to Examples'), findsOneWidget);

    await tester.ensureVisible(find.text('← Back to Examples'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('← Back to Examples'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 18));
    expect(find.byType(BoostFlightStageOverlay), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byType(BoostFlightStageOverlay), findsNothing);
    expect(find.text('Scissor Lift'), findsOneWidget);
  });

  testWidgets('Boost flight transition produces zero layout overflows at 320x640 mobile',
      (WidgetTester tester) async {
    final capturedErrors = <String>[];
    final prevOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      capturedErrors.add(details.exceptionAsString());
      prevOnError?.call(details);
    };

    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(() {
      FlutterError.onError = prevOnError;
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MakerQuestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('2. Examples'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 18));
    expect(find.byType(BoostFlightStageOverlay), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 18));
    expect(find.text('Scissor Lift'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byType(BoostFlightStageOverlay), findsNothing);
    expect(capturedErrors, isEmpty);
  });

  testWidgets('Render 4-stage boost flight sequence contact sheet cleanly',
      (WidgetTester tester) async {
    const frames = [0.06, 0.24, 0.39, 0.68];
    const cellW = 460.0;
    const cellH = 270.0;
    final totalW = cellW * frames.length;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    for (int i = 0; i < frames.length; i++) {
      final t = frames[i];
      const start = Offset(108, 128);
      const target = Offset(348, 152);
      const boxH = 112.0;
      const boxW = boxH * 1.08;

      canvas.save();
      canvas.translate(i * cellW, 0);
      canvas.clipRect(const Rect.fromLTWH(0, 0, cellW, cellH));

      // Frosted stage card backdrop
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(8, 8, cellW - 16, cellH - 16),
          const Radius.circular(18),
        ),
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFEAF2FF), Color(0xFFF6F4FF), Color(0xFFECFEFF)],
          ).createShader(const Rect.fromLTWH(0, 0, cellW, cellH)),
      );

      // Stylized right-hand Examples target card mockup
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(232, 34, 206, 202),
          const Radius.circular(16),
        ),
        Paint()..color = const Color(0xFF0F172A).withValues(alpha: 0.90),
      );

      final trailPainter = BoostFlightTrailPainter(
        progress: t,
        startCenter: start,
        portalTargetCenter: target,
        isWideStage: true,
        stageWidth: cellW,
        targetStage: 1,
        paintStyle: RobotPaint.cobalt,
      );
      trailPainter.paint(canvas, const Size(cellW, cellH));

      final pose = BoostFlightKinematics.evaluate(
        t: t,
        start: start,
        target: target,
        isWideStage: true,
        stageWidth: cellW,
      );

      if (pose.opacity > 0.01) {
        canvas.save();
        canvas.translate(pose.position.dx, pose.position.dy);
        canvas.rotate(pose.tiltAngle);
        canvas.scale(pose.scale);
        canvas.translate(-boxW * 0.5, -boxH * 0.5);
        final botPainter = TalkingRobot3DCartoonPainter(
          idle: (0.25 + t * 2.8) % 1.0,
          entrance: 1.0,
          rawEntrance: 1.0,
          tapBounce: pose.tapBounce,
          confettiProgress: 0.0,
          mood: RobotMood.excited,
          isTalking: false,
          paintStyle: RobotPaint.cobalt,
          hat: RobotHat.none,
          hasBoosters: true,
          isDancing: false,
          userYaw: pose.yaw,
          userPitch: pose.pitch,
          showGroundShadow: false,
          boostThrust: pose.boostThrust,
        );
        botPainter.paint(canvas, const Size(boxW, boxH));
        canvas.restore();
      }
      canvas.restore();
    }

    final picture = recorder.endRecording();
    final byteData = await tester.runAsync(() async {
      final img = await picture.toImage(totalW.toInt(), cellH.toInt());
      return img.toByteData(format: ui.ImageByteFormat.png);
    });
    expect(byteData, isNotNull);
    expect(byteData!.lengthInBytes, greaterThan(1000));

    const dumpPath = String.fromEnvironment('DUMP_BOOST_PREVIEW');
    if (dumpPath.isNotEmpty) {
      final f = File(dumpPath);
      f.parent.createSync(recursive: true);
      f.writeAsBytesSync(byteData.buffer.asUint8List());
    }
  });
}
