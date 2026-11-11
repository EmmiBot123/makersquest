// MakerQuest Flutter App Widget Tests: Talking-Robot Guided Landing & Payment Workflow
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:makerquest/main.dart';

void main() {
  testWidgets('MakerQuest guides users via talking robot, interactive examples & unlocks after checkout', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MakerQuestApp());
    await tester.pumpAndSettle();

    // 1. Initial Minimal Robot Stage State (NOT enrolled yet)
    expect(find.text('MakerQuest'), findsWidgets);
    expect(find.text('ROBOT GUIDE • AGES 7–16'), findsOneWidget);
    expect(find.text('Turn Cardboard into Real Robotics.'), findsOneWidget);
    expect(find.text('BOLTS'), findsOneWidget);
    expect(find.text('1. Meet Bolts'), findsOneWidget);
    expect(find.text('2. Examples'), findsOneWidget);
    expect(find.text('3. Your Plan'), findsOneWidget);
    expect(find.text('4. Pass ₹199'), findsOneWidget);

    // Side bar and workshop projects are gated before enrollment
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.text('Level Progression Map'), findsNothing);
    expect(find.textContaining('Cardboard Scissor Lift Mechanism'), findsNothing);

    // 2. Interact with Stage 1 scrap-to-robot bench
    await tester.tap(find.text('Delivery Box'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Straws'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rubber Band'));
    await tester.pumpAndSettle();
    expect(find.textContaining('RUNNING FROM SCRAPS'), findsOneWidget);

    // 3. Test "Preview 3D CAD" shows a sample preview, NOT open projects
    final previewBtn = find.text('Preview 3D CAD');
    expect(previewBtn, findsOneWidget);
    await tester.tap(previewBtn);
    await tester.pumpAndSettle();

    expect(find.text('Sample 3D CAD Blueprint Preview'), findsOneWidget);
    expect(find.textContaining('Sample Blueprint Only'), findsOneWidget);
    expect(find.text('Level Progression Map'), findsNothing);

    await tester.tap(find.text('Close Preview'));
    await tester.pumpAndSettle();

    // 4. Advance to Interactive Machine Examples & test live controls
    await tester.tap(find.text('Try Live Examples'));
    await tester.pumpAndSettle();

    expect(find.text('Scissor Lift'), findsOneWidget);
    await tester.tap(find.text('Torque Racer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Launch Racer 🚀'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Sprint Range:'), findsOneWidget);

    await tester.tap(find.text('Gravity Coaster'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Drop Marble 🔮'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Exit Speed:'), findsOneWidget);

    // 5. Advance to Your Plan & let Bolts draft the starter trajectory
    await tester.tap(find.text('Pick Builds For Me'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Racers'));
    await tester.pumpAndSettle();

    final draftBtn = find.text('Let Bolts Draft My Plan 🤖✨');
    await tester.ensureVisible(draftBtn);
    await tester.pumpAndSettle();
    await tester.tap(draftBtn);
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();

    expect(find.text('Kinetic Drive Pioneer'), findsOneWidget);
    expect(find.textContaining('Rubber-Band Wind-Up Racer'), findsOneWidget);

    // 6. Open Checkout Dialog from plan result
    final enrollBtn = find.text('Enroll Now (₹199) 💳');
    await tester.ensureVisible(enrollBtn);
    await tester.pumpAndSettle();
    await tester.tap(enrollBtn);
    await tester.pumpAndSettle();

    expect(find.text('Secure Checkout'), findsOneWidget);
    expect(find.textContaining('Cadet All-Access Pass'), findsOneWidget);

    // Apply MAKER100 promo code
    final promoField = find.byWidgetPredicate(
      (w) => w is TextField && (w.decoration?.hintText?.contains('Promo code') ?? false),
    );
    expect(promoField, findsOneWidget);
    await tester.enterText(promoField, 'MAKER100');
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(find.textContaining('100% Free Promo Applied!'), findsOneWidget);

    // Submit payment authorization
    final payBtn = find.textContaining('Activate Cadet Journey');
    await tester.tap(payBtn);
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    // Verify celebration dialog & launch workshop
    expect(find.text('Enrollment Successful! 🏆'), findsOneWidget);
    await tester.tap(find.textContaining('Launch Cadet Workshop Now'));
    await tester.pumpAndSettle();

    // 7. Enrolled workshop routes & tabs unlocked
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.text('Level Progression Map'), findsOneWidget);
    expect(find.textContaining('Cardboard Apprentice'), findsWidgets);

    final projectsNav = find.byIcon(Icons.handyman_rounded);
    await tester.tap(projectsNav);
    await tester.pumpAndSettle();

    expect(find.textContaining('Cardboard Scissor Lift'), findsWidgets);
    expect(find.textContaining('Gravity-Fed Marble Coaster'), findsWidgets);

    await tester.tap(find.textContaining('Cardboard Scissor Lift').first);
    await tester.pumpAndSettle();

    expect(find.text('THE SCIENCE BEHIND THIS BUILD'), findsOneWidget);
    expect(find.textContaining('Teacher & Parent Guide'), findsOneWidget);

    await tester.drag(find.byType(ListView).last, const Offset(0, -350));
    await tester.pumpAndSettle();
    expect(find.text('Workshop Supplies Checklist'), findsOneWidget);

    final backBtn = find.byType(BackButton);
    if (backBtn.evaluate().isNotEmpty) {
      await tester.tap(backBtn);
      await tester.pumpAndSettle();
    }

    await tester.tap(find.byIcon(Icons.quiz_rounded).first);
    await tester.pumpAndSettle();
    expect(find.textContaining('Structural Mechanics & Friction Lab'), findsWidgets);

    await tester.tap(find.byIcon(Icons.auto_stories_rounded).first);
    await tester.pumpAndSettle();
    expect(find.text('Engineering Logbook Entries'), findsOneWidget);
  });
}
