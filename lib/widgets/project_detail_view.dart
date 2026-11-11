// Interactive Detailed Project View with Student STEM Concept Explorer, Checklist & Proof Submission
import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/quest_state.dart';
import '../services/sound_effects.dart';
import '../theme/app_theme.dart';
import 'reward_celebration_dialog.dart';
import 'interactive_mechanism_simulator.dart';
import 'stem_infographics.dart';

class ProjectDetailView extends StatefulWidget {
  final Project project;
  final QuestState state;

  const ProjectDetailView({
    super.key,
    required this.project,
    required this.state,
  });

  @override
  State<ProjectDetailView> createState() => _ProjectDetailViewState();
}

class _ProjectDetailViewState extends State<ProjectDetailView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _notesController = TextEditingController();
  String _selectedProofImage = '';
  int _funRating = 5;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    final existingNotes = widget.state.userProgress.proofNotes[widget.project.id];
    final existingImage = widget.state.userProgress.proofImages[widget.project.id];
    if (existingNotes != null && existingNotes.isNotEmpty) {
      _notesController.text = existingNotes;
    }
    if (existingImage != null) {
      _selectedProofImage = existingImage;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    final isCompleted = widget.state.userProgress.isProjectCompleted(p.id);
    final isUnlocked = widget.state.isLevelUnlocked(p.levelRequired);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: Text(
          p.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.amber.withValues(alpha: 0.4)),
            ),
            child: Text(
              '+${p.xpReward} XP',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.amber,
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          tabs: [
            Tab(
              icon: const Icon(Icons.science_rounded, size: 18),
              text: 'STEM & Materials (${widget.state.userProgress.getChecklistFor(p.id).length}/${p.materialsList.length})',
            ),
            Tab(
              icon: const Icon(Icons.format_list_numbered_rounded, size: 18),
              text: 'Step Guide (${p.steps.length})',
            ),
            const Tab(
              icon: Icon(Icons.verified_rounded, size: 18),
              text: 'Submit Proof',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (!isUnlocked)
            Container(
              color: AppColors.rose.withValues(alpha: 0.15),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.lock_rounded, color: AppColors.rose, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Locked: ${widget.state.getLevelLockReason(p.levelRequired)}',
                      style: const TextStyle(fontSize: 12, color: AppColors.rose, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          if (isCompleted)
            Container(
              color: AppColors.amber.withValues(alpha: 0.15),
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events_rounded, color: AppColors.amber, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      '🏆 Mastered! You have verified and completed this DIY blueprint.',
                      style: TextStyle(fontSize: 12, color: AppColors.amberGlow, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMaterialsTab(),
                _buildStepsTab(),
                _buildProofTab(isCompleted),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TAB 1: STEM Science & Materials Checklist
  Widget _buildMaterialsTab() {
    final p = widget.project;
    final checkedSet = widget.state.userProgress.getChecklistFor(p.id);
    final count = checkedSet.length;
    final total = p.materialsList.length;
    final pct = total > 0 ? count / total : 0.0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 🔬 Student STEM Science Concept Explorer Card
        _buildStemScienceCard(p),

        const SizedBox(height: 14),

        // 👩‍🏫 Teacher & Parent Learning Guide (NGSS Aligned)
        _buildTeacherParentGuideCard(p),

        const SizedBox(height: 14),

        // 🎮 Interactive Virtual Lab & Mechanism Playground
        InteractiveMechanismSimulator(project: p),

        const SizedBox(height: 16),

        // Supplies Checklist Header & Progress Bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bgSecondary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Workshop Supplies Checklist',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textMain),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$count of $total gathered (${(pct * 100).round()}%)',
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: pct == 1.0 ? AppColors.emerald.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(pct * 100).round()}%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: pct == 1.0 ? AppColors.emerald : AppColors.primaryLight,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 8,
                  backgroundColor: AppColors.bgSurface,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    pct == 1.0 ? AppColors.emerald : AppColors.primary,
                  ),
                ),
              ),
              if (pct == 1.0) ...[
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'All parts gathered! Ready for assembly.',
                      style: TextStyle(fontSize: 12, color: AppColors.emerald, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Materials List
        ...p.materialsList.map((m) {
          final isChecked = checkedSet.contains(m.id);
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: isChecked ? AppColors.emerald.withValues(alpha: 0.08) : AppColors.bgCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isChecked ? AppColors.emerald.withValues(alpha: 0.4) : AppColors.border,
              ),
            ),
            child: CheckboxListTile(
              value: isChecked,
              activeColor: AppColors.emerald,
              onChanged: (val) {
                final isChecking = val ?? false;
                if (isChecking) {
                  SoundEffects.playPop();
                }
                final badgeEvent = widget.state.toggleMaterialCheck(p.id, m.id, isChecking);
                setState(() {});
                if (badgeEvent != null) {
                  SoundEffects.playFanfare();
                  showDialog(
                    context: context,
                    builder: (ctx) => RewardCelebrationDialog(event: badgeEvent),
                  );
                }
              },
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      m.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        decoration: isChecked ? TextDecoration.lineThrough : null,
                        color: isChecked ? AppColors.textDim : AppColors.textMain,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.cyan.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      m.amount,
                      style: const TextStyle(fontSize: 10, color: AppColors.cyan, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              subtitle: m.tip.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '💡 Student Tip: ${m.tip}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    )
                  : null,
            ),
          );
        }),

        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => _tabController.animateTo(1),
          child: const Text('Proceed to Assembly Steps ➡️'),
        ),
      ],
    );
  }

  // 🔬 Student STEM Concept Card Widget
  Widget _buildStemScienceCard(Project p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.cyan.withValues(alpha: 0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cyan.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.cyan.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.psychology_rounded, color: AppColors.cyan, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'THE SCIENCE BEHIND THIS BUILD',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.cyan,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      p.stemConcept,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMain,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (p.scienceExplanation.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              p.scienceExplanation,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 12),
          // 📊 Interactive STEM Concept Infographic Visualizer
          StemConceptInfographicWidget(
            projectId: p.id,
            conceptTitle: p.stemConcept,
          ),
          const SizedBox(height: 12),
          // Skills & Safety Badges
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ...p.skillsLearned.map((s) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.bgPrimary,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Text(
                      '🎯 $s',
                      style: const TextStyle(fontSize: 10, color: AppColors.primaryLight, fontWeight: FontWeight.w600),
                    ),
                  )),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  p.ecoFriendlyRating,
                  style: const TextStyle(fontSize: 10, color: AppColors.emerald, fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '🛡️ ${p.safetySupervision}',
                  style: const TextStyle(fontSize: 10, color: AppColors.amberGlow, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 👩‍🏫 Teacher & Parent Learning Guide Widget (NGSS Standards Aligned)
  Widget _buildTeacherParentGuideCard(Project p) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedIconColor: AppColors.textMuted,
          iconColor: AppColors.cyan,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.school_rounded, color: AppColors.primaryLight, size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Teacher & Parent Guide (NGSS Curriculum)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMain,
                  ),
                ),
              ),
            ],
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            // Standard Alignment
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_rounded, size: 14, color: AppColors.amber),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Curriculum Alignment: ${p.curriculumStandards}',
                      style: const TextStyle(fontSize: 11, color: AppColors.amberGlow, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),

            if (p.teacherInquiryQuestions.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '💬 Inquiry Discussion Prompts:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMain),
                ),
              ),
              const SizedBox(height: 6),
              ...p.teacherInquiryQuestions.map((q) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(color: AppColors.cyan, fontSize: 13)),
                        Expanded(
                          child: Text(
                            q,
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],

            if (p.extensionChallenge.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🚀 ', style: TextStyle(fontSize: 14)),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 11, color: AppColors.primaryLight),
                          children: [
                            const TextSpan(
                              text: 'Extension Challenge: ',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                            TextSpan(text: p.extensionChallenge),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // TAB 2: Step-by-Step Instructions
  Widget _buildStepsTab() {
    final p = widget.project;
    final completedSteps = widget.state.userProgress.getStepsFor(p.id);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: p.steps.length + 1,
      itemBuilder: (context, idx) {
        if (idx == p.steps.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ElevatedButton(
              onPressed: () => _tabController.animateTo(2),
              child: const Text('Go to Proof Submission 📸'),
            ),
          );
        }

        final step = p.steps[idx];
        final isDone = completedSteps.contains(step.stepNumber);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: isDone ? AppColors.emerald.withValues(alpha: 0.05) : AppColors.bgCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDone ? AppColors.emerald.withValues(alpha: 0.4) : AppColors.border,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: isDone ? AppColors.emerald : AppColors.primary,
                          child: Text(
                            '${step.stepNumber}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          step.title,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textMain),
                        ),
                      ],
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        minimumSize: const Size(0, 30),
                        backgroundColor: isDone ? AppColors.emerald.withValues(alpha: 0.15) : null,
                        foregroundColor: isDone ? AppColors.emerald : AppColors.textMain,
                        side: BorderSide(color: isDone ? AppColors.emerald : AppColors.borderLight),
                      ),
                      onPressed: () {
                        final nextDone = !isDone;
                        if (nextDone) {
                          SoundEffects.playChime();
                        }
                        widget.state.toggleStep(p.id, step.stepNumber, nextDone);
                        setState(() {});
                      },
                      child: Text(isDone ? '✅ Done' : 'Mark Done'),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Instruction Text
                Text(
                  step.instruction,
                  style: const TextStyle(fontSize: 13, color: AppColors.textMain, height: 1.5),
                ),

                const SizedBox(height: 12),

                // Interactive Technical Step Infographic
                StepInfographicWidget(
                  visualType: step.visualType,
                  title: step.title,
                  stepNumber: step.stepNumber,
                  instruction: step.instruction,
                  tip: step.tip,
                ),

                // Callouts
                if (step.tip.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 11, color: AppColors.primaryLight),
                              children: [
                                const TextSpan(text: 'Maker Pro Tip: ', style: TextStyle(fontWeight: FontWeight.w700)),
                                TextSpan(text: step.tip),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (step.safetyNote.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.rose.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.rose.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🛡️', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 11, color: Color(0xFFFDA4AF)),
                              children: [
                                const TextSpan(text: 'Safety Check: ', style: TextStyle(fontWeight: FontWeight.w700)),
                                TextSpan(text: step.safetyNote),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }



  // TAB 3: Submit Project Proof
  Widget _buildProofTab(bool isCompleted) {
    final p = widget.project;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Reward Hero Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.2),
                AppColors.amber.withValues(alpha: 0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Showcase Your Project Proof',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textMain),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Attach a photo of your working DIY project and log your engineering reflections.',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.amber.withValues(alpha: 0.5)),
                ),
                child: Text(
                  '+${p.xpReward}\nXP',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.amber),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Photo Preview / Picker
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bgSecondary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight, style: BorderStyle.solid),
          ),
          child: Column(
            children: [
              if (_selectedProofImage.isNotEmpty) ...[
                const Icon(Icons.photo_library_rounded, size: 40, color: AppColors.emerald),
                const SizedBox(height: 8),
                Text(
                  'Attached: $_selectedProofImage',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.emerald),
                ),
                const SizedBox(height: 8),
              ] else ...[
                const Icon(Icons.add_a_photo_rounded, size: 40, color: AppColors.textMuted),
                const SizedBox(height: 8),
                const Text(
                  'Upload or Select Project Photo Proof',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMain),
                ),
                const SizedBox(height: 8),
              ],
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedProofImage = '${p.id}_verified_demo.jpg';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Attached verified prototype photo for ${p.title}!')),
                  );
                },
                icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                label: const Text('Use Sample Prototype Photo (1-Click Test)'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Fun Rating
        Row(
          children: [
            const Text(
              'How much fun did you have?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMain),
            ),
            const SizedBox(width: 12),
            Row(
              children: List.generate(5, (starIdx) {
                return IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    starIdx < _funRating ? Icons.star_rounded : Icons.star_border_rounded,
                    color: AppColors.amber,
                    size: 24,
                  ),
                  onPressed: () {
                    setState(() {
                      _funRating = starIdx + 1;
                    });
                  },
                );
              }),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Reflection Journal Notes
        const Text(
          'Maker Engineering Log & Student Reflection',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textMain),
        ),
        const SizedBox(height: 4),
        const Text(
          'Prompts: What was tricky? What surprised you? What would you upgrade next?',
          style: TextStyle(fontSize: 11, color: AppColors.textDim),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 4,
          style: const TextStyle(fontSize: 13, color: AppColors.textMain),
          decoration: InputDecoration(
            hintText: 'e.g. Reinforced the pivot joint with tape and angled the marble run by 25 degrees. The lift elevated my pencil case!',
            hintStyle: const TextStyle(color: AppColors.textDim, fontSize: 12),
            filled: true,
            fillColor: AppColors.bgSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Submit Button
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: () {
            final notes = _notesController.text.trim().isEmpty
                ? 'Constructed prototype according to blueprints. Load test and motion checks passed! Fun Rating: $_funRating/5 stars ⭐'
                : '${_notesController.text.trim()} (Fun Rating: $_funRating/5 ⭐)';
            final img = _selectedProofImage.isEmpty ? '${p.id}_proof.jpg' : _selectedProofImage;

            final reward = widget.state.submitProjectProof(
              projectId: p.id,
              notes: notes,
              image: img,
            );

            SoundEffects.playFanfare();

            showDialog(
              context: context,
              builder: (ctx) => RewardCelebrationDialog(event: reward),
            );
          },
          icon: const Icon(Icons.rocket_launch_rounded),
          label: Text(
            isCompleted ? 'Update Project Verification' : 'Submit Proof & Claim +${p.xpReward} XP!',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}
