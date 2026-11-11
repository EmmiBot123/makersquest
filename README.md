# ⚡ MakerQuest: Gamified DIY Project Learning Web App (Flutter & Node.js)

**MakerQuest** is a gamified DIY project learning web application for students built with **Flutter Web** (Material 3, Custom Painters, interactive state management) and backed by an optional **Node.js REST API** with `node:sqlite`.

Students embark on an engineering odyssey where they unlock higher realms only after completing hands-on DIY projects and passing checkpoint troubleshooting simulations.

---

## 🚀 Key Features by Level (Flutter Web App)

### Level 1: Database Models & Student Profiles
- **User Models**: [`lib/models/user.dart`](file:///Users/abhayadhip/makerquest/lib/models/user.dart) with student name, email, avatar, level, XP, daily streak, and unlocked badge achievements.
- **Project Models**: [`lib/models/project.dart`](file:///Users/abhayadhip/makerquest/lib/models/project.dart) with `levelRequired`, title, description, category, difficulty, estimated time, XP reward, `materialsList` (JSON), and `steps` (JSON).
- **Challenge Models**: [`lib/models/challenge.dart`](file:///Users/abhayadhip/makerquest/lib/models/challenge.dart) with `levelRequired`, `levelTarget`, diagnostic scenarios, question choices, correct index, and educational explanations.
- **Badge Models**: [`lib/models/badge.dart`](file:///Users/abhayadhip/makerquest/lib/models/badge.dart) with badges for milestones, skills, and level masteries.
- **Progress Tracking**: [`lib/models/user_progress.dart`](file:///Users/abhayadhip/makerquest/lib/models/user_progress.dart) managing checked materials, completed steps, proof photos, notes, and challenge scores.
- **Cadet Management**:
  - Quick 1-click demo switcher between **Alex Rivera** (Level 2 • 320 XP) and **Sam Chen** (Level 1 • 50 XP).
  - "Create New Cadet Profile" dialog with customizable avatar selection and automatic +50 XP welcome bonus.

### Level 2: Student Dashboard & Level Progression Map
- **Hero Dashboard ([`lib/widgets/hero_dashboard_card.dart`](file:///Users/abhayadhip/makerquest/lib/widgets/hero_dashboard_card.dart))**:
  - Cadet avatar, active realm title (*Level 2: Kinetic Tinkerer*), and current theme (*Simple Machines & Pulleys*).
  - Animated XP progress bar tracking progress to the next level tier.
  - Quick stat counters: Total XP, DIY Projects Completed, Checkpoints Passed, Badges Earned, and Daily Streak.
  - "Recommended Mission" button to jump directly into the next project.
- **Visual Level Progression Map ([`lib/widgets/level_map_view.dart`](file:///Users/abhayadhip/makerquest/lib/widgets/level_map_view.dart) & [`lib/widgets/level_map_painter.dart`](file:///Users/abhayadhip/makerquest/lib/widgets/level_map_painter.dart))**:
  - Custom-painted wavy cubic Bezier path connecting 5 thematic realms:
    1. **Level 1**: Cardboard Mechanics (*Scissor Lift*, *Gravity Marble Coaster*)
    2. **Level 2**: Simple Machines & Pulleys (*Dual-Pulley Mechanical Crane*, *Cam & Gear Automaton*)
    3. **Level 3**: Basic Circuits & Robotics (*Light-Up Greeting Card*, *Bristle Wiggle-Bot*)
    4. **Level 4**: Smart Inventions & Sensors (*Bio-Mimetic Solar Sunflower Tracker*)
    5. **Level 5**: Master Maker Sanctuary (*Eco-Tech & Automation*)
  - Higher levels remain locked until preceding projects are completed and the checkpoint challenge is passed.
  - Interactive nodes display completion stars, current level glow, locked padlocks, and prerequisite tooltips.

### Level 3: Interactive Project View & Material Checklists
- **Detailed Project Blueprint ([`lib/widgets/project_detail_view.dart`](file:///Users/abhayadhip/makerquest/lib/widgets/project_detail_view.dart))**:
  - **Interactive Material Checklist**: Checkboxes that tick off supplies in real-time with an animated progress meter (e.g., "5 of 5 gathered (100%)"). Gathering 100% of materials awards the **"Resourceful Gatherer"** badge!
  - **Step-by-Step Assembly Guide**: Step checkoffs ("Mark Done"), custom schematic visual boxes, and highlighted *Maker Pro Tips* & *Safety Warning* cards.
  - **Project Proof Submission**: Photo upload dropzone with preview, quick-select verified prototype presets (for instant testing without local files), engineering reflection notes input, and completion button awarding project XP.

### Level 4: Gamified Checkpoint Challenges & Quizzes
- **Interactive Checkpoint Runner ([`lib/widgets/challenge_quiz_dialog.dart`](file:///Users/abhayadhip/makerquest/lib/widgets/challenge_quiz_dialog.dart))**:
  - Scenario-based engineering diagnostic puzzles (e.g. centrifugal flyouts on marble runs, jammed scissor lift linkages, compound pulley mechanical advantage, LED diode forward-bias polarity).
  - Collapsible hint button ("Need a Maker Hint? 💡").
  - Instant scoring with pass threshold (≥ 65%). Perfect scores (100%) award the **"Troubleshooter Ace"** badge!
  - Diagnostic review with thorough educational explanations for each question.
  - Promotes student to the target level upon passing!

### Level 5: Styling, Polish & Responsiveness
- **Design System ([`lib/theme/app_theme.dart`](file:///Users/abhayadhip/makerquest/lib/theme/app_theme.dart))**:
  - Vibrant Material 3 STEM theme with custom dark slate background (`#0F172A`), Quest Indigo (`#6366F1`), Amber Gold (`#F59E0B`), Emerald Green (`#10B981`), Cyan (`#06B6D4`), and Rose (`#F43F5E`).
  - **Celebration Victory Popup ([`lib/widgets/reward_celebration_dialog.dart`](file:///Users/abhayadhip/makerquest/lib/widgets/reward_celebration_dialog.dart))**: Displays fanfare dialog with bouncing trophy, XP chips, and unlocked badge announcements.
  - **Full Responsiveness**: Adaptive navigation rail on desktop / tablet, bottom navigation bar on mobile, and responsive grid layouts.

---

## 🏃 How to Run the Flutter Web App

### Run Flutter Web in Development:
```bash
flutter run -d chrome
```

### Run Flutter Tests:
```bash
flutter test
```
All 8 unit & widget tests pass cleanly:
```
00:02 +8: All tests passed!
```

### Build for Production Web:
```bash
flutter build web --release
```
Production artifacts are compiled to `build/web/`.

### Run via the Integrated Local Server:
```bash
npm start
```
Starts the Node.js HTTP server at **`http://localhost:3000`** serving the compiled Flutter Web application with SQLite database persistence!

---

## 📂 Project Structure

```
makerquest/
├── lib/
│   ├── main.dart                       # Flutter entrypoint & navigation
│   ├── models/
│   │   ├── user.dart                   # Cadet user profile model
│   │   ├── project.dart                # DIY Project, MaterialItem & Step models
│   │   ├── challenge.dart              # Checkpoint challenge & QuizQuestion models
│   │   ├── badge.dart                  # Maker badge achievement model
│   │   └── user_progress.dart          # Progress & checklist state tracking
│   ├── data/
│   │   └── seed_data.dart              # Pre-seeded projects, challenges & demo students
│   ├── services/
│   │   └── quest_state.dart            # ChangeNotifier state manager (XP, progression, badges)
│   ├── theme/
│   │   └── app_theme.dart              # Material 3 dark design system & colors
│   └── widgets/
│       ├── hero_dashboard_card.dart    # Level 2: Student stats & XP progress bar
│       ├── level_map_painter.dart      # Level 2: CustomPainter wavy Bezier path
│       ├── level_map_view.dart         # Level 2: Interactive visual level map
│       ├── project_card.dart           # Level 3: Project card with gather meter
│       ├── project_detail_view.dart    # Level 3: Checklist, steps & proof submitter
│       ├── challenge_quiz_dialog.dart  # Level 4: Checkpoint diagnostic quiz runner
│       ├── reward_celebration_dialog.dart # Level 4/5: Level up & badge celebration modal
│       └── badges_grid_view.dart       # Level 2/5: Trophy case grid
├── web/                                # Flutter web assets & index.html
├── build/web/                          # Compiled Flutter Web release
├── test/
│   ├── widget_test.dart                # Flutter widget tests (navigation, map, catalog)
│   └── quest_state_test.dart           # Unit tests (progression logic, checklist, quiz scoring)
└── server/                             # Optional REST backend & SQLite database
    ├── index.js
    ├── db.js
    ├── auth.js
    └── api.js
```
