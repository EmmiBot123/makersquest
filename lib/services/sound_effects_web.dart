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

