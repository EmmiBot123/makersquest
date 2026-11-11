// Automated verification for all 10 interactive Bolts & MakerQuest upgrades
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:makerquest/main.dart';
import 'package:makerquest/services/bolts_storage.dart';
import 'package:makerquest/services/bolts_voice_service.dart';
import 'package:makerquest/services/sound_effects.dart';
import 'package:makerquest/services/stencil_exporter.dart';

Future<void> _scrollCenterAndTap(WidgetTester tester, Finder finder) async {
  final element = finder.first.evaluate().first;
  await Scrollable.ensureVisible(
    element,
    alignment: 0.5,
    duration: Duration.zero,
  );
  await tester.pumpAndSettle();
  await tester.tap(finder.first);
  await tester.pumpAndSettle();
}

void main() {
  tearDown(() {
    BoltsVoiceService.enabled = false;
    BoltsVoiceService.debugOnSpeak = null;
    BoltsStorage.persistDuringTests = false;
    BoltsStorage.resetForTests();
    SoundEffects.enabled = true;
    StencilExporter.lastDownloadedFilename = null;
  });

  group('Services & Stencil Unit Tests', () {
    test('StencilExporter generates valid A4 SVG blueprint and triggers sample download', () {
      final svg = StencilExporter.buildScissorGrabberStencilSvg();
      expect(svg, contains('width="210mm" height="297mm" viewBox="0 0 210 297"'));
      expect(svg, contains('LINKAGE STRUT #1'));
      expect(svg, contains('CLAW JAW #1'));
      expect(svg, contains('SLIDE GRIP HANDLE'));
      expect(svg, contains('Calibration Check: Should measure 5.0 cm'));

      StencilExporter.downloadScissorStencil();
      expect(StencilExporter.lastDownloadedFilename, StencilExporter.sampleFilename);
    });

    test('BoltsVoiceService strips emojis cleanly and respects enabled toggle', () {
      expect(
        BoltsVoiceService.cleanForSpeech('🤖 ₹199 — 4× stronger + fun! 🚀'),
        '199 rupees , 4 times stronger plus fun!',
      );

      final spoken = <String>[];
      BoltsVoiceService.debugOnSpeak = spoken.add;
      BoltsVoiceService.enabled = false;
      BoltsVoiceService.speak('Should not speak when muted');
      expect(spoken, isEmpty);

      BoltsVoiceService.enabled = true;
      BoltsVoiceService.speak('Beep-boop! ₹199 once!');
      expect(spoken, ['Beep-boop! 199 rupees once!']);
    });

    test('BoltsSavedState round-trips paint, hats, XP & cleared mini-game records', () {
      const original = BoltsSavedState(
        paintName: 'cosmic',
        hatName: 'crown',
        hasBoosters: true,
        soundEnabled: false,
        voiceEnabled: true,
        isRainbowMode: true,
        highFives: 7,
        demoXp: 85,
        racerBestMeters: 5.4,
        catapultBestStreak: 3,
        skyGearsBest: 5,
        clearedChallenges: {'scissor', 'racer', 'catapult'},
      );

      final decoded = BoltsSavedState.fromJson(original.toJson());
      expect(decoded.paintName, 'cosmic');
      expect(decoded.hatName, 'crown');
      expect(decoded.hasBoosters, isTrue);
      expect(decoded.soundEnabled, isFalse);
      expect(decoded.voiceEnabled, isTrue);
      expect(decoded.isRainbowMode, isTrue);
      expect(decoded.highFives, 7);
      expect(decoded.demoXp, 85);
      expect(decoded.racerBestMeters, 5.4);
      expect(decoded.catapultBestStreak, 3);
      expect(decoded.skyGearsBest, 5);
      expect(decoded.clearedChallenges, {'scissor', 'racer', 'catapult'});
    });
  });

  testWidgets('Full desktop flow: voice, power cell, commands, free-flight, 5 mini-games, A4 stencil & Demo XP carryover', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final spokenPhrases = <String>[];
    BoltsVoiceService.debugOnSpeak = spokenPhrases.add;

    await tester.pumpWidget(const MakerQuestApp());
    await tester.pumpAndSettle();

    // 1. Real Spoken Voice Toggle
    await tester.tap(find.text('Voice'));
    await tester.pumpAndSettle();
    expect(find.text('Voice On'), findsOneWidget);
    expect(spokenPhrases.any((s) => s.contains('Voice module online')), isTrue);

    // 2. Power Cell Charge + Demo XP
    await tester.tap(find.text('Charge'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Overdrive Core'), findsOneWidget);
    expect(find.textContaining('+10 Starter XP'), findsOneWidget);

    // 3. Command Bolts ("backflip") + Prism + Joke chips
    final cmdField = find.byWidgetPredicate(
      (w) => w is TextField && (w.decoration?.hintText?.contains('Command Bolts') ?? false),
    );
    expect(cmdField, findsOneWidget);
    await Scrollable.ensureVisible(
      cmdField.first.evaluate().first,
      alignment: 0.5,
      duration: Duration.zero,
    );
    await tester.pumpAndSettle();
    await tester.enterText(cmdField, 'backflip');
    await _scrollCenterAndTap(tester, find.byIcon(Icons.send_rounded));
    expect(find.textContaining('backflip nailed'), findsOneWidget);

    await _scrollCenterAndTap(tester, find.text('🌈 Prism'));
    expect(find.textContaining('PRISM HYPER-GLOW ACTIVATED'), findsOneWidget);

    await _scrollCenterAndTap(tester, find.text('😄 Joke'));

    // 4. Free-Flight Arcade Overlay + Landing
    await _scrollCenterAndTap(tester, find.text('Fly'));
    expect(find.text('✈️ DRAG OR TAP TO STEER BOLTS!'), findsOneWidget);
    expect(find.text('Land Bolts ⬇'), findsOneWidget);
    await tester.tap(find.text('Land Bolts ⬇'));
    await tester.pumpAndSettle();
    expect(find.text('✈️ DRAG OR TAP TO STEER BOLTS!'), findsNothing);

    // 5. Free Printable A4 Stencil Download inside 3D CAD Modal
    await _scrollCenterAndTap(tester, find.text('Preview 3D CAD'));
    final downloadStencilBtn = find.text('Download Free A4 Stencil 📐');
    expect(downloadStencilBtn, findsOneWidget);
    await tester.tap(downloadStencilBtn);
    await tester.pumpAndSettle();
    expect(StencilExporter.lastDownloadedFilename, StencilExporter.sampleFilename);
    await tester.tap(find.text('Close Preview'));
    await tester.pumpAndSettle();

    // 6. All 5 Interactive Physics Mini-Games Cleared (Cleared: 5/5)
    await _scrollCenterAndTap(tester, find.text('Try Live Examples'));

    await tester.tap(find.text('Lift 4× ⬆'));
    await tester.pumpAndSettle();
    expect(find.text('Cleared: 1/5 🎯'), findsOneWidget);

    await tester.tap(find.text('Torque Racer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Launch Racer 🚀'));
    await tester.pumpAndSettle();
    expect(find.text('Cleared: 2/5 🎯'), findsOneWidget);

    await tester.tap(find.text('Claw Gripper'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Target: 📦 Cube'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Target: 🥤 Cup'), findsOneWidget);
    await tester.tap(find.text('Open Jaws'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pinch Cube 🦾'));
    await tester.pumpAndSettle();
    expect(find.text('Cleared: 3/5 🎯'), findsOneWidget);

    await tester.tap(find.text('Gravity Coaster'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Drop Marble 🔮'));
    await tester.pumpAndSettle();
    expect(find.text('Cleared: 4/5 🎯'), findsOneWidget);

    await tester.tap(find.text('Catapult'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Launch Block 🎯'));
    await tester.pumpAndSettle();
    expect(find.text('Cleared: 5/5 🎯'), findsOneWidget);

    // 7. Household Scrap Matcher & Demo XP Carryover into Enrolled Workshop
    await tester.tap(find.text('Pick Builds For Me'));
    await tester.pumpAndSettle();
    expect(find.textContaining('3/4 builds ready tonight'), findsOneWidget);
    await _scrollCenterAndTap(tester, find.text('🪵 Skewers'));
    expect(find.textContaining('4/4 builds ready tonight'), findsOneWidget);

    await _scrollCenterAndTap(tester, find.text('Let Bolts Draft My Plan 🤖✨'));
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();
    expect(find.textContaining('4/4 starter builds ready TONIGHT'), findsOneWidget);
    expect(find.text('✓ Ready tonight'), findsWidgets);

    await _scrollCenterAndTap(tester, find.text('Enroll Now (₹199) 💳'));
    expect(find.textContaining('Starter XP earned with Bolts!'), findsOneWidget);

    final promoField = find.byWidgetPredicate(
      (w) => w is TextField && (w.decoration?.hintText?.contains('Promo code') ?? false),
    );
    await tester.enterText(promoField, 'MAKER100');
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    await _scrollCenterAndTap(tester, find.textContaining('Activate Cadet Journey'));
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Launch Cadet Workshop Now'));
    await tester.pumpAndSettle();

    // 50 welcome + 15 landing XP + 5x15 mini-games + 10 draft = 150 total XP (above baseline 50)
    expect(find.textContaining('150'), findsWidgets);
  });

  for (final size in const [Size(320, 640), Size(360, 800)]) {
    testWidgets('All new controls fit cleanly with zero RenderFlex overflows at ${size.width.toInt()}x${size.height.toInt()}', (tester) async {
      final capturedErrors = <String>[];
      final prevOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        capturedErrors.add(details.exceptionAsString());
        prevOnError?.call(details);
      };

      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        FlutterError.onError = prevOnError;
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const MakerQuestApp());
      await tester.pumpAndSettle();

      await _scrollCenterAndTap(tester, find.text('Charge'));
      await _scrollCenterAndTap(tester, find.text('🤸 Flip'));
      await _scrollCenterAndTap(tester, find.text('🌈 Prism'));
      await _scrollCenterAndTap(tester, find.text('Voice'));

      await _scrollCenterAndTap(tester, find.text('Fly'));
      expect(find.text('Land Bolts ⬇'), findsOneWidget);
      await tester.tap(find.text('Land Bolts ⬇'));
      await tester.pumpAndSettle();

      await _scrollCenterAndTap(tester, find.text('Preview 3D CAD'));
      await tester.tap(find.text('Download Free A4 Stencil 📐'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Close Preview'));
      await tester.pumpAndSettle();

      await _scrollCenterAndTap(tester, find.text('3. Your Plan'));
      await _scrollCenterAndTap(tester, find.text('🪵 Skewers'));
      expect(find.textContaining('4/4 builds ready tonight'), findsOneWidget);

      FlutterError.onError = prevOnError;
      expect(
        capturedErrors,
        isEmpty,
        reason: 'Expected zero RenderFlex/layout errors on ${size.width}x${size.height}',
      );
    });
  }
}
