// MakerQuest State Manager (ChangeNotifier)
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/project.dart';
import '../models/challenge.dart';
import '../models/badge.dart';
import '../models/user_progress.dart';
import '../data/seed_data.dart';

class RewardEvent {
  final String title;
  final String message;
  final String icon;
  final int xpGained;
  final List<MakerBadge> newBadges;
  final bool leveledUp;
  final int newLevel;

  const RewardEvent({
    required this.title,
    required this.message,
    this.icon = '🎉',
    this.xpGained = 0,
    this.newBadges = const [],
    this.leveledUp = false,
    this.newLevel = 1,
  });
}

class QuizEvaluationResult {
  final String challengeId;
  final bool passed;
  final int score;
  final int correctCount;
  final int totalQuestions;
  final int xpGained;
  final bool leveledUp;
  final int newLevel;
  final List<MakerBadge> newBadges;
  final List<QuestionReviewItem> questionReviews;

  const QuizEvaluationResult({
    required this.challengeId,
    required this.passed,
    required this.score,
    required this.correctCount,
    required this.totalQuestions,
    required this.xpGained,
    required this.leveledUp,
    required this.newLevel,
    required this.newBadges,
    required this.questionReviews,
  });
}

class QuestionReviewItem {
  final QuizQuestion question;
  final int studentChoice;
  final bool isCorrect;

  const QuestionReviewItem({
    required this.question,
    required this.studentChoice,
    required this.isCorrect,
  });
}

class QuestState extends ChangeNotifier {
  late User _currentUser;
  late UserProgress _userProgress;
  final List<Project> _projects = List.from(kSeedProjects);
  final List<Challenge> _challenges = List.from(kSeedChallenges);
  final List<MakerBadge> _badges = List.from(kSeedBadges);
  bool _isEnrolled = false; // Initially locked until payment is completed

  QuestState({bool initiallyEnrolled = false}) {
    _isEnrolled = initiallyEnrolled;
    // Default to demo student Alex Rivera (Level 2)
    _currentUser = kAlexStudent;
    _userProgress = kAlexProgress.clone();
  }

  bool get isEnrolled => _isEnrolled;

  void completeEnrollment({String? studentName, String? email, int bonusXp = 0}) {
    _isEnrolled = true;
    final safeBonus = bonusXp < 0 ? 0 : bonusXp;
    if (studentName != null && studentName.trim().isNotEmpty) {
      _currentUser = User(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        name: studentName.trim(),
        email: email != null && email.trim().isNotEmpty ? email.trim() : 'cadet@makerquest.edu',
        avatar: '🚀',
        currentXp: 100 + safeBonus, // Welcome enrollment bonus + landing demo XP
        currentLevel: 1,
        unlockedBadges: const ['badge_first_spark'],
        streakDays: 1,
      );
      _userProgress = UserProgress();
    } else if (safeBonus > 0) {
      _currentUser = _currentUser.copyWith(
        currentXp: _currentUser.currentXp + safeBonus,
      );
    }
    notifyListeners();
  }

  void bypassEnrollmentForDemo(String email) {
    _isEnrolled = true;
    switchDemoUser(email);
  }

  void setEnrolled(bool val) {
    _isEnrolled = val;
    notifyListeners();
  }

  User get currentUser => _currentUser;
  UserProgress get userProgress => _userProgress;
  List<Project> get projects => _projects;
  List<Challenge> get challenges => _challenges;
  List<MakerBadge> get badges => _badges;

  int get completedProjectsCount => _userProgress.completedProjects.length;
  int get completedChallengesCount => _userProgress.completedChallenges.length;
  int get earnedBadgesCount => _currentUser.unlockedBadges.length;

  void switchDemoUser(String email) {
    if (email.contains('sam')) {
      _currentUser = kSamStudent;
      _userProgress = kSamProgress.clone();
    } else {
      _currentUser = kAlexStudent;
      _userProgress = kAlexProgress.clone();
    }
    notifyListeners();
  }

  void updateAvatar(String newAvatar) {
    _currentUser = _currentUser.copyWith(avatar: newAvatar);
    notifyListeners();
  }

  void registerNewCadet({
    required String name,
    required String email,
    String avatar = '🚀',
    int bonusXp = 0,
  }) {
    _isEnrolled = true;
    final safeBonus = bonusXp < 0 ? 0 : bonusXp;
    _currentUser = User(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim().isEmpty ? 'Cadet' : name.trim(),
      email: email.trim(),
      avatar: avatar,
      currentXp: 50 + safeBonus, // Welcome bonus + starter demo XP earned with Bolts
      currentLevel: 1,
      unlockedBadges: const ['badge_first_spark'],
      streakDays: 1,
    );
    _userProgress = UserProgress();
    notifyListeners();
  }

  // Level Progression Unlock Verification (Level 2 requirement)
  bool isLevelUnlocked(int targetLevel) {
    if (targetLevel <= 1) return true;

    final prevLevel = targetLevel - 1;

    // Must have completed at least one project in preceding level
    final completedInPrevLevel = _projects
        .where((p) => p.levelRequired == prevLevel && _userProgress.isProjectCompleted(p.id))
        .length;

    if (completedInPrevLevel == 0) return false;

    // Must have completed checkpoint challenge for prevLevel -> targetLevel
    final chk = _challenges.cast<Challenge?>().firstWhere(
          (c) => c?.levelRequired == prevLevel && c?.levelTarget == targetLevel,
          orElse: () => null,
        );

    if (chk != null && !_userProgress.isChallengeCompleted(chk.id)) {
      return false;
    }

    return true;
  }

  String getLevelLockReason(int targetLevel) {
    if (targetLevel <= 1) return 'Level 1 is unlocked for all makers!';
    final prevLevel = targetLevel - 1;

    final completedInPrev = _projects
        .where((p) => p.levelRequired == prevLevel && _userProgress.isProjectCompleted(p.id))
        .length;

    if (completedInPrev == 0) {
      return 'Complete Level $prevLevel DIY projects before unlocking Level $targetLevel.';
    }

    final chk = _challenges.cast<Challenge?>().firstWhere(
          (c) => c?.levelRequired == prevLevel && c?.levelTarget == targetLevel,
          orElse: () => null,
        );

    if (chk != null && !_userProgress.isChallengeCompleted(chk.id)) {
      return 'Pass the Level $prevLevel Checkpoint Challenge ("${chk.title}") to unlock Level $targetLevel!';
    }

    return 'Level unlocked!';
  }

  // Materials Checklist State (Level 3 requirement)
  RewardEvent? toggleMaterialCheck(String projectId, String materialId, bool isChecked) {
    final current = Set<String>.from(_userProgress.getChecklistFor(projectId));
    if (isChecked) {
      current.add(materialId);
    } else {
      current.remove(materialId);
    }
    _userProgress.checklistState[projectId] = current;

    // Check if 100% gathered for Resourceful Gatherer badge
    final proj = _projects.firstWhere((p) => p.id == projectId);
    RewardEvent? badgeEvent;
    if (current.length == proj.materialsList.length &&
        !_currentUser.unlockedBadges.contains('badge_material_collector')) {
      final updatedBadges = List<String>.from(_currentUser.unlockedBadges)..add('badge_material_collector');
      final badge = _badges.firstWhere((b) => b.id == 'badge_material_collector');
      _currentUser = _currentUser.copyWith(
        currentXp: _currentUser.currentXp + badge.xpBonus,
        unlockedBadges: updatedBadges,
      );
      badgeEvent = RewardEvent(
        title: 'Badge Unlocked!',
        message: 'You gathered 100% of materials for ${proj.title}!',
        icon: badge.icon,
        xpGained: badge.xpBonus,
        newBadges: [badge],
      );
    }

    notifyListeners();
    return badgeEvent;
  }

  void toggleStep(String projectId, int stepNumber, bool isDone) {
    final current = Set<int>.from(_userProgress.getStepsFor(projectId));
    if (isDone) {
      current.add(stepNumber);
    } else {
      current.remove(stepNumber);
    }
    _userProgress.completedSteps[projectId] = current;
    notifyListeners();
  }

  // Submit Project Proof & XP Award (Level 3 requirement)
  RewardEvent submitProjectProof({
    required String projectId,
    required String notes,
    required String image,
  }) {
    final proj = _projects.firstWhere((p) => p.id == projectId);
    final alreadyDone = _userProgress.isProjectCompleted(projectId);

    _userProgress.completedProjects.add(projectId);
    _userProgress.proofNotes[projectId] = notes;
    _userProgress.proofImages[projectId] = image;

    int xpToAdd = alreadyDone ? 0 : proj.xpReward;
    List<MakerBadge> newBadges = [];
    List<String> updatedBadgeIds = List.from(_currentUser.unlockedBadges);

    // Award project badge if any
    if (proj.badgeReward != null && !updatedBadgeIds.contains(proj.badgeReward)) {
      updatedBadgeIds.add(proj.badgeReward!);
      final badge = _badges.cast<MakerBadge?>().firstWhere(
            (b) => b?.id == proj.badgeReward,
            orElse: () => null,
          );
      if (badge != null) {
        newBadges.add(badge);
        xpToAdd += badge.xpBonus;
      }
    }

    final newXp = _currentUser.currentXp + xpToAdd;
    int calculatedLevel = _currentUser.currentLevel;
    if (newXp >= 1601) {
      calculatedLevel = 5;
    } else if (newXp >= 1051) {
      calculatedLevel = 4;
    } else if (newXp >= 601) {
      calculatedLevel = 3;
    } else if (newXp >= 251) {
      calculatedLevel = 2;
    }

    final leveledUp = calculatedLevel > _currentUser.currentLevel;
    _currentUser = _currentUser.copyWith(
      currentXp: newXp,
      currentLevel: calculatedLevel,
      unlockedBadges: updatedBadgeIds,
    );

    notifyListeners();

    return RewardEvent(
      title: leveledUp ? '🌟 LEVEL UP!' : '🎉 Project Completed!',
      message: leveledUp
          ? 'You advanced to Level $calculatedLevel! Earned +$xpToAdd XP!'
          : 'Great engineering work! Claimed +$xpToAdd XP!',
      icon: leveledUp ? '🌟' : '🏆',
      xpGained: xpToAdd,
      newBadges: newBadges,
      leveledUp: leveledUp,
      newLevel: calculatedLevel,
    );
  }

  // Checkpoint Quiz Submission (Level 4 requirement)
  QuizEvaluationResult submitQuiz({
    required String challengeId,
    required Map<String, int> studentAnswers,
  }) {
    final chk = _challenges.firstWhere((c) => c.id == challengeId);
    final alreadyPassed = _userProgress.isChallengeCompleted(challengeId);

    int correctCount = 0;
    List<QuestionReviewItem> reviews = [];

    for (final q in chk.questions) {
      final choice = studentAnswers[q.id] ?? -1;
      final isCorrect = choice == q.correctIndex;
      if (isCorrect) correctCount++;
      reviews.add(QuestionReviewItem(
        question: q,
        studentChoice: choice,
        isCorrect: isCorrect,
      ));
    }

    final total = chk.questions.length;
    final scorePercent = ((correctCount / total) * 100).round();
    final passed = scorePercent >= 65;

    int xpToAdd = (passed && !alreadyPassed) ? chk.xpReward : 0;
    List<MakerBadge> newBadges = [];
    List<String> updatedBadgeIds = List.from(_currentUser.unlockedBadges);

    if (passed) {
      _userProgress.completedChallenges.add(challengeId);
      _userProgress.challengeScores[challengeId] = scorePercent;

      // Perfect score badge
      if (scorePercent == 100 && !updatedBadgeIds.contains('badge_troubleshooter_ace')) {
        updatedBadgeIds.add('badge_troubleshooter_ace');
        final b = _badges.firstWhere((badge) => badge.id == 'badge_troubleshooter_ace');
        newBadges.add(b);
        xpToAdd += b.xpBonus;
      }
    }

    final newXp = _currentUser.currentXp + xpToAdd;
    final newLevel = passed ? (chk.levelTarget > _currentUser.currentLevel ? chk.levelTarget : _currentUser.currentLevel) : _currentUser.currentLevel;
    final leveledUp = newLevel > _currentUser.currentLevel;

    if (passed) {
      _currentUser = _currentUser.copyWith(
        currentXp: newXp,
        currentLevel: newLevel,
        unlockedBadges: updatedBadgeIds,
      );
    }

    notifyListeners();

    return QuizEvaluationResult(
      challengeId: challengeId,
      passed: passed,
      score: scorePercent,
      correctCount: correctCount,
      totalQuestions: total,
      xpGained: xpToAdd,
      leveledUp: leveledUp,
      newLevel: newLevel,
      newBadges: newBadges,
      questionReviews: reviews,
    );
  }
}

