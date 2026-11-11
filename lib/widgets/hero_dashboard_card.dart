// Gamified Hero Dashboard Card (Level 2)
import 'package:flutter/material.dart';
import '../services/quest_state.dart';
import '../theme/app_theme.dart';
import '../models/project.dart';

class HeroDashboardCard extends StatelessWidget {
  final QuestState state;
  final Function(Project project)? onLaunchProject;

  const HeroDashboardCard({
    super.key,
    required this.state,
    this.onLaunchProject,
  });

  @override
  Widget build(BuildContext context) {
    final user = state.currentUser;
    final isMobile = MediaQuery.of(context).size.width < 700;

    // Find next recommended project
    final nextProj = state.projects.cast<Project?>().firstWhere(
          (p) =>
              p != null &&
              p.levelRequired <= user.currentLevel &&
              !state.userProgress.isProjectCompleted(p.id),
          orElse: () => null,
        );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.bgSecondary,
            AppColors.bgPrimary.withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Row: Avatar + Level Meta + XP Bar
          if (!isMobile)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildAvatarBubble(user.avatar),
                const SizedBox(width: 20),
                Expanded(child: _buildGreeting(user)),
                const SizedBox(width: 20),
                SizedBox(
                  width: 300,
                  child: _buildXpBox(user),
                ),
              ],
            )
          else ...[
            Row(
              children: [
                _buildAvatarBubble(user.avatar),
                const SizedBox(width: 16),
                Expanded(child: _buildGreeting(user)),
              ],
            ),
            const SizedBox(height: 16),
            _buildXpBox(user),
          ],

          const SizedBox(height: 20),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 16),

          // Middle: Quick Stats Grid
          Row(
            children: [
              _buildStatItem('⚡', '${user.currentXp}', 'Total XP'),
              _buildStatItem('📦', '${state.completedProjectsCount}', 'Projects Done'),
              _buildStatItem('🎯', '${state.completedChallengesCount}', 'Checkpoints Passed'),
              _buildStatItem('🏅', '${state.earnedBadgesCount} / ${state.badges.length}', 'Badges Earned'),
            ],
          ),

          // Bottom: Recommended Mission
          if (nextProj != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bolt_rounded, color: AppColors.amber, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'RECOMMENDED MISSION',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.amber,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          nextProj.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMain,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      backgroundColor: AppColors.primary,
                    ),
                    onPressed: () => onLaunchProject?.call(nextProj),
                    icon: const Icon(Icons.play_arrow_rounded, size: 18),
                    label: Text('+${nextProj.xpReward} XP'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatarBubble(String avatar) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.violet],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
      ),
      child: Center(
        child: Text(
          avatar,
          style: const TextStyle(fontSize: 32),
        ),
      ),
    );
  }

  Widget _buildGreeting(dynamic user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
              ),
              child: Text(
                'CADET: ${user.name.toUpperCase()}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.amber,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${user.streakDays} Day Streak 🔥',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.rose,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Level ${user.currentLevel}: ${user.levelTitle}',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textMain,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Active Realm: ${user.levelTheme}',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.cyan,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildXpBox(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  'Level Progression',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${user.currentXp}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.amber,
                        ),
                      ),
                      TextSpan(
                        text: ' / ${user.maxXpForLevel} XP',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textDim,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: user.xpProgressPercent,
              minHeight: 10,
              backgroundColor: AppColors.bgSurface,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.amber),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(user.xpProgressPercent * 100).round()}% towards Level ${user.currentLevel + 1}',
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textDim,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String icon, String value, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.bgPrimary.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textMain,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
