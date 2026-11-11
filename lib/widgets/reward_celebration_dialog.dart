// Reward Celebration Modal Dialog (Level 4 & 5)
import 'package:flutter/material.dart';
import '../services/quest_state.dart';
import '../theme/app_theme.dart';
import 'frosted_glass_background.dart';

class RewardCelebrationDialog extends StatelessWidget {
  final RewardEvent event;

  const RewardCelebrationDialog({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    final isCompact = screenW < 420;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: isCompact ? 14 : 40, vertical: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: GlassSurface(
          borderRadius: 24,
          blurSigma: 18,
          tintColor: AppColors.amber,
          borderColor: AppColors.amber.withValues(alpha: 0.72),
          borderWidth: 2,
          child: SingleChildScrollView(
          padding: EdgeInsets.all(isCompact ? 18 : 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Text(
                event.icon,
                style: const TextStyle(fontSize: 54),
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                event.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 8),

              // Message
              Text(
                event.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                  height: 1.4,
                ),
              ),

              if (event.xpGained > 0) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.amber, Color(0xFFD97706)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.amber.withValues(alpha: 0.4),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    '+${event.xpGained} XP',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],

              if (event.newBadges.isNotEmpty) ...[
                const SizedBox(height: 18),
                const Text(
                  'NEW BADGES UNLOCKED:',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.amber,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: event.newBadges.map((b) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.bgPrimary,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.amber.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(b.icon, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              b.title,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMain,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Awesome! 🚀',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
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
}

