// Sound effects service with conditional export for Flutter Web and VM
import 'sound_effects_stub.dart'
    if (dart.library.js_interop) 'sound_effects_web.dart';

class SoundEffects {
  /// Whether UI sound synthesis is enabled (can be toggled by kids/parents).
  static bool enabled = true;

  /// Plays a quick cheerful tap/pop sound when checking off a supply or step
  static void playPop() {
    if (!enabled) return;
    playSoundPopImpl();
  }

  /// Plays a pleasant ascending major chime when completing a step or mission
  static void playChime() {
    if (!enabled) return;
    playSoundChimeImpl();
  }

  /// Plays a triumphant 4-note fanfare when earning a badge or leveling up
  static void playFanfare() {
    if (!enabled) return;
    playSoundFanfareImpl();
  }

  /// Plays a playful R2-D2 style multi-tone robot chirp for Bolts reactions
  static void playRobotBeep() {
    if (!enabled) return;
    playSoundRobotBeepImpl();
  }

  /// Plays a bouncy spring launch sound for catapults, jumps & combos
  static void playBoing() {
    if (!enabled) return;
    playSoundBoingImpl();
  }

  /// Plays a jetpack boost ignition whoosh + portal sparkle chime when Bolts flies into a page
  static void playBoostFlight() {
    if (!enabled) return;
    playSoundBoostImpl();
  }

  /// Plays an electric supercharge power-up triad when feeding Bolts a Power Cell
  static void playPowerUp() {
    if (!enabled) return;
    playSoundPowerUpImpl();
  }

  /// Plays a playful zippy flip chirp when Bolts performs an aerial backflip
  static void playBackflip() {
    if (!enabled) return;
    playSoundBackflipImpl();
  }

  /// Plays a futuristic 360-degree levitation spin whoosh
  static void playSpinWhoosh() {
    if (!enabled) return;
    playSoundSpinWhooshImpl();
  }

  /// Plays a real-time Boombox synthesized percussion/synth note (pads 0..3)
  static void playBeatPad(int padIndex) {
    if (!enabled) return;
    playSoundBeatPadImpl(padIndex);
  }
}

