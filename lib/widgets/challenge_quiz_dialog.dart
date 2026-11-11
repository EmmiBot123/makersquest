// Interactive Checkpoint Quiz & Troubleshooting Dialog (Level 4)
import 'package:flutter/material.dart';
import '../models/challenge.dart';
import '../services/quest_state.dart';
import '../services/sound_effects.dart';
import '../theme/app_theme.dart';
import 'reward_celebration_dialog.dart';

class ChallengeQuizDialog extends StatefulWidget {
  final Challenge challenge;
  final QuestState state;

  const ChallengeQuizDialog({
    super.key,
    required this.challenge,
    required this.state,
  });

  @override
  State<ChallengeQuizDialog> createState() => _ChallengeQuizDialogState();
}

class _ChallengeQuizDialogState extends State<ChallengeQuizDialog> {
  int _currentQuestionIndex = 0;
  final Map<String, int> _selectedAnswers = {};
  bool _showHint = false;
  QuizEvaluationResult? _result;

  @override
  Widget build(BuildContext context) {
    final c = widget.challenge;
    final screenW = MediaQuery.of(context).size.width;
    final isDesktop = screenW >= 700;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 60 : 12,
        vertical: 16,
      ),
      child: Container(
        width: isDesktop ? 680 : double.infinity,
        constraints: const BoxConstraints(maxHeight: 700),
        padding: EdgeInsets.all(screenW < 420 ? 14 : 20),
        child: _result != null ? _buildResultsView() : _buildQuizRunner(c),
      ),
    );
  }

  Widget _buildQuizRunner(Challenge c) {
    final questions = c.questions;
    final q = questions[_currentQuestionIndex];
    final total = questions.length;
    final isLast = _currentQuestionIndex == total - 1;
    final selectedChoice = _selectedAnswers[q.id];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.rose.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'CHECKPOINT ${c.levelRequired}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.rose,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.emerald.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'UNLOCKS LEVEL ${c.levelTarget}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.emerald,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    c.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMain,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Progress bar
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(
                  'Scenario ${_currentQuestionIndex + 1} of $total',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                Text(
                  q.topic,
                  style: const TextStyle(fontSize: 11, color: AppColors.cyan, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (_currentQuestionIndex + 1) / total,
                minHeight: 6,
                backgroundColor: AppColors.bgSurface,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.rose),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Expanded(
          child: ListView(
            children: [
              // Scenario problem card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bgPrimary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.rose.withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.report_problem_rounded, color: AppColors.rose, size: 16),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'WORKSHOP TROUBLE REPORT:',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.rose),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      q.scenario,
                      style: const TextStyle(fontSize: 13, color: AppColors.textMain, height: 1.4),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Question
              Text(
                q.question,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textMain),
              ),

              const SizedBox(height: 12),

              // Options
              ...q.options.asMap().entries.map((entry) {
                final idx = entry.key;
                final opt = entry.value;
                final isSelected = selectedChoice == idx;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: isSelected ? AppColors.primarySoft : AppColors.bgCard,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      SoundEffects.playPop();
                      setState(() {
                        _selectedAnswers[q.id] = idx;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? AppColors.primary : AppColors.bgSurface,
                            ),
                            child: Center(
                              child: Text(
                                String.fromCharCode(65 + idx),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? Colors.white : AppColors.textMain,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              opt,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? AppColors.primary : AppColors.textMain,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              // Hint
              if (q.hint.isNotEmpty) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _showHint = !_showHint;
                      });
                    },
                    icon: const Icon(Icons.lightbulb_rounded, size: 16, color: AppColors.amber),
                    label: Text(
                      _showHint ? 'Hide Hint' : 'Need a Maker Hint?',
                      style: const TextStyle(color: AppColors.amber, fontSize: 12),
                    ),
                  ),
                ),
                if (_showHint) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      q.hint,
                      style: const TextStyle(fontSize: 12, color: AppColors.amberGlow),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Navigation Row
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton(
              onPressed: _currentQuestionIndex > 0
                  ? () {
                      setState(() {
                        _currentQuestionIndex--;
                        _showHint = false;
                      });
                    }
                  : null,
              child: const Text('Previous'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_selectedAnswers[q.id] == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please choose an answer to proceed!')),
                  );
                  return;
                }

                if (isLast) {
                  final eval = widget.state.submitQuiz(
                    challengeId: c.id,
                    studentAnswers: _selectedAnswers,
                  );

                  setState(() {
                    _result = eval;
                  });

                  if (eval.passed) {
                    SoundEffects.playFanfare();
                    showDialog(
                      context: context,
                      builder: (ctx) => RewardCelebrationDialog(
                        event: RewardEvent(
                          title: eval.leveledUp ? '🌟 LEVEL ${eval.newLevel} UNLOCKED!' : '🎯 Checkpoint Cleared!',
                          message: 'You scored ${eval.score}% and earned +${eval.xpGained} XP!',
                          icon: '🏆',
                          xpGained: eval.xpGained,
                          newBadges: eval.newBadges,
                          leveledUp: eval.leveledUp,
                          newLevel: eval.newLevel,
                        ),
                      ),
                    );
                  }
                } else {
                  setState(() {
                    _currentQuestionIndex++;
                    _showHint = false;
                  });
                }
              },
              child: Text(
                isLast ? 'Submit Diagnostic & Claim XP' : 'Next Scenario ➡️',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultsView() {
    final res = _result!;
    final passed = res.passed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Score Hero
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: passed ? AppColors.emerald.withValues(alpha: 0.15) : AppColors.rose.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: passed ? AppColors.emerald.withValues(alpha: 0.4) : AppColors.rose.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            children: [
              Text(
                passed ? '🎉' : '🔄',
                style: const TextStyle(fontSize: 36),
              ),
              const SizedBox(height: 6),
              Text(
                passed ? 'Checkpoint Mastered!' : 'Review & Retry',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textMain),
              ),
              const SizedBox(height: 4),
              Text(
                'Score: ${res.score}% (${res.correctCount} of ${res.totalQuestions} Correct)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: passed ? AppColors.emerald : AppColors.rose,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                passed
                    ? 'Earned +${res.xpGained} XP! Level ${widget.challenge.levelTarget} is unlocked.'
                    : 'A score of 65% or higher is required. Review the diagnostic explanations below!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        const Text(
          'Engineering Diagnostic Explanations:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textMain),
        ),

        const SizedBox(height: 8),

        Expanded(
          child: ListView.builder(
            itemCount: res.questionReviews.length,
            itemBuilder: (context, idx) {
              final qr = res.questionReviews[idx];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: AppColors.bgSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: qr.isCorrect ? AppColors.emerald : AppColors.rose,
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            qr.isCorrect ? '✅ Correct' : '❌ Needs Revision',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: qr.isCorrect ? AppColors.emerald : AppColors.rose,
                            ),
                          ),
                          Text(
                            qr.question.topic,
                            style: const TextStyle(fontSize: 10, color: AppColors.cyan),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        qr.question.question,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMain),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Your Choice: ${qr.studentChoice >= 0 ? qr.question.options[qr.studentChoice] : "None"}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                      if (!qr.isCorrect) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Correct Solution: ${qr.question.options[qr.question.correctIndex]}',
                          style: const TextStyle(fontSize: 12, color: AppColors.emerald, fontWeight: FontWeight.w600),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.bgPrimary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '💡 ${qr.question.explanation}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 8,
          children: [
            if (!passed)
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _result = null;
                    _currentQuestionIndex = 0;
                    _selectedAnswers.clear();
                  });
                },
                child: const Text('Retry Challenge 🔄'),
              ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Return to Quest Map'),
            ),
          ],
        ),
      ],
    );
  }
}

