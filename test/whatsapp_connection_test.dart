// Tests for MakerQuest WhatsApp Connection (+918075971988)
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:makerquest/main.dart';
import 'package:makerquest/services/external_launcher.dart';
import 'package:makerquest/widgets/whatsapp_brand_logo.dart';

void main() {
  group('WhatsApp Connection Unit & Widget Tests', () {
    test('ExternalLauncher exposes +918075971988 and builds valid wa.me URL', () {
      expect(ExternalLauncher.whatsAppPhoneDisplay, '+918075971988');
      expect(ExternalLauncher.whatsAppDigits, '918075971988');

      final defaultUrl = ExternalLauncher.buildWhatsAppUrl();
      expect(defaultUrl, startsWith('https://wa.me/918075971988?text='));
      expect(Uri.tryParse(defaultUrl), isNotNull);

      final customUrl = ExternalLauncher.buildWhatsAppUrl(
        message: 'Help with UPI ₹199',
      );
      expect(customUrl, startsWith('https://wa.me/918075971988?text='));
      expect(Uri.decodeComponent(customUrl), contains('Help with UPI ₹199'));
    });

    testWidgets('Marketing page shows +918075971988 WhatsApp touchpoints & copy button',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const MakerQuestApp());
      await tester.pumpAndSettle();

      // Top navigation, FAB tooltip, custom vector WhatsApp logos & minimal footer expose +918075971988
      expect(find.textContaining('+918075971988'), findsWidgets);
      expect(find.byType(WhatsAppBrandLogo), findsNWidgets(2));
      expect(find.byTooltip('WhatsApp Mentor Helpline: +918075971988'), findsOneWidget);

      // Navigate to Step 4 (Pass & Mentor Help) & verify WhatsApp CTA + Copy Number
      await tester.tap(find.text('4. Pass ₹199'));
      await tester.pumpAndSettle();

      final chatBtn = find.text('Chat on WhatsApp (+918075971988)');
      await tester.ensureVisible(chatBtn);
      await tester.pumpAndSettle();
      expect(chatBtn, findsOneWidget);
      expect(find.byType(WhatsAppBrandLogo), findsNWidgets(3));

      final copyBtn = find.text('Copy Number');
      expect(copyBtn, findsOneWidget);
      await tester.tap(copyBtn);
      await tester.pumpAndSettle();

      expect(
        find.text('Copied WhatsApp number +918075971988 to clipboard!'),
        findsOneWidget,
      );

      // Checkout modal also shows WhatsApp helpline
      final getPassBtn = find.text('Get Cadet Pass ₹199');
      await tester.ensureVisible(getPassBtn);
      await tester.pumpAndSettle();
      await tester.tap(getPassBtn);
      await tester.pumpAndSettle();

      expect(find.textContaining('WhatsApp +918075971988'), findsWidgets);
    });
  });
}
