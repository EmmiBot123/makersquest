// MakerQuest Minimal Interactive Talking-Robot Landing Page (MarketingPageView)
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/bolts_storage.dart';
import '../services/bolts_voice_service.dart';
import '../services/external_launcher.dart';
import '../services/quest_state.dart';
import '../services/sound_effects.dart';
import '../services/stencil_exporter.dart';
import '../theme/app_theme.dart';
import 'bolts_arcade_deck.dart';
import 'bolts_free_flight_overlay.dart';
import 'inventor_sandbox_widget.dart';
import 'kid_robot_builder_animation.dart';
import 'robot_boost_flight_overlay.dart';
import 'stem_infographics.dart';
import 'talking_robot_guide.dart';
import 'frosted_glass_background.dart';

bool get _isRunningTests =>
    WidgetsBinding.instance.runtimeType.toString().contains('Test');

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

class _MarketingPageViewState extends State<MarketingPageView>
    with SingleTickerProviderStateMixin {
  // Guided Stage Index:
  // 0: Meet Bolts (Intro + Scrap-to-Robot bench)
  // 1: Play With Examples (5 interactive physics demos)
  // 2: Your Plan (Lightweight interactive plan builder + drafting hologram)
  // 3: Cadet Pass (Minimal ₹199 unlock card + Ask Bolts FAQ + WhatsApp help)
  // 4: Inventor Sandbox (Modular cardboard machine builder + 3 live tracks)
  int _activeStage = 0;
  final int _robotEntranceKey = 0;
  int _confettiKey = 0;
  int _overchargeKey = 0;
  int _backflipKey = 0;
  int _spinKey = 0;
  int _winkKey = 0;
  int _highFiveCount = 0;
  bool _isRobotTalking = false;
  RobotMood _robotMood = RobotMood.greeting;
  RobotPaint _robotPaint = RobotPaint.cobalt;
  RobotHat _robotHat = RobotHat.none;
  bool _hasBoosters = false;
  bool _isDancing = false;
  bool _isRainbowMode = false;
  bool _soundEnabled = SoundEffects.enabled;
  bool _voiceEnabled = BoltsVoiceService.enabled;
  String _sceneTheme = 'cloud';
  int _sandboxStars = 0;
  String _botMessage =
      'Beep-boop! I am Bolts! Tap scraps on my bench, paint me a new color, or give me a high-five!';

  // Persistent starter XP & mini-game high scores (carries into enrollment!)
  int _demoXp = 0;
  final Set<String> _clearedChallenges = {};
  double _racerBestMeters = 0.0;
  int _catapultBestStreak = 0;
  int _skyGearsBest = 0;
  int _jokeIdx = 0;
  bool _isFreeFlightActive = false;

  // Interactive command bar & Household scrap matcher
  final _scrollController = ScrollController();
  final _commandController = TextEditingController();
  final Set<String> _homeScraps = {'box', 'straws', 'band'};

  // Jetpack boost & fly-into-page transition controller
  late final AnimationController _flightController;
  int _pendingStage = 0;
  String? _pendingCustomMessage;
  bool _isFlightActive = false;
  bool _stageSwappedForFlight = false;

  final GlobalKey _stageStackKey = GlobalKey();
  final GlobalKey _viewportStackKey = GlobalKey();
  final GlobalKey _dockRobotKey = GlobalKey();
  final GlobalKey _rightPaneKey = GlobalKey();

  Offset? _takeoffCenter;
  Offset? _freeFlightStartCenter;
  Offset? _portalTargetCenter;
  double _takeoffRobotHeight = 184.0;

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
    (id: 'sandbox', label: '5. Sandbox', icon: '🛠️'),
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
    _loadSavedBoltsState();
    _flightController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _isRunningTests ? 80 : 1550),
    )
      ..addListener(_handleFlightTick)
      ..addStatusListener(_handleFlightStatus);
    _computeRecommendations();
    _nameController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _loadSavedBoltsState() {
    final saved = BoltsStorage.load();
    _robotPaint = RobotPaint.values.firstWhere(
      (p) => p.name == saved.paintName,
      orElse: () => RobotPaint.cobalt,
    );
    _robotHat = RobotHat.values.firstWhere(
      (h) => h.name == saved.hatName,
      orElse: () => RobotHat.none,
    );
    _hasBoosters = saved.hasBoosters;
    _soundEnabled = saved.soundEnabled;
    SoundEffects.enabled = _soundEnabled;
    _voiceEnabled = saved.voiceEnabled;
    BoltsVoiceService.enabled = _voiceEnabled;
    _isRainbowMode = saved.isRainbowMode;
    _highFiveCount = saved.highFives;
    _demoXp = saved.demoXp;
    _racerBestMeters = saved.racerBestMeters;
    _catapultBestStreak = saved.catapultBestStreak;
    _skyGearsBest = saved.skyGearsBest;
    _sceneTheme = saved.sceneTheme;
    _sandboxStars = saved.sandboxStars;
    _clearedChallenges.addAll(saved.clearedChallenges);
  }

  void _persistBoltsState() {
    BoltsStorage.save(
      BoltsSavedState(
        paintName: _robotPaint.name,
        hatName: _robotHat.name,
        hasBoosters: _hasBoosters,
        soundEnabled: _soundEnabled,
        voiceEnabled: _voiceEnabled,
        isRainbowMode: _isRainbowMode,
        highFives: _highFiveCount,
        demoXp: _demoXp,
        racerBestMeters: _racerBestMeters,
        catapultBestStreak: _catapultBestStreak,
        skyGearsBest: _skyGearsBest,
        sceneTheme: _sceneTheme,
        sandboxStars: _sandboxStars,
        clearedChallenges: _clearedChallenges,
      ),
    );
  }

  void _awardDemoXp(String milestoneKey, int amount) {
    if (_clearedChallenges.contains(milestoneKey)) return;
    setState(() {
      _clearedChallenges.add(milestoneKey);
      _demoXp += amount;
    });
    _persistBoltsState();
  }

  void _setBotSpeech(String message, {RobotMood? mood, bool speak = true}) {
    _botMessage = message;
    if (mood != null) _robotMood = mood;
    if (speak) {
      BoltsVoiceService.speak(message);
    }
  }

  @override
  void dispose() {
    _flightController.dispose();
    _scrollController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _commandController.dispose();
    super.dispose();
  }

  void _scrollToStageTop() {
    if (!_scrollController.hasClients || _scrollController.offset <= 0.0) {
      return;
    }
    if (_isRunningTests) {
      _scrollController.jumpTo(0.0);
    } else {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _handleFlightTick() {
    if (!_isFlightActive || _stageSwappedForFlight) return;
    if (_flightController.value >=
        BoostFlightKinematics.swapProgressThreshold) {
      _commitPendingStage();
    }
  }

  void _handleFlightStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      if (!_isFlightActive) return;
      if (!_stageSwappedForFlight) {
        _commitPendingStage();
      }
      if (mounted) {
        setState(() {
          _isFlightActive = false;
        });
      }
    }
  }

  void _commitPendingStage() {
    if (!mounted) return;
    HapticFeedback.lightImpact();
    _scrollToStageTop();
    setState(() {
      _stageSwappedForFlight = true;
      _applyStageState(_pendingStage, customMessage: _pendingCustomMessage);
      _confettiKey++;
    });
  }

  void _captureFlightAnchors() {
    final stageRender = _stageStackKey.currentContext?.findRenderObject();
    if (stageRender is RenderBox && stageRender.hasSize) {
      final dockRender = _dockRobotKey.currentContext?.findRenderObject();
      if (dockRender is RenderBox && dockRender.hasSize) {
        _takeoffCenter = dockRender.localToGlobal(
          dockRender.size.center(Offset.zero),
          ancestor: stageRender,
        );
        _takeoffRobotHeight = dockRender.size.height;

        final viewportRender =
            _viewportStackKey.currentContext?.findRenderObject();
        if (viewportRender is RenderBox && viewportRender.hasSize) {
          final rel = dockRender.localToGlobal(
            dockRender.size.center(Offset.zero),
            ancestor: viewportRender,
          );
          _freeFlightStartCenter = Offset(
            rel.dx.clamp(48.0, math.max(56.0, viewportRender.size.width - 48.0)),
            rel.dy.clamp(76.0, math.max(96.0, viewportRender.size.height - 56.0)),
          );
        }
      }

      final rightRender = _rightPaneKey.currentContext?.findRenderObject();
      if (rightRender is RenderBox && rightRender.hasSize) {
        final topLeft = rightRender.localToGlobal(
          Offset.zero,
          ancestor: stageRender,
        );
        _portalTargetCenter = Offset(
          topLeft.dx + rightRender.size.width * 0.48,
          topLeft.dy + math.min(rightRender.size.height * 0.42, 165.0),
        );
      }
    }
  }

  void _applyStageState(int stage, {String? customMessage, bool speak = true}) {
    _activeStage = stage;
    switch (stage) {
      case 0:
        _setBotSpeech(
          customMessage ??
              'Beep-boop! I am Bolts! Tap the household scraps on my bench — watch plain cardboard turn into a real moving robot!',
          mood: _isDancing ? RobotMood.dancing : RobotMood.greeting,
          speak: speak,
        );
        break;
      case 1:
        _setBotSpeech(
          customMessage ?? _machineIntros[_exampleIdx],
          mood: _isDancing ? RobotMood.dancing : RobotMood.explaining,
          speak: speak,
        );
        break;
      case 2:
        _setBotSpeech(
          customMessage ??
              (_planReady
                  ? 'Awesome, $_safeName! Here are 3 cardboard machines tailored right for your skills!'
                  : 'Quick 10-second check! Tell me your name, age & home scraps — I will draft your starter plan.'),
          mood: _isDancing
              ? RobotMood.dancing
              : (_planReady ? RobotMood.excited : RobotMood.thinking),
          speak: speak,
        );
        break;
      case 3:
        _setBotSpeech(
          customMessage ??
              'All 17 projects, 3D blueprints & workshops unlock for ₹199 once! Tap any question below to ask me.',
          mood: _isDancing ? RobotMood.dancing : RobotMood.excited,
          speak: speak,
        );
        break;
      case 4:
        _setBotSpeech(
          customMessage ??
              'INVENTOR SANDBOX! 🛠️ Snap together a cardboard Body, Motor, Wheels & Gadget — then test-drive it live!',
          mood: _isDancing ? RobotMood.dancing : RobotMood.excited,
          speak: speak,
        );
        break;
    }
  }

  void _goToStage(int stage, {String? customMessage}) {
    final targetChanged = stage != _activeStage ||
        (_isFlightActive && stage != _pendingStage);
    if (!targetChanged) {
      HapticFeedback.selectionClick();
      SoundEffects.playPop();
      _scrollToStageTop();
      if (_isFreeFlightActive || customMessage != null) {
        setState(() {
          _isFreeFlightActive = false;
          if (customMessage != null) {
            _applyStageState(stage, customMessage: customMessage);
          }
        });
      }
      return;
    }

    HapticFeedback.mediumImpact();
    _captureFlightAnchors();
    SoundEffects.playBoostFlight();
    setState(() {
      _isFreeFlightActive = false;
      _pendingStage = stage;
      _pendingCustomMessage = customMessage;
      _stageSwappedForFlight = false;
      _isFlightActive = true;
      _robotMood = _isDancing ? RobotMood.dancing : RobotMood.excited;
    });
    _flightController.forward(from: 0.0);
  }

  String get _safeName =>
      _nameController.text.trim().isEmpty ? 'Cadet' : _nameController.text.trim();

  void _onTapRobot() {
    const quips = [
      'High-five! Zero ₹2,500 plastic kits needed — just everyday delivery boxes and imagination!',
      'Fun fact: Aligning cardboard flutes lengthwise makes a strip 300% stronger!',
      'Tap "2. Examples" anytime to test real cardboard linkages & play the Catapult game!',
    ];
    late String speech;
    setState(() {
      _highFiveCount++;
      _confettiKey++;
      if (_highFiveCount == 3) {
        SoundEffects.playFanfare();
        speech = 'WOOT! 3× High-Five Combo! My cardboard gears are turbo-charged! (+10 Starter XP)';
      } else if (_highFiveCount == 5) {
        SoundEffects.playFanfare();
        speech = '5× INVENTOR STREAK! You unlocked maximum Bolts sparkle power!';
      } else if (_highFiveCount % 10 == 0) {
        SoundEffects.playFanfare();
        speech = '$_highFiveCount× LEGENDARY COMBO! Even my straw wheels are cheering!';
      } else {
        _tapQuipIdx = (_tapQuipIdx + 1) % quips.length;
        speech = quips[_tapQuipIdx];
      }
      _setBotSpeech(
        speech,
        mood: _isDancing ? RobotMood.dancing : RobotMood.excited,
      );
    });
    if (_highFiveCount >= 3) {
      _awardDemoXp('highfive_3', 10);
    }
    _persistBoltsState();
  }

  void _onSelectPaint(RobotPaint paint) {
    HapticFeedback.selectionClick();
    SoundEffects.playPop();
    setState(() {
      _robotPaint = paint;
      _confettiKey++;
      _setBotSpeech(
        'Whoa, ${paint.label} armor looks awesome on me! Zero paint fumes — pure digital flair!',
        mood: _isDancing ? RobotMood.dancing : RobotMood.excited,
      );
    });
    _persistBoltsState();
  }

  void _onCycleHat() {
    HapticFeedback.selectionClick();
    final nextHat = _robotHat.next;
    SoundEffects.playRobotBeep();
    setState(() {
      _robotHat = nextHat;
      _confettiKey++;
      late String hatMsg;
      switch (nextHat) {
        case RobotHat.cap:
          hatMsg = 'Maker Cap on! Let\'s build something cool out of Amazon boxes!';
          break;
        case RobotHat.crown:
          hatMsg = 'Royal Inventor Crown equipped! Bow to the cardboard kingdom!';
          break;
        case RobotHat.topHat:
          hatMsg = 'Ta-da! Magic Top Hat ready to turn scrap cardboard into physics!';
          break;
        case RobotHat.visor:
          hatMsg = 'Cool Cyber Shades activated! Future robotics engineer coming through!';
          break;
        case RobotHat.none:
          hatMsg = 'Back to my classic glowing telemetry antenna — beep-boop!';
          break;
      }
      _setBotSpeech(
        hatMsg,
        mood: _isDancing ? RobotMood.dancing : RobotMood.excited,
      );
    });
    _persistBoltsState();
  }

  void _onToggleBoosters() {
    HapticFeedback.lightImpact();
    SoundEffects.playBoing();
    setState(() {
      _hasBoosters = !_hasBoosters;
      _confettiKey++;
      _setBotSpeech(
        _hasBoosters
            ? 'TWIN BOOSTERS ENGAGED! Hovering 6 millimeters off the workbench floor!'
            : 'Boosters parked safely back in the toolbox!',
        mood: _isDancing ? RobotMood.dancing : RobotMood.excited,
      );
    });
    _persistBoltsState();
  }

  void _onToggleDance() {
    HapticFeedback.lightImpact();
    SoundEffects.playFanfare();
    setState(() {
      _isDancing = !_isDancing;
      _confettiKey++;
      _setBotSpeech(
        _isDancing
            ? 'DISCO BOLTS MODE! ♪ Boogie-woogie cardboard shuffle initiated! ♪'
            : 'Whew, great dance workout! What build should we test next?',
        mood: _isDancing ? RobotMood.dancing : RobotMood.greeting,
      );
    });
  }

  void _onToggleSound() {
    HapticFeedback.selectionClick();
    setState(() {
      _soundEnabled = !_soundEnabled;
      SoundEffects.enabled = _soundEnabled;
    });
    if (_soundEnabled) {
      SoundEffects.playRobotBeep();
    }
    _persistBoltsState();
  }

  void _onToggleVoice() {
    HapticFeedback.selectionClick();
    setState(() {
      _voiceEnabled = !_voiceEnabled;
      BoltsVoiceService.enabled = _voiceEnabled;
      if (_voiceEnabled) {
        SoundEffects.playChime();
        _setBotSpeech(
          'Voice module online! I will speak my tips out loud as you explore!',
          mood: RobotMood.excited,
        );
      } else {
        BoltsVoiceService.stop();
        _botMessage = 'Voice muted — quiet builder mode ready!';
      }
    });
    _persistBoltsState();
  }

  void _onFeedPowerCell() {
    HapticFeedback.mediumImpact();
    SoundEffects.playPowerUp();
    setState(() {
      _overchargeKey++;
      _confettiKey++;
      _setBotSpeech(
        'ZAP! ⚡ Power Cell absorbed — Overdrive Core spinning at 360% speed!',
        mood: RobotMood.excited,
      );
    });
    _awardDemoXp('power_cell', 10);
  }

  void _triggerBackflip() {
    HapticFeedback.mediumImpact();
    SoundEffects.playBackflip();
    setState(() {
      _backflipKey++;
      _confettiKey++;
      _setBotSpeech(
        'WHEEE! 🤸 Full 360° zero-gravity cardboard servo backflip nailed!',
        mood: RobotMood.excited,
      );
    });
    _awardDemoXp('easter_flip', 5);
  }

  void _toggleRainbowMode() {
    HapticFeedback.lightImpact();
    SoundEffects.playFanfare();
    setState(() {
      _isRainbowMode = !_isRainbowMode;
      _confettiKey++;
      _setBotSpeech(
        _isRainbowMode
            ? 'PRISM HYPER-GLOW ACTIVATED! 🌈 Full-spectrum maker aura engaged!'
            : 'Back to classic crisp workshop LEDs — ready to build!',
        mood: RobotMood.excited,
      );
    });
    _persistBoltsState();
  }

  void _enterFreeFlight() {
    HapticFeedback.mediumImpact();
    _captureFlightAnchors();
    SoundEffects.playBoostFlight();
    setState(() {
      _isFlightActive = false;
      _isFreeFlightActive = true;
      _setBotSpeech(
        'FREE-FLIGHT ARCADE! Drag, tap, or use arrow keys to scoop up all 5 spinning gears in 15s!',
        mood: RobotMood.excited,
      );
    });
  }

  void _handleFreeFlightExit(int collected, bool allCollected) {
    HapticFeedback.mediumImpact();
    setState(() {
      _isFreeFlightActive = false;
      _confettiKey++;
      if (collected > _skyGearsBest) {
        _skyGearsBest = collected;
      }
      if (allCollected) {
        SoundEffects.playFanfare();
        _setBotSpeech(
          'SKY ACE! ✈️ You caught all 5/5 spinning gears (+25 Starter XP unlocked)!',
          mood: RobotMood.excited,
        );
      } else {
        SoundEffects.playChime();
        _setBotSpeech(
          'Nice flight! Caught $collected/5 spinning gears (Best: $_skyGearsBest/5). Fly again anytime to grab all 5!',
          mood: RobotMood.greeting,
        );
      }
    });
    if (allCollected) {
      _awardDemoXp('sky_ace', 25);
    } else if (collected > 0) {
      _awardDemoXp('sky_rookie', 10);
    }
    _persistBoltsState();
  }

  void _tellJoke() {
    const jokes = [
      'Why did the cardboard robot cross the desk? To prove glue sticks together! 😄',
      'What is a rubber-band racer\'s favorite music? Anything with good TORQUE and roll! 🏎️',
      'Why do I love delivery boxes? Every fold is a free robotics skeleton waiting to wake up! 📦',
      'What did the scissor lift say to the bookshelf? "Need a 4× boost up there?" ✂️',
    ];
    HapticFeedback.selectionClick();
    SoundEffects.playRobotBeep();
    setState(() {
      final joke = jokes[_jokeIdx % jokes.length];
      _jokeIdx++;
      _confettiKey++;
      _setBotSpeech(joke, mood: RobotMood.excited);
    });
  }

  void _triggerSpin() {
    HapticFeedback.mediumImpact();
    SoundEffects.playSpinWhoosh();
    setState(() {
      _spinKey++;
      _confettiKey++;
      _setBotSpeech(
        'WHEEE-WHOOSH! 🌀 Full 360° levitation turntable spin locked! Check out my cardboard backplate!',
        mood: RobotMood.excited,
      );
    });
  }

  void _triggerWink() {
    HapticFeedback.lightImpact();
    SoundEffects.playRobotBeep();
    setState(() {
      _winkKey++;
      _setBotSpeech(
        'Heeeey Cadet! 😉 *Wink & wave!* Tap any mini-game in the Arcade below to stack bonus Starter XP!',
        mood: RobotMood.greeting,
      );
    });
  }

  void _triggerConfettiPop() {
    HapticFeedback.mediumImpact();
    SoundEffects.playFanfare();
    setState(() {
      _confettiKey++;
      _setBotSpeech(
        'CONFETTI BLAST! 🎉 Every cardboard scrap you fold today is a real engineering win!',
        mood: RobotMood.excited,
      );
    });
  }

  void _selectSceneTheme(String themeId) {
    late String themeMsg;
    switch (themeId) {
      case 'space':
        themeMsg =
            'Orbital Space Lab backdrop active! 🌌 Zero-gravity cardboard testing initialized!';
        break;
      case 'sunset':
        themeMsg =
            'Golden Workshop Sunset active! 🌅 Evening build session ready!';
        break;
      case 'cyber':
        themeMsg =
            'Mint Cyber Grid active! 🔋 Precision neon blueprint glow engaged!';
        break;
      default:
        themeMsg =
            'Frosted Cloud Workshop restored! ☁️ Fresh daylight maker bench!';
        break;
    }
    setState(() {
      _sceneTheme = themeId;
      _setBotSpeech(themeMsg, mood: RobotMood.excited);
    });
    _persistBoltsState();
  }

  void _openCircuitGame() {
    HapticFeedback.selectionClick();
    SoundEffects.playPop();
    showDialog(
      context: context,
      builder: (ctx) => CircuitSnapDialog(
        onSolved: () {
          _awardDemoXp('circuit_snap', 15);
          if (mounted) {
            setState(() {
              _confettiKey++;
              _setBotSpeech(
                'BRIGHT IDEA! 💡 Closed-loop copper-tape circuit lit cleanly (+15 Starter XP)!',
                mood: RobotMood.excited,
              );
            });
          }
        },
      ),
    );
  }

  void _openTriviaGame() {
    HapticFeedback.selectionClick();
    SoundEffects.playPop();
    showDialog(
      context: context,
      builder: (ctx) => BoltsTriviaDialog(
        onWon: () {
          _awardDemoXp('trivia_ace', 15);
          if (mounted) {
            setState(() {
              _confettiKey++;
              _setBotSpeech(
                'TRIVIA MASTER! 🧠 You beat Bolts in physics (+15 Starter XP unlocked)!',
                mood: RobotMood.excited,
              );
            });
          }
        },
      ),
    );
  }

  void _openBoomboxGame() {
    HapticFeedback.selectionClick();
    SoundEffects.playPop();
    showDialog(
      context: context,
      builder: (ctx) => BoomboxBeatDialog(
        paintStyle: _robotPaint,
        onBeatDropped: () {
          _awardDemoXp('boombox_dj', 10);
          if (mounted) {
            setState(() {
              _isDancing = true;
              _confettiKey++;
              _setBotSpeech(
                'DROP THE BEAT! 🎵 DJ Mode unlocked +10 Starter XP and got my servos grooving!',
                mood: RobotMood.dancing,
              );
            });
          }
        },
      ),
    );
  }

  void _handleBotCommand(String raw) {
    final q = raw.trim().toLowerCase();
    _commandController.clear();
    if (q.isEmpty) return;

    if (q.contains('flip')) {
      _triggerBackflip();
      return;
    }
    if (q.contains('spin') || q.contains('twirl')) {
      _triggerSpin();
      return;
    }
    if (q.contains('wink') || q.contains('wave')) {
      _triggerWink();
      return;
    }
    if (q.contains('confetti') || q.contains('celebrate')) {
      _triggerConfettiPop();
      return;
    }
    if (q.contains('sandbox') || q.contains('invent')) {
      _goToStage(4);
      return;
    }
    if (q.contains('circuit') || q.contains('led') || q.contains('copper')) {
      _openCircuitGame();
      return;
    }
    if (q.contains('trivia') || q.contains('quiz')) {
      _openTriviaGame();
      return;
    }
    if (q.contains('beat') || q.contains('music') || q.contains('boombox')) {
      _openBoomboxGame();
      return;
    }
    if (q.contains('orbit') || q.contains('space')) {
      _selectSceneTheme('space');
      return;
    }
    if (q.contains('sunset')) {
      _selectSceneTheme('sunset');
      return;
    }
    if (q.contains('cyber')) {
      _selectSceneTheme('cyber');
      return;
    }
    if (q.contains('cloud')) {
      _selectSceneTheme('cloud');
      return;
    }
    if (q.contains('rainbow') || q.contains('prism') || q.contains('party')) {
      _toggleRainbowMode();
      return;
    }
    if (q.contains('charge') || q.contains('battery') || q.contains('power')) {
      _onFeedPowerCell();
      return;
    }
    if (q.contains('joke') || q.contains('funny') || q.contains('laugh')) {
      _tellJoke();
      return;
    }
    if (q.contains('dance') || q.contains('disco')) {
      _onToggleDance();
      return;
    }
    if (q.contains('fly') || q.contains('flight') || q.contains('arcade')) {
      _enterFreeFlight();
      return;
    }
    if (q.contains('catapult')) {
      setState(() => _exampleIdx = 4);
      _goToStage(1, customMessage: _machineIntros[4]);
      return;
    }
    if (q.contains('coaster') || q.contains('marble')) {
      setState(() => _exampleIdx = 3);
      _goToStage(1, customMessage: _machineIntros[3]);
      return;
    }
    if (q.contains('claw') || q.contains('grip')) {
      setState(() => _exampleIdx = 2);
      _goToStage(1, customMessage: _machineIntros[2]);
      return;
    }
    if (q.contains('racer') || q.contains('car')) {
      setState(() => _exampleIdx = 1);
      _goToStage(1, customMessage: _machineIntros[1]);
      return;
    }
    if (q.contains('scissor') || q.contains('lift') || q.contains('example')) {
      setState(() => _exampleIdx = 0);
      _goToStage(1, customMessage: _machineIntros[0]);
      return;
    }
    if (q.contains('plan') || q.contains('draft')) {
      _goToStage(2);
      return;
    }
    if (q.contains('price') ||
        q.contains('cost') ||
        q.contains('199') ||
        q.contains('pass') ||
        q.contains('buy') ||
        q.contains('enroll')) {
      _goToStage(
        3,
        customMessage:
            'Just ₹199 once — never monthly! Unlocks all 17 cardboard machines, 3D stencils & 30-day guarantee.',
      );
      return;
    }
    if (q.contains('kit') ||
        q.contains('box') ||
        q.contains('scrap') ||
        q.contains('material')) {
      SoundEffects.playPop();
      setState(() {
        _setBotSpeech(
          'Zero expensive kits needed! Just clean Amazon boxes, straws, wooden skewers, rubber bands & glue.',
          mood: RobotMood.explaining,
        );
      });
      return;
    }
    if (q.contains('school') || q.contains('cbse') || q.contains('icse')) {
      SoundEffects.playPop();
      setState(() {
        _setBotSpeech(
          'Yes! Each machine teaches real CBSE/ICSE mechanics — levers, torque, elastic energy & linkages!',
          mood: RobotMood.explaining,
        );
      });
      return;
    }
    if (q.contains('whatsapp') || q.contains('help') || q.contains('mentor')) {
      SoundEffects.playPop();
      setState(() {
        _setBotSpeech(
          'Message our human maker mentors anytime on WhatsApp +918075971988 for instant photo alignment help!',
          mood: RobotMood.explaining,
        );
      });
      return;
    }

    SoundEffects.playRobotBeep();
    setState(() {
      _setBotSpeech(
        'Beep! Try typing "backflip", "spin", "wink", "sandbox", "circuit", "quiz", "music", or "price"!',
        mood: RobotMood.thinking,
      );
    });
  }

  void _onSelectMachineExample(int idx) {
    setState(() {
      _exampleIdx = idx;
      _setBotSpeech(
        _machineIntros[idx],
        mood: _isDancing ? RobotMood.dancing : RobotMood.explaining,
      );
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
      _setBotSpeech(
        'Scanning $_safeName\'s build picks now... sketching your blueprint trajectory!',
        mood: RobotMood.thinking,
      );
    });
  }

  void _onDraftingComplete() {
    if (!mounted) return;
    setState(() {
      _isDraftingPlan = false;
      _planReady = true;
      _setBotSpeech(
        'Boom, $_safeName! You are a $_archetype ($_aptitudeScore% match)! Start with these 3 builds:',
        mood: RobotMood.excited,
      );
    });
    _awardDemoXp('plan_draft', 10);
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
        bonusXp: _demoXp,
        onPaymentSuccess: (paidName, paidEmail) {
          widget.questState.registerNewCadet(
            name: paidName,
            email: paidEmail,
            avatar: _archetypeIcon,
            bonusXp: _demoXp,
          );
          Navigator.of(ctx).pop();
          _showCelebrationDialog(paidName);
        },
      ),
    );
  }

  void _showCelebrationDialog(String cadetName) {
    SoundEffects.playFanfare();
    final totalStartXp = 50 + _demoXp;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final sz = MediaQuery.sizeOf(ctx);
        final isCompact = sz.width < 480 || sz.height < 700;
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.symmetric(
            horizontal: isCompact ? 12 : 16,
            vertical: isCompact ? 12 : 24,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: GlassSurface(
              borderRadius: 24,
              blurSigma: 18,
              tintColor: AppColors.emerald,
              padding: EdgeInsets.all(isCompact ? 14 : 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: isCompact ? 54 : 72,
                      height: isCompact ? 54 : 72,
                      decoration: BoxDecoration(
                        color: AppColors.emeraldSoft.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.emerald, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          '🎉',
                          style: TextStyle(fontSize: isCompact ? 28 : 36),
                        ),
                      ),
                    ),
                    SizedBox(height: isCompact ? 10 : 16),
                    Text(
                      'Enrollment Successful! 🏆',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isCompact ? 18 : 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _demoXp > 0
                          ? 'Welcome aboard MakerQuest, Cadet $cadetName!\nYour All-Access Odyssey Pass is active with $totalStartXp XP (50 welcome + $_demoXp earned with Bolts!).'
                          : 'Welcome aboard MakerQuest, Cadet $cadetName!\nYour All-Access Odyssey Pass has been activated with 50 XP starter bonus.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted, height: 1.45),
                    ),
                    SizedBox(height: isCompact ? 12 : 20),
                    Container(
                      padding: EdgeInsets.all(isCompact ? 10 : 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
                      ),
                      child: Row(
                        children: [
                          Text(_archetypeIcon, style: const TextStyle(fontSize: 22)),
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
                    SizedBox(height: isCompact ? 14 : 24),
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
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: isCompact ? 11 : 14,
                          ),
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
                        OutlinedButton.icon(
                          icon: const Icon(Icons.download_rounded, size: 16),
                          label: const Text(
                            'Download Free A4 Stencil 📐',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary, width: 1.3),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            SoundEffects.playChime();
                            StencilExporter.downloadScissorStencil();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Downloaded makerquest-free-scissor-stencil.svg — print at 100% A4 scale!',
                                ),
                                backgroundColor: Color(0xFF15803D),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
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
      paused: _isFlightActive || _isFreeFlightActive,
      sceneTheme: _sceneTheme,
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
                child: Stack(
                  key: _viewportStackKey,
                  children: [
                    SingleChildScrollView(
                      controller: _scrollController,
                      padding: EdgeInsets.fromLTRB(
                        isTiny ? 12 : 24,
                        isTiny ? 12 : 22,
                        isTiny ? 12 : 24,
                        84, // clearance above WhatsApp FAB
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 980),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final stageW = constraints.maxWidth.isFinite
                                  ? constraints.maxWidth
                                  : 600.0;
                              final fallbackStart = isWideStage
                                  ? Offset(stageW * 0.21, 224.0)
                                  : Offset(isTiny ? 56.0 : 66.0, 166.0);
                              final fallbackTarget = isWideStage
                                  ? Offset(stageW * 0.68, 265.0)
                                  : Offset(stageW * 0.54, 390.0);

                              return Stack(
                                key: _stageStackKey,
                                clipBehavior: Clip.none,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      _buildMinimalHeaderStrip(isTiny),
                                      SizedBox(height: isTiny ? 10 : 16),
                                      _buildGuidedRobotStage(
                                        isWideStage: isWideStage,
                                        isTiny: isTiny,
                                      ),
                                      const SizedBox(height: 12),
                                      BoltsArcadeShelf(
                                        accentColor: _robotPaint.swatch,
                                        sceneTheme: _sceneTheme,
                                        onSelectTheme: _selectSceneTheme,
                                        onTriggerSpin: _triggerSpin,
                                        onTriggerWink: _triggerWink,
                                        onTriggerConfetti: _triggerConfettiPop,
                                        onOpenSandbox: () => _goToStage(4),
                                        onOpenCircuitGame: _openCircuitGame,
                                        onOpenTriviaGame: _openTriviaGame,
                                        onOpenBoomboxGame: _openBoomboxGame,
                                        clearedMilestones: _clearedChallenges,
                                      ),
                                      const SizedBox(height: 14),
                                      _buildMinimalFooter(isTiny),
                                    ],
                                  ),
                                  if (_isFlightActive)
                                    Positioned.fill(
                                      child: AnimatedBuilder(
                                        animation: _flightController,
                                        builder: (context, _) {
                                          return BoostFlightStageOverlay(
                                            progress: _flightController.value,
                                            startCenter:
                                                _takeoffCenter ?? fallbackStart,
                                            portalTargetCenter:
                                                _portalTargetCenter ??
                                                    fallbackTarget,
                                            robotHeight: _takeoffRobotHeight,
                                            isWideStage: isWideStage,
                                            targetStage: _pendingStage,
                                            paintStyle: _robotPaint,
                                            hat: _robotHat,
                                            isDancing: _isDancing,
                                            isRainbowMode: _isRainbowMode,
                                          );
                                        },
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    if (_isFreeFlightActive)
                      Positioned.fill(
                        child: BoltsFreeFlightOverlay(
                          initialCenter: _freeFlightStartCenter ??
                              Offset(screenW * 0.35, 240.0),
                          paintStyle: _robotPaint,
                          hat: _robotHat,
                          isRainbowMode: _isRainbowMode,
                          onExit: _handleFreeFlightExit,
                        ),
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
        if (_demoXp > 0 || _skyGearsBest > 0) ...[
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7).withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF59E0B)),
                ),
                child: Text(
                  '⭐ +$_demoXp Starter XP${_skyGearsBest > 0 ? ' • ✈️ $_skyGearsBest/5 Gears' : ''} (Carries into Workshop)',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF92400E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        // Minimal Step Selector Tabs
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: List.generate(_stageTabs.length, (i) {
            final tab = _stageTabs[i];
            final active = i == (_isFlightActive ? _pendingStage : _activeStage);
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
    return RepaintBoundary(
      child: GlassSurface(
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
                    child: _buildRobotHostPane(
                      isWideStage: true,
                      isTiny: false,
                    ),
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
      voiceEnabled: _voiceEnabled,
      onToggleVoice: _onToggleVoice,
      onFeedPowerCell: _onFeedPowerCell,
      onEnterFreeFlight: _enterFreeFlight,
    );

    final hideDockBot = _isFlightActive || _isFreeFlightActive;

    if (isWideStage) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
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
                Opacity(
                  opacity: hideDockBot ? 0.0 : 1.0,
                  child: KeyedSubtree(
                    key: _dockRobotKey,
                    child: TalkingRobotCharacter(
                      mood: _robotMood,
                      isTalking: _isRobotTalking,
                      entranceKey: _robotEntranceKey,
                      confettiBurstKey: _confettiKey,
                      overchargeKey: _overchargeKey,
                      backflipKey: _backflipKey,
                      spinKey: _spinKey,
                      winkKey: _winkKey,
                      paintStyle: _robotPaint,
                      hat: _robotHat,
                      hasBoosters: _hasBoosters,
                      isDancing: _isDancing,
                      isRainbowMode: _isRainbowMode,
                      height: 158,
                      onTap: _onTapRobot,
                      onFeedPowerCell: _onFeedPowerCell,
                    ),
                  ),
                ),
                const Text(
                  'Tap Bolts, drag 🔋 onto him, or spin in 3D!',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDim,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          toyBar,
          const SizedBox(height: 10),
          bubble,
          const SizedBox(height: 10),
          _buildQuickReplyChips(),
          const SizedBox(height: 10),
          _buildCommandPromptBar(),
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
              child: Opacity(
                opacity: hideDockBot ? 0.0 : 1.0,
                child: KeyedSubtree(
                  key: _dockRobotKey,
                  child: TalkingRobotCharacter(
                    mood: _robotMood,
                    isTalking: _isRobotTalking,
                    entranceKey: _robotEntranceKey,
                    confettiBurstKey: _confettiKey,
                    overchargeKey: _overchargeKey,
                    backflipKey: _backflipKey,
                    spinKey: _spinKey,
                    winkKey: _winkKey,
                    paintStyle: _robotPaint,
                    hat: _robotHat,
                    hasBoosters: _hasBoosters,
                    isDancing: _isDancing,
                    isRainbowMode: _isRainbowMode,
                    height: isTiny ? 84 : 102,
                    onTap: _onTapRobot,
                    onFeedPowerCell: _onFeedPowerCell,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: bubble),
          ],
        ),
        const SizedBox(height: 10),
        toyBar,
        const SizedBox(height: 8),
        _buildCommandPromptBar(),
      ],
    );
  }

  Widget _buildCommandPromptBar() {
    return GlassSurface(
      borderRadius: 14,
      blurSigma: 8,
      tintColor: _isRainbowMode ? const Color(0xFFEC4899) : _robotPaint.swatch,
      topOpacity: 0.72,
      bottomOpacity: 0.52,
      borderColor: Colors.white.withValues(alpha: 0.88),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commandController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: _handleBotCommand,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMain,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Command Bolts (backflip, spin, sandbox, quiz)...',
                    hintStyle: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textDim,
                    ),
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.92),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              ElevatedButton(
                onPressed: () => _handleBotCommand(_commandController.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Icon(Icons.send_rounded, size: 15),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _cmdQuickChip('🤸 Flip', _triggerBackflip, active: false),
              _cmdQuickChip('🌈 Prism', _toggleRainbowMode, active: _isRainbowMode),
              _cmdQuickChip('😄 Joke', _tellJoke, active: false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cmdQuickChip(
    String label,
    VoidCallback onTap, {
    required bool active,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFFDF2F8) : Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? const Color(0xFFEC4899) : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color: active ? const Color(0xFFDB2777) : AppColors.textMain,
          ),
        ),
      ),
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

      case 3:
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

      default:
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.bolt_rounded, size: 16),
              label: const Text(
                'Circuit Snapper 💡',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _openCircuitGame,
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.auto_awesome_rounded, size: 15),
              label: const Text(
                'My Starter Plan 🎯',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textMain,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _goToStage(2),
            ),
            TextButton(
              onPressed: () => _goToStage(3),
              child: const Text(
                'Get Pass ₹199 🚀',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
              ),
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
        HapticFeedback.selectionClick();
        SoundEffects.playPop();
        setState(() {
          _setBotSpeech(answer, mood: RobotMood.explaining);
        });
      },
    );
  }

  Widget _buildStageRightPane({required bool isTiny}) {
    return KeyedSubtree(
      key: _rightPaneKey,
      child: GlassMotionScope(
        suppressBlur: _isFlightActive,
        child: AnimatedBuilder(
          animation: _flightController,
          builder: (context, child) {
            if (!_isFlightActive) return child!;
            final xf = BoostFlightKinematics.evaluatePaneTransition(
              _flightController.value,
            );
            return Opacity(
              opacity: xf.opacity,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0012)
                  ..rotateY(xf.rotateY),
                child: Transform.scale(
                  scale: xf.scale,
                  alignment: Alignment.center,
                  child: child,
                ),
              ),
            );
          },
          child: RepaintBoundary(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: _isFlightActive ? 0 : 220),
              child: KeyedSubtree(
                key: ValueKey('stage_$_activeStage'),
                child: _activeStage == 0
                    ? ScrapToRobotWorkbench(
                        onReaction: (msg, {bool complete = false}) {
                          setState(() {
                            _setBotSpeech(
                              msg,
                              mood: complete
                                  ? RobotMood.excited
                                  : RobotMood.explaining,
                            );
                          });
                          if (complete) {
                            _awardDemoXp('scrap_bench', 15);
                          }
                        },
                      )
                    : _activeStage == 1
                        ? InteractiveMachinePlayground(
                            activeIndex: _exampleIdx,
                            onSelectMachine: _onSelectMachineExample,
                            clearedChallenges: _clearedChallenges,
                            onChallengeCleared: (id) {
                              _awardDemoXp(id, 15);
                            },
                            initialRacerBest: _racerBestMeters,
                            onRacerBestChanged: (m) {
                              _racerBestMeters = m;
                              _persistBoltsState();
                            },
                            onCatapultStreakChanged: (s) {
                              if (s > _catapultBestStreak) {
                                _catapultBestStreak = s;
                                _persistBoltsState();
                              }
                            },
                            onBoltsComment: (msg) {
                              setState(() {
                                _setBotSpeech(msg, mood: RobotMood.excited);
                              });
                            },
                          )
                        : _activeStage == 2
                            ? _buildInteractivePlanCard(isTiny)
                            : _activeStage == 3
                                ? _buildMinimalPassCard(isTiny)
                                : InventorSandboxWidget(
                                    bestStars: _sandboxStars,
                                    onTestResult: (comment, stars, earnedXp) {
                                      setState(() {
                                        if (stars > _sandboxStars) {
                                          _sandboxStars = stars;
                                        }
                                        if (stars >= 2) _confettiKey++;
                                        _setBotSpeech(
                                          comment,
                                          mood: stars >= 2
                                              ? RobotMood.excited
                                              : RobotMood.explaining,
                                        );
                                      });
                                      if (earnedXp) {
                                        _awardDemoXp('sandbox_win', 20);
                                      } else if (stars > 0) {
                                        _persistBoltsState();
                                      }
                                    },
                                  ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  int _countHomeScrapBuildsReady() {
    final hasBox = _homeScraps.contains('box');
    final hasStraws = _homeScraps.contains('straws');
    final hasSkewers = _homeScraps.contains('skewers');
    final hasBand = _homeScraps.contains('band');
    final hasCaps = _homeScraps.contains('caps');
    if (!hasBox) return 0;
    int ready = 0;
    if (hasStraws || hasSkewers) ready++; // Scissor Lift
    if (hasStraws && hasBand) ready++; // Wind-Up Racer / Claw
    if (hasStraws || hasCaps) ready++; // Coaster / Wheel Cart
    if (hasSkewers && hasBand) ready++; // Catapult / Hoist
    return ready;
  }

  Widget _buildInteractivePlanCard(bool isTiny) {
    final readyCount = _countHomeScrapBuildsReady();
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
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.emerald.withValues(alpha: 0.45)),
              ),
              child: Text(
                '📦 $readyCount/4 starter builds ready TONIGHT from your home scraps!',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF065F46),
                ),
              ),
            ),
            const SizedBox(height: 10),
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
                              if (readyCount > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    '✓ Ready tonight',
                                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF15803D)),
                                  ),
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

    // Minimal 3-input interactive picker form + Household Scrap Matcher
    final vibeOptions = [
      (icon: '🏎️', short: 'Racers', value: 'Speed Racers & Drive Systems'),
      (icon: '✂️', short: 'Lifts', value: 'Scissor Lifts & Lifting Linkages'),
      (icon: '🦾', short: 'Claws', value: 'Articulated Robot Grippers'),
      (icon: '🎢', short: 'Coasters', value: 'Roller Coasters & Gravity'),
    ];
    const scrapOptions = [
      (id: 'box', label: '📦 Box'),
      (id: 'straws', label: '🥤 Straws'),
      (id: 'skewers', label: '🪵 Skewers'),
      (id: 'band', label: '🟡 Bands'),
      (id: 'caps', label: '🍶 Caps'),
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
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.92)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Household Scrap Matcher • $readyCount/4 builds ready tonight',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.emerald,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: scrapOptions.map((s) {
                      final hasIt = _homeScraps.contains(s.id);
                      return FilterChip(
                        label: Text(
                          s.label,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: hasIt ? const Color(0xFF065F46) : AppColors.textMain,
                          ),
                        ),
                        selected: hasIt,
                        selectedColor: const Color(0xFFDCFCE7),
                        backgroundColor: Colors.white,
                        checkmarkColor: AppColors.emerald,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        onSelected: (checked) {
                          HapticFeedback.selectionClick();
                          SoundEffects.playPop();
                          setState(() {
                            if (checked) {
                              _homeScraps.add(s.id);
                            } else {
                              _homeScraps.remove(s.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
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
  final int bonusXp;
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
    this.bonusXp = 0,
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
                      if (widget.bonusXp > 0) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFF59E0B)),
                          ),
                          child: Text(
                            '⭐ Includes +${widget.bonusXp} Starter XP earned with Bolts!',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF92400E),
                            ),
                          ),
                        ),
                      ],
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
