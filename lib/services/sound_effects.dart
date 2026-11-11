// Sound effects service with conditional export for Flutter Web and VM
import 'sound_effects_stub.dart'
    if (dart.library.js_interop) 'sound_effects_web.dart';

class SoundEffects {
  /// Plays a quick cheerful tap/pop sound when checking off a supply or step
  static void playPop() {
    playSoundPopImpl();
  }

  /// Plays a pleasant ascending major chime when completing a step or mission
  static void playChime() {
    playSoundChimeImpl();
  }

  /// Plays a triumphant 4-note fanfare when earning a badge or leveling up
  static void playFanfare() {
    playSoundFanfareImpl();
  }
}

