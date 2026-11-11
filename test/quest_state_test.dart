// Unit tests for MakerQuest QuestState, progression logic, checklists, and quizzes
import 'package:flutter_test/flutter_test.dart';
import 'package:makerquest/services/quest_state.dart';

void main() {
  group('QuestState Unit Tests', () {
    late QuestState state;

    setUp(() {
      state = QuestState();
    });

    test('Initial state defaults to demo cadet Alex Rivera at Level 2', () {
      expect(state.currentUser.name, 'Alex Rivera');
      expect(state.currentUser.currentLevel, 2);
      expect(state.currentUser.currentXp, 320);
      expect(state.currentUser.unlockedBadges.contains('badge_first_spark'), isTrue);
      expect(state.currentUser.unlockedBadges.contains('badge_cardboard_pioneer'), isTrue);
    });

    test('Level progression gating unlocks Level 1 always, and Level 2 for Alex', () {
      expect(state.isLevelUnlocked(1), isTrue);
      expect(state.isLevelUnlocked(2), isTrue);
      // Level 3 is locked for Alex until Level 2 projects & Checkpoint 2 are passed
      expect(state.isLevelUnlocked(3), isFalse);
      expect(state.getLevelLockReason(3), contains('Level 2'));
    });

    test('Switching demo student to Sam Chen resets to Level 1 starter', () {
      state.switchDemoUser('sam@makerquest.edu');
      expect(state.currentUser.name, 'Sam Chen');
      expect(state.currentUser.currentLevel, 1);
      expect(state.currentUser.currentXp, 50);
      expect(state.isLevelUnlocked(1), isTrue);
      expect(state.isLevelUnlocked(2), isFalse);
    });

    test('Registering a new cadet gives 50 XP bonus and First Spark badge', () {
      state.registerNewCadet(
        name: 'Jordan Sparks',
        email: 'jordan@makerquest.edu',
        avatar: '🤖',
      );
      expect(state.currentUser.name, 'Jordan Sparks');
      expect(state.currentUser.currentLevel, 1);
      expect(state.currentUser.currentXp, 50);
      expect(state.currentUser.unlockedBadges, contains('badge_first_spark'));
    });

    test('Gathering 100% materials unlocks Resourceful Gatherer badge', () {
      state.switchDemoUser('sam@makerquest.edu');
      final proj = state.projects.firstWhere((p) => p.id == 'proj_scissor_lift');

      RewardEvent? lastReward;
      for (final m in proj.materialsList) {
        lastReward = state.toggleMaterialCheck(proj.id, m.id, true);
      }

      expect(lastReward, isNotNull);
      expect(lastReward!.title, contains('Badge Unlocked'));
      expect(state.currentUser.unlockedBadges, contains('badge_material_collector'));
    });

    test('Submitting project proof awards XP and updates completed state', () {
      state.switchDemoUser('sam@makerquest.edu');
      final initialXp = state.currentUser.currentXp;

      final reward = state.submitProjectProof(
        projectId: 'proj_scissor_lift',
        notes: 'Constructed scissor pantograph!',
        image: 'demo_image.jpg',
      );

      expect(state.userProgress.isProjectCompleted('proj_scissor_lift'), isTrue);
      expect(state.currentUser.currentXp, greaterThan(initialXp));
      expect(reward.xpGained, 170); // 120 project XP + 50 badge reward bonus
    });

    test('Passing Checkpoint Quiz with 100% score awards Troubleshooter Ace badge and unlocks next level', () {
      state.switchDemoUser('sam@makerquest.edu');

      // Complete Level 1 projects first
      state.submitProjectProof(projectId: 'proj_scissor_lift', notes: 'Done', image: 'img');
      state.submitProjectProof(projectId: 'proj_marble_coaster', notes: 'Done', image: 'img');

      // Take Checkpoint 1 with all correct answers: q1_1: 1, q1_2: 0, q1_3: 1
      final quizResult = state.submitQuiz(
        challengeId: 'chal_checkpoint_1',
        studentAnswers: {
          'q1_1': 1,
          'q1_2': 0,
          'q1_3': 1,
        },
      );

      expect(quizResult.passed, isTrue);
      expect(quizResult.score, 100);
      expect(quizResult.correctCount, 3);
      expect(state.currentUser.currentLevel, 2);
      expect(state.currentUser.unlockedBadges, contains('badge_troubleshooter_ace'));
      expect(state.isLevelUnlocked(2), isTrue);
    });
  });
}
