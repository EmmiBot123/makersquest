// Comprehensive Mobile Viewport Responsiveness & Overflow Tests (320x640 & 360x800)
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:makerquest/data/seed_data.dart';
import 'package:makerquest/main.dart';
import 'package:makerquest/services/quest_state.dart';
import 'package:makerquest/widgets/interactive_mechanism_simulator.dart';
import 'package:makerquest/widgets/level_map_view.dart';
import 'package:makerquest/widgets/project_detail_view.dart';
import 'package:makerquest/widgets/reward_celebration_dialog.dart';

Future<void> _setMobileViewport(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
}

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
  const viewports = <Size>[
    Size(320, 640),
    Size(360, 800),
  ];

  group('Mobile Responsiveness Tests (No RenderFlex Overflows or Layout Errors)', () {
    for (final size in viewports) {
      testWidgets('Talking robot guided stage, examples, planner & checkout fit at ${size.width.toInt()}x${size.height.toInt()}', (tester) async {
        final capturedErrors = <String>[];
        final prevOnError = FlutterError.onError;
        FlutterError.onError = (details) {
          capturedErrors.add(details.exceptionAsString());
          prevOnError?.call(details);
        };

        await _setMobileViewport(tester, size);
        addTearDown(() {
          FlutterError.onError = prevOnError;
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(const MakerQuestApp());
        await tester.pumpAndSettle();

        expect(find.byType(NavigationRail), findsNothing);
        expect(find.byType(NavigationBar), findsNothing);
        expect(find.text('Turn Cardboard into Real Robotics.'), findsOneWidget);
        expect(find.text('BOLTS'), findsOneWidget);

        // Stage 0: Scrap workbench taps & CAD Preview
        await _scrollCenterAndTap(tester, find.text('Delivery Box'));
        await _scrollCenterAndTap(tester, find.text('Straws'));
        await _scrollCenterAndTap(tester, find.text('Rubber Band'));
        expect(find.textContaining('RUNNING FROM SCRAPS'), findsOneWidget);

        await _scrollCenterAndTap(tester, find.text('Preview 3D CAD'));
        expect(find.text('Sample 3D CAD Blueprint Preview'), findsOneWidget);
        await tester.tap(find.text('Close Preview'));
        await tester.pumpAndSettle();

        // Stage 1: All 4 interactive machine playgrounds
        await _scrollCenterAndTap(tester, find.text('2. Examples'));
        for (final machine in ['Scissor Lift', 'Torque Racer', 'Claw Gripper', 'Gravity Coaster']) {
          await _scrollCenterAndTap(tester, find.text(machine));
        }
        await _scrollCenterAndTap(tester, find.text('Drop Marble 🔮'));

        // Stage 2: Minimal planner & drafting hologram
        await _scrollCenterAndTap(tester, find.text('3. Your Plan'));
        await _scrollCenterAndTap(tester, find.text('Let Bolts Draft My Plan 🤖✨'));
        await tester.pump(const Duration(milliseconds: 1200));
        await tester.pumpAndSettle();
        expect(find.text('Kinetic Drive Pioneer'), findsOneWidget);

        // Stage 3: Minimal Cadet Pass & Ask Bolts Q&A
        await _scrollCenterAndTap(tester, find.text('4. Pass ₹199'));
        await _scrollCenterAndTap(tester, find.text('📦 Do we need kits?'));
        expect(find.textContaining('Zero kits!'), findsOneWidget);

        // Open Checkout modal and test promo + UPI layout
        await _scrollCenterAndTap(tester, find.textContaining('Unlock Workshop Now (₹199) 🚀'));
        expect(find.text('Secure Checkout'), findsOneWidget);

        final promoField = find.byWidgetPredicate(
          (w) => w is TextField && (w.decoration?.hintText?.contains('Promo code') ?? false),
        );
        await tester.enterText(promoField, 'MAKER100');
        await tester.tap(find.text('Apply'));
        await tester.pumpAndSettle();

        await _scrollCenterAndTap(tester, find.textContaining('Activate Cadet Journey'));
        await tester.pump(const Duration(milliseconds: 1700));
        await tester.pumpAndSettle();

        expect(find.text('Enrollment Successful! 🏆'), findsOneWidget);
        await tester.tap(find.textContaining('Launch Cadet Workshop Now'));
        await tester.pumpAndSettle();

        // Enrolled mobile shell uses bottom NavigationBar and NO NavigationRail
        expect(find.byType(NavigationRail), findsNothing);
        expect(find.byType(NavigationBar), findsOneWidget);

        FlutterError.onError = prevOnError;
        expect(capturedErrors, isEmpty, reason: 'Expected zero FlutterError layout issues on ${size.width}x${size.height}');
      });

      testWidgets('Enrolled workshop tabs, dialogs, LevelMap modes & Notebook fit at ${size.width.toInt()}x${size.height.toInt()}', (tester) async {
        final capturedErrors = <String>[];
        final prevOnError = FlutterError.onError;
        FlutterError.onError = (details) {
          capturedErrors.add(details.exceptionAsString());
          prevOnError?.call(details);
        };

        await _setMobileViewport(tester, size);
        addTearDown(() {
          FlutterError.onError = prevOnError;
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(const MakerQuestApp());
        await tester.pumpAndSettle();

        // Unlock workshop via top bar CTA with MAKER100
        await _scrollCenterAndTap(
          tester,
          find.text(size.width < 420 ? 'Pass ₹199' : 'Get Cadet Pass ₹199'),
        );

        final promoField = find.byWidgetPredicate(
          (w) => w is TextField && (w.decoration?.hintText?.contains('Promo code') ?? false),
        );
        await tester.enterText(promoField, 'MAKER100');
        await tester.tap(find.text('Apply'));
        await tester.pumpAndSettle();

        await _scrollCenterAndTap(tester, find.textContaining('Activate Cadet Journey'));
        await tester.pump(const Duration(milliseconds: 1700));
        await tester.pumpAndSettle();

        await tester.tap(find.textContaining('Launch Cadet Workshop Now'));
        await tester.pumpAndSettle();

        // 1. Quest Map (Winding Trail + Blueprint Tree)
        await tester.dragUntilVisible(
          find.text('Level Progression Map'),
          find.byType(ListView).first,
          const Offset(0, -350),
        );
        await tester.pumpAndSettle();
        expect(find.text('Level Progression Map'), findsOneWidget);

        await _scrollCenterAndTap(tester, find.textContaining('Blueprint Tree'));
        await _scrollCenterAndTap(tester, find.textContaining('Quest Trail'));

        final scissorStation = find.descendant(
          of: find.byType(LevelMapView),
          matching: find.text('Scissor Lift'),
        );
        await tester.dragUntilVisible(
          scissorStation,
          find.byType(ListView).first,
          const Offset(0, -300),
        );
        await _scrollCenterAndTap(tester, scissorStation);
        expect(find.text('Launch Mission Blueprint 🚀'), findsOneWidget);
        await tester.tap(find.text('Back to Roadmap'));
        await tester.pumpAndSettle();

        // 2. DIY Projects Catalog + ProjectDetailView 3 tabs
        await tester.tap(find.byIcon(Icons.handyman_rounded));
        await tester.pumpAndSettle();
        expect(find.text('WHAT MATERIALS DO YOU HAVE AT HOME?'), findsOneWidget);

        await _scrollCenterAndTap(tester, find.textContaining('Cardboard Scissor Lift').first);

        expect(find.text('THE SCIENCE BEHIND THIS BUILD'), findsOneWidget);
        await tester.drag(find.byType(ListView).last, const Offset(0, -400));
        await tester.pumpAndSettle();

        await _scrollCenterAndTap(tester, find.textContaining('Step Guide'));
        await _scrollCenterAndTap(tester, find.text('Submit Proof'));

        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();

        // 3. Checkpoints & ChallengeQuizDialog
        await tester.tap(find.byIcon(Icons.quiz_rounded));
        await tester.pumpAndSettle();
        final startQuizFinder = find.textContaining('Start Checkpoint Simulation');
        await tester.dragUntilVisible(
          startQuizFinder,
          find.byType(ListView).first,
          const Offset(0, -300),
        );
        await _scrollCenterAndTap(tester, startQuizFinder.first);

        expect(find.textContaining('Scenario 1 of'), findsOneWidget);
        await tester.tap(find.byIcon(Icons.close_rounded).last);
        await tester.pumpAndSettle();

        // 4. Badges Grid
        await tester.tap(find.byIcon(Icons.military_tech_rounded));
        await tester.pumpAndSettle();
        expect(find.byType(GridView), findsOneWidget);

        // 5. Maker Notebook + STEM Certificate dialog
        await tester.tap(find.byIcon(Icons.auto_stories_rounded));
        await tester.pumpAndSettle();
        expect(find.text('Engineering Logbook Entries'), findsOneWidget);
        await _scrollCenterAndTap(tester, find.text('STEM Certificate'));
        expect(find.text('Save / Print Certificate'), findsOneWidget);
        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();

        // 6. AppBar Profile PopupMenu -> Avatar Studio & Register Dialogs
        await tester.tap(find.byIcon(Icons.arrow_drop_down));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Customize Avatar & Style'));
        await tester.pumpAndSettle();
        expect(find.text('Cadet Avatar Studio'), findsOneWidget);
        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.arrow_drop_down));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Create New Cadet Profile'));
        await tester.pumpAndSettle();
        expect(find.text('Cancel'), findsOneWidget);
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // 7. Switch to Alex Rivera demo profile and verify Notebook Entry cards fit mobile
        await tester.tap(find.byIcon(Icons.arrow_drop_down));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Alex Rivera (Level 2)'));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.auto_stories_rounded));
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.text('Cadet Reflection & Discovery Log:'),
          find.byType(ListView).first,
          const Offset(0, -300),
        );
        expect(find.text('Cadet Reflection & Discovery Log:'), findsWidgets);

        FlutterError.onError = prevOnError;
        expect(capturedErrors, isEmpty, reason: 'Expected zero FlutterError layout issues on ${size.width}x${size.height}');
      });
    }

    testWidgets('All InteractiveMechanismSimulator variants, ProjectDetailView & RewardCelebrationDialog fit at 320x640', (tester) async {
      final capturedErrors = <String>[];
      final prevOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        capturedErrors.add(details.exceptionAsString());
        prevOnError?.call(details);
      };

      await _setMobileViewport(tester, const Size(320, 640));
      addTearDown(() {
        FlutterError.onError = prevOnError;
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final questState = QuestState(initiallyEnrolled: true);

      for (final project in kSeedProjects) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: InteractiveMechanismSimulator(project: project),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => RewardCelebrationDialog(
                event: RewardEvent(
                  title: 'Level Up! Mechanical Inventor Unlocked',
                  message: 'Awesome build! You earned 120 XP and mastered 0-degree cardboard flute alignment.',
                  icon: '🏆',
                  xpGained: 120,
                  newBadges: [kSeedBadges.first],
                  leveledUp: true,
                  newLevel: 2,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: ProjectDetailView(
            project: kSeedProjects.last,
            state: questState,
          ),
        ),
      );
      await tester.pumpAndSettle();

      FlutterError.onError = prevOnError;
      expect(capturedErrors, isEmpty, reason: 'Expected zero FlutterError layout issues across all simulators and dialogs');
    });
  });
}
