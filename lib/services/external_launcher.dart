// External URL and WhatsApp connection service with conditional web/VM import
import 'external_launcher_stub.dart'
    if (dart.library.js_interop) 'external_launcher_web.dart';

class ExternalLauncher {
  /// Official MakerQuest India WhatsApp Mentor & Enrollment Helpline
  static const String whatsAppPhoneDisplay = '+918075971988';
  static const String whatsAppDigits = '918075971988';

  static String buildWhatsAppUrl({
    String message =
        'Hi MakerQuest! I would like to connect regarding the Cardboard Robotics Cadet Pass (₹199).',
  }) {
    final encoded = Uri.encodeComponent(message);
    return 'https://wa.me/$whatsAppDigits?text=$encoded';
  }

  static void openWhatsApp({String? message}) {
    openExternalUrlImpl(
      buildWhatsAppUrl(
        message: message ??
            'Hi MakerQuest! I would like to connect regarding the Cardboard Robotics Cadet Pass (₹199).',
      ),
    );
  }

  static void openExternalUrl(String url) {
    openExternalUrlImpl(url);
  }
}

