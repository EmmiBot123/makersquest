// Badge Model for MakerQuest Flutter App

class MakerBadge {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String category;
  final int xpBonus;

  const MakerBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    this.xpBonus = 50,
  });

  factory MakerBadge.fromJson(Map<String, dynamic> json) {
    return MakerBadge(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? '🏅',
      category: json['category'] as String? ?? 'General',
      xpBonus: json['xp_bonus'] as int? ?? (json['xpBonus'] as int? ?? 50),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'category': category,
      'xp_bonus': xpBonus,
    };
  }
}

