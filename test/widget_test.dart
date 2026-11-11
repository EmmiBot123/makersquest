// MakerQuest Flutter App Widget Tests: Gated Marketing & Payment Workflow
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:makerquest/main.dart';

void main() {
  testWidgets('MakerQuest gates projects behind payment and unlocks after checkout', (WidgetTester tester) async {
    // Set a desktop screen size for testing
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MakerQuestApp());
    await tester.pumpAndSettle();

    // 1. Initial State: User is NOT enrolled yet.
    // Verify Marketing & Capability Assessment Page is displayed
    expect(find.text('MakerQuest'), findsWidgets);
    expect(find.text('DIY STEM ODYSSEY'), findsWidgets);
    expect(find.text('Transform Cardboard into Real Robotics.'), findsOneWidget);
    expect(find.text('WHAT WE OFFER & WHAT WE DO'), findsOneWidget);
    expect(find.text('Discover What Your Student is Capable of Building'), findsOneWidget);

    // 2. Verify Side Bar (NavigationRail) and Workshop Projects are NOT visible before payment
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.text('Level Progression Map'), findsNothing);
    expect(find.textContaining('Cardboard Scissor Lift Mechanism'), findsNothing);

    // 3. Test "Watch 3D Schematics in Action" on the first page shows a sample preview, NOT open projects
    final watchSchematicBtn = find.textContaining('Watch 3D Schematics in Action');
    expect(watchSchematicBtn, findsOneWidget);
    await tester.tap(watchSchematicBtn);
    await tester.pumpAndSettle();

    // Verify sample preview modal is shown with lock notice
    expect(find.text('Sample 3D CAD Blueprint Preview'), findsOneWidget);
    expect(find.textContaining('Sample Blueprint Only'), findsOneWidget);
    // Projects and workshop map are STILL not open
    expect(find.text('Level Progression Map'), findsNothing);

    // Close preview modal
    await tester.tap(find.text('Close Preview'));
    await tester.pumpAndSettle();

    // 4. Test tapping "Free Student Capability Test" auto scrolls down to the assessment form
    final capabilityHeroBtn = find.textContaining('Free Student Capability Test');
    expect(capabilityHeroBtn, findsOneWidget);
    await tester.tap(capabilityHeroBtn);
    await tester.pumpAndSettle();
    expect(find.text('FREE 60-SECOND MAKER DIAGNOSTIC'), findsOneWidget);

    // Student takes the STEM Capability Diagnostic
    final analyzeBtn = find.textContaining('Analyze Maker Capability');
    expect(analyzeBtn, findsOneWidget);
    await tester.ensureVisible(analyzeBtn);
    await tester.pumpAndSettle();
    await tester.tap(analyzeBtn);
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();

    // Verify diagnostic recommendations rendered
    expect(find.textContaining('Maker Profile:'), findsOneWidget);
    expect(find.textContaining('is Capable of Building Right Now:'), findsOneWidget);

    // 5. Open Dummy Checkout Dialog
    final enrollBtn = find.textContaining('Enroll Now 💳');
    expect(enrollBtn, findsOneWidget);
    await tester.ensureVisible(enrollBtn);
    await tester.pumpAndSettle();
    await tester.tap(enrollBtn);
    await tester.pumpAndSettle();

    expect(find.text('Secure Checkout'), findsOneWidget);
    expect(find.textContaining('Cadet All-Access Pass'), findsOneWidget);

    // 6. Apply MAKER100 promo code (100% free cadet scholarship)
    final promoField = find.byWidgetPredicate((w) => w is TextField && (w.decoration?.hintText?.contains('Promo code') ?? false));
    expect(promoField, findsOneWidget);
    await tester.enterText(promoField, 'MAKER100');
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(find.textContaining('100% Free Promo Applied!'), findsOneWidget);

    // 7. Submit payment authorization
    final payBtn = find.textContaining('Activate Cadet Journey');
    expect(payBtn, findsOneWidget);
    await tester.tap(payBtn);
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    // 8. Verify celebration dialog and launch workshop
    expect(find.text('Enrollment Successful! 🏆'), findsOneWidget);
    final launchBtn = find.textContaining('Launch Cadet Workshop Now');
    expect(launchBtn, findsOneWidget);
    await tester.tap(launchBtn);
    await tester.pumpAndSettle();

    // ========================================================
    // 9. ONLY AFTER PAYMENT: SIDE BAR AND PROJECTS ARE VISIBLE!
    // ========================================================
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.text('Level Progression Map'), findsOneWidget);
    expect(find.textContaining('Cardboard Apprentice'), findsWidgets);

    // Navigate to DIY Projects tab
    final projectsNav = find.byIcon(Icons.handyman_rounded);
    expect(projectsNav, findsOneWidget);
    await tester.tap(projectsNav);
    await tester.pumpAndSettle();

    // Verify projects are now accessible
    expect(find.textContaining('Cardboard Scissor Lift'), findsWidgets);
    expect(find.textContaining('Gravity-Fed Marble Coaster'), findsWidgets);

    // Open Scissor Lift project detail
    final scissorLift = find.textContaining('Cardboard Scissor Lift').first;
    await tester.tap(scissorLift);
    await tester.pumpAndSettle();

    // Verify Science, parent guide and checklist are accessible
    expect(find.text('THE SCIENCE BEHIND THIS BUILD'), findsOneWidget);
    expect(find.textContaining('Teacher & Parent Guide'), findsOneWidget);

    // Scroll down to check checklist
    await tester.drag(find.byType(ListView).last, const Offset(0, -350));
    await tester.pumpAndSettle();
    expect(find.text('Workshop Supplies Checklist'), findsOneWidget);

    // Return to main workshop
    final backBtn = find.byType(BackButton);
    if (backBtn.evaluate().isNotEmpty) {
      await tester.tap(backBtn);
      await tester.pumpAndSettle();
    }

    // Checkpoints are now accessible
    final checkpointsNav = find.byIcon(Icons.quiz_rounded);
    expect(checkpointsNav, findsWidgets);
    await tester.tap(checkpointsNav.first);
    await tester.pumpAndSettle();
    expect(find.textContaining('Structural Mechanics & Friction Lab'), findsWidgets);

    // Notebook is accessible
    final notebookNav = find.byIcon(Icons.auto_stories_rounded);
    expect(notebookNav, findsWidgets);
    await tester.tap(notebookNav.first);
    await tester.pumpAndSettle();
    expect(find.text('Engineering Logbook Entries'), findsOneWidget);
  });
}
