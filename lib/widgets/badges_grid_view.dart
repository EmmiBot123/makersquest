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

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final cols = w >= 900 ? 4 : (w >= 620 ? 3 : (w >= 380 ? 2 : 1));
        final spacing = cols == 1 ? 12.0 : 14.0;
        final horizontalPad = w < 420 ? 12.0 : 16.0;

        return GridView.builder(
          padding: EdgeInsets.all(horizontalPad),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            mainAxisExtent: cols == 1 ? 215 : 235,
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
                padding: EdgeInsets.all(cols <= 2 ? 12 : 14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon circle
                    Container(
                      width: 50,
                      height: 50,
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
                          style: TextStyle(fontSize: isUnlocked ? 24 : 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      b.category.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: isUnlocked ? AppColors.textMain : AppColors.textDim,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Expanded(
                      child: Text(
                        b.description,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
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
      },
    );
  }
}

