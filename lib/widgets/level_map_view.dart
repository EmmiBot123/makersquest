// Gamified STEM Learning Roadmap & Quest Progression Trail for MakerQuest
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/quest_state.dart';
import '../services/sound_effects.dart';
import '../models/project.dart';
import '../models/challenge.dart';
import '../theme/app_theme.dart';
import 'level_map_painter.dart';

enum RoadmapNodeType {
  realmBanner,
  projectStation,
  checkpointGate,
  summitCapstone,
}

class RoadmapNode {
  final String id;
  final int level;
  final String title;
  final String subtitle;
  final String icon;
  final int xp;
  final RoadmapNodeType type;
  final Project? project;
  final Challenge? challenge;
  final double alignment; // -0.5 for left, 0.0 for center, 0.5 for right

  const RoadmapNode({
    required this.id,
    required this.level,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.xp,
    required this.type,
    this.project,
    this.challenge,
    this.alignment = 0.0,
  });
}

class LevelNodeData {
  final int level;
  final String title;
  final String theme;
  final String icon;
  final int minXp;
  final int maxXp;

  const LevelNodeData({
    required this.level,
    required this.title,
    required this.theme,
    required this.icon,
    required this.minXp,
    required this.maxXp,
  });
}

class LevelMapView extends StatefulWidget {
  final QuestState state;
  final Function(int level)? onFilterLevelProjects;
  final Function(Challenge challenge)? onLaunchChallenge;
  final Function(Project project)? onOpenProject;

  const LevelMapView({
    super.key,
    required this.state,
    this.onFilterLevelProjects,
    this.onLaunchChallenge,
    this.onOpenProject,
  });

  static const List<LevelNodeData> kLevelTiers = [
    LevelNodeData(level: 1, title: 'Cardboard Apprentice', theme: 'Cardboard Mechanics', icon: '📦', minXp: 0, maxXp: 250),
    LevelNodeData(level: 2, title: 'Kinetic Tinkerer', theme: 'Simple Machines & Pulleys', icon: '⚙️', minXp: 251, maxXp: 600),
    LevelNodeData(level: 3, title: 'Circuit Pioneer', theme: 'Basic Circuits & Robotics', icon: '💡', minXp: 601, maxXp: 1050),
    LevelNodeData(level: 4, title: 'Robotics Innovator', theme: 'Smart Inventions & Sensors', icon: '🤖', minXp: 1051, maxXp: 1600),
    LevelNodeData(level: 5, title: 'Master Maker', theme: 'Eco-Tech & Automation', icon: '🌻', minXp: 1601, maxXp: 9999),
  ];

  @override
  State<LevelMapView> createState() => _LevelMapViewState();
}

class _LevelMapViewState extends State<LevelMapView> {
  // View mode: 'trail' (Winding Quest Path) or 'tree' (Curriculum Blueprint Tree)
  String _roadmapMode = 'trail';
  int _selectedRealmFilter = 0; // 0: All Realms, 1..5

  @override
  Widget build(BuildContext context) {
    final nodes = _buildRoadmapNodes();
    final completedCount = nodes.where((n) => _isNodeMastered(n)).length;
    final totalCount = nodes.where((n) => n.type != RoadmapNodeType.realmBanner).length;

    final isCompact = MediaQuery.sizeOf(context).width < 420;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(isCompact ? 12 : 16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Roadmap Header HUD
          _buildRoadmapHeaderHUD(context, completedCount, totalCount),

          const SizedBox(height: 16),

          // 2. Active View: Winding Trail or Blueprint Tree
          if (_roadmapMode == 'trail')
            _buildWindingQuestTrail(nodes)
          else
            _buildCurriculumBlueprintTree(),
        ],
      ),
    );
  }

  Widget _buildRoadmapHeaderHUD(BuildContext context, int completedCount, int totalCount) {
    final user = widget.state.currentUser;
    final pct = totalCount > 0 ? (completedCount / totalCount * 100).round() : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Clean Tier 1: Title + Progress + Mode Switcher (Responsive Wrap)
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 6,
              children: [
                const Text(
                  'Level Progression Map',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textMain),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    '🏆 $completedCount/$totalCount Stations ($pct%) • ⚡ ${user.currentXp} XP',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.emerald),
                  ),
                ),
              ],
            ),
            // Mode Switcher Buttons
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  _buildModeTab('🗺️ Quest Trail', 'trail'),
                  _buildModeTab('🧭 Blueprint Tree', 'tree'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Clean Tier 2: Realm Quick Filter Bar
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildRealmFilterChip('All Odyssey 🌐', 0),
              _buildRealmFilterChip('Lvl 1: Cardboard 📦', 1),
              _buildRealmFilterChip('Lvl 2: Machines ⚙️', 2),
              _buildRealmFilterChip('Lvl 3: Circuits 💡', 3),
              _buildRealmFilterChip('Lvl 4: Sensors 🤖', 4),
              _buildRealmFilterChip('Lvl 5: Summit 🏆', 5),
              const SizedBox(width: 8),
              ActionChip(
                avatar: Text(user.avatar, style: const TextStyle(fontSize: 12)),
                label: const Text('📍 Jump to My Cadet Spot', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                backgroundColor: AppColors.primarySoft,
                side: const BorderSide(color: AppColors.primary),
                onPressed: () {
                  SoundEffects.playPop();
                  setState(() {
                    _selectedRealmFilter = user.currentLevel;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRealmFilterChip(String label, int level) {
    final isSelected = _selectedRealmFilter == level;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white,
        showCheckmark: false,
        side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textMain,
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
        ),
        onSelected: (_) {
          SoundEffects.playPop();
          setState(() {
            _selectedRealmFilter = level;
          });
        },
      ),
    );
  }

  Widget _buildModeTab(String label, String mode) {
    final isSelected = _roadmapMode == mode;
    return InkWell(
      onTap: () {
        SoundEffects.playPop();
        setState(() => _roadmapMode = mode);
      },
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // MODE 1: WINDING QUEST TRAIL (Interactive Gamified Pathway)
  // ══════════════════════════════════════════════════════════════════
  Widget _buildWindingQuestTrail(List<RoadmapNode> nodes) {
    final displayNodes = _selectedRealmFilter == 0
        ? nodes
        : nodes.where((n) => n.level == _selectedRealmFilter).toList();

    // Determine the SINGLE active cadet node (the very first unmastered, unlocked station)
    String? activeMissionNodeId;
    for (final n in displayNodes) {
      if (n.type == RoadmapNodeType.projectStation && n.project != null) {
        final isMastered = widget.state.userProgress.isProjectCompleted(n.project!.id);
        final isUnlocked = widget.state.isLevelUnlocked(n.project!.levelRequired);
        if (!isMastered && isUnlocked) {
          activeMissionNodeId = n.id;
          break;
        }
      } else if (n.type == RoadmapNodeType.checkpointGate && n.challenge != null) {
        final isCompleted = widget.state.userProgress.isChallengeCompleted(n.challenge!.id);
        final isUnlocked = widget.state.isLevelUnlocked(n.challenge!.levelRequired);
        if (!isCompleted && isUnlocked) {
          activeMissionNodeId = n.id;
          break;
        }
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;

        // Calculate anchors and coordinates with generous, clean vertical breathing room
        final List<Offset> anchors = [];
        final List<double> nodeTops = [];
        final List<double> nodeHeights = [];
        double currentY = 24.0;

        // Gentle, elegant S-curve spread (centered in viewport)
        final spread = (w * 0.22).clamp(70.0, 160.0);

        for (int i = 0; i < displayNodes.length; i++) {
          final node = displayNodes[i];
          double h;
          double stepGap;
          switch (node.type) {
            case RoadmapNodeType.realmBanner:
              h = w < 380 ? 116.0 : 84.0;
              stepGap = 36.0;
              break;
            case RoadmapNodeType.checkpointGate:
              h = w < 420 ? 132.0 : 92.0;
              stepGap = 44.0;
              break;
            case RoadmapNodeType.summitCapstone:
              h = w < 360 ? 156.0 : 136.0;
              stepGap = 40.0;
              break;
            case RoadmapNodeType.projectStation:
              h = 110.0;
              stepGap = 54.0;
              break;
          }

          final centerY = currentY + (node.type == RoadmapNodeType.projectStation ? 38.0 : h / 2);
          final centerX = node.type == RoadmapNodeType.projectStation
              ? (w * 0.5 + node.alignment * spread)
              : (w * 0.5);

          anchors.add(Offset(centerX, centerY));
          nodeTops.add(currentY);
          nodeHeights.add(h);

          // Vertical spacing between roadmap milestones
          currentY += h + stepGap;
        }

        final totalCanvasHeight = currentY + 40.0;

        // Compute Road Segment Statuses (connecting anchor i to anchor i+1)
        final List<RoadSegmentStatus> segmentStatuses = [];
        for (int i = 0; i < displayNodes.length - 1; i++) {
          final nextNode = displayNodes[i + 1];
          final isNextMastered = _isNodeMastered(nextNode);
          final isNextActive = (nextNode.id == activeMissionNodeId);

          if (isNextMastered) {
            segmentStatuses.add(RoadSegmentStatus.completed);
          } else if (isNextActive || _isNodeActive(displayNodes[i]) || _isNodeMastered(displayNodes[i])) {
            segmentStatuses.add(RoadSegmentStatus.active);
          } else {
            segmentStatuses.add(RoadSegmentStatus.locked);
          }
        }

        return Container(
          width: w,
          height: totalCanvasHeight,
          decoration: BoxDecoration(
            color: const Color(0xFFFAFBFC),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, 6)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // 1. Technical Blueprint Grid Background
                Positioned.fill(
                  child: CustomPaint(
                    painter: BlueprintGridPainter(),
                  ),
                ),

                // 2. Continuous Multi-Node Bezier Highway
                Positioned.fill(
                  child: CustomPaint(
                    painter: ContinuousRoadPainter(
                      anchors: anchors,
                      statuses: segmentStatuses,
                    ),
                  ),
                ),

                // 3. Interactive Positioned Station Nodes (Direct Positioned Elements)
                for (int i = 0; i < displayNodes.length; i++)
                  ..._buildPositionedStationWidgets(
                    node: displayNodes[i],
                    anchor: anchors[i],
                    top: nodeTops[i],
                    height: nodeHeights[i],
                    width: w,
                    isActiveMission: displayNodes[i].id == activeMissionNodeId,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildPositionedStationWidgets({
    required RoadmapNode node,
    required Offset anchor,
    required double top,
    required double height,
    required double width,
    required bool isActiveMission,
  }) {
    switch (node.type) {
      case RoadmapNodeType.realmBanner:
        return [
          Positioned(
            top: top,
            left: 16,
            right: 16,
            child: _buildRealmBanner(node),
          ),
        ];
      case RoadmapNodeType.checkpointGate:
        return [
          Positioned(
            top: top,
            left: 16,
            right: 16,
            child: _buildCheckpointGateNode(node),
          ),
        ];
      case RoadmapNodeType.summitCapstone:
        return [
          Positioned(
            top: top,
            left: 16,
            right: 16,
            child: _buildSummitCapstoneNode(node),
          ),
        ];
      case RoadmapNodeType.projectStation:
        return _buildProjectStationWidgets(
          node: node,
          anchor: anchor,
          top: top,
          height: height,
          canvasWidth: width,
          isActiveMission: isActiveMission,
        );
    }
  }

  // Station Type 1: Realm Gateway Archway
  Widget _buildRealmBanner(RoadmapNode node) {
    final isUnlocked = widget.state.isLevelUnlocked(node.level);
    final isCurrent = widget.state.currentUser.currentLevel == node.level;
    final isTight = MediaQuery.sizeOf(context).width < 440;

    final statusChip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCurrent
            ? AppColors.emeraldSoft
            : isUnlocked
                ? AppColors.primarySoft
                : AppColors.bgSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isCurrent ? '📍 YOU ARE HERE' : isUnlocked ? 'UNLOCKED' : 'LOCKED 🔒',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: isCurrent
              ? AppColors.emerald
              : isUnlocked
                  ? AppColors.primary
                  : AppColors.textDim,
        ),
      ),
    );

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.symmetric(horizontal: isTight ? 12 : 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCurrent
                ? AppColors.emerald
                : isUnlocked
                    ? AppColors.primary.withValues(alpha: 0.5)
                    : AppColors.border,
            width: isCurrent ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (isCurrent ? AppColors.emerald : AppColors.primary).withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: isTight ? 40 : 46,
              height: isTight ? 40 : 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isUnlocked ? AppColors.primarySoft : AppColors.bgSurface,
              ),
              child: Center(
                child: Text(node.icon, style: TextStyle(fontSize: isTight ? 20 : 24)),
              ),
            ),
            SizedBox(width: isTight ? 10 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Text(
                        'Level ${node.level}: ${node.title}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isUnlocked ? AppColors.textMain : AppColors.textDim,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.cyanSoft,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _getTierTitle(node.level),
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.cyan),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    node.subtitle,
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  if (isTight) ...[
                    const SizedBox(height: 6),
                    statusChip,
                  ],
                ],
              ),
            ),
            if (!isTight) ...[
              const SizedBox(width: 8),
              statusChip,
            ],
          ],
        ),
      ),
    );
  }

  // Station Type 2: Tactile 3D Project Stepping Stone on Road (Duolingo / Candy Crush style)
  List<Widget> _buildProjectStationWidgets({
    required RoadmapNode node,
    required Offset anchor,
    required double top,
    required double height,
    required double canvasWidth,
    required bool isActiveMission,
  }) {
    final p = node.project;
    if (p == null) return const [];

    final isMastered = widget.state.userProgress.isProjectCompleted(p.id);
    final isUnlocked = widget.state.isLevelUnlocked(p.levelRequired);
    final user = widget.state.currentUser;

    const discDiameter = 72.0;
    final discX = anchor.dx - discDiameter / 2;
    final discY = anchor.dy - discDiameter / 2;

    final pillWidth = math.min(176.0, math.max(124.0, canvasWidth * 0.48));
    final maxPillX = math.max(8.0, canvasWidth - pillWidth - 8.0);
    final pillX = (anchor.dx - pillWidth / 2).clamp(8.0, maxPillX);
    final pillY = discY + discDiameter + 8.0;

    const kSimIds = {
      'proj_scissor_lift',
      'proj_test_cart',
      'proj_marble_coaster',
      'proj_pulley_crane',
      'proj_gear_automaton',
      'proj_moving_jaws',
      'proj_paper_circuit',
      'proj_wiggle_bot',
      'proj_solar_tracker',
    };
    final hasSim = kSimIds.contains(p.id);

    return [
      // 1. The 3D Tactile Stepping Stone directly centered on the road
      Positioned(
        left: discX,
        top: discY,
        width: discDiameter,
        height: discDiameter,
        child: Tooltip(
          message: '${p.title} (${p.difficulty} • +${p.xpReward} XP)\nTap to launch mission briefing',
          child: InkWell(
            onTap: () {
              SoundEffects.playPop();
              _showMissionLaunchpad(node);
            },
            borderRadius: BorderRadius.circular(discDiameter / 2),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Glowing Pulse Aura for Active Cadet Mission
                if (isActiveMission)
                  Container(
                    width: discDiameter + 16,
                    height: discDiameter + 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF6366F1), width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                          blurRadius: 14,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                  ),

                // Tactile 3D Disc Face
                Container(
                  width: discDiameter,
                  height: discDiameter,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isMastered
                          ? const [Color(0xFF34D399), Color(0xFF059669)]
                          : isActiveMission
                              ? const [Color(0xFF818CF8), Color(0xFF4F46E5)]
                              : isUnlocked
                                  ? const [Colors.white, Color(0xFFF8FAFC)]
                                  : const [Color(0xFFE2E8F0), Color(0xFFCBD5E1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: isMastered
                          ? const Color(0xFF047857)
                          : isActiveMission
                              ? const Color(0xFF4338CA)
                              : isUnlocked
                                  ? AppColors.primary
                                  : const Color(0xFF94A3B8),
                      width: 3.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isMastered
                            ? AppColors.emerald.withValues(alpha: 0.30)
                            : isActiveMission
                                ? AppColors.primary.withValues(alpha: 0.35)
                                : Colors.black12,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      node.icon,
                      style: TextStyle(
                        fontSize: 32,
                        color: isUnlocked ? null : Colors.black26,
                      ),
                    ),
                  ),
                ),

                // Active Cadet Callout Beacon directly above the disc
                if (isActiveMission)
                  Positioned(
                    top: -26,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: math.max(120.0, canvasWidth * 0.56)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F46E5),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4F46E5).withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(user.avatar, style: const TextStyle(fontSize: 11)),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '${user.name}: Start Here! 🚀',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (isMastered)
                  Positioned(
                    top: -14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFF59E0B)),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
                        ],
                      ),
                      child: const Text('⭐⭐⭐', style: TextStyle(fontSize: 9)),
                    ),
                  ),

                // Corner Status Indicator
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isMastered
                          ? AppColors.emerald
                          : isActiveMission
                              ? AppColors.amber
                              : isUnlocked
                                  ? AppColors.primary
                                  : AppColors.textDim,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      isMastered
                          ? Icons.check_rounded
                          : isActiveMission
                              ? Icons.play_arrow_rounded
                              : isUnlocked
                                  ? Icons.construction_rounded
                                  : Icons.lock_rounded,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // 2. Compact Title & XP Pill directly beneath the stepping stone
      Positioned(
        left: pillX,
        top: pillY,
        width: pillWidth,
        child: Tooltip(
          message: p.title,
          child: InkWell(
            onTap: () {
              SoundEffects.playPop();
              _showMissionLaunchpad(node);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActiveMission
                      ? AppColors.primary
                      : isMastered
                          ? AppColors.emerald.withValues(alpha: 0.5)
                          : const Color(0xFFE2E8F0),
                  width: isActiveMission ? 2.0 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isActiveMission ? AppColors.primary : Colors.black).withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getShortTitle(p.title),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isUnlocked ? AppColors.textMain : AppColors.textDim,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 4,
                    runSpacing: 2,
                    children: [
                      Text(
                        isMastered ? '⭐ Done' : '+${p.xpReward} XP',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isMastered
                              ? AppColors.emerald
                              : isActiveMission
                                  ? AppColors.primary
                                  : const Color(0xFFD97706),
                        ),
                      ),
                      if (hasSim)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.cyanSoft,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '🕹️ SIM',
                            style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: AppColors.cyan),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ];
  }

  String _getShortTitle(String title) {
    const titleMap = {
      'Cardboard Scissor Lift Mechanism': 'Scissor Lift',
      'Smooth-Rolling Test Cart with Straw Bearings': 'Test Cart',
      'Gravity-Fed Marble Coaster Run': 'Marble Coaster',
      'Rubber-Band Wind-Up Drive Racer': 'Rubber Racer',
      'Syringe Hydraulic Excavator Arm with Claw': 'Hydraulic Arm',
      'Sturdy Popsicle-Stick Truss Bridge': 'Truss Bridge',
      'Acoustic Rubber-Band String Guitar': 'String Guitar',
      'Pneumatic Cardboard Stomp Rocket Launcher': 'Stomp Rocket',
      'Sturdy Crank-and-Piston Moving Jaws': 'Crank & Piston Jaws',
      'Hand-Cranked Kinetic Automaton': 'Kinetic Automaton',
      'Multi-Ratio Compound Pulley Crane': 'Compound Pulley',
      'Copper Tape LED Greeting Card Circuit': 'LED Card Circuit',
      'Conductive Graphite-Drawn Touch Sensor': 'Graphite Sensor',
      'Recycled-Cup Bristle Vibration Wiggle-Bot': 'Vibration Wiggle-Bot',
      'Dual-LED Polarity Reversing Traffic Light': 'Polarity Traffic Light',
      'Single-Transistor Touch-Sensitive Nightlight': 'Touch Nightlight',
      'Photoresistor Light-Tracking Solar Pointer': 'Solar Pointer',
      'Micro-Servo Steerable Rover Chassis': 'Steerable Rover',
      'Dual-Motor Cardboard Obstacle Rover': 'Obstacle Rover',
      'Ultrasonic Guided Smart Delivery Cart': 'Smart Delivery Cart',
      'Sound-Reactive LED Voice Visualizer': 'Voice Visualizer',
      'Grand Autonomous Sorting Crane Summit': 'Autonomous Crane',
    };
    if (titleMap.containsKey(title)) return titleMap[title]!;
    return title
        .replaceAll(' Mechanism', '')
        .replaceAll(' with Straw Bearings', '')
        .replaceAll(' with Claw', '')
        .replaceAll(' Launcher', '')
        .replaceAll(' Run', '')
        .replaceAll(' Chassis', '');
  }

  // Station Type 3: Checkpoint Diagnostic Gateway Bridge
  Widget _buildCheckpointGateNode(RoadmapNode node) {
    final c = node.challenge;
    if (c == null) return const SizedBox.shrink();

    final isUnlocked = widget.state.isLevelUnlocked(c.levelRequired);
    final isCompleted = widget.state.userProgress.isChallengeCompleted(c.id);
    final isCompact = MediaQuery.sizeOf(context).width < 460;

    final gateButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isCompleted ? AppColors.emerald : (isUnlocked ? AppColors.amber : AppColors.bgSurface),
        foregroundColor: isCompleted ? Colors.white : (isUnlocked ? const Color(0xFF1E1B4B) : AppColors.textDim),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        minimumSize: const Size(0, 32),
      ),
      onPressed: () {
        SoundEffects.playPop();
        _showMissionLaunchpad(node);
      },
      child: Text(
        isCompleted ? 'Review' : (isUnlocked ? 'Enter ⚡' : 'Locked 🔒'),
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
      ),
    );

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 16, vertical: 10),
        decoration: BoxDecoration(
          color: isCompleted ? const Color(0xFFECFDF5) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCompleted ? AppColors.emerald : AppColors.amber,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isCompleted ? AppColors.emerald : AppColors.amber).withValues(alpha: 0.15),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            SoundEffects.playPop();
            _showMissionLaunchpad(node);
          },
          child: Row(
            children: [
              Container(
                width: isCompact ? 42 : 48,
                height: isCompact ? 42 : 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? AppColors.emerald.withValues(alpha: 0.15) : AppColors.amber.withValues(alpha: 0.15),
                  border: Border.all(color: isCompleted ? AppColors.emerald : AppColors.amber, width: 2),
                ),
                child: Center(
                  child: Text(isCompleted ? '⚡' : '🚧', style: TextStyle(fontSize: isCompact ? 19 : 22)),
                ),
              ),
              SizedBox(width: isCompact ? 10 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 2,
                      children: [
                        Text(
                          'CHECKPOINT GATE ${c.levelRequired}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: isCompleted ? AppColors.emerald : AppColors.amber,
                            letterSpacing: 0.6,
                          ),
                        ),
                        Text(
                          '+${c.xpReward} XP',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.amber),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      c.title,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textMain),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isCompleted
                          ? 'Passed! Unlocked Level ${c.levelTarget} License'
                          : 'Diagnose mechanics to unlock Level ${c.levelTarget}',
                      style: TextStyle(
                        fontSize: 10,
                        color: isCompleted ? AppColors.emerald : AppColors.textMuted,
                        fontWeight: isCompleted ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    if (isCompact) ...[
                      const SizedBox(height: 8),
                      gateButton,
                    ],
                  ],
                ),
              ),
              if (!isCompact) ...[
                const SizedBox(width: 8),
                gateButton,
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // INTERACTIVE MISSION LAUNCHPAD MODAL
  // ══════════════════════════════════════════════════════════════════
  void _showMissionLaunchpad(RoadmapNode node) {
    if (node.project != null) {
      _showProjectLaunchpadDialog(node.project!);
    } else if (node.challenge != null) {
      _showChallengeLaunchpadDialog(node.challenge!);
    } else if (node.type == RoadmapNodeType.summitCapstone) {
      if (widget.onFilterLevelProjects != null) {
        widget.onFilterLevelProjects!(5);
      }
    }
  }

  void _showProjectLaunchpadDialog(Project p) {
    final isUnlocked = widget.state.isLevelUnlocked(p.levelRequired);
    final isMastered = widget.state.userProgress.isProjectCompleted(p.id);
    final totalMaterials = p.materialsList.length;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            final currentChecklist = widget.state.userProgress.getChecklistFor(p.id);
            final currentCount = currentChecklist.length;
            final pct = totalMaterials > 0 ? (currentCount / totalMaterials * 100).round() : 0;
            final screenW = MediaQuery.sizeOf(dialogCtx).width;
            final isNarrow = screenW < 480;

            return AlertDialog(
              insetPadding: EdgeInsets.symmetric(horizontal: isNarrow ? 12 : 40, vertical: 20),
              actionsOverflowButtonSpacing: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              backgroundColor: Colors.white,
              titlePadding: EdgeInsets.fromLTRB(isNarrow ? 16 : 20, 18, isNarrow ? 16 : 20, 10),
              contentPadding: EdgeInsets.symmetric(horizontal: isNarrow ? 16 : 20),
              actionsPadding: EdgeInsets.fromLTRB(isNarrow ? 16 : 20, 12, isNarrow ? 16 : 20, 18),
              title: Row(
                children: [
                  Container(
                    width: isNarrow ? 42 : 48,
                    height: isNarrow ? 42 : 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isMastered ? AppColors.emeraldSoft : AppColors.primarySoft,
                      border: Border.all(
                        color: isMastered ? AppColors.emerald : AppColors.primary,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        isMastered ? '⭐' : '🛠️',
                        style: TextStyle(fontSize: isNarrow ? 20 : 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySoft,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'LEVEL ${p.levelRequired} • ${p.category.toUpperCase()}',
                                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.primary),
                                ),
                              ),
                              Text(
                                '+${p.xpReward} XP',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.amber),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          p.title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textMain),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: math.min(460.0, screenW - 48),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(height: 16),

                      // STEM Concept Banner
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.cyanSoft,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Text('🔬', style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'ENGINEERING PRINCIPLE',
                                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.cyan, letterSpacing: 0.6),
                                  ),
                                  Text(
                                    p.stemConcept,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMain),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        p.description,
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4),
                      ),

                      const SizedBox(height: 14),

                      // Interactive Supplies Mini Checklist
                      SizedBox(
                        width: double.infinity,
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            const Text(
                              'Workshop Supplies Needed:',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textMain),
                            ),
                            Text(
                              '$currentCount / $totalMaterials gathered ($pct%)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: pct == 100 ? AppColors.emerald : AppColors.amber,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: totalMaterials > 0 ? currentCount / totalMaterials : 0.0,
                          minHeight: 6,
                          backgroundColor: AppColors.bgSurface,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            pct == 100 ? AppColors.emerald : AppColors.primary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Materials quick checkboxes
                      ...p.materialsList.map((m) {
                        final checked = currentChecklist.contains(m.id);
                        return InkWell(
                          onTap: () {
                            SoundEffects.playPop();
                            final reward = widget.state.toggleMaterialCheck(p.id, m.id, !checked);
                            setDialogState(() {});
                            if (reward != null) {
                              SoundEffects.playFanfare();
                            }
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                            child: Row(
                              children: [
                                Icon(
                                  checked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                                  color: checked ? AppColors.emerald : AppColors.textDim,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${m.name} (${m.amount})',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: checked ? AppColors.textMain : AppColors.textMuted,
                                      fontWeight: checked ? FontWeight.w700 : FontWeight.w500,
                                      decoration: checked ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                      if (!isUnlocked) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.rose.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.rose.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Text('🔒', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.state.getLevelLockReason(p.levelRequired),
                                  style: const TextStyle(fontSize: 11, color: AppColors.rose, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Back to Roadmap'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isMastered ? AppColors.emerald : AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  onPressed: isUnlocked
                      ? () {
                          Navigator.of(ctx).pop();
                          _handleProjectTap(p);
                        }
                      : null,
                  icon: Icon(isMastered ? Icons.refresh_rounded : Icons.rocket_launch_rounded, size: 16),
                  label: Text(
                    isMastered ? 'Review Completed Blueprint' : 'Launch Mission Blueprint 🚀',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showChallengeLaunchpadDialog(Challenge c) {
    final isUnlocked = widget.state.isLevelUnlocked(c.levelRequired);
    final isCompleted = widget.state.userProgress.isChallengeCompleted(c.id);

    showDialog(
      context: context,
      builder: (ctx) {
        final screenW = MediaQuery.sizeOf(ctx).width;
        final isNarrow = screenW < 480;
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: isNarrow ? 12 : 40, vertical: 20),
          actionsOverflowButtonSpacing: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          titlePadding: EdgeInsets.fromLTRB(isNarrow ? 16 : 24, 20, isNarrow ? 16 : 24, 10),
          contentPadding: EdgeInsets.symmetric(horizontal: isNarrow ? 16 : 24),
          actionsPadding: EdgeInsets.fromLTRB(isNarrow ? 16 : 24, 12, isNarrow ? 16 : 24, 20),
          title: Row(
            children: [
              Container(
                width: isNarrow ? 42 : 48,
                height: isNarrow ? 42 : 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? AppColors.emeraldSoft : AppColors.amberSoft,
                ),
                child: Center(
                  child: Text(isCompleted ? '⚡' : '🚧', style: TextStyle(fontSize: isNarrow ? 20 : 24)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CHECKPOINT GATEWAY ${c.levelRequired}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: isCompleted ? AppColors.emerald : AppColors.amber,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      c.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textMain),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: math.min(440.0, screenW - 48),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  Text(
                    c.description,
                    style: const TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Text('🎯', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${c.questions.length} Scenario Troubleshooting Puzzles • +${c.xpReward} XP Reward',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMain),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isUnlocked) ...[
                    const SizedBox(height: 12),
                    Text(
                      '🔒 Complete Level ${c.levelRequired} DIY projects before entering this checkpoint gateway.',
                      style: const TextStyle(fontSize: 11, color: AppColors.rose),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Back to Roadmap'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isCompleted ? AppColors.emerald : AppColors.amber,
                foregroundColor: isCompleted ? Colors.white : const Color(0xFF1E1B4B),
              ),
              onPressed: isUnlocked
                  ? () {
                      Navigator.of(ctx).pop();
                      _handleChallengeTap(c);
                    }
                  : null,
              icon: const Icon(Icons.quiz_rounded, size: 16),
              label: Text(isCompleted ? 'Retake Checkpoint' : 'Start Checkpoint Simulation ⚡', style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        );
      },
    );
  }

  // Station Type 4: Summit Master Maker Capstone
  Widget _buildSummitCapstoneNode(RoadmapNode node) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF312E81), Color(0xFF1E1B4B)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.amber, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.amber.withValues(alpha: 0.3),
              blurRadius: 18,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            const Text('🏆', style: TextStyle(fontSize: 34)),
            const SizedBox(height: 6),
            const Text(
              'MASTER MAKER SUMMIT',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Official STEM Certification & Engineering Portfolio Sign-off',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppColors.amberGlow),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.amber,
                foregroundColor: const Color(0xFF1E1B4B),
              ),
              onPressed: () {
                if (widget.onFilterLevelProjects != null) {
                  widget.onFilterLevelProjects!(5);
                }
              },
              icon: const Icon(Icons.workspace_premium_rounded, size: 16),
              label: const Text('View Capstone Odyssey', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // MODE 2: BLUEPRINT TREE (roadmap.sh-Style Architecture Tree)
  // ══════════════════════════════════════════════════════════════════
  Widget _buildCurriculumBlueprintTree() {
    return Column(
      children: LevelMapView.kLevelTiers.map((tier) {
        final isUnlocked = widget.state.isLevelUnlocked(tier.level);
        final isCurrent = widget.state.currentUser.currentLevel == tier.level;
        final projects = widget.state.projects.where((p) => p.levelRequired == tier.level).toList();
        final chk = widget.state.challenges.cast<Challenge?>().firstWhere(
              (c) => c?.levelRequired == tier.level,
              orElse: () => null,
            );

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.bgSecondary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCurrent
                  ? AppColors.emerald
                  : isUnlocked
                      ? AppColors.borderLight
                      : AppColors.border,
              width: isCurrent ? 2 : 1,
            ),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: isCurrent || tier.level <= 2,
              leading: Text(tier.icon, style: const TextStyle(fontSize: 24)),
              title: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Text(
                    'Level ${tier.level}: ${tier.title}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textMain),
                  ),
                  if (isCurrent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.emerald.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'CURRENT',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.emerald),
                      ),
                    ),
                ],
              ),
              subtitle: Text(
                'Theme: ${tier.theme} • XP: ${tier.minXp} - ${tier.maxXp}',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                // Branch Projects
                ...projects.map((p) {
                  final isDone = widget.state.userProgress.isProjectCompleted(p.id);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: isDone ? AppColors.emerald.withValues(alpha: 0.08) : AppColors.bgCard,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isDone ? AppColors.emerald.withValues(alpha: 0.4) : AppColors.border,
                      ),
                    ),
                    child: ListTile(
                      dense: true,
                      leading: Icon(
                        isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                        color: isDone ? AppColors.emerald : AppColors.textDim,
                        size: 20,
                      ),
                      title: Text(
                        p.title,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textMain),
                      ),
                      subtitle: Text(
                        'STEM Concept: ${p.stemConcept}',
                        style: const TextStyle(fontSize: 11, color: AppColors.cyan),
                      ),
                      trailing: TextButton(
                        onPressed: isUnlocked ? () => _handleProjectTap(p) : null,
                        child: Text(isDone ? 'Review' : 'Build 🚀'),
                      ),
                    ),
                  );
                }),

                if (chk != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
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
                              const Text('⚡', style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      chk.title,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMain),
                                    ),
                                    Text(
                                      'Unlocks Level ${chk.levelTarget} License',
                                      style: const TextStyle(fontSize: 10, color: AppColors.amberGlow),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.amber,
                              foregroundColor: const Color(0xFF1E1B4B),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              minimumSize: const Size(0, 32),
                            ),
                            onPressed: isUnlocked ? () => _handleChallengeTap(chk) : null,
                            child: const Text('Gateway Quiz', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // HELPER METHODS & NODE DEFINITIONS
  // ══════════════════════════════════════════════════════════════════
  List<RoadmapNode> _buildRoadmapNodes() {
    return [
      // ══════════════════════════════════════════════════════════════
      // LEVEL 1: CARDBOARD MECHANICS (Ch. 1-3)
      // ══════════════════════════════════════════════════════════════
      const RoadmapNode(
        id: 'r1_banner',
        level: 1,
        title: 'Cardboard Mechanics',
        subtitle: 'Cardboard Apprentice • Foundational Linkages',
        icon: '📦',
        xp: 0,
        type: RoadmapNodeType.realmBanner,
        alignment: 0.0,
      ),
      RoadmapNode(
        id: 'p_scissor',
        level: 1,
        title: 'Cardboard Scissor Lift',
        subtitle: 'Pantograph Linkages & Elevation',
        icon: '✂️',
        xp: 120,
        type: RoadmapNodeType.projectStation,
        project: widget.state.projects.firstWhere((p) => p.id == 'proj_scissor_lift'),
        alignment: -0.55,
      ),
      RoadmapNode(
        id: 'p_cart',
        level: 1,
        title: 'Smooth-Rolling Test Cart',
        subtitle: 'Straw Bearings & Axle Alignment',
        icon: '🏎️',
        xp: 110,
        type: RoadmapNodeType.projectStation,
        project: widget.state.projects.firstWhere((p) => p.id == 'proj_test_cart'),
        alignment: 0.55,
      ),
      RoadmapNode(
        id: 'p_coaster',
        level: 1,
        title: 'Gravity Marble Coaster',
        subtitle: 'Potential vs. Kinetic Energy',
        icon: '🎢',
        xp: 130,
        type: RoadmapNodeType.projectStation,
        project: widget.state.projects.firstWhere((p) => p.id == 'proj_marble_coaster'),
        alignment: -0.55,
      ),
      RoadmapNode(
        id: 'p_rubber',
        level: 1,
        title: 'Rubber-Band Racer',
        subtitle: 'Elastic Energy & Axle Torque',
        icon: '🏎️',
        xp: 125,
        type: RoadmapNodeType.projectStation,
        project: widget.state.projects.firstWhere((p) => p.id == 'proj_rubber_drive'),
        alignment: 0.55,
      ),
      RoadmapNode(
        id: 'chk_1',
        level: 1,
        title: 'Structural Mechanics Lab',
        subtitle: 'Solve engineering diagnostics to unlock Level 2',
        icon: '⚡',
        xp: 150,
        type: RoadmapNodeType.checkpointGate,
        challenge: widget.state.challenges.firstWhere((c) => c.id == 'chal_checkpoint_1'),
        alignment: 0.0,
      ),

      // ══════════════════════════════════════════════════════════════
      // LEVEL 2: SIMPLE MACHINES & PULLEYS (Ch. 4-6)
      // ══════════════════════════════════════════════════════════════
      const RoadmapNode(
        id: 'r2_banner',
        level: 2,
        title: 'Simple Machines & Pulleys',
        subtitle: 'Mechanical Advantage & Rotary Cams',
        icon: '⚙️',
        xp: 250,
        type: RoadmapNodeType.realmBanner,
        alignment: 0.0,
      ),
      RoadmapNode(
        id: 'p_crane',
        level: 2,
        title: 'Dual-Pulley Mechanical Crane',
        subtitle: 'Block & Tackle Advantage',
        icon: '🏗️',
        xp: 180,
        type: RoadmapNodeType.projectStation,
        project: widget.state.projects.firstWhere((p) => p.id == 'proj_pulley_crane'),
        alignment: 0.55,
      ),
      RoadmapNode(
        id: 'p_automaton',
        level: 2,
        title: 'Cam & Gear Automaton',
        subtitle: 'Rotary to Oscillating Motion',
        icon: '🎭',
        xp: 190,
        type: RoadmapNodeType.projectStation,
        project: widget.state.projects.firstWhere((p) => p.id == 'proj_gear_automaton'),
        alignment: -0.55,
      ),
      RoadmapNode(
        id: 'p_robot_arm',
        level: 2,
        title: 'Articulated Arm & Scoop',
        subtitle: 'Levers, Stiffeners & Moments',
        icon: '🦾',
        xp: 185,
        type: RoadmapNodeType.projectStation,
        project: widget.state.projects.firstWhere((p) => p.id == 'proj_robot_arm'),
        alignment: 0.55,
      ),
      RoadmapNode(
        id: 'p_trapdoor',
        level: 2,
        title: 'Trap-Door Scoop',
        subtitle: 'Living-Hinge Delivery Latch',
        icon: '📦',
        xp: 175,
        type: RoadmapNodeType.projectStation,
        project: widget.state.projects.firstWhere((p) => p.id == 'proj_trapdoor_scoop'),
        alignment: -0.55,
      ),
      RoadmapNode(
        id: 'chk_2',
        level: 2,
        title: 'Mechanical Advantage Lab',
        subtitle: 'Diagnose pulley rigging to unlock Level 3',
        icon: '⚡',
        xp: 200,
        type: RoadmapNodeType.checkpointGate,
        challenge: widget.state.challenges.firstWhere((c) => c.id == 'chal_checkpoint_2'),
        alignment: 0.0,
      ),

      // ══════════════════════════════════════════════════════════════
      // LEVEL 3: ROBOTIC GRIPPERS & CIRCUITS (Ch. 5 & 8)
      // ══════════════════════════════════════════════════════════════
      const RoadmapNode(
        id: 'r3_banner',
        level: 3,
        title: 'Robotic Grippers & Circuits',
        subtitle: 'Mirrored Linkages & Vibration Locomotion',
        icon: '💡',
        xp: 600,
        type: RoadmapNodeType.realmBanner,
        alignment: 0.0,
      ),
      RoadmapNode(
        id: 'p_jaws',
        level: 3,
        title: 'Moving Jaws & Springy Claw',
        subtitle: 'Mirrored Clamping Grippers',
        icon: '🦀',
        xp: 210,
        type: RoadmapNodeType.projectStation,
        project: widget.state.projects.firstWhere((p) => p.id == 'proj_moving_jaws'),
        alignment: -0.55,
      ),
      RoadmapNode(
        id: 'p_walking',
        level: 3,
        title: 'Walking-Style Leg Linkage',
        subtitle: 'Four-Bar Elliptical Step Gait',
        icon: '🦿',
        xp: 230,
        type: RoadmapNodeType.projectStation,
        project: widget.state.projects.firstWhere((p) => p.id == 'proj_walking_linkage'),
        alignment: 0.55,
      ),
      RoadmapNode(
        id: 'p_circuit',
        level: 3,
        title: 'Origami Light-Up Card',
        subtitle: 'LED Polarity & Closed Circuits',
        icon: '💌',
        xp: 200,
        type: RoadmapNodeType.projectStation,
        project: widget.state.projects.firstWhere((p) => p.id == 'proj_paper_circuit'),
        alignment: -0.55,
      ),
      RoadmapNode(
        id: 'p_wiggle',
        level: 3,
        title: 'Bristle Wiggle-Bot',
        subtitle: 'Vibrational Locomotion',
        icon: '🤖',
        xp: 220,
        type: RoadmapNodeType.projectStation,
        project: widget.state.projects.firstWhere((p) => p.id == 'proj_wiggle_bot'),
        alignment: 0.55,
      ),
      RoadmapNode(
        id: 'chk_3',
        level: 3,
        title: 'Circuit Polarity Lab',
        subtitle: 'Diagnose forward voltage to unlock Level 4',
        icon: '⚡',
        xp: 250,
        type: RoadmapNodeType.checkpointGate,
        challenge: widget.state.challenges.firstWhere((c) => c.id == 'chal_checkpoint_3'),
        alignment: 0.0,
      ),

      // ══════════════════════════════════════════════════════════════
      // LEVEL 4: MOVING CREATURES & SMART SENSORS (Ch. 7 & 11)
      // ══════════════════════════════════════════════════════════════
      const RoadmapNode(
        id: 'r4_banner',
        level: 4,
        title: 'Moving Creatures & Sensors',
        subtitle: 'Harmonic Cams & Heliotropism',
        icon: '🦅',
        xp: 1050,
        type: RoadmapNodeType.realmBanner,
        alignment: 0.0,
      ),
      RoadmapNode(
        id: 'p_cam_creature',
        level: 4,
        title: 'Flapping Wing Creature',
        subtitle: 'Dual-Lobe Cams & Living Hinges',
        icon: '🦋',
        xp: 280,
        type: RoadmapNodeType.projectStation,
        project: widget.state.projects.firstWhere((p) => p.id == 'proj_cam_creature'),
        alignment: -0.55,
      ),
      RoadmapNode(
        id: 'p_solar',
        level: 4,
        title: 'Solar Sunflower Tracker',
        subtitle: 'Photoresistors & Heliotropism',
        icon: '🌻',
        xp: 300,
        type: RoadmapNodeType.projectStation,
        project: widget.state.projects.firstWhere((p) => p.id == 'proj_solar_tracker'),
        alignment: 0.55,
      ),
      RoadmapNode(
        id: 'chk_4',
        level: 4,
        title: 'Kinematic Synchronization Lab',
        subtitle: 'Diagnose cam frequency & sensor loops',
        icon: '⚡',
        xp: 300,
        type: RoadmapNodeType.checkpointGate,
        challenge: widget.state.challenges.firstWhere((c) => c.id == 'chal_checkpoint_4'),
        alignment: 0.0,
      ),

      // ══════════════════════════════════════════════════════════════
      // LEVEL 5: MASTER MAKER CAPSTONE & SUMMIT (Ch. 11 & 12)
      // ══════════════════════════════════════════════════════════════
      const RoadmapNode(
        id: 'r5_banner',
        level: 5,
        title: 'Master Maker Odyssey',
        subtitle: 'System Integration & STEM Certification',
        icon: '🏆',
        xp: 1600,
        type: RoadmapNodeType.realmBanner,
        alignment: 0.0,
      ),
      RoadmapNode(
        id: 'p_rover',
        level: 5,
        title: 'Autonomous Rescue Rover',
        subtitle: 'Drive + Boom Lift + Claw Rescue',
        icon: '🚙',
        xp: 350,
        type: RoadmapNodeType.projectStation,
        project: widget.state.projects.firstWhere((p) => p.id == 'proj_rescue_rover'),
        alignment: -0.55,
      ),
      RoadmapNode(
        id: 'p_notebook',
        level: 5,
        title: 'STEM Engineering Logbook',
        subtitle: 'The 5-Step Engineering Cycle',
        icon: '📝',
        xp: 200,
        type: RoadmapNodeType.projectStation,
        project: widget.state.projects.firstWhere((p) => p.id == 'proj_lab_notebook'),
        alignment: 0.55,
      ),
      RoadmapNode(
        id: 'p_lifter',
        level: 5,
        title: 'Heavy Compound Lifter',
        subtitle: 'Multiplying Gear & Pulley Muscle',
        icon: '🏗️',
        xp: 320,
        type: RoadmapNodeType.projectStation,
        project: widget.state.projects.firstWhere((p) => p.id == 'proj_heavy_lifter'),
        alignment: -0.55,
      ),
      const RoadmapNode(
        id: 'summit',
        level: 5,
        title: 'Master Maker Capstone',
        subtitle: 'STEM Certification & Portfolio Sign-off',
        icon: '🏆',
        xp: 1600,
        type: RoadmapNodeType.summitCapstone,
        alignment: 0.0,
      ),
    ];
  }

  bool _isNodeMastered(RoadmapNode node) {
    if (node.project != null) {
      return widget.state.userProgress.isProjectCompleted(node.project!.id);
    }
    if (node.challenge != null) {
      return widget.state.userProgress.isChallengeCompleted(node.challenge!.id);
    }
    if (node.type == RoadmapNodeType.realmBanner) {
      return widget.state.isLevelUnlocked(node.level);
    }
    return false;
  }

  bool _isNodeActive(RoadmapNode node) {
    if (node.project != null) {
      final p = node.project!;
      final isDone = widget.state.userProgress.isProjectCompleted(p.id);
      final isUnlocked = widget.state.isLevelUnlocked(p.levelRequired);
      return !isDone && isUnlocked && widget.state.currentUser.currentLevel == p.levelRequired;
    }
    if (node.challenge != null) {
      final c = node.challenge!;
      final isDone = widget.state.userProgress.isChallengeCompleted(c.id);
      final isUnlocked = widget.state.isLevelUnlocked(c.levelRequired);
      return !isDone && isUnlocked;
    }
    return false;
  }

  void _handleProjectTap(Project project) {
    if (widget.onOpenProject != null) {
      widget.onOpenProject!(project);
    } else if (widget.onFilterLevelProjects != null) {
      widget.onFilterLevelProjects!(project.levelRequired);
    }
  }

  void _handleChallengeTap(Challenge challenge) {
    if (widget.onLaunchChallenge != null) {
      widget.onLaunchChallenge!(challenge);
    }
  }

  String _getTierTitle(int level) {
    switch (level) {
      case 1:
        return 'Cardboard Apprentice';
      case 2:
        return 'Kinetic Tinkerer';
      case 3:
        return 'Circuit Pioneer';
      case 4:
        return 'Robotics Innovator';
      case 5:
        return 'Master Maker';
      default:
        return 'Cadet';
    }
  }
}
