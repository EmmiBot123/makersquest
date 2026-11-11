// Browser localStorage persistence for customized Bolts, starter demo XP & mini-game records
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'bolts_storage_stub.dart'
    if (dart.library.js_interop) 'bolts_storage_web.dart';

class BoltsSavedState {
  final String paintName;
  final String hatName;
  final bool hasBoosters;
  final bool soundEnabled;
  final bool voiceEnabled;
  final bool isRainbowMode;
  final int highFives;
  final int demoXp;
  final double racerBestMeters;
  final int catapultBestStreak;
  final int skyGearsBest;
  final Set<String> clearedChallenges;
  final String sceneTheme;
  final int sandboxStars;

  const BoltsSavedState({
    this.paintName = 'cobalt',
    this.hatName = 'none',
    this.hasBoosters = false,
    this.soundEnabled = true,
    this.voiceEnabled = false,
    this.isRainbowMode = false,
    this.highFives = 0,
    this.demoXp = 0,
    this.racerBestMeters = 0.0,
    this.catapultBestStreak = 0,
    this.skyGearsBest = 0,
    this.clearedChallenges = const {},
    this.sceneTheme = 'cloud',
    this.sandboxStars = 0,
  });

  Map<String, dynamic> toJson() => {
        'paintName': paintName,
        'hatName': hatName,
        'hasBoosters': hasBoosters,
        'soundEnabled': soundEnabled,
        'voiceEnabled': voiceEnabled,
        'isRainbowMode': isRainbowMode,
        'highFives': highFives,
        'demoXp': demoXp,
        'racerBestMeters': racerBestMeters,
        'catapultBestStreak': catapultBestStreak,
        'skyGearsBest': skyGearsBest,
        'clearedChallenges': clearedChallenges.toList(),
        'sceneTheme': sceneTheme,
        'sandboxStars': sandboxStars,
      };

  factory BoltsSavedState.fromJson(Map<String, dynamic> map) {
    final rawCleared = map['clearedChallenges'];
    final cleared = <String>{};
    if (rawCleared is List) {
      for (final item in rawCleared) {
        if (item is String) cleared.add(item);
      }
    }
    return BoltsSavedState(
      paintName: map['paintName'] as String? ?? 'cobalt',
      hatName: map['hatName'] as String? ?? 'none',
      hasBoosters: map['hasBoosters'] as bool? ?? false,
      soundEnabled: map['soundEnabled'] as bool? ?? true,
      voiceEnabled: map['voiceEnabled'] as bool? ?? false,
      isRainbowMode: map['isRainbowMode'] as bool? ?? false,
      highFives: (map['highFives'] as num?)?.toInt() ?? 0,
      demoXp: (map['demoXp'] as num?)?.toInt() ?? 0,
      racerBestMeters: (map['racerBestMeters'] as num?)?.toDouble() ?? 0.0,
      catapultBestStreak: (map['catapultBestStreak'] as num?)?.toInt() ?? 0,
      skyGearsBest: (map['skyGearsBest'] as num?)?.toInt() ?? 0,
      clearedChallenges: cleared,
      sceneTheme: map['sceneTheme'] as String? ?? 'cloud',
      sandboxStars: (map['sandboxStars'] as num?)?.toInt() ?? 0,
    );
  }
}

class BoltsStorage {
  static const String _storageKey = 'makerquest_bolts_state_v1';

  /// Disabled in unrelated VM tests to avoid state leaks; dedicated tests can set true.
  static bool persistDuringTests = false;

  static bool get _shouldAccessStore {
    final inTest =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    return !inTest || persistDuringTests;
  }

  static BoltsSavedState load() {
    if (!_shouldAccessStore) return const BoltsSavedState();
    try {
      final raw = loadStorageValueImpl(_storageKey);
      if (raw == null || raw.isEmpty) return const BoltsSavedState();
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return BoltsSavedState.fromJson(decoded);
      }
    } catch (_) {}
    return const BoltsSavedState();
  }

  static void save(BoltsSavedState state) {
    if (!_shouldAccessStore) return;
    try {
      saveStorageValueImpl(_storageKey, jsonEncode(state.toJson()));
    } catch (_) {}
  }

  static void resetForTests() {
    resetStorageForTestsImpl(_storageKey);
  }
}
