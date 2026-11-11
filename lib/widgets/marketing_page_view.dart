// MakerQuest Minimal Interactive Talking-Robot Landing Page (MarketingPageView)
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/external_launcher.dart';
import '../services/quest_state.dart';
import '../services/sound_effects.dart';
import '../theme/app_theme.dart';
import 'kid_robot_builder_animation.dart';
import 'stem_infographics.dart';
import 'talking_robot_guide.dart';
import 'frosted_glass_background.dart';

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
  // Guided Stage Index:
  // 0: Meet Bolts (Intro + Scrap-to-Robot bench)
  // 1: Play With Examples (4 interactive physics demos)
  // 2: Your Plan (Lightweight interactive plan builder + drafting hologram)
  // 3: Cadet Pass (Minimal ₹199 unlock card + Ask Bolts FAQ + WhatsApp help)
  int _activeStage = 0;
  int _robotEntranceKey = 0;
  int _confettiKey = 0;
  int _highFiveCount = 0;
  bool _isRobotTalking = false;
  RobotMood _robotMood = RobotMood.greeting;
  RobotPaint _robotPaint = RobotPaint.cobalt;
  RobotHat _robotHat = RobotHat.none;
  bool _hasBoosters = false;
  bool _isDancing = false;
  bool _soundEnabled = SoundEffects.enabled;
  String _botMessage =
      'Beep-boop! I am Bolts! Tap scraps on my bench, paint me a new color, or give me a high-five!';

  // Interactive example index (Stage 1)
  int _exampleIdx = 0;
  int _tapQuipIdx = 0;

  // Lightweight plan builder state (Stage 2)
  final _planFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Aarav Sharma');
  final _emailController = TextEditingController(text: 'aarav.maker@example.com');
  int _selectedAge = 9;
  String _favoriteInterest = 'Speed Racers & Drive Systems';
  bool _isDraftingPlan = false;
  bool _planReady = false;

  String _archetype = 'Kinetic Drive Pioneer';
  String _archetypeIcon = '🏎️';
  int _aptitudeScore = 96;
  List<({String name, String icon, String time, String desc})> _recommendedProjects = [];

  final double _planPrice = 199.0;
  final String _currencySymbol = '₹';

  static const List<({String id, String label, String icon})> _stageTabs = [
    (id: 'meet', label: '1. Meet Bolts', icon: '🤖'),
    (id: 'examples', label: '2. Examples', icon: '⚙️'),
    (id: 'plan', label: '3. Your Plan', icon: '🎯'),
    (id: 'pass', label: '4. Pass ₹199', icon: '🚀'),
  ];

  static const List<String> _machineIntros = [
    'Example 1 — Scissor Lift: Slide the handle to stretch criss-cross cardboard arms 4× taller!',
    'Example 2 — Torque Racer: Wind the rubber band, hit Launch, and watch it zoom across the floor!',
    'Example 3 — Claw Gripper: Pull the trigger slider to squeeze & hoist the cargo cube!',
    'Example 4 — Gravity Coaster: Tilt the ramp slope and drop the marble through banked curves!',
    'Example 5 — Catapult Mini-Game: Aim Launch Power around 50–78% and hit Launch Block to score!',
  ];

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
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _goToStage(int stage, {String? customMessage}) {
    SoundEffects.playPop();
    setState(() {
      _activeStage = stage;
      _robotEntranceKey++;
      switch (stage) {
        case 0:
          _robotMood = _isDancing ? RobotMood.dancing : RobotMood.greeting;
          _botMessage = customMessage ??
              'Beep-boop! I am Bolts! Tap the household scraps on my bench — watch plain cardboard turn into a real moving robot!';
          break;
        case 1:
          _robotMood = _isDancing ? RobotMood.dancing : RobotMood.explaining;
          _botMessage = customMessage ?? _machineIntros[_exampleIdx];
          break;
        case 2:
          _robotMood = _isDancing
              ? RobotMood.dancing
              : (_planReady ? RobotMood.excited : RobotMood.thinking);
          _botMessage = customMessage ??
              (_planReady
                  ? 'Awesome, $_safeName! Here are 3 cardboard machines tailored right for your skills!'
                  : 'Quick 10-second check! Tell me your name, age & favorite build — I will draft your starter plan.');
          break;
        case 3:
          _robotMood = _isDancing ? RobotMood.dancing : RobotMood.excited;
          _botMessage = customMessage ??
              'All 17 projects, 3D blueprints & workshops unlock for ₹199 once! Tap any question below to ask me.';
          break;
      }
    });
  }

  String get _safeName =>
      _nameController.text.trim().isEmpty ? 'Cadet' : _nameController.text.trim();

  void _onTapRobot() {
    const quips = [
      'High-five! Zero ₹2,500 plastic kits needed — just everyday delivery boxes and imagination!',
      'Fun fact: Aligning cardboard flutes lengthwise makes a strip 300% stronger!',
      'Tap "2. Examples" anytime to test real cardboard linkages & play the Catapult game!',
    ];
    setState(() {
      _highFiveCount++;
      _confettiKey++;
      _robotMood = _isDancing ? RobotMood.dancing : RobotMood.excited;
      if (_highFiveCount == 3) {
        SoundEffects.playFanfare();
        _botMessage = 'WOOT! 3× High-Five Combo! My cardboard gears are turbo-charged!';
      } else if (_highFiveCount == 5) {
        SoundEffects.playFanfare();
        _botMessage = '5× INVENTOR STREAK! You unlocked maximum Bolts sparkle power!';
      } else if (_highFiveCount % 10 == 0) {
        SoundEffects.playFanfare();
        _botMessage = '$_highFiveCount× LEGENDARY COMBO! Even my straw wheels are cheering!';
      } else {
        _tapQuipIdx = (_tapQuipIdx + 1) % quips.length;
        _botMessage = quips[_tapQuipIdx];
      }
    });
  }

  void _onSelectPaint(RobotPaint paint) {
    SoundEffects.playPop();
    setState(() {
      _robotPaint = paint;
      _confettiKey++;
      _robotMood = _isDancing ? RobotMood.dancing : RobotMood.excited;
      _botMessage =
          'Whoa, ${paint.label} armor looks awesome on me! Zero paint fumes — pure digital flair!';
    });
  }

  void _onCycleHat() {
    final nextHat = _robotHat.next;
    SoundEffects.playRobotBeep();
    setState(() {
      _robotHat = nextHat;
      _confettiKey++;
      _robotMood = _isDancing ? RobotMood.dancing : RobotMood.excited;
      switch (nextHat) {
        case RobotHat.cap:
          _botMessage = 'Maker Cap on! Let\'s build something cool out of Amazon boxes!';
          break;
        case RobotHat.crown:
          _botMessage = 'Royal Inventor Crown equipped! Bow to the cardboard kingdom!';
          break;
        case RobotHat.topHat:
          _botMessage = 'Ta-da! Magic Top Hat ready to turn scrap cardboard into physics!';
          break;
        case RobotHat.visor:
          _botMessage = 'Cool Cyber Shades activated! Future robotics engineer coming through!';
          break;
        case RobotHat.none:
          _botMessage = 'Back to my classic glowing telemetry antenna — beep-boop!';
          break;
      }
    });
  }

  void _onToggleBoosters() {
    SoundEffects.playBoing();
    setState(() {
      _hasBoosters = !_hasBoosters;
      _confettiKey++;
      _robotMood = _isDancing ? RobotMood.dancing : RobotMood.excited;
      _botMessage = _hasBoosters
          ? 'TWIN BOOSTERS ENGAGED! Hovering 6 millimeters off the workbench floor!'
          : 'Boosters parked safely back in the toolbox!';
    });
  }

  void _onToggleDance() {
    SoundEffects.playFanfare();
    setState(() {
      _isDancing = !_isDancing;
      _confettiKey++;
      _robotMood = _isDancing ? RobotMood.dancing : RobotMood.greeting;
      _botMessage = _isDancing
          ? 'DISCO BOLTS MODE! ♪ Boogie-woogie cardboard shuffle initiated! ♪'
          : 'Whew, great dance workout! What build should we test next?';
    });
  }

  void _onToggleSound() {
    setState(() {
      _soundEnabled = !_soundEnabled;
      SoundEffects.enabled = _soundEnabled;
    });
    if (_soundEnabled) {
      SoundEffects.playRobotBeep();
    }
  }

  void _onSelectMachineExample(int idx) {
    setState(() {
      _exampleIdx = idx;
      _robotMood = _isDancing ? RobotMood.dancing : RobotMood.explaining;
      _botMessage = _machineIntros[idx];
    });
  }

  void _computeRecommendations() {
    if (_favoriteInterest.contains('Racers') || _favoriteInterest.contains('Speed')) {
      _archetype = 'Kinetic Drive Pioneer';
      _archetypeIcon = '🏎️';
      _aptitudeScore = 95 + (_selectedAge % 4);
      _recommendedProjects = [
        (
          name: 'Rubber-Band Wind-Up Racer',
          icon: '🏎️',
          time: '35 mins',
          desc: 'Twist rubber bands onto straw axles to race 5+ meters.',
        ),
        (
          name: 'Low-Friction Test Cart',
          icon: '🛒',
          time: '30 mins',
          desc: 'Drinking-straw axle sleeves built from one small box.',
        ),
        (
          name: 'Cardboard Scissor Lift',
          icon: '✂️',
          time: '35 mins',
          desc: 'Pantograph linkage lifting 4× vertical stroke.',
        ),
      ];
    } else if (_favoriteInterest.contains('Scissor') || _favoriteInterest.contains('Lifts')) {
      _archetype = 'Kinematic Linkage Architect';
      _archetypeIcon = '🏗️';
      _aptitudeScore = 94 + (_selectedAge % 5);
      _recommendedProjects = [
        (
          name: 'Cardboard Scissor Lift',
          icon: '✂️',
          time: '35 mins',
          desc: '3-tier criss-cross linkage lifting 250g cargo.',
        ),
        (
          name: 'Dual-Pulley Crane',
          icon: '🏗️',
          time: '40 mins',
          desc: 'Double-advantage hoist with cardboard lock pawl.',
        ),
        (
          name: 'Mechanical Claw Gripper',
          icon: '🦾',
          time: '45 mins',
          desc: 'Finger-pull lever jaws that pinch bottles & toys.',
        ),
      ];
    } else if (_favoriteInterest.contains('Coaster') || _favoriteInterest.contains('Marble')) {
      _archetype = 'Gravity Energy Explorer';
      _archetypeIcon = '🎢';
      _aptitudeScore = 97;
      _recommendedProjects = [
        (
          name: 'Gravity Marble Coaster',
          icon: '🎢',
          time: '45 mins',
          desc: 'Banked cardboard turns using gravity & centrifugal force.',
        ),
        (
          name: 'Rubber-Band Wind-Up Racer',
          icon: '🏎️',
          time: '35 mins',
          desc: 'Elastic energy propulsion with zero electronics.',
        ),
        (
          name: 'Cardboard Scissor Lift',
          icon: '✂️',
          time: '35 mins',
          desc: 'Precision sliding track shoe & X-linkages.',
        ),
      ];
    } else {
      _archetype = 'Bionic Robotics Inventor';
      _archetypeIcon = '🦾';
      _aptitudeScore = 96;
      _recommendedProjects = [
        (
          name: 'Mechanical Claw Gripper',
          icon: '🦾',
          time: '45 mins',
          desc: 'Trigger-pulled opposite jaws with rubber-pad grip.',
        ),
        (
          name: 'Cardboard Bionic Hand',
          icon: '🖐️',
          time: '50 mins',
          desc: 'Straw knuckles & string tendons mimicking human fingers.',
        ),
        (
          name: 'Dual-Pulley Crane',
          icon: '🏗️',
          time: '40 mins',
          desc: 'Compound lifting arm with smooth rotary spool.',
        ),
      ];
    }
  }

  void _startPlanDrafting() {
    if (_planFormKey.currentState != null && !_planFormKey.currentState!.validate()) {
      return;
    }
    SoundEffects.playPop();
    _computeRecommendations();
    setState(() {
      _isDraftingPlan = true;
      _planReady = false;
      _robotMood = RobotMood.thinking;
      _botMessage = 'Scanning $_safeName\'s build picks now... sketching your blueprint trajectory!';
    });
  }

  void _onDraftingComplete() {
    if (!mounted) return;
    setState(() {
      _isDraftingPlan = false;
      _planReady = true;
      _robotMood = RobotMood.excited;
      _botMessage =
          'Boom, $_safeName! You are a $_archetype ($_aptitudeScore% match)! Start with these 3 builds:';
    });
  }

  void _openCheckoutDialog() {
    SoundEffects.playPop();
    final studentName = _safeName;
    final studentEmail = _emailController.text.trim().isEmpty
        ? 'cadet@makerquest.edu'
        : _emailController.text.trim();

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
      builder: (ctx) {
        final isCompact = MediaQuery.sizeOf(ctx).width < 480;
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: GlassSurface(
              borderRadius: 24,
              blurSigma: 18,
              tintColor: AppColors.emerald,
              padding: EdgeInsets.all(isCompact ? 18 : 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.emeraldSoft.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.emerald, width: 2),
                      ),
                      child: const Center(child: Text('🎉', style: TextStyle(fontSize: 36))),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Enrollment Successful! 🏆',
                      textAlign: TextAlign.center,
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
                        color: Colors.white.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
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
                        label: const Text(
                          'Launch Cadet Workshop Now 🚀',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
            ),
          ),
        );
      },
    );
  }

  void _showSampleSchematicPreviewDialog() {
    SoundEffects.playPop();
    showDialog(
      context: context,
      builder: (ctx) {
        final screenW = MediaQuery.sizeOf(ctx).width;
        final isCompact = screenW < 600;
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 40, vertical: 20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860, maxHeight: 880),
            child: GlassSurface(
              borderRadius: 24,
              blurSigma: 18,
              padding: EdgeInsets.all(isCompact ? 14 : 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
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
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sample 3D CAD Blueprint Preview',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: isCompact ? 14 : 16,
                                      color: AppColors.textMain,
                                    ),
                                  ),
                                  const Text(
                                    'Interactive Kinematics, 3D Assembly & Stress Simulation Demo',
                                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const StepInfographicWidget(
                            visualType: 'pantograph_cut',
                            title: 'Measure & Cut Cardboard Struts with Aligned Flutes',
                            stepNumber: 1,
                            instruction:
                                'Cut six identical cardboard strips (15 cm long, 2 cm wide) so internal corrugation flutes run lengthwise for maximum strength.',
                            tip: 'Longitudinal flutes resist over 300% more bending force than cross-cut strips.',
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFF59E0B)),
                            ),
                            child: const Row(
                              children: [
                                Text('🔒', style: TextStyle(fontSize: 24)),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Sample Blueprint Only (Project 1 of 17)',
                                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF92400E)),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'All 17 projects, step guides, physics simulations & quizzes unlock after Cadet Pass enrollment.',
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
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      alignment: WrapAlignment.end,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Close Preview', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700)),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.rocket_launch_rounded, size: 16),
                          label: const Text(
                            'Enroll to Unlock All 17 Blueprints (₹199) 💳',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.emerald,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            _openCheckoutDialog();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _copyWhatsAppNumber() {
    SoundEffects.playPop();
    Clipboard.setData(
      const ClipboardData(text: ExternalLauncher.whatsAppPhoneDisplay),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Copied WhatsApp number ${ExternalLauncher.whatsAppPhoneDisplay} to clipboard!',
        ),
        backgroundColor: Color(0xFF15803D),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    final isWideStage = screenW >= 780;
    final isTiny = screenW < 420;

    return FrostedCloudBackdrop(
      accentColor: _robotPaint.swatch,
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
          child: const Icon(Icons.chat_rounded, size: 24),
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildTopNavigation(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    isTiny ? 12 : 24,
                    isTiny ? 12 : 22,
                    isTiny ? 12 : 24,
                    84, // clearance above WhatsApp FAB
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 980),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildMinimalHeaderStrip(isTiny),
                          SizedBox(height: isTiny ? 10 : 16),
                          _buildGuidedRobotStage(
                            isWideStage: isWideStage,
                            isTiny: isTiny,
                          ),
                          const SizedBox(height: 14),
                          _buildMinimalFooter(isTiny),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopNavigation(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    final showWideNav = screenW >= 720;
    final isTiny = screenW < 420;

    return GlassChromeBar(
      padding: EdgeInsets.symmetric(
        horizontal: isTiny ? 12 : 24,
        vertical: isTiny ? 8 : 12,
      ),
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: isTiny ? 30 : 36,
                  height: isTiny ? 30 : 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, Color(0xFFEC4899)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(child: Text('⚡', style: TextStyle(fontSize: isTiny ? 16 : 19))),
                ),
                SizedBox(width: isTiny ? 8 : 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'MakerQuest',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: isTiny ? 15 : 17,
                        color: AppColors.textMain,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const Text(
                      'ROBOT GUIDE • AGES 7–16',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppColors.amber,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Wrap(
              spacing: isTiny ? 6 : 10,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (showWideNav)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.chat_rounded, size: 15, color: Color(0xFF16A34A)),
                    label: const Text(
                      ExternalLauncher.whatsAppPhoneDisplay,
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF15803D)),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFF0FDF4),
                      side: const BorderSide(color: Color(0xFF86EFAC)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () {
                      SoundEffects.playPop();
                      ExternalLauncher.openWhatsApp();
                    },
                  ),
                if (widget.questState.isEnrolled)
                  ElevatedButton.icon(
                    icon: Icon(Icons.handyman_rounded, size: isTiny ? 14 : 16),
                    label: Text(
                      isTiny ? 'Workshop' : 'Back to Workshop',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: isTiny ? 11 : 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.bgSurface,
                      foregroundColor: AppColors.textMain,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(horizontal: isTiny ? 10 : 14, vertical: isTiny ? 8 : 9),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: widget.onLaunchWorkshop,
                  ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: isTiny ? 12 : 16, vertical: isTiny ? 8 : 9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  onPressed: _openCheckoutDialog,
                  child: Text(
                    isTiny ? 'Pass ₹199' : 'Get Cadet Pass ₹199',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: isTiny ? 11 : 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimalHeaderStrip(bool isTiny) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Turn Cardboard into Real Robotics.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isTiny ? 22 : 30,
            fontWeight: FontWeight.w900,
            color: AppColors.textMain,
            letterSpacing: -0.8,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 10),
        // Minimal Step Selector Tabs
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: List.generate(_stageTabs.length, (i) {
            final tab = _stageTabs[i];
            final active = i == _activeStage;
            return InkWell(
              onTap: () => _goToStage(i),
              borderRadius: BorderRadius.circular(24),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(
                  horizontal: isTiny ? 10 : 14,
                  vertical: isTiny ? 7 : 8,
                ),
                decoration: BoxDecoration(
                  gradient: active
                      ? const LinearGradient(
                          colors: [Color(0xFF0F172A), Color(0xFF312E81)],
                        )
                      : LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.78),
                            Colors.white.withValues(alpha: 0.54),
                          ],
                        ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: active
                        ? const Color(0xFF4F46E5).withValues(alpha: 0.75)
                        : Colors.white.withValues(alpha: 0.9),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (active ? AppColors.primary : const Color(0xFF94A3B8))
                          .withValues(alpha: active ? 0.22 : 0.12),
                      blurRadius: active ? 12 : 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(tab.icon, style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 5),
                    Text(
                      tab.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: active ? Colors.white : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildGuidedRobotStage({
    required bool isWideStage,
    required bool isTiny,
  }) {
    return GlassSurface(
      borderRadius: 26,
      blurSigma: 18,
      tintColor: _robotPaint.swatch,
      topOpacity: 0.78,
      bottomOpacity: 0.56,
      borderColor: Colors.white.withValues(alpha: 0.90),
      borderWidth: 1.5,
      padding: EdgeInsets.all(isTiny ? 12 : 22),
      child: isWideStage
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: _buildRobotHostPane(isWideStage: true, isTiny: false),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 7,
                  child: _buildStageRightPane(isTiny: false),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildRobotHostPane(isWideStage: false, isTiny: isTiny),
                const SizedBox(height: 14),
                _buildStageRightPane(isTiny: isTiny),
                const SizedBox(height: 14),
                _buildQuickReplyChips(),
              ],
            ),
    );
  }

  Widget _buildRobotHostPane({
    required bool isWideStage,
    required bool isTiny,
  }) {
    final bubble = RobotSpeechBubble(
      message: _botMessage,
      speakerTag: 'BOLTS',
      accentColor: _activeStage == 3 ? AppColors.emerald : _robotPaint.swatch,
      onTalkingChanged: (talking) {
        if (mounted && _isRobotTalking != talking) {
          setState(() => _isRobotTalking = talking);
        }
      },
    );

    final toyBar = BoltsCustomizeToyBar(
      paintStyle: _robotPaint,
      onSelectPaint: _onSelectPaint,
      hat: _robotHat,
      onCycleHat: _onCycleHat,
      hasBoosters: _hasBoosters,
      onToggleBoosters: _onToggleBoosters,
      isDancing: _isDancing,
      onToggleDance: _onToggleDance,
      soundEnabled: _soundEnabled,
      onToggleSound: _onToggleSound,
      highFiveCount: _highFiveCount,
    );

    if (isWideStage) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.66),
                  _robotPaint.swatch.withValues(alpha: 0.11),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.90),
                width: 1.3,
              ),
            ),
            child: Column(
              children: [
                TalkingRobotCharacter(
                  mood: _robotMood,
                  isTalking: _isRobotTalking,
                  entranceKey: _robotEntranceKey,
                  confettiBurstKey: _confettiKey,
                  paintStyle: _robotPaint,
                  hat: _robotHat,
                  hasBoosters: _hasBoosters,
                  isDancing: _isDancing,
                  height: 174,
                  onTap: _onTapRobot,
                ),
                const Text(
                  'Tap Bolts for high-fives & confetti!',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDim,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          toyBar,
          const SizedBox(height: 12),
          bubble,
          const SizedBox(height: 12),
          _buildQuickReplyChips(),
        ],
      );
    }

    // Compact mobile top host block: Bolts next to his speech bubble + playful toy dock!
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.68),
                    _robotPaint.swatch.withValues(alpha: 0.12),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.88),
                  width: 1.2,
                ),
              ),
              child: TalkingRobotCharacter(
                mood: _robotMood,
                isTalking: _isRobotTalking,
                entranceKey: _robotEntranceKey,
                confettiBurstKey: _confettiKey,
                paintStyle: _robotPaint,
                hat: _robotHat,
                hasBoosters: _hasBoosters,
                isDancing: _isDancing,
                height: isTiny ? 84 : 102,
                onTap: _onTapRobot,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: bubble),
          ],
        ),
        const SizedBox(height: 10),
        toyBar,
      ],
    );
  }

  Widget _buildQuickReplyChips() {
    switch (_activeStage) {
      case 0:
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow_rounded, size: 16),
              label: const Text('Try Live Examples', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _goToStage(1),
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.view_in_ar_rounded, size: 15),
              label: const Text('Preview 3D CAD', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textMain,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _showSampleSchematicPreviewDialog,
            ),
            TextButton(
              onPressed: () => _goToStage(2),
              child: const Text('Make My Plan 🎯', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
            ),
          ],
        );

      case 1:
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: const Text('Pick Builds For Me', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _goToStage(2),
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.swap_horiz_rounded, size: 15),
              label: const Text('Next Machine', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textMain,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _onSelectMachineExample((_exampleIdx + 1) % 5),
            ),
            TextButton(
              onPressed: _showSampleSchematicPreviewDialog,
              child: const Text('3D CAD 📐', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
            ),
          ],
        );

      case 2:
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.rocket_launch_rounded, size: 16),
              label: const Text('Unlock All 17 Builds (₹199)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _goToStage(3),
            ),
            OutlinedButton(
              onPressed: () => _goToStage(1),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textMain,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('← Back to Examples', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ],
        );

      default:
        // Interactive "Ask Bolts" Parent & Kid Question Chips!
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ASK BOLTS ANYTHING:',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: AppColors.textDim,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _askChip(
                  '📦 Do we need kits?',
                  'Zero kits! Every build uses clean Amazon/Flipkart boxes, straws, wooden skewers, rubber bands & glue.',
                ),
                _askChip(
                  '💳 Is ₹199 monthly?',
                  'Never monthly! ₹199 one-time unlocks all 12 chapters & 17 builds forever — backed by a 30-day refund.',
                ),
                _askChip(
                  '🎓 Good for school?',
                  'Yes! Each machine matches CBSE/ICSE physics (levers, torque, energy) and includes science fair display tips.',
                ),
                _askChip(
                  '💬 What if stuck?',
                  'Send a quick photo to our real human mentors on WhatsApp +918075971988 — we reply fast with alignment help!',
                ),
              ],
            ),
          ],
        );
    }
  }

  Widget _askChip(String label, String answer) {
    return ActionChip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMain),
      ),
      backgroundColor: Colors.white.withValues(alpha: 0.72),
      side: BorderSide(color: Colors.white.withValues(alpha: 0.90), width: 1.2),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      onPressed: () {
        SoundEffects.playPop();
        setState(() {
          _robotMood = RobotMood.explaining;
          _botMessage = answer;
        });
      },
    );
  }

  Widget _buildStageRightPane({required bool isTiny}) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: KeyedSubtree(
        key: ValueKey('stage_$_activeStage'),
        child: _activeStage == 0
            ? ScrapToRobotWorkbench(
                onReaction: (msg, {bool complete = false}) {
                  setState(() {
                    _robotMood = complete ? RobotMood.excited : RobotMood.explaining;
                    _botMessage = msg;
                  });
                },
              )
            : _activeStage == 1
                ? InteractiveMachinePlayground(
                    activeIndex: _exampleIdx,
                    onSelectMachine: _onSelectMachineExample,
                    onBoltsComment: (msg) {
                      setState(() {
                        _robotMood = RobotMood.excited;
                        _botMessage = msg;
                      });
                    },
                  )
                : _activeStage == 2
                    ? _buildInteractivePlanCard(isTiny)
                    : _buildMinimalPassCard(isTiny),
      ),
    );
  }

  Widget _buildInteractivePlanCard(bool isTiny) {
    if (_isDraftingPlan) {
      return RobotPlanDraftingAnimation(
        studentName: _safeName,
        onComplete: _onDraftingComplete,
      );
    }

    if (_planReady) {
      return GlassSurface(
        borderRadius: 20,
        blurSigma: 12,
        tintColor: AppColors.primary,
        borderColor: Colors.white.withValues(alpha: 0.90),
        padding: EdgeInsets.all(isTiny ? 14 : 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(_archetypeIcon, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$_safeName • Age $_selectedAge',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary),
                            ),
                            Text(
                              _archetype,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textMain),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.emerald,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$_aptitudeScore% Fit',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._recommendedProjects.map(
              (p) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.90)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.icon, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(p.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textMain)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(p.time, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(p.desc, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.refresh_rounded, size: 15),
                  label: const Text('Change Picks', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  onPressed: () {
                    setState(() {
                      _planReady = false;
                      _robotMood = RobotMood.thinking;
                      _botMessage = 'Sure! Pick another age or favorite machine and I will redraft it!';
                    });
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.bolt_rounded, size: 16),
                  label: const Text('Enroll Now (₹199) 💳', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emerald,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _openCheckoutDialog,
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Minimal 3-input interactive picker form
    final vibeOptions = [
      (icon: '🏎️', short: 'Racers', value: 'Speed Racers & Drive Systems'),
      (icon: '✂️', short: 'Lifts', value: 'Scissor Lifts & Lifting Linkages'),
      (icon: '🦾', short: 'Claws', value: 'Articulated Robot Grippers'),
      (icon: '🎢', short: 'Coasters', value: 'Roller Coasters & Gravity'),
    ];

    return Form(
      key: _planFormKey,
      child: GlassSurface(
        borderRadius: 20,
        blurSigma: 12,
        tintColor: AppColors.primary,
        borderColor: Colors.white.withValues(alpha: 0.90),
        padding: EdgeInsets.all(isTiny ? 14 : 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '10-SECOND STARTER PLANNER',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Cadet First Name',
                hintText: 'e.g. Aarav',
                isDense: true,
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.face_rounded, size: 18, color: AppColors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
              ),
              validator: (val) => (val == null || val.trim().isEmpty) ? 'Enter a name' : null,
            ),
            const SizedBox(height: 12),
            Text(
              'Age: $_selectedAge yrs',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textMain),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [7, 8, 9, 10, 11, 12, 13, 14].map((age) {
                final selected = age == _selectedAge;
                return ChoiceChip(
                  label: Text(age == 14 ? '14+' : '$age', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: selected ? Colors.white : AppColors.textMain)),
                  selected: selected,
                  selectedColor: AppColors.primary,
                  backgroundColor: Colors.white,
                  showCheckmark: false,
                  onSelected: (_) {
                    SoundEffects.playPop();
                    setState(() => _selectedAge = age);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            const Text(
              'Pick what sounds coolest:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textMain),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: vibeOptions.map((v) {
                final selected = _favoriteInterest == v.value;
                return InkWell(
                  onTap: () {
                    SoundEffects.playPop();
                    setState(() => _favoriteInterest = v.value);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primarySoft : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.border,
                        width: selected ? 1.8 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(v.icon, style: const TextStyle(fontSize: 15)),
                        const SizedBox(width: 5),
                        Text(
                          v.short,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: selected ? AppColors.primary : AppColors.textMain,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              icon: const Icon(Icons.auto_awesome_rounded, size: 17),
              label: const Text(
                'Let Bolts Draft My Plan 🤖✨',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: _startPlanDrafting,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimalPassCard(bool isTiny) {
    return GlassSurface(
      isDark: true,
      borderRadius: 20,
      blurSigma: 16,
      borderColor: const Color(0xFF60A5FA).withValues(alpha: 0.48),
      borderWidth: 1.5,
      padding: EdgeInsets.all(isTiny ? 14 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CADET ALL-ACCESS PASS',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF93C5FD), letterSpacing: 1.0),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Lifetime DIY Robotics Workshop',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.emerald.withValues(alpha: 0.5)),
                ),
                child: const Text(
                  '₹199 once',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF6EE7B7)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _passBullet('17 real cardboard machines & 12 guided chapters'),
          _passBullet('Interactive 3D CAD blueprints & physics simulators'),
          _passBullet('Zero extra kit cost • 30-day money-back guarantee'),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            icon: const Icon(Icons.rocket_launch_rounded, size: 17),
            label: const Text(
              'Unlock Workshop Now (₹199) 🚀',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emerald,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: _openCheckoutDialog,
          ),
          const SizedBox(height: 14),
          // Clean WhatsApp Mentor Row inside Finale Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF25D366).withValues(alpha: 0.35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '💬 Questions? Real Maker Mentors on WhatsApp:',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFA7F3D0)),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.chat_rounded, size: 15),
                      label: const Text(
                        'Chat on WhatsApp (${ExternalLauncher.whatsAppPhoneDisplay})',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        SoundEffects.playPop();
                        ExternalLauncher.openWhatsApp();
                      },
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.copy_rounded, size: 14),
                      label: const Text('Copy Number', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _copyWhatsAppNumber,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _passBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✓ ', style: TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.w900, fontSize: 13)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalFooter(bool isTiny) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 6,
      children: [
        const Text(
          '© 2026 MakerQuest • Zero-Waste Cardboard Robotics',
          style: TextStyle(fontSize: 11, color: AppColors.textDim, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        InkWell(
          onTap: () {
            SoundEffects.playPop();
            ExternalLauncher.openWhatsApp();
          },
          borderRadius: BorderRadius.circular(12),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: Text(
              'WhatsApp: ${ExternalLauncher.whatsAppPhoneDisplay}',
              style: TextStyle(fontSize: 11, color: Color(0xFF15803D), fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
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

    await Future.delayed(const Duration(milliseconds: 1400));

    if (!mounted) return;
    setState(() => _isProcessing = false);

    widget.onPaymentSuccess(widget.studentName, widget.studentEmail);
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    final isTiny = screenW < 400;
    final total = math.max(0.0, widget.planPrice - _discount);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: screenW < 480 ? 12 : 40, vertical: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: GlassSurface(
          borderRadius: 24,
          blurSigma: 18,
          padding: EdgeInsets.all(screenW < 480 ? 16 : 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
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
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Secure Checkout', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textMain)),
                                Text('Simulated Sandbox Payment Gateway', style: TextStyle(fontSize: 10, color: AppColors.emerald, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(height: 24),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.64),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.90)),
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
                            const Flexible(child: Text('Promo Discount', style: TextStyle(color: AppColors.emerald, fontSize: 11, fontWeight: FontWeight.w700))),
                            const SizedBox(width: 8),
                            Text('-${widget.currencySymbol}${_discount.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.emerald, fontSize: 12, fontWeight: FontWeight.w800)),
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

                const Text('Instant UPI / Express Checkout:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(height: 6),
                if (isTiny)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OutlinedButton.icon(
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
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
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
                    ],
                  )
                else
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
                              Flexible(
                                child: Text(
                                  'Processing Sandbox Payment...',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'Pay ${widget.currencySymbol}${total.toStringAsFixed(0)} & Activate Cadet Journey 🚀',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    '🔒 256-Bit SSL Encrypted • Simulated Mock Payment • Zero Real Charges',
                    textAlign: TextAlign.center,
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
                        textAlign: TextAlign.center,
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
