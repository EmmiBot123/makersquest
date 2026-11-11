// Student Maker Notebook & Engineering Portfolio View
import 'package:flutter/material.dart';
import '../services/quest_state.dart';
import '../models/project.dart';
import '../theme/app_theme.dart';
import 'project_detail_view.dart';

class MakerNotebookView extends StatefulWidget {
  final QuestState state;

  const MakerNotebookView({super.key, required this.state});

  @override
  State<MakerNotebookView> createState() => _MakerNotebookViewState();
}

class _MakerNotebookViewState extends State<MakerNotebookView> {
  String _filter = 'all'; // 'all', 'mastered', 'progress'

  @override
  Widget build(BuildContext context) {
    final user = widget.state.currentUser;
    final completedCount = widget.state.userProgress.completedProjects.length;
    final challengesCount = widget.state.userProgress.completedChallenges.length;
    final badgesCount = user.unlockedBadges.length;

    // Filter projects
    final allProjects = widget.state.projects;
    final filteredProjects = allProjects.where((p) {
      final isDone = widget.state.userProgress.isProjectCompleted(p.id);
      final checklist = widget.state.userProgress.getChecklistFor(p.id);
      final hasStarted = isDone || checklist.isNotEmpty;

      if (_filter == 'mastered') {
        return isDone;
      } else if (_filter == 'progress') {
        return hasStarted && !isDone;
      }
      return hasStarted;
    }).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // 1. Cadet Identity & Portfolio Summary Header
        _buildCadetPortfolioHeader(context, user, completedCount, challengesCount, badgesCount),

        const SizedBox(height: 16),

        // 2. Filter Bar
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            const Text(
              'Engineering Logbook Entries',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textMain),
            ),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildFilterButton('All Logs', 'all'),
                _buildFilterButton('Mastered', 'mastered'),
                _buildFilterButton('In-Progress', 'progress'),
              ],
            ),
          ],
        ),

        const SizedBox(height: 12),

        // 3. Log entries list
        if (filteredProjects.isEmpty)
          _buildEmptyState()
        else
          ...filteredProjects.map((p) => _buildNotebookEntryCard(context, p)),
      ],
    );
  }

  Widget _buildCadetPortfolioHeader(
    BuildContext context,
    dynamic user,
    int completedCount,
    int challengesCount,
    int badgesCount,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.bgCard,
            AppColors.primary.withValues(alpha: 0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar circle
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.cyan],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(user.avatar, style: const TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textMain,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.amber.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            'Level ${user.currentLevel}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.amberGlow,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.levelTitle,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.cyan,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Quick stat chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _buildStatPill('🏆 $completedCount Mastered', AppColors.emerald),
                        _buildStatPill('🎯 $challengesCount Solved', AppColors.cyan),
                        _buildStatPill('🏅 $badgesCount Badges', AppColors.amber),
                        _buildStatPill('⚡ ${user.currentXp} XP Total', AppColors.primaryLight),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),
          // Certificate Generation Action
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Text(
                'Record engineering reflections, project proofs, and verify your DIY skills.',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.amber,
                  foregroundColor: const Color(0xFF1E1B4B),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _showStemCertificateDialog(context),
                icon: const Icon(Icons.workspace_premium_rounded, size: 18),
                label: const Text(
                  'STEM Certificate',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }

  Widget _buildFilterButton(String label, String value) {
    final isSelected = _filter == value;
    return InkWell(
      onTap: () => setState(() => _filter = value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildNotebookEntryCard(BuildContext context, Project p) {
    final isDone = widget.state.userProgress.isProjectCompleted(p.id);
    final notes = widget.state.userProgress.proofNotes[p.id] ?? '';
    final proofImage = widget.state.userProgress.proofImages[p.id];
    final checklist = widget.state.userProgress.getChecklistFor(p.id);
    final steps = widget.state.userProgress.getStepsFor(p.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDone ? AppColors.emerald.withValues(alpha: 0.4) : AppColors.border,
          width: isDone ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status & Level row
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDone
                            ? AppColors.emerald.withValues(alpha: 0.15)
                            : AppColors.cyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isDone ? '✅ MASTERED' : '🔨 IN-PROGRESS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isDone ? AppColors.emerald : AppColors.cyan,
                        ),
                      ),
                    ),
                    Text(
                      'Level ${p.levelRequired} • ${p.category}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
                Text(
                  '+${p.xpReward} XP',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.amber,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Title & Science concept
            Text(
              p.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textMain),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.psychology_rounded, size: 14, color: AppColors.cyan),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    p.stemConcept,
                    style: const TextStyle(fontSize: 12, color: AppColors.cyan, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Reflection notes block (if submitted)
            if (notes.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bgPrimary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text('📝', style: TextStyle(fontSize: 14)),
                        SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Cadet Reflection & Discovery Log:',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMain,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '"$notes"',
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFFCBD5E1),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Photo / Blueprint representation
            if (proofImage != null && proofImage.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.bgPrimary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.photo_camera_rounded, size: 16, color: AppColors.emerald),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Project Proof: $proofImage',
                        style: const TextStyle(fontSize: 11, color: AppColors.emerald, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Skills & Upcycling badges
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ...p.skillsLearned.map((s) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.bgSurface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('🎯 $s', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    )),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    p.ecoFriendlyRating,
                    style: const TextStyle(fontSize: 10, color: AppColors.emerald, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Footer progress & Open Blueprint button
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                Text(
                  isDone
                      ? '5/5 Stars Fun Rating ⭐⭐⭐⭐⭐'
                      : '${checklist.length}/${p.materialsList.length} supplies • ${steps.length}/${p.steps.length} steps',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => ProjectDetailView(
                          project: p,
                          state: widget.state,
                        ),
                      ),
                    );
                  },
                  icon: Icon(isDone ? Icons.menu_book_rounded : Icons.play_arrow_rounded, size: 16),
                  label: Text(isDone ? 'Review Blueprint' : 'Continue Build'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('📖', style: TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Your Maker Notebook is Ready!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textMain),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start a DIY project, gather materials, and attach your photo proof to log your first engineering discovery.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.5),
          ),
        ],
      ),
    );
  }

  // 🎓 STEM Certificate of Achievement Dialog
  void _showStemCertificateDialog(BuildContext context) {
    final user = widget.state.currentUser;
    final completedCount = widget.state.userProgress.completedProjects.length;
    final screenSize = MediaQuery.sizeOf(context);
    final isCompact = screenSize.width < 420;

    showDialog(
      context: context,
      builder: (ctx) {
        final maxDialogH = MediaQuery.sizeOf(ctx).height * 0.88;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(isCompact ? 12 : 16),
          child: Container(
            constraints: BoxConstraints(maxWidth: 620, maxHeight: maxDialogH),
            padding: EdgeInsets.all(isCompact ? 16 : 24),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.amber, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.amber.withValues(alpha: 0.25),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Certificate Header
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('⚡', style: TextStyle(fontSize: 18)),
                              SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'MAKERQUEST STEM ACADEMY',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                    color: AppColors.amberGlow,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: isCompact ? 12 : 16),

                        Text(
                          'CERTIFICATE OF STEM MASTERY',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isCompact ? 18 : 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),

                        const SizedBox(height: 4),

                        const Text(
                          'This officially certifies that',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: AppColors.textMuted, fontStyle: FontStyle.italic),
                        ),

                        const SizedBox(height: 10),

                        // Cadet Name
                        Text(
                          user.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isCompact ? 22 : 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.cyan,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Has achieved rank Level ${user.currentLevel}: ${user.levelTitle}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.amber,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: isCompact ? 6 : 16),
                          child: Text(
                            'For successfully mastering $completedCount hands-on DIY engineering blueprints, gathering workshop materials, and passing troubleshooting scenario diagnostics.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFCBD5E1),
                              height: 1.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Official Seal & Signatures
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.bgSecondary,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Flexible(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('🎖️', style: TextStyle(fontSize: 26)),
                                    SizedBox(height: 4),
                                    Text(
                                      'Verified Blueprint Seal',
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 12),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'MakerQuest STEM Faculty',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Director of Hands-on Learning',
                                      style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Sticky bottom actions so Close/Save always remain reachable on short phones
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Close'),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Certificate downloaded for ${user.name}! 🎓'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.download_rounded, size: 16),
                      label: const Text('Save / Print Certificate'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
