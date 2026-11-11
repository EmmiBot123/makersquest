// MakerQuest Modern Marketing & Student Capability Assessment Page
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/external_launcher.dart';
import '../services/quest_state.dart';
import '../services/sound_effects.dart';
import '../theme/app_theme.dart';
import 'kid_robot_builder_animation.dart';
import 'stem_infographics.dart';

class MarketingPageView extends StatefulWidget {
  final QuestState questState;
  final VoidCallback onLaunchWorkshop;

  const MarketingPageView({
    super.key,
    required this.questState,
    required this.onLaunchWorkshop,
  });

  @override
  State<MarketingPageView> createState() => _MarketingPageViewState();
}

class _MarketingPageViewState extends State<MarketingPageView> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final GlobalKey _assessmentKey = GlobalKey();
  final GlobalKey _resultsKey = GlobalKey();
  final GlobalKey _curriculumKey = GlobalKey();
  final GlobalKey _pricingKey = GlobalKey();
  final GlobalKey _faqKey = GlobalKey();

  final _nameController = TextEditingController(text: 'Aarav Sharma');
  final _emailController = TextEditingController(text: 'aarav.maker@example.com');
  int _selectedAge = 9;
  String _experienceLevel = 'Intermediate (Lego, crafting & kits)';
  String _favoriteInterest = 'Speed Racers & Drive Systems';

  bool _isAnalyzing = false;
  bool _analysisComplete = false;

  // Analysis result states
  String _archetype = 'Kinetic Mechanism Pioneer';
  String _archetypeIcon = '🏎️';
  int _aptitudeScore = 96;
  final String _recommendedTrack = 'Level 1: Cardboard Mechanics ➔ Level 2: Simple Machines';
  List<({String name, String icon, String diff, String time, String desc})> _recommendedProjects = [];

  // Payment dialog state
  final double _planPrice = 199.0;
  final String _currencySymbol = '₹';
  final Set<int> _expandedFaqs = {0};
  final Set<String> _checkedScrapItems = {'box', 'skewers', 'straws', 'bands', 'scissors'};

  @override
  void initState() {
    super.initState();
    _computeRecommendations();
    _nameController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _scrollToKey(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
        alignment: 0.05,
      );
    }
  }

  void _computeRecommendations() {
    if (_favoriteInterest.contains('Racers') || _favoriteInterest.contains('Speed')) {
      _archetype = 'Kinetic Drive Pioneer';
      _archetypeIcon = '🏎️';
      _aptitudeScore = 95 + (_selectedAge % 4);
      _recommendedProjects = [
        (name: 'Rubber-Band Wind-Up Drive Racer', icon: '🏎️', diff: 'Beginner', time: '35 mins', desc: 'Direct-axle elastic energy storage with high-traction tires'),
        (name: 'Smooth-Rolling Test Cart with Straw Bearings', icon: '🛒', diff: 'Beginner', time: '30 mins', desc: 'Low-friction cylindrical straw sleeves with donut spacers'),
        (name: 'Cardboard Scissor Lift Mechanism', icon: '✂️', diff: 'Beginner', time: '35 mins', desc: '3-tier pantograph linkage elevating 4x vertical height'),
        (name: 'Gravity-Fed Marble Coaster Run', icon: '🎢', diff: 'Beginner', time: '45 mins', desc: 'U-channel banked chutes testing potential to kinetic velocity'),
      ];
    } else if (_favoriteInterest.contains('Scissor') || _favoriteInterest.contains('Cranes')) {
      _archetype = 'Kinematic Linkage Architect';
      _archetypeIcon = '🏗️';
      _aptitudeScore = 94 + (_selectedAge % 5);
      _recommendedProjects = [
        (name: 'Cardboard Scissor Lift Mechanism', icon: '✂️', diff: 'Beginner', time: '35 mins', desc: 'Pantograph linkage expanding 4x vertical stroke'),
        (name: 'Dual-Pulley Mechanical Crane', icon: '🏗️', diff: 'Intermediate', time: '40 mins', desc: 'Compound pulley system doubling lifting mechanical advantage'),
        (name: 'Articulated Mechanical Robot Gripper', icon: '🦾', diff: 'Intermediate', time: '45 mins', desc: 'Opposing jaw levers with spring-return tension'),
        (name: 'Smooth-Rolling Test Cart with Straw Bearings', icon: '🛒', diff: 'Beginner', time: '30 mins', desc: 'Straw-bearing chassis with parallel axle alignment'),
      ];
    } else if (_favoriteInterest.contains('Roller') || _favoriteInterest.contains('Coaster')) {
      _archetype = 'Gravitational Physics Explorer';
      _archetypeIcon = '🎢';
      _aptitudeScore = 97;
      _recommendedProjects = [
        (name: 'Gravity-Fed Marble Coaster Run', icon: '🎢', diff: 'Beginner', time: '45 mins', desc: 'Banked turns counteracting centrifugal forces'),
        (name: 'Rubber-Band Wind-Up Drive Racer', icon: '🏎️', diff: 'Beginner', time: '35 mins', desc: 'Elastic torque converted to forward kinetic propulsion'),
        (name: 'Cardboard Scissor Lift Mechanism', icon: '✂️', diff: 'Beginner', time: '35 mins', desc: 'Multi-stage scissor linkage with sliding track shoe'),
        (name: 'Dual-Pulley Mechanical Crane', icon: '🏗️', diff: 'Intermediate', time: '40 mins', desc: 'Compound rigging with smooth crank spool'),
      ];
    } else {
      _archetype = 'Robotics & Mechanisms Innovator';
      _archetypeIcon = '🤖';
      _aptitudeScore = 96;
      _recommendedProjects = [
        (name: 'Articulated Mechanical Robot Gripper', icon: '🦾', diff: 'Intermediate', time: '45 mins', desc: 'Dual-lever linkage clamping mechanism with high-friction pads'),
        (name: 'Cardboard Scissor Lift Mechanism', icon: '✂️', diff: 'Beginner', time: '35 mins', desc: 'Aligned flute corrugation for 4x bending resistance'),
        (name: 'Rubber-Band Wind-Up Drive Racer', icon: '🏎️', diff: 'Beginner', time: '35 mins', desc: 'Stored elastic potential energy converted into axle torque'),
        (name: 'Dual-Pulley Mechanical Crane', icon: '🏗️', diff: 'Intermediate', time: '40 mins', desc: 'Compound mechanical advantage lifting 150g cargo'),
      ];
    }
  }

  void _runAnalysis() {
    if (!_formKey.currentState!.validate()) return;

    SoundEffects.playPop();
    setState(() {
      _isAnalyzing = true;
      _analysisComplete = false;
    });

    _computeRecommendations();
  }

  void _onRobotDraftingComplete() {
    if (!mounted) return;
    setState(() {
      _isAnalyzing = false;
      _analysisComplete = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scrollToKey(_resultsKey);
      }
    });
  }

  void _openCheckoutDialog() {
    SoundEffects.playPop();
    final studentName = _nameController.text.trim().isEmpty ? 'Young Cadet' : _nameController.text.trim();
    final studentEmail = _emailController.text.trim().isEmpty ? 'cadet@makerquest.edu' : _emailController.text.trim();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _DummyCheckoutDialog(
        studentName: studentName,
        studentAge: _selectedAge,
        studentEmail: studentEmail,
        archetype: _archetype,
        archetypeIcon: _archetypeIcon,
        aptitudeScore: _aptitudeScore,
        planPrice: _planPrice,
        currencySymbol: _currencySymbol,
        onPaymentSuccess: (paidName, paidEmail) {
          // Register cadet in QuestState
          widget.questState.registerNewCadet(
            name: paidName,
            email: paidEmail,
            avatar: _archetypeIcon,
          );
          Navigator.of(ctx).pop();
          _showCelebrationDialog(paidName);
        },
      ),
    );
  }

  void _showCelebrationDialog(String cadetName) {
    SoundEffects.playFanfare();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.emeraldSoft,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.emerald, width: 2),
              ),
              child: const Center(
                child: Text('🎉', style: TextStyle(fontSize: 36)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Enrollment Successful! 🏆',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textMain),
            ),
            const SizedBox(height: 8),
            Text(
              'Welcome aboard MakerQuest, Cadet $cadetName!\nYour All-Access Odyssey Pass has been activated with 50 XP starter bonus.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.5),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Text(_archetypeIcon, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cadet Archetype: $_archetype', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                        Text('Aptitude: $_aptitudeScore% • Level 1 Unlocked', style: const TextStyle(fontSize: 11, color: AppColors.emerald, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.rocket_launch_rounded),
                label: const Text('Launch Cadet Workshop Now 🚀', style: TextStyle(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  widget.onLaunchWorkshop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSampleSchematicPreviewDialog() {
    SoundEffects.playPop();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860, maxHeight: 880),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(child: Text('📐', style: TextStyle(fontSize: 20))),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sample 3D CAD Blueprint Preview',
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textMain),
                            ),
                            Text(
                              'Interactive Kinematics, 3D Assembly & Stress Simulation Demo',
                              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Interactive Blueprint Viewer (Sample Scissor Linkage)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const StepInfographicWidget(
                          visualType: 'pantograph_cut',
                          title: 'Measure & Cut Cardboard Struts with Aligned Flutes',
                          stepNumber: 1,
                          instruction: 'Use a ruler to draw six identical cardboard strips (15 cm long, 2 cm wide). Cut them so internal corrugation flutes run longitudinally for maximum bending resistance.',
                          tip: 'Internal flutes vertically aligned resist over 300% more compressive load than horizontal cut strips.',
                        ),
                        const SizedBox(height: 16),
                        // Lock Notice Banner
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFF59E0B)),
                          ),
                          child: Row(
                            children: [
                              const Text('🔒', style: TextStyle(fontSize: 24)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Sample Blueprint Only (Project 1 of 17)',
                                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF92400E)),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Full workshop access to all 17 projects, step guides, physics simulations, and checkpoint challenges unlocks after Cadet Pass enrollment.',
                                      style: TextStyle(fontSize: 11, color: Color(0xFF78350F)),
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
                const SizedBox(height: 16),

                // Action Footer
                Wrap(
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Close Preview', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700)),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.rocket_launch_rounded, size: 16),
                      label: const Text('Enroll to Unlock All 17 Blueprints (₹199) 💳', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emerald,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _openCheckoutDialog();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final isDesktop = screenW >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButton: FloatingActionButton(
        heroTag: 'whatsapp_marketing_fab',
        tooltip: 'WhatsApp Mentor Helpline: ${ExternalLauncher.whatsAppPhoneDisplay}',
        backgroundColor: const Color(0xFF25D366),
        foregroundColor: Colors.white,
        elevation: 6,
        onPressed: () {
          SoundEffects.playPop();
          ExternalLauncher.openWhatsApp();
        },
        child: const Icon(Icons.chat_rounded, size: 26),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTopNavigation(context),
            _buildHeroSection(isDesktop),
            _buildLiveActivityTicker(),
            _buildTrustBadgeBar(isDesktop),
            _buildScreenTimeContrastSection(isDesktop),
            _buildWeekendOutcomesSection(isDesktop),
            _buildScrapAuditWidget(isDesktop),
            _buildScienceExhibitionSection(isDesktop),
            _buildHowItWorksSection(isDesktop),
            _buildCurriculumRoadmapSection(isDesktop),
            _buildCertificatePreviewSection(isDesktop),
            _buildWhatWeOfferSection(isDesktop),
            _buildParentRoiCalculator(isDesktop),
            _buildAssessmentSection(isDesktop),
            if (_analysisComplete) _buildAnalysisResultsSection(isDesktop),
            _buildPricingSection(isDesktop),
            _buildCurriculumComparison(isDesktop),
            _buildWhatsAppSupportSection(isDesktop),
            _buildFaqSection(isDesktop),
            _buildTestimonialsSection(isDesktop),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // 1. TOP MARKETING NAVIGATION
  Widget _buildTopNavigation(BuildContext context) {
    final showWideNav = MediaQuery.of(context).size.width >= 720;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFFEC4899)]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(child: Text('⚡', style: TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MakerQuest', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.textMain, letterSpacing: -0.5)),
                  Text('DIY STEM ODYSSEY', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.amber, letterSpacing: 0.8)),
                ],
              ),
            ],
          ),
          Row(
            children: [
              if (showWideNav) ...[
                OutlinedButton.icon(
                  icon: const Icon(Icons.chat_rounded, size: 15, color: Color(0xFF16A34A)),
                  label: const Text(
                    ExternalLauncher.whatsAppPhoneDisplay,
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF15803D)),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFF0FDF4),
                    side: const BorderSide(color: Color(0xFF86EFAC)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () {
                    SoundEffects.playPop();
                    ExternalLauncher.openWhatsApp();
                  },
                ),
                const SizedBox(width: 10),
              ],
              if (widget.questState.isEnrolled) ...[
                ElevatedButton.icon(
                  icon: const Icon(Icons.handyman_rounded, size: 16),
                  label: const Text('Back to Workshop', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bgSurface,
                    foregroundColor: AppColors.textMain,
                    elevation: 0,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: widget.onLaunchWorkshop,
                ),
                const SizedBox(width: 10),
              ],
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () {
                  // Scroll to quiz or open checkout
                  _openCheckoutDialog();
                },
                child: const Text('Get Cadet Pass ₹199', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. HERO SECTION
  Widget _buildHeroSection(bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 20, vertical: 48),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFFF1F5F9)],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🇮🇳', style: TextStyle(fontSize: 14)),
                    SizedBox(width: 6),
                    Text('Indian STEM Curriculum (CBSE • ICSE • NEP 2020) • Ages 7–16', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryLight)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Transform Cardboard into Real Robotics.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textMain,
                  letterSpacing: -1.0,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Step away from passive screens. MakerQuest turns everyday scrap boxes, wooden skewers, and rubber bands into 17+ working kinetic machines, pneumatic lifts, and speed racers — guided by interactive 3D blueprints and physics simulations.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.textMuted, height: 1.55),
              ),
              const SizedBox(height: 28),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.analytics_rounded, size: 18),
                    label: const Text('Free Student Capability Test 🚀', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      _scrollToKey(_assessmentKey);
                    },
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.play_circle_outline_rounded, size: 18),
                    label: const Text('Watch 3D Schematics in Action', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textMain)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _showSampleSchematicPreviewDialog,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Interactive Kid & Robot Live Workshop Animation
              const KidRobotWorkshopHeroAnimation(),

              const SizedBox(height: 16),
              // Value stats bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('17+ Builds', 'Kinetic Mechanisms', '🛠️'),
                    _buildStatItem('5 Realms', 'From Linkages to Rovers', '🗺️'),
                    _buildStatItem('10 Badges', 'XP & Certifications', '🏅'),
                    _buildStatItem('₹0 Kit Cost', '100% Upcycled Scrap', '♻️'),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              InkWell(
                onTap: () => _scrollToKey(_assessmentKey),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('Scroll Down to Capability Diagnostic', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_downward_rounded, size: 16, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String val, String sub, String icon) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textMain)),
        Text(sub, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ],
    );
  }

  // TRUST RIBBON
  Widget _buildTrustBadgeBar(bool isDesktop) {
    final badges = [
      (icon: '🇮🇳', title: 'Indian Curriculum Aligned', desc: 'CBSE, ICSE & NEP 2020 Standards'),
      (icon: '🔬', title: 'Atal Tinkering Lab Ready', desc: 'Hands-on experiential prototypes'),
      (icon: '♻️', title: '100% Scrap Guarantee', desc: 'Zero expensive plastic kit lock-in'),
      (icon: '🛡️', title: 'Child Safety Verified', desc: 'Step-by-step adult guidance flags'),
      (icon: '🏆', title: 'Official STEM Diploma', desc: 'Printable Graduation Certifications'),
    ];

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 16, vertical: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: badges.map((b) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(b.icon, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(b.title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMain)),
                      Text(b.desc, style: const TextStyle(fontSize: 9, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
      ),
    );
  }

  // 1B. LIVE CADET ACTIVITY TICKER
  Widget _buildLiveActivityTicker() {
    return const AnimatedCadetMarqueeTicker(
      items: [
        (who: '🇮🇳 Aarav S. (Class 5, Bengaluru)', action: 'Enrolled 4 mins ago'),
        (who: '🏆 Rohan M. (Class 7, Pune)', action: 'Mastered Scissor Lift (+120 XP)'),
        (who: '⚡ Ananya P. (Class 4, Delhi)', action: 'Unlocked Level 2 Stored Energy'),
        (who: '🔬 Kendriya Vidyalaya Club', action: 'Activated 15 Cadet Passes'),
        (who: '🤖 Dev K. (Class 8, Hyderabad)', action: 'Built Dual-Pulley Crane (+180 XP)'),
      ],
    );
  }

  // 1C. SCREEN TIME DETOX CONTRAST SECTION
  Widget _buildScreenTimeContrastSection(bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 20, vertical: 56),
      color: const Color(0xFFF1F5F9),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1060),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text('THE PARENT\'S SCREEN-TIME DILEMMA', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppColors.primary, letterSpacing: 1.2)),
              ),
              const SizedBox(height: 12),
              const Text(
                'Replace Screen Fatigue with Real Engineering Pride',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textMain, letterSpacing: -0.8),
              ),
              const SizedBox(height: 10),
              const Text(
                'Children don\'t lack focus — they lack physical challenges worth their focus. Channel their screen energy into real machines.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textMuted, height: 1.5),
              ),
              const SizedBox(height: 32),
              isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildContrastCard(isPositive: false)),
                        const SizedBox(width: 24),
                        Expanded(child: _buildContrastCard(isPositive: true)),
                      ],
                    )
                  : Column(
                      children: [
                        _buildContrastCard(isPositive: false),
                        const SizedBox(height: 16),
                        _buildContrastCard(isPositive: true),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContrastCard({required bool isPositive}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isPositive ? Colors.white : const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPositive ? AppColors.emerald.withValues(alpha: 0.4) : AppColors.rose.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: isPositive
            ? [BoxShadow(color: AppColors.emerald.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 6))]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(isPositive ? '⚡' : '📱', style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPositive ? 'MakerQuest Cadet Odyssey' : 'Typical Screen Consumption',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isPositive ? AppColors.emerald : AppColors.rose,
                      ),
                    ),
                    Text(
                      isPositive ? 'Active Creator & Problem Solver' : 'Passive Gaming & Video Binging',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 14),
          if (!isPositive) ...[
            _buildContrastBullet('❌ 3-5 hours daily lost to YouTube shorts and video game dopamine loops'),
            _buildContrastBullet('❌ Eye strain, irritability, and shortened academic attention span'),
            _buildContrastBullet('❌ Zero tangible physical creations or mechanical intuitions gained'),
            _buildContrastBullet('❌ Boredom and tantrums whenever phones or tablets are confiscated'),
          ] else ...[
            _buildContrastBullet('✅ 17 physical working machines built with their own hands by Sunday'),
            _buildContrastBullet('✅ Intuitive mastery of CBSE & ICSE physics laws (levers, torque, kinematics)'),
            _buildContrastBullet('✅ 10 collectible badges, milestone XP, and official junior STEM diploma'),
            _buildContrastBullet('✅ Genuine self-esteem showing their functional robots to friends & family'),
          ],
          const SizedBox(height: 12),
          AnimatedParentImpactMeters(isPositive: isPositive),
        ],
      ),
    );
  }

  Widget _buildContrastBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text, style: const TextStyle(fontSize: 12.5, height: 1.45, color: AppColors.textMain, fontWeight: FontWeight.w600)),
    );
  }

  // 1D. WEEKEND PHYSICAL OUTCOMES SHOWCASE
  Widget _buildWeekendOutcomesSection(bool isDesktop) {
    final outcomes = [
      (
        title: 'Cardboard Scissor Hoist',
        icon: '✂️',
        stat: 'Lifts 250g 4x Height',
        mechanic: '3-Tier Pantograph Linkage',
        science: 'Class 1 Levers & Force Multiplication',
        desc: 'Transforms horizontal sliding motion into vertical lift. Students lift pencil cases, toys, and phone stands.',
        type: 'scissor_lift',
      ),
      (
        title: 'Stored Elastic Torque Racer',
        icon: '🏎️',
        stat: 'Races 5+ Meters',
        mechanic: 'Rear-Axle Rubber Band Winch',
        science: 'Elastic Potential to Kinetic Energy',
        desc: 'Cardboard chassis with drinking-straw bushings and centered wheels for zero-wobble sprint speed.',
        type: 'speed_racer',
      ),
      (
        title: 'Dual-Banked Gravity Coaster',
        icon: '🎢',
        stat: 'Zero-Derailment Curves',
        mechanic: 'Corrugated Banked Rails',
        science: 'Centripetal Force & Gravitational Acceleration',
        desc: 'Multi-tiered marble coaster with calibrated velocity curves and catch-funnels constructed from delivery boxes.',
        type: 'marble_coaster',
      ),
      (
        title: 'Articulated Mechanical Gripper',
        icon: '🦾',
        stat: 'Grabs Everyday Objects',
        mechanic: 'Dual Trigger-Pull Linkage',
        science: 'Friction Coefficients & Normal Force',
        desc: 'Operated by hand-held finger triggers to securely pinch and lift bottles, stationery, and small fruit.',
        type: 'robot_gripper',
      ),
    ];

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 20, vertical: 56),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.emeraldSoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text('TANGIBLE TINKERING OUTCOMES', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppColors.emerald, letterSpacing: 1.2)),
              ),
              const SizedBox(height: 12),
              const Text(
                'What Your Child Will Build by Sunday Evening',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textMain, letterSpacing: -0.8),
              ),
              const SizedBox(height: 10),
              const Text(
                'No useless theoretical models. Authentic, functioning kinetic robotics they can play with, demonstrate, and take to school.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textMuted, height: 1.5),
              ),
              const SizedBox(height: 36),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isDesktop ? (MediaQuery.of(context).size.width >= 1100 ? 4 : 2) : (MediaQuery.of(context).size.width >= 600 ? 2 : 1),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  mainAxisExtent: 400,
                ),
                itemCount: outcomes.length,
                itemBuilder: (ctx, i) {
                  final o = outcomes[i];
                  return Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(o.icon, style: const TextStyle(fontSize: 28)),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySoft,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  o.stat,
                                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.primary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        AnimatedMechanismMiniPreview(
                          mechanicType: o.type,
                          height: 74,
                        ),
                        const SizedBox(height: 10),
                        Text(o.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textMain)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.emeraldSoft, borderRadius: BorderRadius.circular(6)),
                          child: Text(o.science, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.emerald)),
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: Text(o.desc, style: const TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.4)),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              const AnimatedScrapToRobotShowcase(),
            ],
          ),
        ),
      ),
    );
  }

  // 1E. 60-SECOND ZERO-EXPENSE SCRAP AUDIT
  Widget _buildScrapAuditWidget(bool isDesktop) {
    final items = [
      ('box', '📦 Clean Delivery Box', 'Amazon, Flipkart, or cereal cardboard'),
      ('skewers', '🍢 Wooden Skewers or Toothpicks', 'Standard 15cm wooden food skewers'),
      ('straws', '🥤 Drinking Straws or Pen Refills', 'Low-friction rotational bearing sleeves'),
      ('bands', '🪢 Standard Rubber Bands', 'Stored elastic potential energy engines'),
      ('scissors', '✂️ Scissors & School Glue', 'Child-safe scissors & PVA/Fevicol glue'),
    ];

    final readyCount = _checkedScrapItems.length;
    final pct = (readyCount / 5.0 * 100).toInt();

    return Container(
      color: const Color(0xFFF8FAFC),
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 20, vertical: 56),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Container(
            padding: EdgeInsets.all(isDesktop ? 36 : 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 8)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('ZERO HIDDEN HARDWARE EXPENSES', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppColors.emerald, letterSpacing: 1.2)),
                          SizedBox(height: 4),
                          Text('The 60-Second Household Scrap Audit', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textMain)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: pct == 100 ? AppColors.emeraldSoft : AppColors.amberSoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$pct% Ready',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: pct == 100 ? AppColors.emerald : AppColors.amberGlow,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Tick the common household items you already have at home right now:',
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: readyCount / 5.0,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation(pct == 100 ? AppColors.emerald : AppColors.primary),
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  children: items.map((item) {
                    final isChecked = _checkedScrapItems.contains(item.$1);
                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (isChecked) {
                            _checkedScrapItems.remove(item.$1);
                          } else {
                            _checkedScrapItems.add(item.$1);
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        child: Row(
                          children: [
                            Checkbox(
                              value: isChecked,
                              activeColor: AppColors.emerald,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    _checkedScrapItems.add(item.$1);
                                  } else {
                                    _checkedScrapItems.remove(item.$1);
                                  }
                                });
                              },
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.$2, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: isChecked ? AppColors.textMain : AppColors.textMuted)),
                                  Text(item.$3, style: const TextStyle(fontSize: 11, color: AppColors.textDim)),
                                ],
                              ),
                            ),
                            if (isChecked)
                              const Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 18),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: pct == 100 ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: pct == 100 ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    children: [
                      Text(pct == 100 ? '🎉' : '💡', style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          pct == 100
                              ? '100% Supplies Ready! You will spend ₹0 extra on materials to build all 17 robotics blueprints!'
                              : 'Almost ready! Even if you only have scrap boxes and skewers, you can build the first 6 chapters today.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: pct == 100 ? const Color(0xFF065F46) : const Color(0xFF92400E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 1F. CBSE & SCIENCE EXHIBITION ADVANTAGE
  Widget _buildScienceExhibitionSection(bool isDesktop) {
    final benefits = [
      (
        icon: '📋',
        title: 'Printable 1:1 Science Fair Display Boards',
        desc: 'Pre-formatted A3/A4 display placard with Title, Hypothesis, Apparatus, Circuit Diagram & Working Principles ready to print for school stalls.',
        color: AppColors.primary,
      ),
      (
        icon: '🗣️',
        title: 'Examiner Viva Voce Cheat Sheet',
        desc: 'Empowers cadets to explain physics concepts (Class 1 levers, Hooke\'s law, Pascal\'s hydraulic principle) to judges with absolute confidence.',
        color: AppColors.emerald,
      ),
      (
        icon: '🎖️',
        title: 'CBSE & ICSE Practical Homework Ready',
        desc: 'Directly fulfills NEP 2020 hands-on portfolio requirements and Atal Tinkering Lab experiential science assignments.',
        color: AppColors.amber,
      ),
    ];

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 20, vertical: 56),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text('SCHOOL & ACADEMIC ADVANTAGE', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppColors.primary, letterSpacing: 1.2)),
              ),
              const SizedBox(height: 12),
              const Text(
                'Win 1st Prize at the School Science Exhibition',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textMain, letterSpacing: -0.8),
              ),
              const SizedBox(height: 10),
              const Text(
                'Never scramble the night before a school science submission again. Every MakerQuest machine comes with ready-to-present exhibition materials.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textMuted, height: 1.5),
              ),
              const SizedBox(height: 36),
              isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: benefits.map((b) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: _buildScienceBenefitCard(b)))).toList(),
                    )
                  : Column(
                      children: benefits.map((b) => Padding(padding: const EdgeInsets.only(bottom: 16), child: _buildScienceBenefitCard(b))).toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScienceBenefitCard(({String icon, String title, String desc, Color color}) b) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: b.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(b.icon, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(height: 14),
          Text(b.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textMain, height: 1.3)),
          const SizedBox(height: 8),
          Text(b.desc, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.5)),
        ],
      ),
    );
  }

  // HOW IT WORKS IN 3 STEPS
  Widget _buildHowItWorksSection(bool isDesktop) {
    final steps = [
      (
        step: '01',
        icon: '📐',
        color: AppColors.primary,
        title: 'Inspect Interactive 3D Blueprints',
        desc: 'Before cutting, cadets rotate exploded 3D models, inspect millimeter dimensions, and study corrugation flute grain angles (90° for 300% strength).',
      ),
      (
        step: '02',
        icon: '📦',
        color: const Color(0xFF10B981),
        title: 'Upcycle Household Scrap Materials',
        desc: 'Zero ₹2,500 plastic sets required. Grab clean cereal boxes, Amazon/Flipkart delivery cardboard, drinking straws, wooden skewers, and rubber bands from home.',
      ),
      (
        step: '03',
        icon: '🚀',
        color: const Color(0xFFF59E0B),
        title: 'Simulate Physics & Earn Certifications',
        desc: 'Test real-world mechanical advantage, calculate velocity ratios, pass checkpoint quizzes, submit proof photos, and graduate with official STEM diplomas.',
      ),
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 20, vertical: 56),
      color: const Color(0xFFF8FAFC),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text('HOW IT WORKS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppColors.primary, letterSpacing: 1.2)),
              ),
              const SizedBox(height: 10),
              const Text(
                'From Delivery Box to Dynamic Robotics in 3 Steps',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textMain, letterSpacing: -0.6),
              ),
              const SizedBox(height: 10),
              const Text(
                'A systematic engineering methodology designed by educators to replace passive gaming with active invention.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textMuted, height: 1.5),
              ),
              const SizedBox(height: 36),
              isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: steps.asMap().entries.map((entry) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: _buildStepCard(entry.value, entry.key)))).toList(),
                    )
                  : Column(
                      children: steps.asMap().entries.map((entry) => Padding(padding: const EdgeInsets.only(bottom: 16), child: _buildStepCard(entry.value, entry.key))).toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard(({String step, String icon, Color color, String title, String desc}) s, int index) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AnimatedStepIconBadge(
                emoji: s.icon,
                color: s.color,
                staggerIndex: index,
              ),
              Text(s.step, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: s.color.withValues(alpha: 0.3))),
            ],
          ),
          const SizedBox(height: 18),
          Text(s.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textMain, height: 1.3)),
          const SizedBox(height: 8),
          Text(s.desc, style: const TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.5)),
        ],
      ),
    );
  }

  // COMPLETE 12-CHAPTER CURRICULUM SYLLABUS
  Widget _buildCurriculumRoadmapSection(bool isDesktop) {
    final chapters = [
      (
        num: '01',
        title: 'Flute Mechanics & Scissor Hoists',
        principle: 'Corrugation Grain & 300% Bending Resistance',
        build: 'Cardboard Scissor Pantograph',
        icon: '✂️',
      ),
      (
        num: '02',
        title: 'Straw Bearings & Low-Friction Axles',
        principle: 'Sliding Friction Reduction & Concentric Hubs',
        build: 'Smooth-Rolling Test Cart',
        icon: '🛒',
      ),
      (
        num: '03',
        title: 'Gravitational Potential & Banked Chutes',
        principle: 'Threshold Velocity & Centripetal Curve Physics',
        build: 'Gravity-Fed Marble Coaster Run',
        icon: '🎢',
      ),
      (
        num: '04',
        title: 'Elastic Potential & Axle Torque',
        principle: 'Hooke\'s Law & Stored Strain Energy Release',
        build: 'Rubber-Band Wind-Up Drive Racer',
        icon: '🏎️',
      ),
      (
        num: '05',
        title: 'Compound Pulleys & Mechanical Advantage',
        principle: 'Force Multiplication & Block-and-Tackle Rigging',
        build: 'Compound Pulley Cargo Crane',
        icon: '🏗️',
      ),
      (
        num: '06',
        title: 'Rotary Cams & Eccentric Automata',
        principle: 'Rotary-to-Linear Motion & Follower Phasing',
        build: 'Cardboard Cam & Gear Automaton',
        icon: '🎡',
      ),
      (
        num: '07',
        title: 'Bio-Mechanics & String Tendons',
        principle: 'Tendon Routing & Antagonist Spring Returns',
        build: 'Articulated Bionic Tendon Hand',
        icon: '🦾',
      ),
      (
        num: '08',
        title: 'Fluid Power & Hydraulic Pistons',
        principle: 'Pascal\'s Law of Enclosed Fluid Pressure',
        build: 'Hydraulic Syringe Excavator Arm',
        icon: '💧',
      ),
      (
        num: '09',
        title: 'Gear Pitch Ratios & Transmissions',
        principle: 'Pitch Diameters & Torque vs Speed Trades',
        build: '2-Speed Cardboard Gearbox',
        icon: '⚙️',
      ),
      (
        num: '10',
        title: 'Four-Bar Walkers & Linkage Robots',
        principle: 'Planar Pivot Ellipses & Crank Synchronization',
        build: 'Walking-Style Leg Linkage Rover',
        icon: '🤖',
      ),
      (
        num: '11',
        title: 'Solar Sensors & Clean Circuits',
        principle: 'Optical Tracking & LED Polarity Logic',
        build: 'Bio-Mimetic Solar Sunflower Tracker',
        icon: '🌻',
      ),
      (
        num: '12',
        title: 'Autonomous Obstacle Sensing & Robotics',
        principle: 'Tactile Micro-Switches & Auto-Reverse',
        build: 'Smart Autonomous Reverse-Rover',
        icon: '🤖',
      ),
    ];

    return Container(
      key: _curriculumKey,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 20, vertical: 60),
      color: Colors.white,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.emeraldSoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text('NEP 2020 & ATL COMPLIANT SYLLABUS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppColors.emerald, letterSpacing: 1.2)),
              ),
              const SizedBox(height: 12),
              const Text(
                'Structured Indian STEM Curriculum (Classes 3 to 10)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textMain, letterSpacing: -0.8),
              ),
              const SizedBox(height: 10),
              const Text(
                'Each progressive chapter maps directly to CBSE & ICSE physics competencies: levers, linkages, friction, kinetic energy, hydraulic pressure, and gear ratios.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textMuted, height: 1.5),
              ),
              const SizedBox(height: 36),

              // 12 Chapter Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isDesktop ? 3 : 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isDesktop ? 1.7 : 2.2,
                ),
                itemCount: chapters.length,
                itemBuilder: (context, idx) {
                  final ch = chapters[idx];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('CHAPTER ${ch.num}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: AppColors.primary)),
                            ),
                            Text(ch.icon, style: const TextStyle(fontSize: 20)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(ch.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textMain, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text('🔬 ${ch.principle}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.build_circle_rounded, size: 14, color: AppColors.emerald),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text('Build: ${ch.build}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMain), overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.rocket_launch_rounded, size: 18),
                label: const Text('Enroll to Unlock All 12 Chapters (₹199) 🚀', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                ),
                onPressed: _openCheckoutDialog,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 2B. JUNIOR ROBOTICS DIPLOMA & PORTFOLIO ACCREDITATION
  Widget _buildCertificatePreviewSection(bool isDesktop) {
    final cadetName = _nameController.text.trim().isEmpty ? 'Aarav Sharma' : _nameController.text.trim();

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 20, vertical: 56),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.amberSoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text('TANGIBLE RECOGNITION FOR SCHOOL', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppColors.amberGlow, letterSpacing: 1.2)),
              ),
              const SizedBox(height: 12),
              const Text(
                'Recognized Junior Robotics Engineering Diploma',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textMain, letterSpacing: -0.8),
              ),
              const SizedBox(height: 10),
              const Text(
                'Printable, high-resolution certificate recognized for CBSE/ICSE practical portfolios, Atal Tinkering Labs & School Science Exhibitions.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textMuted, height: 1.5),
              ),
              const SizedBox(height: 32),
              // Realistic Diploma Frame
              Container(
                padding: EdgeInsets.all(isDesktop ? 36 : 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDF7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD4AF37), width: 3),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFD4AF37).withValues(alpha: 0.25), blurRadius: 25, offset: const Offset(0, 8)),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('🇮🇳', style: TextStyle(fontSize: 24)),
                        Column(
                          children: const [
                            Text('MAKERQUEST ACADEMY OF JUNIOR ROBOTICS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF92400E), letterSpacing: 1.5)),
                            Text('NATIONAL STEM EXPERIENTIAL FRAMEWORK • NEP 2020', style: TextStyle(fontSize: 9, color: Color(0xFFB45309), letterSpacing: 1.0)),
                          ],
                        ),
                        const AnimatedGoldShimmerDiplomaSeal(),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('OFFICIAL DIPLOMA OF CERTIFICATION', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), letterSpacing: 1.2)),
                    const SizedBox(height: 8),
                    const Text('This credential is proudly awarded to', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Color(0xFF64748B))),
                    const SizedBox(height: 10),
                    Text(
                      cadetName,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        letterSpacing: 0.5,
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFFD4AF37),
                        decorationThickness: 2,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'for demonstrating verified mastery in 17+ hands-on mechanical builds, 3D kinematic blueprint CAD, linkage kinematics, and stored potential energy systems.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Color(0xFF334155), height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('VERIFIED CREDENTIAL ID', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                            Text('MQ-CADET-2026-IND', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), fontFamily: 'monospace')),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFF59E0B)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.verified_rounded, size: 14, color: Color(0xFFD97706)),
                              SizedBox(width: 4),
                              Text('Official STEM Diploma', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF92400E))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 3. WHAT WE OFFER & WHAT WE DO
  Widget _buildWhatWeOfferSection(bool isDesktop) {
    final features = [
      (
        icon: '📐',
        title: 'Interactive 3D CAD & Blueprint Visualizer',
        desc: 'Before cutting cardboard, students inspect exact millimeter dimensions, internal corrugation flute grain (0°), exploded assemblies, and physics force vectors.',
        color: AppColors.cyan,
      ),
      (
        icon: '📚',
        title: '12 Chapters of Cardboard Robotics',
        desc: 'Based on authentic maker engineering: Scissor lifts, straw-bearing rolling carts, rubber-band torque racers, double-banked marble runs, and mechanical grippers.',
        color: AppColors.primary,
      ),
      (
        icon: '♻️',
        title: 'Zero Waste, Low-Cost Upcycled Materials',
        desc: 'No ₹2,500+ plastic electronics kits that break. Everything is built with upcycled boxes, wooden skewers, drinking straws, and rubber bands.',
        color: AppColors.emerald,
      ),
      (
        icon: '🎮',
        title: 'Gamified Quest Path & Certifications',
        desc: 'Earn XP, level up from Cardboard Apprentice to Master Maker, pass interactive checkpoint quizzes, and graduate with printable STEM certificates.',
        color: AppColors.amber,
      ),
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 20, vertical: 50),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              const Text('WHAT WE OFFER & WHAT WE DO', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.primary, letterSpacing: 1.2)),
              const SizedBox(height: 8),
              const Text('The Complete Hands-On STEM Learning Journey', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textMain)),
              const SizedBox(height: 12),
              const Text(
                'We turn engineering theory into tactile problem-solving that students can hold, test, and celebrate.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textMuted),
              ),
              const SizedBox(height: 36),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isDesktop ? 2 : 1,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: isDesktop ? 2.2 : 2.0,
                ),
                itemCount: features.length,
                itemBuilder: (context, idx) {
                  final f = features[idx];
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: f.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(child: Text(f.icon, style: const TextStyle(fontSize: 24))),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(f.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textMain)),
                              const SizedBox(height: 6),
                              Text(f.desc, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.45)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 3B. SMART PARENT'S SAVINGS CALCULATOR
  Widget _buildParentRoiCalculator(bool isDesktop) {
    return Container(
      color: const Color(0xFFF1F5F9),
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 20, vertical: 56),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: Container(
            padding: EdgeInsets.all(isDesktop ? 36 : 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 8)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('THE SMART PARENT\'S ARITHMETIC', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppColors.primary, letterSpacing: 1.2)),
                          SizedBox(height: 4),
                          Text('Annual Extracurricular STEM Cost Comparison', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textMain)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.emeraldSoft,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('Save ₹15,000+', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.emerald)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),
                _buildRoiRow('Weekend Robotics Coaching (1 Year)', '₹6,000 – ₹15,000', isPositive: false),
                _buildRoiRow('3 Commercial Plastic Robot Kits (Break easily)', '₹7,500', isPositive: false),
                _buildRoiRow('Video Games & Mobile App Microtransactions', '₹2,400', isPositive: false),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                _buildRoiRow('MakerQuest All-Access Lifetime Pass (17 Builds)', '₹199 One-Time', isPositive: true),
                _buildRoiRow('Materials Cost (Clean Household Scrap Delivery Boxes)', '₹0.00', isPositive: true),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: Row(
                    children: const [
                      Text('💡', style: TextStyle(fontSize: 20)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'For less than the price of a single movie ticket or Domino\'s pizza (₹199), your child gains a permanent, reusable engineering playground.',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF065F46), height: 1.45),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoiRow(String title, String cost, {required bool isPositive}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '${isPositive ? "✅" : "❌"} $title',
              style: TextStyle(fontSize: 13, fontWeight: isPositive ? FontWeight.w800 : FontWeight.w600, color: isPositive ? AppColors.textMain : AppColors.textMuted),
            ),
          ),
          Text(
            cost,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: isPositive ? AppColors.emerald : AppColors.rose,
            ),
          ),
        ],
      ),
    );
  }

  // 4. STUDENT CAPABILITY & READINESS ASSESSMENT
  Widget _buildAssessmentSection(bool isDesktop) {
    return Container(
      key: _assessmentKey,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 20, vertical: 50),
      color: Colors.white,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.amberSoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text('FREE 60-SECOND MAKER DIAGNOSTIC', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppColors.amberGlow)),
              ),
              const SizedBox(height: 10),
              const Text('Discover What Your Student is Capable of Building', textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.textMain)),
              const SizedBox(height: 8),
              const Text(
                'Enter your student\'s details below. Our pedagogical diagnostic engine will analyze their spatial, mechanical, and motor readiness, and recommend their customized robotics curriculum.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.5),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 6)),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name & Email
                      isDesktop
                          ? Row(
                              children: [
                                Expanded(child: _buildNameField()),
                                const SizedBox(width: 16),
                                Expanded(child: _buildEmailField()),
                              ],
                            )
                          : Column(
                              children: [
                                _buildNameField(),
                                const SizedBox(height: 16),
                                _buildEmailField(),
                              ],
                            ),
                      const SizedBox(height: 20),

                      // Age Selector with Grade Badges
                      const Text('Student Age & Stage:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textMain)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [7, 8, 9, 10, 11, 12, 13, 14, 15, 16].map((age) {
                          final isSelected = _selectedAge == age;
                          return ChoiceChip(
                            label: Text('Age $age', style: TextStyle(fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600, fontSize: 12)),
                            selected: isSelected,
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textMain),
                            onSelected: (val) {
                              if (val) setState(() => _selectedAge = age);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Prior Experience
                      const Text('Current Building Experience:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textMain)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _experienceLevel,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Beginner (Crafting, paper & scissors)', child: Text('🌱 Beginner: Enjoys crafting, scissors & paper')),
                          DropdownMenuItem(value: 'Intermediate (Lego, crafting & kits)', child: Text('⚙️ Intermediate: Has built Lego models & simple kits')),
                          DropdownMenuItem(value: 'Advanced (Mechanics, coding & gears)', child: Text('🚀 Advanced: Loves robotics, mechanical gears & coding')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _experienceLevel = val);
                        },
                      ),
                      const SizedBox(height: 20),

                      // Dream Interest
                      const Text('What mechanism excites them most?', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textMain)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _favoriteInterest,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Speed Racers & Drive Systems', child: Text('🏎️ Speed Racers & Wheels (Elastic Potential Torque)')),
                          DropdownMenuItem(value: 'Scissor Lifts & Lifting Linkages', child: Text('🏗️ Scissor Lifts & Cranes (Mechanical Advantage)')),
                          DropdownMenuItem(value: 'Roller Coasters & Gravity Chutes', child: Text('🎢 Roller Coasters (Gravitational Physics & Banked Turns)')),
                          DropdownMenuItem(value: 'Articulated Robot Grippers & Jaws', child: Text('🦾 Articulated Robot Grippers (Dual-Lever Mechanics)')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _favoriteInterest = val);
                        },
                      ),
                      const SizedBox(height: 24),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: _isAnalyzing
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.psychology_rounded, size: 20),
                          label: Text(
                            _isAnalyzing ? 'Bot "Bolts" is Drafting Blueprint...' : 'Analyze Maker Capability & Generate Plan 🚀',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _isAnalyzing ? null : _runAnalysis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Animated Robot Architect Drafting Blueprint Screen
              if (_isAnalyzing) ...[
                const SizedBox(height: 24),
                RobotPlanDraftingAnimation(
                  studentName: _nameController.text.trim().isEmpty ? 'Young Cadet' : _nameController.text.trim(),
                  onComplete: _onRobotDraftingComplete,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Student\'s Full Name *', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textMain)),
        const SizedBox(height: 6),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'e.g. Aarav Sharma',
            prefixIcon: const Icon(Icons.person_outline_rounded, size: 18),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter student name' : null,
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Parent / Student Email *', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textMain)),
        const SizedBox(height: 6),
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            hintText: 'e.g. parent@example.com',
            prefixIcon: const Icon(Icons.email_outlined, size: 18),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Please enter an email';
            if (!v.contains('@')) return 'Enter a valid email address';
            return null;
          },
        ),
      ],
    );
  }

  // 5. DIAGNOSTIC RESULTS: WHAT THE STUDENT IS CAPABLE OF BUILDING
  Widget _buildAnalysisResultsSection(bool isDesktop) {
    final studentName = _nameController.text.trim().isEmpty ? 'Student' : _nameController.text.trim();

    return Container(
      key: _resultsKey,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 20, vertical: 50),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge & Archetype Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF93C5FD)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(child: Text(_archetypeIcon, style: const TextStyle(fontSize: 32))),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('$studentName\'s Maker Profile:', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.emeraldSoft,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text('$_aptitudeScore% Mechanical Aptitude', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.emerald)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(_archetype, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textMain)),
                          const SizedBox(height: 2),
                          Text('Recommended Curriculum: $_recommendedTrack', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text('What $studentName is Capable of Building Right Now:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textMain)),
              const SizedBox(height: 6),
              Text('Based on age $_selectedAge and aptitude for $_favoriteInterest, $studentName can master these 4 projects in their first 2 weeks:', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              const SizedBox(height: 16),

              // 4 Recommended Projects Cards
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isDesktop ? 2 : 1,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: isDesktop ? 2.6 : 2.2,
                ),
                itemCount: _recommendedProjects.length,
                itemBuilder: (context, idx) {
                  final p = _recommendedProjects[idx];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.icon, style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textMain)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: AppColors.emeraldSoft, borderRadius: BorderRadius.circular(6)),
                                    child: Text(p.diff, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.emerald)),
                                  ),
                                  const SizedBox(width: 6),
                                  Text('⏱️ ${p.time}', style: const TextStyle(fontSize: 10, color: AppColors.textDim)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(p.desc, style: const TextStyle(fontSize: 11, color: AppColors.textMuted), maxLines: 2, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 28),

              // CALL TO ACTION / PURCHASE BOX
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF0F172A)]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 8)),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('SPECIAL CADET ENROLLMENT OFFER', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Color(0xFF38BDF8))),
                          const SizedBox(height: 4),
                          Text('Unlock $studentName\'s All-Access MakerQuest Odyssey', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                          const SizedBox(height: 6),
                          const Text(
                            'One-time software license. Includes full 12-chapter interactive 3D blueprints, CAD simulator, gamified quest map, and engineering certificates.',
                            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8), height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_currencySymbol, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                            Text(_planPrice.toStringAsFixed(0), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                          ],
                        ),
                        const Text('Lifetime Access', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.payment_rounded, size: 16),
                          label: const Text('Enroll Now 💳', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF38BDF8),
                            foregroundColor: const Color(0xFF0F172A),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: _openCheckoutDialog,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // STANDALONE PRICING & LIFETIME CADET PASS VALUE STACK
  Widget _buildPricingSection(bool isDesktop) {
    return Container(
      key: _pricingKey,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 20, vertical: 60),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFEF4444)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('⚡', style: TextStyle(fontSize: 14)),
                    SizedBox(width: 6),
                    Text('LIMITED LAUNCH OFFER • OVER 90% OFF', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.0)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Cadet All-Access Lifetime Pass',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.8),
              ),
              const SizedBox(height: 10),
              const Text(
                'One single payment. Lifetime access. No recurring subscriptions. Everything your young engineer needs to master mechanical robotics.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8), height: 1.5),
              ),
              const SizedBox(height: 36),

              // Pricing Card Box
              Container(
                padding: EdgeInsets.all(isDesktop ? 36 : 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 30, offset: const Offset(0, 15)),
                  ],
                ),
                child: Column(
                  children: [
                    // Urgency progress bar
                    Container(
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('🔥 Inaugural Cohort: 462 of 500 Passes Claimed', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF92400E))),
                              Text('92% Claimed', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFFD97706))),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: const LinearProgressIndicator(
                              value: 0.92,
                              minHeight: 6,
                              backgroundColor: Color(0xFFFDE68A),
                              valueColor: AlwaysStoppedAnimation(Color(0xFFD97706)),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text('Next 500 batch will be priced at ₹499. Lock in ₹199 lifetime rate today.', style: TextStyle(fontSize: 10, color: Color(0xFFB45309), fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),

                    // Price Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Text('₹', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textMain)),
                        const Text('199', style: TextStyle(fontSize: 54, fontWeight: FontWeight.w900, color: AppColors.textMain, letterSpacing: -1.5)),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('One-Time Payment', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.emerald)),
                            Text('Normally ₹2,999 for toy kits', style: TextStyle(fontSize: 11, color: AppColors.textMuted, decoration: TextDecoration.lineThrough)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),

                    // Feature Value Stack
                    _buildPricingFeatureItem('All 12 Progressive Indian STEM Engineering Chapters (Lifetime Access)', '₹800 value'),
                    _buildPricingFeatureItem('17+ Interactive 3D CAD Blueprint Visualizers with Kinematic Physics', '₹600 value'),
                    _buildPricingFeatureItem('10 Collectible Engineering Badges & Official STEM Graduation Diploma', '₹350 value'),
                    _buildPricingFeatureItem('Printable 1:1 Scale Dimension Cut Sheets & Scoring Guides', '₹250 value'),
                    _buildPricingFeatureItem('Parent & Educator Discussion Guides with NEP 2020 Science Lessons', '₹300 value'),
                    _buildPricingFeatureItem('Zero Scrap Kit Dependencies (Uses everyday household delivery boxes)', 'Priceless'),
                    _buildPricingFeatureItem('Free Access to All Future Seasonal DIY Project Drops & Updates', 'Included'),

                    const SizedBox(height: 24),

                    // No-Brainer Cost Comparison
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('THE NO-BRAINER COMPARISON', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: 1.0)),
                          SizedBox(height: 8),
                          Text('❌ Robotics Coaching Class in India: ₹5,000 to ₹12,000 / month', style: TextStyle(fontSize: 11.5, color: AppColors.rose, fontWeight: FontWeight.w600)),
                          SizedBox(height: 4),
                          Text('❌ Plastic Robot Toy Kit on Amazon: ₹2,499 - ₹4,999 (breaks once)', style: TextStyle(fontSize: 11.5, color: AppColors.rose, fontWeight: FontWeight.w600)),
                          SizedBox(height: 4),
                          Text('❌ One Family Movie / Domino\'s Order: ₹800+', style: TextStyle(fontSize: 11.5, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                          SizedBox(height: 6),
                          Divider(),
                          SizedBox(height: 6),
                          Text('✅ MakerQuest All-Access Pass: ₹199 One-Time (Lifetime)', style: TextStyle(fontSize: 13, color: AppColors.emerald, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // CTA Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                      ),
                      onPressed: _openCheckoutDialog,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.lock_open_rounded, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Claim Cadet Lifetime Pass for ₹199 🚀',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Instant UPI / Cards Payment Strip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('⚡ Instant Activation via UPI (GPay • PhonePe • Paytm • BHIM) & Cards', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 100% UPI refund reassurance banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: const Row(
                        children: [
                          Text('🛡️', style: TextStyle(fontSize: 20)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '30-Day Risk-Free Guarantee: If your child doesn\'t build their first working kinetic machine in 30 days, simply message us for an immediate 100% refund of ₹199 directly to your UPI ID.',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF065F46), height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Guarantee & Security Strip
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: const [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_user_rounded, size: 16, color: AppColors.emerald),
                            SizedBox(width: 6),
                            Text('30-Day 100% Money-Back Guarantee', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMain)),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shield_rounded, size: 16, color: AppColors.primary),
                            SizedBox(width: 6),
                            Text('256-bit Encrypted Checkout', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.flash_on_rounded, size: 16, color: AppColors.amber),
                            SizedBox(width: 6),
                            Text('Instant Digital Workshop Unlock', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPricingFeatureItem(String title, String tag) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(color: AppColors.emeraldSoft, shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, color: AppColors.emerald, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMain)),
          ),
          const SizedBox(width: 8),
          Text(tag, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
        ],
      ),
    );
  }

  // 6. CURRICULUM COMPARISON TABLE
  Widget _buildCurriculumComparison(bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 20, vertical: 50),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              const Text('TRANSPARENT VALUE', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.primary, letterSpacing: 1.2)),
              const SizedBox(height: 8),
              const Text('Why Families Choose MakerQuest over Plastic Kits', textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.textMain)),
              const SizedBox(height: 24),
              Table(
                border: TableBorder.all(color: AppColors.border, borderRadius: BorderRadius.circular(12)),
                children: [
                  TableRow(
                    decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
                    children: const [
                      Padding(padding: EdgeInsets.all(12), child: Text('Feature', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
                      Padding(padding: EdgeInsets.all(12), child: Text('MakerQuest Software', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.primary))),
                      Padding(padding: EdgeInsets.all(12), child: Text('Traditional Toy Robot Kits', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.textMuted))),
                    ],
                  ),
                  _buildTableRow('Materials Cost', '₹0 (Scrap cardboard & rubber bands)', '₹2,000 - ₹5,000+ per single kit'),
                  _buildTableRow('Mechanisms Taught', '17+ physical kinematic machines', '1 static proprietary toy'),
                  _buildTableRow('Interactive 3D CAD', 'Full exploded 3D & physics vectors', 'Static paper manual or none'),
                  _buildTableRow('Skill Longevity', 'Lifelong engineering intuition', 'Assembled once, abandoned in drawer'),
                  _buildTableRow('Curriculum Progression', '5 Levels, NEP 2020 & CBSE/ICSE Physics Labs', 'No curriculum alignment'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _buildTableRow(String feature, String mqVal, String toyVal) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(12), child: Text(feature, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
        Padding(padding: const EdgeInsets.all(12), child: Text('✅ $mqVal', style: const TextStyle(fontSize: 12, color: AppColors.emerald, fontWeight: FontWeight.w600))),
        Padding(padding: const EdgeInsets.all(12), child: Text('❌ $toyVal', style: const TextStyle(fontSize: 12, color: AppColors.textMuted))),
      ],
    );
  }

  // 6B. WHATSAPP MENTOR SUPPORT
  Widget _buildWhatsAppSupportSection(bool isDesktop) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 20, vertical: 56),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: Container(
            padding: EdgeInsets.all(isDesktop ? 36 : 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)]),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF25D366).withValues(alpha: 0.35), width: 1.5),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 8)),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('1-ON-1 MAKER MENTORSHIP', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Color(0xFF34D399), letterSpacing: 1.2)),
                      const SizedBox(height: 6),
                      const Text('Never Get Stuck: Dedicated WhatsApp Support', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                      const SizedBox(height: 8),
                      const Text(
                        'Is a linkage sticking? Straw bearing wobbling? Send a 10-second video or photo to our dedicated engineering WhatsApp helpline. Our maker mentors respond with personalized alignment tips within 15 minutes during build hours.',
                        style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8), height: 1.5),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF25D366).withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF25D366).withValues(alpha: 0.45)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('📞', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 8),
                            const SelectableText(
                              'Official WhatsApp Helpline: ${ExternalLauncher.whatsAppPhoneDisplay}',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF6EE7B7), letterSpacing: 0.3),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.chat_rounded, size: 17),
                            label: const Text(
                              'Chat on WhatsApp (${ExternalLauncher.whatsAppPhoneDisplay})',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF25D366),
                              foregroundColor: const Color(0xFF052E16),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              SoundEffects.playPop();
                              ExternalLauncher.openWhatsApp();
                            },
                          ),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.copy_rounded, size: 15, color: Color(0xFFCBD5E1)),
                            label: const Text(
                              'Copy Number',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.white.withValues(alpha: 0.28)),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              Clipboard.setData(const ClipboardData(text: ExternalLauncher.whatsAppPhoneDisplay));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Copied WhatsApp number ${ExternalLauncher.whatsAppPhoneDisplay} to clipboard!'),
                                  backgroundColor: Color(0xFF15803D),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isDesktop) ...[
                  const SizedBox(width: 32),
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      SoundEffects.playPop();
                      ExternalLauncher.openWhatsApp();
                    },
                    child: Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        color: const Color(0xFF25D366).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF25D366).withValues(alpha: 0.55), width: 1.5),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('💬', style: TextStyle(fontSize: 40)),
                          SizedBox(height: 4),
                          Text('OPEN CHAT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF6EE7B7), letterSpacing: 0.8)),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // FREQUENTLY ASKED QUESTIONS ACCORDION
  Widget _buildFaqSection(bool isDesktop) {
    final faqs = [
      (
        q: 'Do I need to buy expensive robotics kits, electronics, or specialized tools?',
        a: 'No, absolutely not! The core mission of MakerQuest is 100% zero-waste scrap engineering. All you need are clean cardboard boxes (like Amazon, Flipkart, or cereal cartons), drinking straws, wooden skewers, rubber bands, household scissors, and glue. Everything is built from scratch.',
      ),
      (
        q: 'What age group is MakerQuest suitable for?',
        a: 'MakerQuest is designed for Indian students from Class 3 to Class 10 (ages 7 to 16). Younger inventors (ages 7–9) enjoy building with parental or elder sibling guidance, while older cadets (ages 10–16) work independently through the interactive 3D CAD blueprints, kinematic formulas, and checkpoint challenges.',
      ),
      (
        q: 'Is this a monthly subscription or a one-time purchase?',
        a: 'MakerQuest is a single one-time payment of ₹199. You receive permanent lifetime access to all 12 chapters, all 17+ interactive 3D blueprints, CAD simulator tools, and all future updates with zero recurring fees.',
      ),
      (
        q: 'How is this different from watching free YouTube videos?',
        a: 'YouTube videos are passive, unstructured, and often leave students frustrated with missing dimensions or unverified mechanics. MakerQuest provides interactive 3D CAD models you can rotate and zoom, step-by-step progress tracking, real physics formulas, error-prevention cards, and verifiable STEM certifications.',
      ),
      (
        q: 'What if my child doesn\'t enjoy it? Do you offer a guarantee?',
        a: 'We offer an unconditional 30-day 100% money-back guarantee. If your student doesn\'t build their first working machine or isn\'t completely captivated, simply let us know and we will issue an immediate full refund of ₹199 — no questions asked.',
      ),
      (
        q: 'Can Indian schools, Atal Tinkering Labs (ATL), or homeschoolers use MakerQuest?',
        a: 'Yes! MakerQuest is fully aligned with the Indian National Education Policy (NEP 2020) experiential learning mandate and CBSE/ICSE practical physics standards. It is perfect for Atal Tinkering Labs (ATL) and school science clubs, including educator lesson summaries and zero-cost material guides.',
      ),
    ];

    return Container(
      key: _faqKey,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 20, vertical: 56),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text('FREQUENTLY ASKED QUESTIONS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppColors.primary, letterSpacing: 1.2)),
              ),
              const SizedBox(height: 10),
              const Text(
                'Everything You Need to Know',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textMain, letterSpacing: -0.6),
              ),
              const SizedBox(height: 8),
              const Text(
                'Got questions about MakerQuest? Here are answers to the most common questions from parents and teachers.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textMuted),
              ),
              const SizedBox(height: 32),

              Column(
                children: List.generate(faqs.length, (idx) {
                  final faq = faqs[idx];
                  final isExpanded = _expandedFaqs.contains(idx);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isExpanded ? const Color(0xFFF8FAFC) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isExpanded ? AppColors.primary.withValues(alpha: 0.4) : const Color(0xFFE2E8F0)),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        setState(() {
                          if (isExpanded) {
                            _expandedFaqs.remove(idx);
                          } else {
                            _expandedFaqs.add(idx);
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    faq.q,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: isExpanded ? AppColors.primary : AppColors.textMain,
                                    ),
                                  ),
                                ),
                                Icon(
                                  isExpanded ? Icons.remove_circle_outline_rounded : Icons.add_circle_outline_rounded,
                                  color: isExpanded ? AppColors.primary : AppColors.textMuted,
                                  size: 20,
                                ),
                              ],
                            ),
                            if (isExpanded) ...[
                              const SizedBox(height: 10),
                              Text(
                                faq.a,
                                style: const TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.55),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 7. TESTIMONIALS
  Widget _buildTestimonialsSection(bool isDesktop) {
    final testimonials = [
      (
        quote: 'My 10-year-old built the scissor lift and rubber-band racer in two days using Amazon delivery boxes! He actually understands mechanical advantage and levers now.',
        author: 'Ananya Sharma, Parent (Bengaluru)',
        stars: '⭐⭐⭐⭐⭐'
      ),
      (
        quote: 'As an Atal Tinkering Lab (ATL) coordinator, MakerQuest is the most accessible, high-engagement STEM platform we have introduced. Zero costly imported kits needed.',
        author: 'Rajesh K., Science & ATL In-Charge (New Delhi)',
        stars: '⭐⭐⭐⭐⭐'
      ),
    ];

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 20, vertical: 50),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              const Text('TRUSTED BY FAMILIES & EDUCATORS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.primary, letterSpacing: 1.2)),
              const SizedBox(height: 8),
              const Text('What Young Makers & Parents Say', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textMain)),
              const SizedBox(height: 24),
              isDesktop
                  ? Row(
                      children: testimonials.map((t) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: _buildTestimonialCard(t)))).toList(),
                    )
                  : Column(
                      children: testimonials.map((t) => Padding(padding: const EdgeInsets.only(bottom: 16), child: _buildTestimonialCard(t))).toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestimonialCard(({String quote, String author, String stars}) t) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.stars, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 10),
          Text('"${t.quote}"', style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: AppColors.textMain, height: 1.5)),
          const SizedBox(height: 12),
          Text(t.author, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppColors.primary)),
        ],
      ),
    );
  }

  // 8. FOOTER
  Widget _buildFooter() {
    return Container(
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFFEC4899)]),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(child: Text('⚡', style: TextStyle(fontSize: 18))),
                  ),
                  const SizedBox(width: 10),
                  const Text('MakerQuest Academy', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Inspiring the next generation of engineers through hands-on cardboard robotics and kinematic design.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 14),
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  SoundEffects.playPop();
                  ExternalLauncher.openWhatsApp();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366).withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF25D366).withValues(alpha: 0.4)),
                  ),
                  child: const Text(
                    '💬 WhatsApp Helpline: ${ExternalLauncher.whatsAppPhoneDisplay} • Chat Now',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF6EE7B7)),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text('© 2026 MakerQuest. All rights reserved. Kid-Safe Solo DIY Platform.', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// DUMMY CHECKOUT PAYMENT DIALOG (Simulated Sandbox)
// ══════════════════════════════════════════════════════════════════
class _DummyCheckoutDialog extends StatefulWidget {
  final String studentName;
  final int studentAge;
  final String studentEmail;
  final String archetype;
  final String archetypeIcon;
  final int aptitudeScore;
  final double planPrice;
  final String currencySymbol;
  final void Function(String name, String email) onPaymentSuccess;

  const _DummyCheckoutDialog({
    required this.studentName,
    required this.studentAge,
    required this.studentEmail,
    required this.archetype,
    required this.archetypeIcon,
    required this.aptitudeScore,
    required this.planPrice,
    required this.currencySymbol,
    required this.onPaymentSuccess,
  });

  @override
  State<_DummyCheckoutDialog> createState() => _DummyCheckoutDialogState();
}

class _DummyCheckoutDialogState extends State<_DummyCheckoutDialog> {
  late TextEditingController _cardNameCtrl;
  final _cardNumberCtrl = TextEditingController(text: '4242 4242 4242 4242');
  final _cardExpCtrl = TextEditingController(text: '12/28');
  final _cardCvcCtrl = TextEditingController(text: '789');
  final _promoCtrl = TextEditingController();

  double _discount = 0.0;
  bool _isProcessing = false;
  String? _promoMessage;

  @override
  void initState() {
    super.initState();
    _cardNameCtrl = TextEditingController(text: '${widget.studentName} (Parent)');
  }

  @override
  void dispose() {
    _cardNameCtrl.dispose();
    _cardNumberCtrl.dispose();
    _cardExpCtrl.dispose();
    _cardCvcCtrl.dispose();
    _promoCtrl.dispose();
    super.dispose();
  }

  void _applyPromo() {
    final code = _promoCtrl.text.trim().toUpperCase();
    if (code == 'MAKER100' || code == 'FREE') {
      setState(() {
        _discount = widget.planPrice;
        _promoMessage = '100% Free Promo Applied! 🎉';
      });
    } else if (code == 'STEM50') {
      setState(() {
        _discount = widget.planPrice * 0.5;
        _promoMessage = '50% Student Discount Applied! ⚡';
      });
    } else {
      setState(() {
        _discount = 0.0;
        _promoMessage = 'Invalid promo code. Try "MAKER100" or "STEM50"';
      });
    }
  }

  void _submitPayment() async {
    setState(() => _isProcessing = true);
    SoundEffects.playPop();

    // Simulated sandbox gateway latency
    await Future.delayed(const Duration(milliseconds: 1400));

    if (!mounted) return;
    setState(() => _isProcessing = false);

    widget.onPaymentSuccess(widget.studentName, widget.studentEmail);
  }

  @override
  Widget build(BuildContext context) {
    final total = math.max(0.0, widget.planPrice - _discount);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modal header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(child: Text('💳', style: TextStyle(fontSize: 20))),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Secure Checkout', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textMain)),
                            Text('Simulated Sandbox Payment Gateway', style: TextStyle(fontSize: 10, color: AppColors.emerald, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Order summary banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.archetypeIcon, style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${widget.studentName}\'s Cadet All-Access Pass', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12), overflow: TextOverflow.ellipsis),
                                Text('Age ${widget.studentAge} • ${widget.archetype}', style: const TextStyle(fontSize: 10, color: AppColors.textMuted), overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('${widget.currencySymbol}${widget.planPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                        ],
                      ),
                      if (_discount > 0) ...[
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Promo Discount', style: TextStyle(color: AppColors.emerald, fontSize: 11, fontWeight: FontWeight.w700)),
                            Text('-${widget.currencySymbol}${_discount.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.emerald, fontWeight: FontWeight.w800, fontSize: 12)),
                          ],
                        ),
                      ],
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text('Total Due Today (Lifetime):', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${widget.currencySymbol}${total.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Promo code row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _promoCtrl,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          hintText: 'Promo code (try "MAKER100")',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.bgSurface,
                        foregroundColor: AppColors.textMain,
                        elevation: 0,
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _applyPromo,
                      child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                  ],
                ),
                if (_promoMessage != null) ...[
                  const SizedBox(height: 4),
                  Text(_promoMessage!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _discount > 0 ? AppColors.emerald : AppColors.rose)),
                ],
                const SizedBox(height: 16),

                // Simulated Express Checkout
                const Text('Instant UPI / Express Checkout:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Text('⚡', style: TextStyle(fontSize: 16)),
                        label: const Text('UPI / GPay', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black)),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.black.withValues(alpha: 0.05),
                          side: const BorderSide(color: AppColors.border),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _submitPayment,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Text('📱', style: TextStyle(fontSize: 16)),
                        label: const Text('PhonePe / Paytm', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black)),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.black.withValues(alpha: 0.05),
                          side: const BorderSide(color: AppColors.border),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _submitPayment,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Card details form
                const Text('Or Pay with Card:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(height: 6),

                TextField(
                  controller: _cardNameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Name on Card',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: _cardNumberCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Card Number',
                    prefixIcon: const Icon(Icons.credit_card_rounded, size: 18),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _cardExpCtrl,
                        decoration: InputDecoration(
                          labelText: 'Expires (MM/YY)',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _cardCvcCtrl,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'CVC / Security',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Pay button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _isProcessing ? null : _submitPayment,
                    child: _isProcessing
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                              SizedBox(width: 10),
                              Text('Processing Sandbox Payment...', style: TextStyle(fontWeight: FontWeight.w700)),
                            ],
                          )
                        : Text(
                            'Pay ${widget.currencySymbol}${total.toStringAsFixed(0)} & Activate Cadet Journey 🚀',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    '🔒 256-Bit SSL Encrypted • Simulated Mock Payment • Zero Real Charges',
                    style: TextStyle(fontSize: 10, color: AppColors.textDim),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      SoundEffects.playPop();
                      ExternalLauncher.openWhatsApp(
                        message:
                            'Hi MakerQuest! I need quick help with UPI / Cadet Pass enrollment (₹199) for ${widget.studentName}.',
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: Text(
                        '💬 Need UPI or enrollment help? WhatsApp ${ExternalLauncher.whatsAppPhoneDisplay}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF15803D),
                          decoration: TextDecoration.underline,
                        ),
                      ),
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
