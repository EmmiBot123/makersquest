// Tests verifying Frosted Cloud Light glassmorphism & ambient background animation
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:makerquest/main.dart';
import 'package:makerquest/widgets/frosted_glass_background.dart';

void main() {
  testWidgets(
      'FrostedCloudBackdrop & GlassSurface wrap landing stage and enrolled workshop cleanly',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MakerQuestApp());
    await tester.pumpAndSettle();

    // 1. Landing stage mounts FrostedCloudBackdrop, GlassChromeBar, GlassSurface & BackdropFilter
    expect(find.byType(FrostedCloudBackdrop), findsOneWidget);
    expect(find.byType(GlassChromeBar), findsOneWidget);
    expect(find.byType(GlassSurface), findsWidgets);
    expect(find.byType(BackdropFilter), findsWidgets);

    // Paint switch updates backdrop aura cleanly without throwing
    await tester.tap(find.byTooltip('Paint Bolts: Mint'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Mint armor'), findsOneWidget);

    // 2. Enroll via MAKER100 & verify enrolled workshop shell keeps frosted backdrop & chrome
    await tester.tap(find.text('Get Cadet Pass ₹199'));
    await tester.pumpAndSettle();

    final promoField = find.byWidgetPredicate(
      (w) => w is TextField && (w.decoration?.hintText?.contains('Promo code') ?? false),
    );
    await tester.enterText(promoField, 'MAKER100');
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Activate Cadet Journey'));
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Launch Cadet Workshop Now'));
    await tester.pumpAndSettle();

    expect(find.byType(FrostedCloudBackdrop), findsOneWidget);
    expect(find.byType(GlassChromeBar), findsWidgets);
    expect(find.byType(GlassSurface), findsWidgets);
    expect(find.byType(NavigationRail), findsOneWidget);
  });

  testWidgets('FrostedCloudBackdrop and GlassSurface work on 320x640 mobile with zero errors',
      (WidgetTester tester) async {
    final errors = <String>[];
    final prevOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      errors.add(details.exceptionAsString());
      prevOnError?.call(details);
    };

    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(() {
      FlutterError.onError = prevOnError;
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: FrostedCloudBackdrop(
          accentColor: Color(0xFFEC4899),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: GlassSurface(
                  padding: EdgeInsets.all(16),
                  child: Text('Frosted Mobile Card'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Frosted Mobile Card'), findsOneWidget);
    expect(find.byType(BackdropFilter), findsOneWidget);
    expect(errors, isEmpty);
  });
}
