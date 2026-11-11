// Automated tests for Stage 5 Inventor Sandbox, 3D Trick Lab, Scene Switcher & Playable Arcade Mini-Games
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:makerquest/main.dart';
import 'package:makerquest/services/bolts_storage.dart';
import 'package:makerquest/services/sound_effects.dart';

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
    BoltsStorage.persistDuringTests = false;
    BoltsStorage.resetForTests();
    SoundEffects.enabled = true;
  });

  group('Storage & Audio Extension Unit Tests', () {
    test('BoltsSavedState round-trips sceneTheme and sandboxStars with backward-compatible defaults', () {
      const saved = BoltsSavedState(
        paintName: 'solar',
        sceneTheme: 'space',
        sandboxStars: 3,
        clearedChallenges: {'sandbox_win', 'circuit_snap'},
      );

      final roundTripped = BoltsSavedState.fromJson(saved.toJson());
      expect(roundTripped.sceneTheme, 'space');
      expect(roundTripped.sandboxStars, 3);
      expect(roundTripped.clearedChallenges, {'sandbox_win', 'circuit_snap'});

      final legacy = BoltsSavedState.fromJson(const {'paintName': 'cobalt'});
      expect(legacy.sceneTheme, 'cloud');
      expect(legacy.sandboxStars, 0);
    });

    test('New SoundEffects helpers execute cleanly under enabled/disabled states', () {
      SoundEffects.enabled = true;
      SoundEffects.playSpinWhoosh();
      for (int i = 0; i < 4; i++) {
        SoundEffects.playBeatPad(i);
      }

      SoundEffects.enabled = false;
      SoundEffects.playSpinWhoosh();
      SoundEffects.playBeatPad(0);
    });
  });

  testWidgets(
    'Desktop flow: Trick Lab, Scene Switcher, 5. Sandbox, Circuit Snapper, Trivia Duel, Boombox Beat Lab & commands',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const MakerQuestApp());
      await tester.pumpAndSettle();

      // 1. Trick Lab buttons trigger new 3D tricks & speech
      await _scrollCenterAndTap(tester, find.text('🌀 360° Spin'));
      expect(find.textContaining('360° levitation turntable spin'), findsOneWidget);

      await _scrollCenterAndTap(tester, find.text('😉 Wink & Wave'));
      expect(find.textContaining('Wink & wave'), findsOneWidget);

      await _scrollCenterAndTap(tester, find.text('🎉 Confetti Pop'));
      expect(find.textContaining('CONFETTI BLAST'), findsOneWidget);

      // 2. Scene Switcher updates frosted backdrop palette
      await _scrollCenterAndTap(tester, find.text('🌌 Orbit'));
      expect(find.textContaining('Orbital Space Lab'), findsOneWidget);

      await _scrollCenterAndTap(tester, find.text('🌅 Sunset'));
      expect(find.textContaining('Golden Workshop Sunset'), findsOneWidget);

      await _scrollCenterAndTap(tester, find.text('🔋 Cyber'));
      expect(find.textContaining('Mint Cyber Grid'), findsOneWidget);

      await _scrollCenterAndTap(tester, find.text('☁️ Cloud'));
      expect(find.textContaining('Frosted Cloud Workshop'), findsOneWidget);

      // 3. Stage 5: Inventor Sandbox + Presets + Randomizer + Test-Drive XP (+20 XP)
      await _scrollCenterAndTap(tester, find.text('5. Sandbox'));
      expect(find.text('INVENTOR SANDBOX'), findsOneWidget);

      await _scrollCenterAndTap(tester, find.text('🎈 Balloon Jet'));
      expect(find.textContaining('Balloon Jet loaded'), findsOneWidget);

      await _scrollCenterAndTap(tester, find.text('🎲 Wild Mix'));
      expect(find.textContaining('Wild Mix generated'), findsOneWidget);

      await _scrollCenterAndTap(tester, find.text('🏎️ Dragster'));
      await _scrollCenterAndTap(tester, find.text('Test-Drive Build 🚀'));
      expect(find.text('Best: ⭐⭐⭐'), findsOneWidget);
      expect(find.textContaining('+20 Starter XP'), findsOneWidget);

      // Custom part & track selection inside Sandbox
      await _scrollCenterAndTap(tester, find.text('🧱 Crate Smash'));
      await _scrollCenterAndTap(tester, find.text('📦 Box'));
      await _scrollCenterAndTap(tester, find.text('⚖️ Weight'));
      await _scrollCenterAndTap(tester, find.text('🕷️ Hex Legs'));
      await _scrollCenterAndTap(tester, find.text('✂️ Claw'));
      await _scrollCenterAndTap(tester, find.text('Test-Drive Build 🚀'));
      expect(find.textContaining('SCISSOR SNATCH!'), findsOneWidget);

      // 4. Mini-Game 1: Copper-Tape Circuit Snapper (+15 XP -> 35 XP total)
      await _scrollCenterAndTap(tester, find.text('Circuit Snapper'));
      expect(find.text('Copper-Tape Circuit Snapper'), findsOneWidget);

      // Verify diagnostic feedback before fixing wiring
      await _scrollCenterAndTap(tester, find.text('Test Circuit ⚡'));
      expect(find.textContaining('flip Battery Polarity'), findsOneWidget);

      await _scrollCenterAndTap(tester, find.text('🔋 Polarity: - Up'));
      await _scrollCenterAndTap(tester, find.text('⚡ Top Tape: Open'));
      await _scrollCenterAndTap(tester, find.text('Test Circuit ⚡'));
      expect(find.text('Circuit Lit! 🎉'), findsOneWidget);
      expect(find.textContaining('BEACON LIT!'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded).last);
      await tester.pumpAndSettle();
      expect(find.textContaining('+35 Starter XP'), findsOneWidget);

      // 5. Mini-Game 2: Beat-Bolts STEM Trivia Duel (+15 XP -> 50 XP total)
      await _scrollCenterAndTap(tester, find.text('STEM Trivia Duel'));
      expect(find.text('Beat-Bolts Trivia (1/5)'), findsOneWidget);

      const answers = [
        '300% stronger against bending',
        'Reduces sliding friction by ~60%',
        'Up to 4× higher',
        '20° inward banked walls',
        'Elastic potential energy',
      ];
      for (int i = 0; i < answers.length; i++) {
        await tester.tap(find.text(answers[i]));
        await tester.pumpAndSettle();
        final btnLabel = i < answers.length - 1 ? 'Next Question →' : 'See Final Score 🏆';
        await tester.tap(find.text(btnLabel));
        await tester.pumpAndSettle();
      }
      expect(find.text('Score: 5 / 5'), findsOneWidget);
      expect(find.textContaining('MASTER CADET!'), findsOneWidget);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.textContaining('+50 Starter XP'), findsOneWidget);

      // 6. Mini-Game 3: Bolts Boombox Beat Lab (+10 XP -> 60 XP total + Dancing mode)
      await _scrollCenterAndTap(tester, find.text('Boombox Beat Lab'));
      expect(find.text('Bolts Boombox Beat Lab'), findsOneWidget);
      await tester.tap(find.text('🥁 Box Kick'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('⚡ Zap'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Play Disco Loop ▶️ (+10 XP)'));
      await tester.pumpAndSettle();
      expect(find.text('Stop Beat ⏹'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded).last);
      await tester.pumpAndSettle();
      expect(find.textContaining('+60 Starter XP'), findsOneWidget);
      expect(find.text('Dancing'), findsOneWidget);

      // 7. Command Prompt shortcuts for new features
      final cmdField = find.byWidgetPredicate(
        (w) => w is TextField && (w.decoration?.hintText?.contains('Command Bolts') ?? false),
      );
      await Scrollable.ensureVisible(
        cmdField.first.evaluate().first,
        alignment: 0.5,
        duration: Duration.zero,
      );
      await tester.pumpAndSettle();
      await tester.enterText(cmdField, 'spin');
      await _scrollCenterAndTap(tester, find.byIcon(Icons.send_rounded));
      expect(find.textContaining('360° levitation turntable spin'), findsOneWidget);

      await tester.enterText(cmdField, 'orbit');
      await _scrollCenterAndTap(tester, find.byIcon(Icons.send_rounded));
      expect(find.textContaining('Orbital Space Lab'), findsOneWidget);

      await tester.enterText(cmdField, 'circuit');
      await _scrollCenterAndTap(tester, find.byIcon(Icons.send_rounded));
      expect(find.text('Copper-Tape Circuit Snapper'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close_rounded).last);
      await tester.pumpAndSettle();
    },
  );

  for (final size in const [Size(320, 640), Size(360, 800)]) {
    testWidgets(
      'Sandbox, Trick Lab & all 3 Arcade mini-game dialogs fit with zero RenderFlex overflows at ${size.width.toInt()}x${size.height.toInt()}',
      (tester) async {
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

        // Trick Lab + Scene Switcher
        await _scrollCenterAndTap(tester, find.text('🌀 360° Spin'));
        await _scrollCenterAndTap(tester, find.text('😉 Wink & Wave'));
        await _scrollCenterAndTap(tester, find.text('🎉 Confetti Pop'));
        await _scrollCenterAndTap(tester, find.text('🌌 Orbit'));

        // Stage 5 Sandbox on small viewport
        await _scrollCenterAndTap(tester, find.text('5. Sandbox'));
        expect(find.text('INVENTOR SANDBOX'), findsOneWidget);
        await _scrollCenterAndTap(tester, find.text('🎲 Wild Mix'));
        await _scrollCenterAndTap(tester, find.text('Test-Drive Build 🚀'));

        // All 3 Arcade Dialogs open & close cleanly without overflow
        await _scrollCenterAndTap(tester, find.text('Circuit Snapper'));
        expect(find.text('Copper-Tape Circuit Snapper'), findsOneWidget);
        await tester.tap(find.byIcon(Icons.close_rounded).last);
        await tester.pumpAndSettle();

        await _scrollCenterAndTap(tester, find.text('STEM Trivia Duel'));
        expect(find.text('Beat-Bolts Trivia (1/5)'), findsOneWidget);
        await tester.tap(find.byIcon(Icons.close_rounded).last);
        await tester.pumpAndSettle();

        await _scrollCenterAndTap(tester, find.text('Boombox Beat Lab'));
        expect(find.text('Bolts Boombox Beat Lab'), findsOneWidget);
        await tester.tap(find.byIcon(Icons.close_rounded).last);
        await tester.pumpAndSettle();

        FlutterError.onError = prevOnError;
        expect(
          capturedErrors,
          isEmpty,
          reason: 'Expected zero layout/overflow errors on ${size.width}x${size.height}',
        );
      },
    );
  }
}
