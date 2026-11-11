// Badges Trophy Case Grid View Widget
import 'package:flutter/material.dart';
import '../services/quest_state.dart';
import '../theme/app_theme.dart';

class BadgesGridView extends StatelessWidget {
  final QuestState state;

  const BadgesGridView({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final unlockedIds = state.currentUser.unlockedBadges.toSet();
    final badges = state.badges;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 260,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: badges.length,
      itemBuilder: (context, idx) {
        final b = badges[idx];
        final isUnlocked = unlockedIds.contains(b.id);

        return Card(
          color: isUnlocked ? AppColors.bgSecondary : AppColors.bgSecondary.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isUnlocked ? AppColors.amber.withValues(alpha: 0.5) : AppColors.border,
              width: isUnlocked ? 1.5 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon circle
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isUnlocked ? AppColors.amber.withValues(alpha: 0.15) : AppColors.bgSurface,
                    border: Border.all(
                      color: isUnlocked ? AppColors.amber : AppColors.border,
                      width: 2,
                    ),
                    boxShadow: isUnlocked
                        ? [
                            BoxShadow(
                              color: AppColors.amber.withValues(alpha: 0.25),
                              blurRadius: 10,
                            )
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      isUnlocked ? b.icon : '🔒',
                      style: TextStyle(fontSize: isUnlocked ? 26 : 20),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  b.category.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: AppColors.cyan,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  b.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isUnlocked ? AppColors.textMain : AppColors.textDim,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  b.description,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.amber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '+${b.xpBonus} XP Bonus',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.amber,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

