// Tests verifying 3D Pixar/Cartoon character Bolts painter, interactive 3D turn & variants
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:makerquest/widgets/frosted_glass_background.dart';
import 'package:makerquest/widgets/robot_3d_cartoon_painter.dart';
import 'package:makerquest/widgets/talking_robot_guide.dart';

void main() {
  testWidgets('TalkingRobotCharacter renders 3D cartoon painter and handles tap + 3D horizontal drag',
      (WidgetTester tester) async {
    int tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: FrostedCloudBackdrop(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: GlassSurface(
                padding: const EdgeInsets.all(20),
                child: TalkingRobotCharacter(
                  mood: RobotMood.greeting,
                  isTalking: false,
                  paintStyle: RobotPaint.cobalt,
                  hat: RobotHat.none,
                  height: 184,
                  onTap: () => tapCount++,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final painterFinder = find.byWidgetPredicate(
      (w) => w is CustomPaint && w.painter is TalkingRobot3DCartoonPainter,
    );
    expect(painterFinder, findsOneWidget);

    // Drag horizontally in 3D & spring back cleanly
    await tester.drag(find.byType(TalkingRobotCharacter), const Offset(55, 0));
    await tester.pumpAndSettle();

    // Tap still triggers high-five cleanly
    await tester.tap(find.byTooltip('Tap Bolts for a high-five!'));
    await tester.pumpAndSettle();
    expect(tapCount, 1);
  });

  testWidgets('TalkingRobot3DCartoonPainter renders all paints, hats, moods, boosters & angles cleanly',
      (WidgetTester tester) async {
    const poses = <({
      String name,
      RobotPaint paint,
      RobotHat hat,
      RobotMood mood,
      bool boosters,
      bool dancing,
      bool talking,
      double yaw,
      double pitch,
    })>[
      (
        name: 'Cobalt Hero Greeting',
        paint: RobotPaint.cobalt,
        hat: RobotHat.none,
        mood: RobotMood.greeting,
        boosters: false,
        dancing: false,
        talking: false,
        yaw: 0.12,
        pitch: -0.04,
      ),
      (
        name: 'Solar Crown Boosters',
        paint: RobotPaint.amber,
        hat: RobotHat.crown,
        mood: RobotMood.excited,
        boosters: true,
        dancing: false,
        talking: true,
        yaw: -0.45,
        pitch: 0.08,
      ),
      (
        name: 'Mint Cap Explaining',
        paint: RobotPaint.mint,
        hat: RobotHat.cap,
        mood: RobotMood.explaining,
        boosters: true,
        dancing: false,
        talking: false,
        yaw: 0.42,
        pitch: 0.02,
      ),
      (
        name: 'Cosmic Shades Dancing',
        paint: RobotPaint.magenta,
        hat: RobotHat.visor,
        mood: RobotMood.dancing,
        boosters: false,
        dancing: true,
        talking: true,
        yaw: -0.25,
        pitch: -0.05,
      ),
      (
        name: 'Cobalt TopHat Thinking',
        paint: RobotPaint.cobalt,
        hat: RobotHat.topHat,
        mood: RobotMood.thinking,
        boosters: false,
        dancing: false,
        talking: false,
        yaw: 0.25,
        pitch: -0.10,
      ),
    ];

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const cellW = 240.0;
    const cellH = 240.0;
    final totalW = cellW * poses.length;

    // Frosted sky backing matching real stage
    canvas.drawRect(
      Rect.fromLTWH(0, 0, totalW, cellH),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFEAF2FF), Color(0xFFF6F4FF), Color(0xFFECFEFF)],
        ).createShader(Rect.fromLTWH(0, 0, totalW, cellH)),
    );

    for (int i = 0; i < poses.length; i++) {
      final p = poses[i];
      canvas.save();
      canvas.translate(i * cellW + 18, 22);
      final painter = TalkingRobot3DCartoonPainter(
        idle: 0.25,
        entrance: 1.0,
        rawEntrance: 1.0,
        tapBounce: 0.0,
        confettiProgress: 0.0,
        mood: p.mood,
        isTalking: p.talking,
        paintStyle: p.paint,
        hat: p.hat,
        hasBoosters: p.boosters,
        isDancing: p.dancing,
        userYaw: p.yaw,
        userPitch: p.pitch,
      );
      painter.paint(canvas, const Size(204, 188));
      canvas.restore();
    }

    final picture = recorder.endRecording();
    final byteData = await tester.runAsync(() async {
      final img = await picture.toImage(totalW.toInt(), cellH.toInt());
      return img.toByteData(format: ui.ImageByteFormat.png);
    });
    expect(byteData, isNotNull);
    expect(byteData!.lengthInBytes, greaterThan(1000));

    const dumpPath = String.fromEnvironment('DUMP_ROBOT_PREVIEW');
    if (dumpPath.isNotEmpty) {
      final f = File(dumpPath);
      f.parent.createSync(recursive: true);
      f.writeAsBytesSync(byteData.buffer.asUint8List());
    }
  });
}
