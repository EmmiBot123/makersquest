// Challenge & Quiz Models for MakerQuest Flutter App

class QuizQuestion {
  final String id;
  final String scenario;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String hint;
  final String topic;

  const QuizQuestion({
    required this.id,
    required this.scenario,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.hint = '',
    this.topic = '',
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as String? ?? '',
      scenario: json['scenario'] as String? ?? '',
      question: json['question'] as String? ?? '',
      options: (json['options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      correctIndex: json['correct_index'] as int? ?? (json['correctIndex'] as int? ?? 0),
      explanation: json['explanation'] as String? ?? '',
      hint: json['hint'] as String? ?? '',
      topic: json['topic'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scenario': scenario,
      'question': question,
      'options': options,
      'correct_index': correctIndex,
      'explanation': explanation,
      'hint': hint,
      'topic': topic,
    };
  }
}

class Challenge {
  final String id;
  final int levelRequired;
  final int levelTarget;
  final String title;
  final String description;
  final String category;
  final String type;
  final int xpReward;
  final String? badgeReward;
  final List<QuizQuestion> questions;

  const Challenge({
    required this.id,
    required this.levelRequired,
    required this.levelTarget,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    required this.xpReward,
    this.badgeReward,
    required this.questions,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    var rawQuestions = json['questions'] ?? [];
    List<QuizQuestion> qList = [];
    if (rawQuestions is List) {
      qList = rawQuestions.map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>)).toList();
    }

    return Challenge(
      id: json['id'] as String? ?? '',
      levelRequired: json['level_required'] as int? ?? (json['levelRequired'] as int? ?? 1),
      levelTarget: json['level_target'] as int? ?? (json['levelTarget'] as int? ?? 2),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      type: json['type'] as String? ?? 'scenario_puzzle',
      xpReward: json['xp_reward'] as int? ?? (json['xpReward'] as int? ?? 150),
      badgeReward: json['badge_reward'] as String? ?? json['badgeReward'] as String?,
      questions: qList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'level_required': levelRequired,
      'level_target': levelTarget,
      'title': title,
      'description': description,
      'category': category,
      'type': type,
      'xp_reward': xpReward,
      'badge_reward': badgeReward,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}

