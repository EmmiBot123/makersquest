// Cross-platform Web Speech synthesis service for Bolts the Robot
import 'bolts_voice_service_stub.dart'
    if (dart.library.js_interop) 'bolts_voice_service_web.dart';

class BoltsVoiceService {
  static bool enabled = false;

  /// Optional test hook invoked when [speak] executes so unit tests can assert speech.
  static void Function(String spokenText)? debugOnSpeak;

  static String cleanForSpeech(String raw) {
    var cleaned = raw
        .replaceAll('₹199', '199 rupees')
        .replaceAll('₹', 'rupees ')
        .replaceAll('×', ' times ')
        .replaceAll('→', ' to ')
        .replaceAll('—', ', ')
        .replaceAll('+', ' plus ');
    // Strip non-BMP emoji & variation selectors so speech engines read smooth prose
    cleaned = cleaned.replaceAll(
      RegExp(r'[\u{1F000}-\u{1FFFF}\u{2600}-\u{27BF}\uFE0F]', unicode: true),
      ' ',
    );
    return cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static void speak(String rawText) {
    if (!enabled) return;
    final clean = cleanForSpeech(rawText);
    if (clean.isEmpty) return;
    debugOnSpeak?.call(clean);
    speakRobotTextImpl(clean);
  }

  static void stop() {
    stopRobotSpeechImpl();
  }
}
