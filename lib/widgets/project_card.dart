// Project Card Widget for MakerQuest Flutter App
import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/quest_state.dart';
import '../theme/app_theme.dart';
import 'frosted_glass_background.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final QuestState state;
  final VoidCallback onOpen;

  const ProjectCard({
    super.key,
    required this.project,
    required this.state,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlocked = state.isLevelUnlocked(project.levelRequired);
    final isCompleted = state.userProgress.isProjectCompleted(project.id);
    final checkedCount = state.userProgress.getChecklistFor(project.id).length;
    final totalMaterials = project.materialsList.length;
    final gatherPercent = totalMaterials > 0 ? checkedCount / totalMaterials : 0.0;

    return GlassSurface(
      borderRadius: 18,
      blurSigma: 10,
      tintColor: isCompleted ? AppColors.amber : AppColors.primary,
      borderColor: isCompleted
          ? AppColors.amber.withValues(alpha: 0.55)
          : (isUnlocked
              ? Colors.white.withValues(alpha: 0.90)
              : Colors.white.withValues(alpha: 0.50)),
      borderWidth: isCompleted ? 1.5 : 1.2,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: isUnlocked ? onOpen : null,
          child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Tags & XP
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            'LVL ${project.levelRequired}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryLight,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.cyan.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            project.category,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.cyan,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.amber.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      '+${project.xpReward} XP',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.amber,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Title & Description
              Text(
                project.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                project.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 12),

              // Meta Tags (time, difficulty, steps)
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildTag(Icons.timer_outlined, project.estimatedTime),
                  _buildTag(Icons.speed_rounded, project.difficulty),
                  _buildTag(Icons.list_alt_rounded, '${project.steps.length} Steps'),
                ],
              ),

              const SizedBox(height: 14),

              // Materials Gathered Progress
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Flexible(
                        child: Text(
                          'Materials Gathered',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$checkedCount / $totalMaterials',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMain),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: gatherPercent,
                      minHeight: 6,
                      backgroundColor: AppColors.bgSurface,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        gatherPercent == 1.0 ? AppColors.emerald : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Bottom Button
              SizedBox(
                width: double.infinity,
                child: !isUnlocked
                    ? Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.rose.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.rose.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          '🔒 ${state.getLevelLockReason(project.levelRequired)}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11, color: AppColors.rose),
                        ),
                      )
                    : ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isCompleted ? AppColors.emerald : AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        onPressed: onOpen,
                        icon: Icon(
                          isCompleted ? Icons.emoji_events_rounded : Icons.handyman_rounded,
                          size: 16,
                        ),
                        label: Text(
                          isCompleted ? 'Review Completed Project' : 'Open DIY Blueprint & Checklist',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
