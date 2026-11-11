// MakerQuest Flutter Web Application Entrypoint
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'services/quest_state.dart';
import 'theme/app_theme.dart';
import 'models/project.dart';
import 'models/challenge.dart';
import 'widgets/hero_dashboard_card.dart';
import 'widgets/level_map_view.dart';
import 'widgets/project_card.dart';
import 'widgets/project_detail_view.dart';
import 'widgets/challenge_quiz_dialog.dart';
import 'widgets/badges_grid_view.dart';
import 'widgets/frosted_glass_background.dart';
import 'widgets/maker_notebook_view.dart';
import 'widgets/marketing_page_view.dart';
import 'widgets/whatsapp_brand_logo.dart';
import 'services/external_launcher.dart';
import 'services/sound_effects.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MakerQuestApp());
}

class MakerQuestApp extends StatelessWidget {
  const MakerQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MakerQuest - Gamified DIY Project Learning',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MakerQuestHomePage(),
    );
  }
}

class MakerQuestHomePage extends StatefulWidget {
  const MakerQuestHomePage({super.key});

  @override
  State<MakerQuestHomePage> createState() => _MakerQuestHomePageState();
}

class _MakerQuestHomePageState extends State<MakerQuestHomePage> {
  final QuestState _questState = QuestState();
  int _currentNavIndex = 5; // Default to Marketing & Enrollment page
  String _projectFilter = 'all'; // 'all', '1', '2', '3', '4', 'completed'
  String _projectSearch = '';
  final Set<String> _pantryFilters = {};

  void _onSelectNav(int idx) {
    if (!_questState.isEnrolled && idx != 5) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.rose,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          content: const Row(
            children: [
              Icon(Icons.lock_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Cadet Pass Required: Please complete enrollment (₹199 or promo MAKER100) below to view DIY projects and workshops!',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ],
          ),
          action: SnackBarAction(
            label: 'Enroll Now',
            textColor: Colors.white,
            onPressed: () {
              setState(() => _currentNavIndex = 5);
            },
          ),
        ),
      );
      setState(() => _currentNavIndex = 5);
      return;
    }

    setState(() => _currentNavIndex = idx);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _questState,
      builder: (context, _) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isDesktop = screenWidth >= 800;
        final isEnrolled = _questState.isEnrolled;

        // When NOT enrolled: completely omit app bar, side bar and bottom bar.
        // Provides a clean, distraction-free marketing & diagnostic experience!
        if (!isEnrolled) {
          return Scaffold(
            body: _buildCurrentView(context),
          );
        }

        // When enrolled: Frosted Cloud Backdrop + glassmorphic AppBar & navigation chrome
        return FrostedCloudBackdrop(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: _buildAppBar(context),
            body: isDesktop
                ? Row(
                    children: [
                      _buildNavigationRail(),
                      Expanded(child: _buildCurrentView(context)),
                    ],
                  )
                : _buildCurrentView(context),
            bottomNavigationBar: isDesktop ? null : _buildBottomNavigationBar(),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final user = _questState.currentUser;
    final isEnrolled = _questState.isEnrolled;
    final screenW = MediaQuery.sizeOf(context).width;
    final isTiny = screenW < 380;
    final isCompact = screenW < 480;

    return AppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: const GlassChromeBar(child: SizedBox.expand()),
      titleSpacing: isCompact ? 10 : null,
      title: InkWell(
        onTap: () {
          setState(() {
            _currentNavIndex = isEnrolled ? 0 : 5;
          });
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isTiny ? 32 : 36,
              height: isTiny ? 32 : 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFFEC4899)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text('⚡', style: TextStyle(fontSize: isTiny ? 17 : 20)),
              ),
            ),
            SizedBox(width: isTiny ? 8 : 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'MakerQuest',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isTiny ? 15 : 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMain,
                    ),
                  ),
                  if (!isTiny)
                    const Text(
                      'DIY STEM ODYSSEY',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppColors.amber,
                        letterSpacing: 0.8,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (screenW >= 750)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              icon: Text(isEnrolled ? '🏆' : '🇮🇳', style: const TextStyle(fontSize: 14)),
              label: Text(
                isEnrolled ? 'Cadet Pass: Active ✨' : 'Enroll Cadet ₹199 🚀',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isEnrolled ? AppColors.emeraldSoft : AppColors.primarySoft,
                foregroundColor: isEnrolled ? AppColors.emerald : AppColors.primary,
                elevation: 0,
                side: BorderSide(color: (isEnrolled ? AppColors.emerald : AppColors.primary).withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () {
                setState(() {
                  _currentNavIndex = 5;
                });
              },
            ),
          ),
        // Quick Student Profile & Switcher
        PopupMenuButton<String>(
          offset: const Offset(0, 48),
          color: AppColors.bgSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.borderLight),
          ),
          onSelected: (val) {
            if (val == 'whatsapp') {
              SoundEffects.playPop();
              ExternalLauncher.openWhatsApp(
                message:
                    'Hi MakerQuest Mentor! I am ${user.name} and need quick build help.',
              );
            } else if (val == 'marketing') {
              setState(() {
                _currentNavIndex = 5;
              });
            } else if (val == 'register') {
              _showRegisterDialog(context);
            } else if (val == 'avatar') {
              _showAvatarStudioDialog(context);
            } else if (val.startsWith('demo:')) {
              final email = val.replaceFirst('demo:', '');
              _questState.bypassEnrollmentForDemo(email);
              setState(() => _currentNavIndex = 0);
            } else {
              _questState.switchDemoUser(val);
            }
          },
          itemBuilder: (ctx) => [
            const PopupMenuItem(
              value: 'marketing',
              child: Row(
                children: [
                  Icon(Icons.rocket_launch_rounded, size: 18, color: AppColors.primary),
                  SizedBox(width: 10),
                  Flexible(
                    child: Text('STEM Diagnostic & Plans', style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'whatsapp',
              child: Row(
                children: [
                  WhatsAppBrandLogo(size: 19),
                  SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      'WhatsApp Mentor (${ExternalLauncher.whatsAppPhoneDisplay})',
                      style: TextStyle(fontSize: 13, color: Color(0xFF15803D), fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              enabled: false,
              child: Text(
                isEnrolled ? 'ENROLLED CADET PROFILE' : 'ALREADY ENROLLED? (DEMO ACCESS)',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textDim),
              ),
            ),
            PopupMenuItem(
              value: 'demo:alex@makerquest.edu',
              child: Row(
                children: [
                  const Text('🦊', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isEnrolled ? 'Alex Rivera (Level 2)' : 'Alex Rivera (Demo Pass)', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textMain)),
                        const Text('Kinetic Tinkerer • 320 XP', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'demo:sam@makerquest.edu',
              child: Row(
                children: [
                  const Text('🚀', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isEnrolled ? 'Sam Chen (Level 1)' : 'Sam Chen (Demo Pass)', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textMain)),
                        const Text('Cardboard Starter • 50 XP', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isEnrolled) ...[
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'avatar',
                child: Row(
                  children: [
                    Icon(Icons.palette_rounded, size: 18, color: AppColors.primary),
                    SizedBox(width: 10),
                    Flexible(
                      child: Text('Customize Avatar & Style', style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'register',
                child: Row(
                  children: [
                    Icon(Icons.person_add_rounded, size: 18, color: AppColors.cyan),
                    SizedBox(width: 10),
                    Flexible(
                      child: Text('Create New Cadet Profile', style: TextStyle(fontSize: 13, color: AppColors.cyan, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ],
          ],
          child: Container(
            margin: EdgeInsets.only(right: isCompact ? 8 : 16),
            padding: EdgeInsets.symmetric(horizontal: isCompact ? 7 : 10, vertical: 4),
            decoration: BoxDecoration(
              color: isEnrolled ? AppColors.bgSecondary : AppColors.amberSoft,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isEnrolled ? AppColors.borderLight : AppColors.amber),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: isTiny ? 11 : 12,
                  backgroundColor: isEnrolled ? AppColors.primary : AppColors.amber,
                  child: Text(isEnrolled ? user.avatar : '🔒', style: TextStyle(fontSize: isTiny ? 11 : 12)),
                ),
                SizedBox(width: isTiny ? 5 : 8),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isTiny ? 72 : 140),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isEnrolled ? user.name : 'Prospect Cadet',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: isTiny ? 11 : 12, fontWeight: FontWeight.w700, color: AppColors.textMain),
                      ),
                      Text(
                        isTiny
                            ? (isEnrolled ? 'L${user.currentLevel} • ${user.currentXp}XP' : 'Enroll ₹199')
                            : (isEnrolled ? 'Lvl ${user.currentLevel} • ${user.currentXp} XP' : 'Not Enrolled • ₹199'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 10, color: isEnrolled ? AppColors.amber : AppColors.rose, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.arrow_drop_down, color: AppColors.textMuted, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationRail() {
    final locked = !_questState.isEnrolled;
    return GlassChromeBar(
      border: Border(
        right: BorderSide(
          color: Colors.white.withValues(alpha: 0.85),
          width: 1.2,
        ),
      ),
      child: NavigationRail(
        selectedIndex: locked ? 5 : _currentNavIndex,
        backgroundColor: Colors.transparent,
        indicatorColor: AppColors.primary.withValues(alpha: 0.14),
        selectedIconTheme: const IconThemeData(color: AppColors.primary),
      unselectedIconTheme: const IconThemeData(color: AppColors.textMuted),
      selectedLabelTextStyle: const TextStyle(
        color: AppColors.primary,
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
      unselectedLabelTextStyle: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 12,
      ),
      onDestinationSelected: _onSelectNav,
      destinations: [
        NavigationRailDestination(
          icon: Icon(locked ? Icons.lock_outline_rounded : Icons.alt_route_rounded),
          selectedIcon: Icon(locked ? Icons.lock_rounded : Icons.alt_route_rounded, color: AppColors.primary),
          label: Text(locked ? 'Roadmap 🔒' : 'Roadmap'),
        ),
        NavigationRailDestination(
          icon: Icon(locked ? Icons.lock_outline_rounded : Icons.handyman_rounded),
          selectedIcon: Icon(locked ? Icons.lock_rounded : Icons.handyman_rounded, color: AppColors.primary),
          label: Text(locked ? 'Projects 🔒' : 'DIY Projects'),
        ),
        NavigationRailDestination(
          icon: Icon(locked ? Icons.lock_outline_rounded : Icons.quiz_rounded),
          selectedIcon: Icon(locked ? Icons.lock_rounded : Icons.quiz_rounded, color: AppColors.primary),
          label: Text(locked ? 'Quizzes 🔒' : 'Checkpoints'),
        ),
        NavigationRailDestination(
          icon: Icon(locked ? Icons.lock_outline_rounded : Icons.military_tech_rounded),
          selectedIcon: Icon(locked ? Icons.lock_rounded : Icons.military_tech_rounded, color: AppColors.primary),
          label: Text(locked ? 'Badges 🔒' : 'Badges'),
        ),
        NavigationRailDestination(
          icon: Icon(locked ? Icons.lock_outline_rounded : Icons.auto_stories_rounded),
          selectedIcon: Icon(locked ? Icons.lock_rounded : Icons.auto_stories_rounded, color: AppColors.primary),
          label: Text(locked ? 'Logbook 🔒' : 'Notebook'),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.rocket_launch_rounded),
          selectedIcon: const Icon(Icons.rocket_launch_rounded, color: AppColors.primary),
          label: Text(locked ? 'Enroll ₹199 🚀' : 'Curriculum'),
        ),
      ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    final locked = !_questState.isEnrolled;
    final isTiny = MediaQuery.sizeOf(context).width < 380;
    return GlassChromeBar(
      border: Border(
        top: BorderSide(
          color: Colors.white.withValues(alpha: 0.85),
          width: 1.2,
        ),
      ),
      child: NavigationBar(
        selectedIndex: locked ? 5 : _currentNavIndex,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primary.withValues(alpha: 0.18),
      labelBehavior: isTiny ? NavigationDestinationLabelBehavior.onlyShowSelected : NavigationDestinationLabelBehavior.alwaysShow,
      onDestinationSelected: _onSelectNav,
      destinations: [
        NavigationDestination(
          icon: Icon(locked ? Icons.lock_outline_rounded : Icons.alt_route_rounded),
          label: locked ? 'Map 🔒' : 'Roadmap',
        ),
        NavigationDestination(
          icon: Icon(locked ? Icons.lock_outline_rounded : Icons.handyman_rounded),
          label: locked ? 'Projects 🔒' : 'Projects',
        ),
        NavigationDestination(
          icon: Icon(locked ? Icons.lock_outline_rounded : Icons.quiz_rounded),
          label: locked ? 'Quizzes 🔒' : (isTiny ? 'Quizzes' : 'Checkpoints'),
        ),
        NavigationDestination(
          icon: Icon(locked ? Icons.lock_outline_rounded : Icons.military_tech_rounded),
          label: locked ? 'Badges 🔒' : 'Badges',
        ),
        NavigationDestination(
          icon: Icon(locked ? Icons.lock_outline_rounded : Icons.auto_stories_rounded),
          label: locked ? 'Logbook 🔒' : 'Notebook',
        ),
        NavigationDestination(
          icon: const Icon(Icons.rocket_launch_rounded),
          label: locked ? 'Enroll 🚀' : 'Academy',
        ),
      ],
      ),
    );
  }

  Widget _buildCurrentView(BuildContext context) {
    if (!_questState.isEnrolled) {
      return MarketingPageView(
        questState: _questState,
        onLaunchWorkshop: () {
          setState(() {
            _questState.completeEnrollment();
            _currentNavIndex = 0;
          });
        },
      );
    }
    switch (_currentNavIndex) {
      case 0:
        return _buildQuestMapView(context);
      case 1:
        return _buildProjectsView(context);
      case 2:
        return _buildChallengesView(context);
      case 3:
        return _buildBadgesView(context);
      case 4:
        return MakerNotebookView(state: _questState);
      case 5:
        return MarketingPageView(
          questState: _questState,
          onLaunchWorkshop: () => setState(() => _currentNavIndex = 0),
        );
      default:
        return _buildQuestMapView(context);
    }
  }

  // VIEW 1: Quest Map & Dashboard
  Widget _buildQuestMapView(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        HeroDashboardCard(
          state: _questState,
          onLaunchProject: (proj) => _openProject(context, proj),
        ),
        LevelMapView(
          state: _questState,
          onFilterLevelProjects: (lvl) {
            setState(() {
              _projectFilter = '$lvl';
              _currentNavIndex = 1;
            });
          },
          onLaunchChallenge: (chk) => _openChallenge(context, chk),
          onOpenProject: (proj) => _openProject(context, proj),
        ),
      ],
    );
  }

  // VIEW 2: DIY Projects Catalog
  Widget _buildProjectsView(BuildContext context) {
    final projects = _questState.projects.where((p) {
      final matchesLevel = _projectFilter == 'all'
          ? true
          : _projectFilter == 'completed'
              ? _questState.userProgress.isProjectCompleted(p.id)
              : '${p.levelRequired}' == _projectFilter;

      final query = _projectSearch.toLowerCase().trim();
      final matchesSearch = query.isEmpty ||
          p.title.toLowerCase().contains(query) ||
          p.description.toLowerCase().contains(query) ||
          p.category.toLowerCase().contains(query);

      final matchesPantry = _pantryFilters.isEmpty ||
          _pantryFilters.every((tag) => p.materialsList.any((m) => m.name.toLowerCase().contains(tag)));

      return matchesLevel && matchesSearch && matchesPantry;
    }).toList();

    return Column(
      children: [
        // Filter bar & search
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                onChanged: (val) {
                  setState(() {
                    _projectSearch = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search DIY projects by name or materials...',
                  hintStyle: const TextStyle(fontSize: 13, color: AppColors.textDim),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textDim),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.72),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.90)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.90)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All Realms', 'all'),
                    _buildFilterChip('Lvl 1: Cardboard', '1'),
                    _buildFilterChip('Lvl 2: Simple Machines', '2'),
                    _buildFilterChip('Lvl 3: Circuits & Bots', '3'),
                    _buildFilterChip('Lvl 4: Smart Sensors', '4'),
                    _buildFilterChip('🏆 Completed', 'completed'),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Interactive Upcycle Household Finder
              GlassSurface(
                borderRadius: 16,
                blurSigma: 10,
                tintColor: AppColors.cyan,
                topOpacity: 0.74,
                bottomOpacity: 0.54,
                borderColor: AppColors.cyan.withValues(alpha: 0.35),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Row(
                            children: [
                              Text('♻️', style: TextStyle(fontSize: 13)),
                              SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'WHAT MATERIALS DO YOU HAVE AT HOME?',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.cyan,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_pantryFilters.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              SoundEffects.playPop();
                              setState(() => _pantryFilters.clear());
                            },
                            child: const Text('Clear', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.cyan)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildPantryChip('📦 Cardboard Box', 'cardboard'),
                          _buildPantryChip('🧃 Tubes / Rolls', 'tube'),
                          _buildPantryChip('🔘 Bottle Caps', 'cap'),
                          _buildPantryChip('🥢 Skewers', 'skewer'),
                          _buildPantryChip('📎 Paperclips', 'pin'),
                          _buildPantryChip('🔋 3V Battery', 'battery'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Grid
        Expanded(
          child: projects.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded, size: 48, color: AppColors.textDim),
                      SizedBox(height: 8),
                      Text(
                        'No DIY projects match your filter.',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 560) {
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: projects.length,
                        itemBuilder: (context, idx) {
                          final p = projects[idx];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: ProjectCard(
                              project: p,
                              state: _questState,
                              onOpen: () => _openProject(context, p),
                            ),
                          );
                        },
                      );
                    }

                    final SliverGridDelegate delegate = constraints.maxWidth < 840
                        ? const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            mainAxisExtent: 385,
                          )
                        : const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 420,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.88,
                          );
                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      gridDelegate: delegate,
                      itemCount: projects.length,
                      itemBuilder: (context, idx) {
                        final p = projects[idx];
                        return ProjectCard(
                          project: p,
                          state: _questState,
                          onOpen: () => _openProject(context, p),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _projectFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.bgSecondary,
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: 1,
        ),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textMuted,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
        onSelected: (val) {
          SoundEffects.playPop();
          setState(() {
            _projectFilter = value;
          });
        },
      ),
    );
  }

  Widget _buildPantryChip(String label, String keyword) {
    final isSelected = _pantryFilters.contains(keyword);
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        selectedColor: AppColors.cyan,
        backgroundColor: Colors.white,
        showCheckmark: false,
        side: BorderSide(
          color: isSelected ? AppColors.cyan : AppColors.border,
          width: 1,
        ),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textMain,
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
        onSelected: (val) {
          SoundEffects.playPop();
          setState(() {
            if (val) {
              _pantryFilters.add(keyword);
            } else {
              _pantryFilters.remove(keyword);
            }
          });
        },
      ),
    );
  }

  // VIEW 3: Checkpoints & Quizzes
  Widget _buildChallengesView(BuildContext context) {
    final challenges = _questState.challenges;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Checkpoint Troubleshooting Simulations',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textMain),
        ),
        const SizedBox(height: 4),
        const Text(
          'Diagnose engineering problems to earn Level licenses and massive XP rewards!',
          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
        const SizedBox(height: 16),
        ...challenges.map((c) {
          final isUnlocked = _questState.isLevelUnlocked(c.levelRequired);
          final isCompleted = _questState.userProgress.isChallengeCompleted(c.id);
          final score = _questState.userProgress.challengeScores[c.id];

          return GlassSurface(
            margin: const EdgeInsets.only(bottom: 16),
            borderRadius: 18,
            blurSigma: 12,
            tintColor: isCompleted ? AppColors.emerald : AppColors.primary,
            borderColor: isCompleted
                ? AppColors.emerald.withValues(alpha: 0.55)
                : Colors.white.withValues(alpha: 0.90),
            borderWidth: isCompleted ? 1.5 : 1.3,
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.rose.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'CHECKPOINT ${c.levelRequired}',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.rose),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.emerald.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'UNLOCKS LEVEL ${c.levelTarget}',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.emerald),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '+${c.xpReward} XP',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.amber),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    c.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textMain),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    c.description,
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.bgSurface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          '🧩 ${c.questions.length} Diagnostic Scenarios',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ),
                      if (isCompleted && score != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.emerald.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '✅ Score: $score%',
                            style: const TextStyle(fontSize: 11, color: AppColors.emerald, fontWeight: FontWeight.w700),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: isUnlocked
                        ? ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isCompleted ? AppColors.bgSurface : AppColors.primary,
                              foregroundColor: isCompleted ? AppColors.primary : Colors.white,
                              side: isCompleted ? const BorderSide(color: AppColors.primary) : null,
                            ),
                            onPressed: () => _openChallenge(context, c),
                            icon: Icon(isCompleted ? Icons.refresh_rounded : Icons.quiz_rounded, size: 16),
                            label: Text(isCompleted ? 'Retake Checkpoint Quiz' : 'Start Checkpoint Simulation'),
                          )
                        : Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.rose.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '🔒 Locked: Complete Level ${c.levelRequired} DIY projects first',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 11, color: AppColors.rose),
                            ),
                          ),
                  ),
                ],
              ),
            );
        }),
      ],
    );
  }

  // VIEW 4: Badges Showcase
  Widget _buildBadgesView(BuildContext context) {
    return BadgesGridView(state: _questState);
  }

  void _openProject(BuildContext context, Project project) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => ProjectDetailView(
          project: project,
          state: _questState,
        ),
      ),
    );
  }

  void _openChallenge(BuildContext context, Challenge challenge) {
    showDialog(
      context: context,
      builder: (ctx) => ChallengeQuizDialog(
        challenge: challenge,
        state: _questState,
      ),
    );
  }

  void _showAvatarStudioDialog(BuildContext context) {
    final avatars = [
      {'emoji': '🚀', 'title': 'Cosmic Rocket', 'desc': 'Aerospace & propulsion'},
      {'emoji': '🤖', 'title': 'Robo Builder', 'desc': 'Kinematics & servos'},
      {'emoji': '🦊', 'title': 'Clever Tinkerer', 'desc': 'Rapid upcycle prototyping'},
      {'emoji': '⚡', 'title': 'Spark Inventor', 'desc': 'Circuits & currents'},
      {'emoji': '🌻', 'title': 'Solar Architect', 'desc': 'Clean bio-mimetic tech'},
      {'emoji': '🎨', 'title': 'Creative Artisan', 'desc': 'Aesthetic industrial design'},
      {'emoji': '🦖', 'title': 'Dino Maker', 'desc': 'Prehistoric cardboard gear'},
      {'emoji': '🧪', 'title': 'Lab Alchemist', 'desc': 'Polymer & material science'},
      {'emoji': '🎮', 'title': 'Logic Coder', 'desc': 'Microcontroller algorithms'},
      {'emoji': '🦄', 'title': 'Visionary Spark', 'desc': 'Dream big, build bold'},
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        final screenW = MediaQuery.sizeOf(ctx).width;
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.symmetric(horizontal: screenW < 480 ? 14 : 40, vertical: 20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: math.min(540.0, screenW - 28),
              maxHeight: MediaQuery.sizeOf(ctx).height * 0.86,
            ),
            child: GlassSurface(
              borderRadius: 24,
              blurSigma: 18,
              tintColor: AppColors.primary,
              padding: EdgeInsets.all(screenW < 480 ? 16 : 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Row(
                    children: [
                      Text('🎨', style: TextStyle(fontSize: 22)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Cadet Avatar Studio', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textMain)),
                            Text('Choose your MakerQuest persona', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Flexible(
                    child: GridView.builder(
                      shrinkWrap: true,
                      itemCount: avatars.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: screenW < 520 ? 1 : 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        mainAxisExtent: 68,
                      ),
                      itemBuilder: (context, i) {
                        final item = avatars[i];
                        final isCurrent = _questState.currentUser.avatar == item['emoji'];
                        return InkWell(
                          onTap: () {
                            SoundEffects.playChime();
                            _questState.updateAvatar(item['emoji']!);
                            Navigator.of(ctx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Avatar updated to ${item['emoji']} ${item['title']}!'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? AppColors.primarySoft.withValues(alpha: 0.85)
                                  : Colors.white.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isCurrent ? AppColors.primary : Colors.white.withValues(alpha: 0.9),
                                width: isCurrent ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(item['emoji']!, style: const TextStyle(fontSize: 26)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        item['title']!,
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMain),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        item['desc']!,
                                        style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                if (isCurrent)
                                  const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 16),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Close'),
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

  void _showRegisterDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    String selectedAvatar = '🚀';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            final screenW = MediaQuery.sizeOf(dialogCtx).width;
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: EdgeInsets.symmetric(horizontal: screenW < 480 ? 14 : 40, vertical: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: math.min(440.0, screenW - 28)),
                child: GlassSurface(
                  borderRadius: 24,
                  blurSigma: 18,
                  tintColor: AppColors.cyan,
                  padding: EdgeInsets.all(screenW < 480 ? 16 : 22),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Create New Cadet Profile',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textMain),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: nameCtrl,
                          decoration: const InputDecoration(labelText: 'Cadet Name', hintText: 'e.g. Jordan Maker'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: emailCtrl,
                          decoration: const InputDecoration(labelText: 'Student Email', hintText: 'jordan@makerquest.edu'),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: selectedAvatar,
                          decoration: const InputDecoration(labelText: 'Maker Avatar'),
                          items: const [
                            DropdownMenuItem(value: '🚀', child: Text('🚀 Rocket Pioneer')),
                            DropdownMenuItem(value: '🤖', child: Text('🤖 Bot Builder')),
                            DropdownMenuItem(value: '🦊', child: Text('🦊 Clever Fox')),
                            DropdownMenuItem(value: '⚡', child: Text('⚡ Spark Inventor')),
                            DropdownMenuItem(value: '🌻', child: Text('🌻 Solar Architect')),
                          ],
                          onChanged: (val) {
                            setDialogState(() {
                              selectedAvatar = val ?? '🚀';
                            });
                          },
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          alignment: WrapAlignment.end,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(dialogCtx).pop(),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (nameCtrl.text.trim().isEmpty || emailCtrl.text.trim().isEmpty) return;
                                _questState.registerNewCadet(
                                  name: nameCtrl.text.trim(),
                                  email: emailCtrl.text.trim(),
                                  avatar: selectedAvatar,
                                );
                                Navigator.of(dialogCtx).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Welcome, ${nameCtrl.text.trim()}! +50 XP bonus awarded!')),
                                );
                              },
                              child: const Text('Create Cadet'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
