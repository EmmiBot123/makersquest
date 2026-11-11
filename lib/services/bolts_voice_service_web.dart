// Web Speech API implementation for Bolts the Robot on Flutter Web
import 'package:web/web.dart' as web;

void speakRobotTextImpl(String text) {
  try {
    final synth = web.window.speechSynthesis;
    synth.cancel();
    final utter = web.SpeechSynthesisUtterance(text);
    utter.lang = 'en-IN';
    utter.pitch = 1.18;
    utter.rate = 1.04;
    utter.volume = 0.85;
    synth.speak(utter);
  } catch (_) {}
}

void stopRobotSpeechImpl() {
  try {
    web.window.speechSynthesis.cancel();
  } catch (_) {}
}
