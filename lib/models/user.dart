// User Model for MakerQuest Flutter App

class User {
  final String id;
  final String name;
  final String email;
  final String avatar;
  final int currentXp;
  final int currentLevel;
  final List<String> unlockedBadges;
  final int streakDays;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar = '🚀',
    this.currentXp = 0,
    this.currentLevel = 1,
    this.unlockedBadges = const [],
    this.streakDays = 1,
  });

  String get levelTitle {
    switch (currentLevel) {
      case 1:
        return 'Cardboard Apprentice';
      case 2:
        return 'Kinetic Tinkerer';
      case 3:
        return 'Circuit Pioneer';
      case 4:
        return 'Robotics Innovator';
      case 5:
        return 'Master Maker';
      default:
        return 'Maker Cadet';
    }
  }

  String get levelTheme {
    switch (currentLevel) {
      case 1:
        return 'Cardboard Mechanics';
      case 2:
        return 'Simple Machines & Pulleys';
      case 3:
        return 'Basic Circuits & Robotics';
      case 4:
        return 'Smart Inventions & Sensors';
      case 5:
        return 'Eco-Tech & Automation';
      default:
        return 'Engineering Fundamentals';
    }
  }

  int get minXpForLevel {
    switch (currentLevel) {
      case 1: return 0;
      case 2: return 251;
      case 3: return 601;
      case 4: return 1051;
      case 5: return 1601;
      default: return 0;
    }
  }

  int get maxXpForLevel {
    switch (currentLevel) {
      case 1: return 250;
      case 2: return 600;
      case 3: return 1050;
      case 4: return 1600;
      case 5: return 9999;
      default: return 250;
    }
  }

  double get xpProgressPercent {
    if (currentLevel >= 5) return 1.0;
    final range = maxXpForLevel - minXpForLevel;
    if (range <= 0) return 1.0;
    final current = currentXp - minXpForLevel;
    if (current <= 0) return 0.0;
    final pct = current / range;
    return pct > 1.0 ? 1.0 : pct;
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatar,
    int? currentXp,
    int? currentLevel,
    List<String>? unlockedBadges,
    int? streakDays,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      currentXp: currentXp ?? this.currentXp,
      currentLevel: currentLevel ?? this.currentLevel,
      unlockedBadges: unlockedBadges ?? this.unlockedBadges,
      streakDays: streakDays ?? this.streakDays,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Cadet',
      email: json['email'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '🚀',
      currentXp: json['current_xp'] as int? ?? (json['currentXp'] as int? ?? 0),
      currentLevel: json['current_level'] as int? ?? (json['currentLevel'] as int? ?? 1),
      unlockedBadges: (json['unlocked_badges'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          (json['unlockedBadges'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      streakDays: json['streak_days'] as int? ?? (json['streakDays'] as int? ?? 1),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'current_xp': currentXp,
      'current_level': currentLevel,
      'unlocked_badges': unlockedBadges,
      'streak_days': streakDays,
    };
  }
}

