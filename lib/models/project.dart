// Project Model for MakerQuest Flutter App - Enriched for Student Learning
class MaterialItem {
  final String id;
  final String name;
  final String amount;
  final bool optional;
  final String tip;

  const MaterialItem({
    required this.id,
    required this.name,
    required this.amount,
    this.optional = false,
    this.tip = '',
  });

  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    return MaterialItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      amount: json['amount'] as String? ?? '',
      optional: json['optional'] as bool? ?? false,
      tip: json['tip'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'optional': optional,
      'tip': tip,
    };
  }
}

class ProjectStep {
  final int stepNumber;
  final String title;
  final String instruction;
  final String tip;
  final String safetyNote;
  final String visualType;

  const ProjectStep({
    required this.stepNumber,
    required this.title,
    required this.instruction,
    this.tip = '',
    this.safetyNote = '',
    this.visualType = '',
  });

  factory ProjectStep.fromJson(Map<String, dynamic> json) {
    return ProjectStep(
      stepNumber: json['step_number'] as int? ?? (json['stepNumber'] as int? ?? 1),
      title: json['title'] as String? ?? '',
      instruction: json['instruction'] as String? ?? '',
      tip: json['tip'] as String? ?? '',
      safetyNote: json['safety_note'] as String? ?? (json['safetyNote'] as String? ?? ''),
      visualType: json['visual_type'] as String? ?? (json['visualType'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'step_number': stepNumber,
      'title': title,
      'instruction': instruction,
      'tip': tip,
      'safety_note': safetyNote,
      'visual_type': visualType,
    };
  }
}

class Project {
  final String id;
  final int levelRequired;
  final String title;
  final String description;
  final String category;
  final String difficulty;
  final String estimatedTime;
  final int xpReward;
  final String? badgeReward;
  final List<MaterialItem> materialsList;
  final List<ProjectStep> steps;
  final int orderIndex;
  final String stemConcept;
  final String scienceExplanation;
  final List<String> skillsLearned;
  final String safetySupervision;
  final String ecoFriendlyRating;
  final String curriculumStandards;
  final List<String> teacherInquiryQuestions;
  final String extensionChallenge;

  const Project({
    required this.id,
    required this.levelRequired,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.estimatedTime,
    required this.xpReward,
    this.badgeReward,
    required this.materialsList,
    required this.steps,
    this.orderIndex = 1,
    this.stemConcept = 'Engineering Design',
    this.scienceExplanation = '',
    this.skillsLearned = const [],
    this.safetySupervision = 'Kid-Safe Solo',
    this.ecoFriendlyRating = '95% Recycled Household Supplies ♻️',
    this.curriculumStandards = 'NGSS 3-5-ETS1-1 Engineering Design',
    this.teacherInquiryQuestions = const [],
    this.extensionChallenge = '',
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    var rawMaterials = json['materials_list'] ?? json['materialsList'] ?? [];
    List<MaterialItem> mats = [];
    if (rawMaterials is List) {
      mats = rawMaterials.map((m) => MaterialItem.fromJson(m as Map<String, dynamic>)).toList();
    }

    var rawSteps = json['steps'] ?? [];
    List<ProjectStep> stps = [];
    if (rawSteps is List) {
      stps = rawSteps.map((s) => ProjectStep.fromJson(s as Map<String, dynamic>)).toList();
    }

    return Project(
      id: json['id'] as String? ?? '',
      levelRequired: json['level_required'] as int? ?? (json['levelRequired'] as int? ?? 1),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? 'Beginner',
      estimatedTime: json['estimated_time'] as String? ?? (json['estimatedTime'] as String? ?? '30 mins'),
      xpReward: json['xp_reward'] as int? ?? (json['xpReward'] as int? ?? 100),
      badgeReward: json['badge_reward'] as String? ?? json['badgeReward'] as String?,
      materialsList: mats,
      steps: stps,
      orderIndex: json['order_index'] as int? ?? (json['orderIndex'] as int? ?? 1),
      stemConcept: json['stem_concept'] as String? ?? (json['stemConcept'] as String? ?? 'Engineering Design'),
      scienceExplanation: json['science_explanation'] as String? ?? (json['scienceExplanation'] as String? ?? ''),
      skillsLearned: (json['skills_learned'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          (json['skillsLearned'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const [],
      safetySupervision: json['safety_supervision'] as String? ?? (json['safetySupervision'] as String? ?? 'Kid-Safe Solo'),
      ecoFriendlyRating: json['eco_friendly_rating'] as String? ?? (json['ecoFriendlyRating'] as String? ?? '95% Recycled Household Supplies ♻️'),
      curriculumStandards: json['curriculum_standards'] as String? ?? (json['curriculumStandards'] as String? ?? 'NGSS 3-5-ETS1-1 Engineering Design'),
      teacherInquiryQuestions: (json['teacher_inquiry_questions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          (json['teacherInquiryQuestions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const [],
      extensionChallenge: json['extension_challenge'] as String? ?? (json['extensionChallenge'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'level_required': levelRequired,
      'title': title,
      'description': description,
      'category': category,
      'difficulty': difficulty,
      'estimated_time': estimatedTime,
      'xp_reward': xpReward,
      'badge_reward': badgeReward,
      'materials_list': materialsList.map((m) => m.toJson()).toList(),
      'steps': steps.map((s) => s.toJson()).toList(),
      'order_index': orderIndex,
      'stem_concept': stemConcept,
      'science_explanation': scienceExplanation,
      'skills_learned': skillsLearned,
      'safety_supervision': safetySupervision,
      'eco_friendly_rating': ecoFriendlyRating,
      'curriculum_standards': curriculumStandards,
      'teacher_inquiry_questions': teacherInquiryQuestions,
      'extension_challenge': extensionChallenge,
    };
  }
}
