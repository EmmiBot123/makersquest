// Web Audio API implementation for MakerQuest on Flutter Web
import 'package:web/web.dart' as web;

web.AudioContext? _audioCtx;

web.AudioContext? _getAudioContext() {
  try {
    _audioCtx ??= web.AudioContext();
    if (_audioCtx?.state == 'suspended') {
      _audioCtx?.resume();
    }
    return _audioCtx;
  } catch (_) {
    return null;
  }
}

void playSoundPopImpl() {
  try {
    final ctx = _getAudioContext();
    if (ctx == null) return;
    final osc = ctx.createOscillator();
    final gain = ctx.createGain();
    osc.connect(gain);
    gain.connect(ctx.destination);
    osc.type = 'sine';
    final now = ctx.currentTime;
    osc.frequency.setValueAtTime(520, now);
    gain.gain.setValueAtTime(0.08, now);
    gain.gain.exponentialRampToValueAtTime(0.001, now + 0.08);
    osc.start(now);
    osc.stop(now + 0.08);
  } catch (_) {}
}

void playSoundChimeImpl() {
  try {
    final ctx = _getAudioContext();
    if (ctx == null) return;
    final now = ctx.currentTime;
    final freqs = [523.25, 659.25, 783.99]; // C5, E5, G5
    for (int i = 0; i < freqs.length; i++) {
      final osc = ctx.createOscillator();
      final gain = ctx.createGain();
      osc.connect(gain);
      gain.connect(ctx.destination);
      osc.type = 'triangle';
      final noteStart = now + (i * 0.08);
      osc.frequency.setValueAtTime(freqs[i], noteStart);
      gain.gain.setValueAtTime(0.1, noteStart);
      gain.gain.exponentialRampToValueAtTime(0.001, noteStart + 0.2);
      osc.start(noteStart);
      osc.stop(noteStart + 0.2);
    }
  } catch (_) {}
}

void playSoundFanfareImpl() {
  try {
    final ctx = _getAudioContext();
    if (ctx == null) return;
    final now = ctx.currentTime;
    final notes = [523.25, 659.25, 783.99, 1046.50]; // C5, E5, G5, C6
    for (int i = 0; i < notes.length; i++) {
      final osc = ctx.createOscillator();
      final gain = ctx.createGain();
      osc.connect(gain);
      gain.connect(ctx.destination);
      osc.type = 'triangle';
      final noteStart = now + (i * 0.1);
      final dur = (i == notes.length - 1) ? 0.35 : 0.12;
      osc.frequency.setValueAtTime(notes[i], noteStart);
      gain.gain.setValueAtTime(0.12, noteStart);
      gain.gain.exponentialRampToValueAtTime(0.001, noteStart + dur);
      osc.start(noteStart);
      osc.stop(noteStart + dur);
    }
  } catch (_) {}
}

void playSoundRobotBeepImpl() {
  try {
    final ctx = _getAudioContext();
    if (ctx == null) return;
    final now = ctx.currentTime;
    final notes = [880.0, 1174.66, 698.46, 1318.51];
    final offsets = [0.0, 0.055, 0.11, 0.165];
    for (int i = 0; i < notes.length; i++) {
      final osc = ctx.createOscillator();
      final gain = ctx.createGain();
      osc.connect(gain);
      gain.connect(ctx.destination);
      osc.type = 'sine';
      final t = now + offsets[i];
      osc.frequency.setValueAtTime(notes[i], t);
      gain.gain.setValueAtTime(0.08, t);
      gain.gain.exponentialRampToValueAtTime(0.001, t + 0.07);
      osc.start(t);
      osc.stop(t + 0.07);
    }
  } catch (_) {}
}

void playSoundBoingImpl() {
  try {
    final ctx = _getAudioContext();
    if (ctx == null) return;
    final now = ctx.currentTime;
    final osc = ctx.createOscillator();
    final gain = ctx.createGain();
    osc.connect(gain);
    gain.connect(ctx.destination);
    osc.type = 'triangle';
    osc.frequency.setValueAtTime(240, now);
    osc.frequency.exponentialRampToValueAtTime(760, now + 0.16);
    gain.gain.setValueAtTime(0.11, now);
    gain.gain.exponentialRampToValueAtTime(0.001, now + 0.18);
    osc.start(now);
    osc.stop(now + 0.18);
  } catch (_) {}
}

void playSoundBoostImpl() {
  try {
    final ctx = _getAudioContext();
    if (ctx == null) return;
    final now = ctx.currentTime;

    // 1. Sub-bass thruster ignition thump
    final subOsc = ctx.createOscillator();
    final subGain = ctx.createGain();
    subOsc.connect(subGain);
    subGain.connect(ctx.destination);
    subOsc.type = 'sine';
    subOsc.frequency.setValueAtTime(115, now);
    subOsc.frequency.exponentialRampToValueAtTime(48, now + 0.16);
    subGain.gain.setValueAtTime(0.11, now);
    subGain.gain.exponentialRampToValueAtTime(0.001, now + 0.18);
    subOsc.start(now);
    subOsc.stop(now + 0.18);

    // 2. Smooth dual-oscillator rising turbo jet whoosh (synced to ~760ms portal dive)
    for (final cfg in [
      (type: 'triangle', f0: 145.0, f1: 880.0, vol: 0.065),
      (type: 'sawtooth', f0: 152.0, f1: 920.0, vol: 0.028),
    ]) {
      final osc = ctx.createOscillator();
      final gain = ctx.createGain();
      osc.connect(gain);
      gain.connect(ctx.destination);
      osc.type = cfg.type;
      osc.frequency.setValueAtTime(cfg.f0, now + 0.05);
      osc.frequency.exponentialRampToValueAtTime(cfg.f1, now + 0.72);
      gain.gain.setValueAtTime(0.004, now + 0.05);
      gain.gain.linearRampToValueAtTime(cfg.vol, now + 0.22);
      gain.gain.exponentialRampToValueAtTime(0.001, now + 0.78);
      osc.start(now + 0.05);
      osc.stop(now + 0.78);
    }

    // 3. Portal warp sparkle shimmer right at ~760ms card reveal + touchdown chime
    final chimeNotes = [783.99, 1046.50, 1318.51, 1567.98];
    for (int i = 0; i < chimeNotes.length; i++) {
      final osc = ctx.createOscillator();
      final gain = ctx.createGain();
      osc.connect(gain);
      gain.connect(ctx.destination);
      osc.type = 'sine';
      final t = now + 0.72 + (i * 0.055);
      osc.frequency.setValueAtTime(chimeNotes[i], t);
      gain.gain.setValueAtTime(0.06, t);
      gain.gain.exponentialRampToValueAtTime(0.001, t + 0.22);
      osc.start(t);
      osc.stop(t + 0.22);
    }
  } catch (_) {}
}

void playSoundPowerUpImpl() {
  try {
    final ctx = _getAudioContext();
    if (ctx == null) return;
    final now = ctx.currentTime;
    final notes = [330.0, 440.0, 659.25, 880.0, 1318.51];
    for (int i = 0; i < notes.length; i++) {
      final osc = ctx.createOscillator();
      final gain = ctx.createGain();
      osc.connect(gain);
      gain.connect(ctx.destination);
      osc.type = i.isEven ? 'triangle' : 'sine';
      final t = now + (i * 0.06);
      osc.frequency.setValueAtTime(notes[i], t);
      gain.gain.setValueAtTime(0.09, t);
      gain.gain.exponentialRampToValueAtTime(0.001, t + 0.18);
      osc.start(t);
      osc.stop(t + 0.18);
    }
  } catch (_) {}
}

void playSoundBackflipImpl() {
  try {
    final ctx = _getAudioContext();
    if (ctx == null) return;
    final now = ctx.currentTime;
    final osc = ctx.createOscillator();
    final gain = ctx.createGain();
    osc.connect(gain);
    gain.connect(ctx.destination);
    osc.type = 'sine';
    osc.frequency.setValueAtTime(340, now);
    osc.frequency.exponentialRampToValueAtTime(980, now + 0.18);
    osc.frequency.exponentialRampToValueAtTime(520, now + 0.36);
    gain.gain.setValueAtTime(0.10, now);
    gain.gain.exponentialRampToValueAtTime(0.001, now + 0.38);
    osc.start(now);
    osc.stop(now + 0.38);
  } catch (_) {}
}

