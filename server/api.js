// MakerQuest Core API Logic
const crypto = require('node:crypto');
const { getDb } = require('./db');
const { getUserByToken, getUserById } = require('./auth');

const LEVEL_CONFIG = [
  { level: 1, title: 'Cardboard Apprentice', minXp: 0, maxXp: 250, theme: 'Cardboard Mechanics' },
  { level: 2, title: 'Kinetic Tinkerer', minXp: 251, maxXp: 600, theme: 'Simple Machines & Pulleys' },
  { level: 3, title: 'Circuit Pioneer', minXp: 601, maxXp: 1050, theme: 'Basic Circuits & Robotics' },
  { level: 4, title: 'Robotics Innovator', minXp: 1051, maxXp: 1600, theme: 'Smart Inventions & Sensors' },
  { level: 5, title: 'Master Maker', minXp: 1601, maxXp: 9999, theme: 'Eco-Tech & Automation' }
];

function getLevelInfo(levelNumber) {
  return LEVEL_CONFIG.find(l => l.level === levelNumber) || LEVEL_CONFIG[0];
}

// Check if a level is unlocked for a user
function checkLevelUnlocked(userId, targetLevel) {
  if (targetLevel <= 1) return { unlocked: true, reason: 'Level 1 is open to all makers!' };

  const db = getDb();
  const prevLevel = targetLevel - 1;

  // Check if checkpoint challenge for prevLevel -> targetLevel is completed
  const challenge = db.prepare(`
    SELECT c.id, c.title, up.status
    FROM challenges c
    LEFT JOIN user_progress up ON up.item_id = c.id AND up.user_id = ? AND up.status = 'completed'
    WHERE c.level_required = ? AND c.level_target = ?
  `).get(userId, prevLevel, targetLevel);

  // Check if at least one project from prevLevel is completed
  const completedProjectsCount = db.prepare(`
    SELECT count(*) as count
    FROM projects p
    JOIN user_progress up ON up.item_id = p.id AND up.user_id = ? AND up.status = 'completed'
    WHERE p.level_required = ?
  `).get(userId, prevLevel).count;

  if (completedProjectsCount === 0) {
    return {
      unlocked: false,
      reason: `Complete DIY projects in Level ${prevLevel} before unlocking Level ${targetLevel}.`,
      requiredProjects: 1,
      completedProjects: completedProjectsCount
    };
  }

  if (challenge && challenge.status !== 'completed') {
    return {
      unlocked: false,
      reason: `Pass the Level ${prevLevel} Checkpoint Challenge ("${challenge.title}") to unlock Level ${targetLevel}!`,
      requiredChallengeId: challenge.id
    };
  }

  return { unlocked: true, reason: 'Level unlocked!' };
}

// Student Dashboard Data
function getDashboardData(userId) {
  const db = getDb();
  const user = getUserById(userId);
  if (!user) throw new Error('User not found');

  const levelInfo = getLevelInfo(user.current_level);
  const nextLevelInfo = LEVEL_CONFIG.find(l => l.level === user.current_level + 1) || null;

  // Total projects completed
  const completedProjects = db.prepare(`
    SELECT count(*) as count
    FROM user_progress
    WHERE user_id = ? AND item_type = 'project' AND status = 'completed'
  `).get(userId).count;

  // Total challenges completed
  const completedChallenges = db.prepare(`
    SELECT count(*) as count
    FROM user_progress
    WHERE user_id = ? AND item_type = 'challenge' AND status = 'completed'
  `).get(userId).count;

  // Badges list
  const allBadges = db.prepare('SELECT * FROM badges').all();
  const badgesWithStatus = allBadges.map(b => ({
    ...b,
    is_unlocked: user.unlocked_badges.includes(b.id)
  }));

  // Level Progression Map Nodes
  const levelNodes = LEVEL_CONFIG.map(cfg => {
    const unlockStatus = checkLevelUnlocked(userId, cfg.level);
    const projectsInLevel = db.prepare('SELECT count(*) as count FROM projects WHERE level_required = ?').get(cfg.level).count;
    const completedInLevel = db.prepare(`
      SELECT count(*) as count
      FROM projects p
      JOIN user_progress up ON up.item_id = p.id AND up.user_id = ? AND up.status = 'completed'
      WHERE p.level_required = ?
    `).get(userId, cfg.level).count;

    const challenge = db.prepare('SELECT id, title, type, xp_reward FROM challenges WHERE level_required = ?').get(cfg.level);
    let challengeCompleted = false;
    if (challenge) {
      const chalProgress = db.prepare(`
        SELECT status FROM user_progress WHERE user_id = ? AND item_id = ? AND status = 'completed'
      `).get(userId, challenge.id);
      challengeCompleted = !!chalProgress;
    }

    const isFullyCompleted = projectsInLevel > 0 && completedInLevel >= projectsInLevel && (!challenge || challengeCompleted);
    const isCurrent = user.current_level === cfg.level;

    return {
      level: cfg.level,
      title: cfg.title,
      theme: cfg.theme,
      minXp: cfg.minXp,
      maxXp: cfg.maxXp,
      is_unlocked: unlockStatus.unlocked,
      unlock_reason: unlockStatus.reason,
      is_current: isCurrent,
      is_completed: isFullyCompleted,
      projects_total: projectsInLevel,
      projects_completed: completedInLevel,
      challenge_id: challenge ? challenge.id : null,
      challenge_title: challenge ? challenge.title : null,
      challenge_completed: challengeCompleted
    };
  });

  // Calculate XP progress in current level
  let xpCurrentLevel = user.current_xp - levelInfo.minXp;
  if (xpCurrentLevel < 0) xpCurrentLevel = 0;
  const xpLevelRange = (levelInfo.maxXp - levelInfo.minXp) || 100;
  const xpPercent = Math.min(100, Math.round((xpCurrentLevel / xpLevelRange) * 100));

  // Recent activity / next recommended project
  const nextProject = db.prepare(`
    SELECT p.id, p.title, p.category, p.level_required, p.xp_reward, p.difficulty, p.estimated_time
    FROM projects p
    LEFT JOIN user_progress up ON up.item_id = p.id AND up.user_id = ? AND up.status = 'completed'
    WHERE up.status IS NULL AND p.level_required <= ?
    ORDER BY p.level_required ASC, p.order_index ASC
    LIMIT 1
  `).get(userId, user.current_level);

  return {
    user: {
      ...user,
      level_title: levelInfo.title,
      level_theme: levelInfo.theme,
      xp_in_level: xpCurrentLevel,
      xp_for_next_level: levelInfo.maxXp,
      xp_progress_percent: xpPercent,
      completed_projects_count: completedProjects,
      completed_challenges_count: completedChallenges,
      earned_badges_count: user.unlocked_badges.length,
      total_badges_count: allBadges.length
    },
    level_map: levelNodes,
    badges: badgesWithStatus,
    next_recommended_project: nextProject || null
  };
}

// Get All Projects for user
function getAllProjects(userId) {
  const db = getDb();
  const user = getUserById(userId);
  if (!user) throw new Error('User not found');

  const projects = db.prepare(`
    SELECT p.*,
      up.status as user_status,
      up.checklist_state,
      up.completed_steps,
      up.proof_image,
      up.proof_notes,
      up.xp_awarded,
      up.completed_at
    FROM projects p
    LEFT JOIN user_progress up ON up.item_id = p.id AND up.user_id = ?
    ORDER BY p.level_required ASC, p.order_index ASC
  `).all(userId);

  return projects.map(p => {
    const unlockStatus = checkLevelUnlocked(userId, p.level_required);
    let materials = [];
    let steps = [];
    let checklist = [];
    let completedSteps = [];

    try { materials = JSON.parse(p.materials_list || '[]'); } catch (e) {}
    try { steps = JSON.parse(p.steps || '[]'); } catch (e) {}
    try { checklist = JSON.parse(p.checklist_state || '[]'); } catch (e) {}
    try { completedSteps = JSON.parse(p.completed_steps || '[]'); } catch (e) {}

    return {
      id: p.id,
      level_required: p.level_required,
      title: p.title,
      description: p.description,
      category: p.category,
      difficulty: p.difficulty,
      estimated_time: p.estimated_time,
      xp_reward: p.xp_reward,
      badge_reward: p.badge_reward,
      materials_count: materials.length,
      steps_count: steps.length,
      is_unlocked: unlockStatus.unlocked,
      unlock_reason: unlockStatus.reason,
      status: p.user_status || 'not_started',
      materials_gathered_count: checklist.length,
      checklist_state: checklist,
      completed_steps: completedSteps,
      proof_image: p.proof_image,
      proof_notes: p.proof_notes,
      xp_awarded: p.xp_awarded || 0,
      completed_at: p.completed_at
    };
  });
}

// Get Detailed Project View
function getProjectDetails(userId, projectId) {
  const db = getDb();
  const user = getUserById(userId);
  if (!user) throw new Error('User not found');

  const p = db.prepare('SELECT * FROM projects WHERE id = ?').get(projectId);
  if (!p) throw new Error('Project not found');

  const unlockStatus = checkLevelUnlocked(userId, p.level_required);

  const progress = db.prepare(`
    SELECT * FROM user_progress WHERE user_id = ? AND item_id = ?
  `).get(userId, projectId);

  let materials = [];
  let steps = [];
  let checklist = [];
  let completedSteps = [];

  try { materials = JSON.parse(p.materials_list || '[]'); } catch (e) {}
  try { steps = JSON.parse(p.steps || '[]'); } catch (e) {}
  if (progress) {
    try { checklist = JSON.parse(progress.checklist_state || '[]'); } catch (e) {}
    try { completedSteps = JSON.parse(progress.completed_steps || '[]'); } catch (e) {}
  }

  // Look up badge reward details if any
  let badgeRewardDetails = null;
  if (p.badge_reward) {
    badgeRewardDetails = db.prepare('SELECT * FROM badges WHERE id = ?').get(p.badge_reward);
  }

  return {
    id: p.id,
    level_required: p.level_required,
    title: p.title,
    description: p.description,
    category: p.category,
    difficulty: p.difficulty,
    estimated_time: p.estimated_time,
    xp_reward: p.xp_reward,
    badge_reward: badgeRewardDetails,
    materials_list: materials,
    steps: steps,
    is_unlocked: unlockStatus.unlocked,
    unlock_reason: unlockStatus.reason,
    user_progress: {
      status: progress ? progress.status : 'not_started',
      checklist_state: checklist,
      completed_steps: completedSteps,
      proof_image: progress ? progress.proof_image : null,
      proof_notes: progress ? progress.proof_notes : '',
      xp_awarded: progress ? progress.xp_awarded : 0,
      completed_at: progress ? progress.completed_at : null
    }
  };
}

// Update Checklist State
function updateChecklist(userId, projectId, checkedIds) {
  const db = getDb();
  const user = getUserById(userId);
  if (!user) throw new Error('User not found');

  const p = db.prepare('SELECT materials_list FROM projects WHERE id = ?').get(projectId);
  if (!p) throw new Error('Project not found');

  const materials = JSON.parse(p.materials_list || '[]');
  const validIds = new Set(materials.map(m => m.id));
  const sanitizedChecked = (Array.isArray(checkedIds) ? checkedIds : []).filter(id => validIds.has(id));

  const now = new Date().toISOString();
  const existing = db.prepare('SELECT id, status FROM user_progress WHERE user_id = ? AND item_id = ?').get(userId, projectId);

  if (existing) {
    db.prepare(`
      UPDATE user_progress
      SET checklist_state = ?, updated_at = ?
      WHERE id = ?
    `).run(JSON.stringify(sanitizedChecked), now, existing.id);
  } else {
    db.prepare(`
      INSERT INTO user_progress (id, user_id, item_type, item_id, status, checklist_state, completed_steps, score, xp_awarded, updated_at)
      VALUES (?, ?, 'project', ?, 'in_progress', ?, '[]', 0, 0, ?)
    `).run(crypto.randomUUID(), userId, projectId, JSON.stringify(sanitizedChecked), now);
  }

  // Check if student unlocked "Resourceful Gatherer" badge (100% gathered)
  let badgeEarned = null;
  const isAllGathered = materials.length > 0 && sanitizedChecked.length === materials.length;
  if (isAllGathered && !user.unlocked_badges.includes('badge_material_collector')) {
    const updatedBadges = [...user.unlocked_badges, 'badge_material_collector'];
    const badgeBonus = 50;
    const newXp = user.current_xp + badgeBonus;
    db.prepare(`
      UPDATE users SET unlocked_badges = ?, current_xp = ? WHERE id = ?
    `).run(JSON.stringify(updatedBadges), newXp, userId);

    badgeEarned = db.prepare('SELECT * FROM badges WHERE id = ?').get('badge_material_collector');
  }

  return {
    projectId,
    checkedIds: sanitizedChecked,
    totalMaterials: materials.length,
    gatheredCount: sanitizedChecked.length,
    percentComplete: Math.round((sanitizedChecked.length / materials.length) * 100),
    badgeEarned
  };
}

// Toggle Step Completion
function toggleStep(userId, projectId, stepNumber, completed) {
  const db = getDb();
  const existing = db.prepare('SELECT id, completed_steps FROM user_progress WHERE user_id = ? AND item_id = ?').get(userId, projectId);
  const now = new Date().toISOString();

  let completedSteps = [];
  if (existing) {
    try { completedSteps = JSON.parse(existing.completed_steps || '[]'); } catch (e) {}
  }

  const stepNum = Number(stepNumber);
  if (completed) {
    if (!completedSteps.includes(stepNum)) completedSteps.push(stepNum);
  } else {
    completedSteps = completedSteps.filter(s => s !== stepNum);
  }
  completedSteps.sort((a, b) => a - b);

  if (existing) {
    db.prepare(`
      UPDATE user_progress
      SET completed_steps = ?, updated_at = ?
      WHERE id = ?
    `).run(JSON.stringify(completedSteps), now, existing.id);
  } else {
    db.prepare(`
      INSERT INTO user_progress (id, user_id, item_type, item_id, status, checklist_state, completed_steps, score, xp_awarded, updated_at)
      VALUES (?, ?, 'project', ?, 'in_progress', '[]', ?, 0, 0, ?)
    `).run(crypto.randomUUID(), userId, projectId, JSON.stringify(completedSteps), now);
  }

  return { projectId, completedSteps };
}

// Submit Project Proof & Award XP
function submitProjectProof(userId, projectId, proofNotes, proofImage) {
  const db = getDb();
  const user = getUserById(userId);
  if (!user) throw new Error('User not found');

  const p = db.prepare('SELECT * FROM projects WHERE id = ?').get(projectId);
  if (!p) throw new Error('Project not found');

  const unlockStatus = checkLevelUnlocked(userId, p.level_required);
  if (!unlockStatus.unlocked) {
    throw new Error(`Project locked: ${unlockStatus.reason}`);
  }

  const existing = db.prepare('SELECT * FROM user_progress WHERE user_id = ? AND item_id = ?').get(userId, projectId);
  const alreadyCompleted = existing && existing.status === 'completed';

  const now = new Date().toISOString();
  let xpGained = alreadyCompleted ? 0 : p.xp_reward;
  let newBadges = [];

  // Update or insert progress
  if (existing) {
    db.prepare(`
      UPDATE user_progress
      SET status = 'completed', proof_notes = ?, proof_image = ?,
          xp_awarded = ?, completed_at = COALESCE(completed_at, ?), updated_at = ?
      WHERE id = ?
    `).run(
      proofNotes || existing.proof_notes || '',
      proofImage || existing.proof_image || 'project_proof_default.jpg',
      alreadyCompleted ? existing.xp_awarded : xpGained,
      now,
      now,
      existing.id
    );
  } else {
    db.prepare(`
      INSERT INTO user_progress (id, user_id, item_type, item_id, status, checklist_state, completed_steps, proof_image, proof_notes, score, xp_awarded, completed_at, updated_at)
      VALUES (?, ?, 'project', ?, 'completed', '[]', '[]', ?, ?, 100, ?, ?, ?)
    `).run(
      crypto.randomUUID(),
      userId,
      projectId,
      proofImage || 'project_proof_default.jpg',
      proofNotes || '',
      xpGained,
      now,
      now
    );
  }

  // Update user XP & Level
  let newXp = user.current_xp + xpGained;
  let updatedBadges = [...user.unlocked_badges];

  // Check if project has a specific badge reward
  if (p.badge_reward && !updatedBadges.includes(p.badge_reward)) {
    updatedBadges.push(p.badge_reward);
    const badge = db.prepare('SELECT * FROM badges WHERE id = ?').get(p.badge_reward);
    if (badge) {
      newBadges.push(badge);
      newXp += (badge.xp_bonus || 0);
    }
  }

  // Calculate new level based on XP & progression
  let calculatedLevel = user.current_level;
  for (const cfg of LEVEL_CONFIG) {
    if (newXp >= cfg.minXp) {
      calculatedLevel = Math.max(calculatedLevel, cfg.level);
    }
  }

  const leveledUp = calculatedLevel > user.current_level;

  db.prepare(`
    UPDATE users
    SET current_xp = ?, current_level = ?, unlocked_badges = ?, updated_at = ?
    WHERE id = ?
  `).run(newXp, calculatedLevel, JSON.stringify(updatedBadges), now, userId);

  return {
    success: true,
    alreadyCompleted,
    xp_gained: xpGained,
    total_xp: newXp,
    leveled_up: leveledUp,
    new_level: calculatedLevel,
    new_badges: newBadges,
    project_title: p.title
  };
}

// Get All Challenges
function getAllChallenges(userId) {
  const db = getDb();
  const user = getUserById(userId);
  if (!user) throw new Error('User not found');

  const challenges = db.prepare('SELECT * FROM challenges ORDER BY level_required ASC').all();

  return challenges.map(c => {
    const progress = db.prepare(`
      SELECT status, score, xp_awarded, completed_at
      FROM user_progress
      WHERE user_id = ? AND item_id = ?
    `).get(userId, c.id);

    // To unlock challenge, at least one project in that level must be completed
    const completedProjectsCount = db.prepare(`
      SELECT count(*) as count
      FROM projects p
      JOIN user_progress up ON up.item_id = p.id AND up.user_id = ? AND up.status = 'completed'
      WHERE p.level_required = ?
    `).get(userId, c.level_required).count;

    let questions = [];
    try { questions = JSON.parse(c.questions || '[]'); } catch (e) {}

    return {
      id: c.id,
      level_required: c.level_required,
      level_target: c.level_target,
      title: c.title,
      description: c.description,
      category: c.category,
      type: c.type,
      xp_reward: c.xp_reward,
      badge_reward: c.badge_reward,
      questions_count: questions.length,
      is_unlocked: completedProjectsCount > 0,
      unlock_reason: completedProjectsCount > 0 ? 'Unlocked!' : `Complete a project in Level ${c.level_required} to unlock this challenge.`,
      status: progress ? progress.status : 'not_started',
      score: progress ? progress.score : null,
      xp_awarded: progress ? progress.xp_awarded : 0,
      completed_at: progress ? progress.completed_at : null
    };
  });
}

// Get Single Challenge with questions (for quiz runner)
function getChallengeDetails(userId, challengeId) {
  const db = getDb();
  const user = getUserById(userId);
  if (!user) throw new Error('User not found');

  const c = db.prepare('SELECT * FROM challenges WHERE id = ?').get(challengeId);
  if (!c) throw new Error('Challenge not found');

  const progress = db.prepare(`
    SELECT status, score, xp_awarded, completed_at
    FROM user_progress
    WHERE user_id = ? AND item_id = ?
  `).get(userId, challengeId);

  let rawQuestions = [];
  try { rawQuestions = JSON.parse(c.questions || '[]'); } catch (e) {}

  // If already completed, can return answers and explanations; otherwise provide question choices
  const isCompleted = progress && progress.status === 'completed';

  const clientQuestions = rawQuestions.map(q => ({
    id: q.id,
    scenario: q.scenario,
    question: q.question,
    options: q.options,
    topic: q.topic,
    hint: q.hint,
    ...(isCompleted ? {
      correct_index: q.correct_index,
      explanation: q.explanation
    } : {})
  }));

  return {
    id: c.id,
    level_required: c.level_required,
    level_target: c.level_target,
    title: c.title,
    description: c.description,
    category: c.category,
    type: c.type,
    xp_reward: c.xp_reward,
    badge_reward: c.badge_reward,
    questions: clientQuestions,
    is_completed: isCompleted,
    previous_score: progress ? progress.score : null
  };
}

// Submit Challenge Quiz Answers
function submitChallengeQuiz(userId, challengeId, studentAnswers) {
  const db = getDb();
  const user = getUserById(userId);
  if (!user) throw new Error('User not found');

  const c = db.prepare('SELECT * FROM challenges WHERE id = ?').get(challengeId);
  if (!c) throw new Error('Challenge not found');

  const rawQuestions = JSON.parse(c.questions || '[]');
  let correctCount = 0;
  const questionResults = [];

  for (const q of rawQuestions) {
    const studentChoice = Number(studentAnswers[q.id]);
    const isCorrect = studentChoice === q.correct_index;
    if (isCorrect) correctCount++;

    questionResults.push({
      id: q.id,
      topic: q.topic,
      scenario: q.scenario,
      question: q.question,
      options: q.options,
      student_choice: studentChoice,
      correct_index: q.correct_index,
      is_correct: isCorrect,
      explanation: q.explanation
    });
  }

  const totalQuestions = rawQuestions.length || 1;
  const scorePercent = Math.round((correctCount / totalQuestions) * 100);
  const passed = scorePercent >= 65;

  const existing = db.prepare('SELECT * FROM user_progress WHERE user_id = ? AND item_id = ?').get(userId, challengeId);
  const alreadyCompleted = existing && existing.status === 'completed';

  const now = new Date().toISOString();
  let xpGained = (passed && !alreadyCompleted) ? c.xp_reward : 0;
  let newBadges = [];
  let updatedBadges = [...user.unlocked_badges];

  if (passed) {
    // Perfect score badge bonus!
    if (scorePercent === 100 && !updatedBadges.includes('badge_troubleshooter_ace')) {
      updatedBadges.push('badge_troubleshooter_ace');
      const badge = db.prepare('SELECT * FROM badges WHERE id = ?').get('badge_troubleshooter_ace');
      if (badge) {
        newBadges.push(badge);
        xpGained += (badge.xp_bonus || 0);
      }
    }

    if (existing) {
      db.prepare(`
        UPDATE user_progress
        SET status = 'completed', score = ?, xp_awarded = ?, completed_at = COALESCE(completed_at, ?), updated_at = ?
        WHERE id = ?
      `).run(scorePercent, alreadyCompleted ? existing.xp_awarded : xpGained, now, now, existing.id);
    } else {
      db.prepare(`
        INSERT INTO user_progress (id, user_id, item_type, item_id, status, checklist_state, completed_steps, score, xp_awarded, completed_at, updated_at)
        VALUES (?, ?, 'challenge', ?, 'completed', '[]', '[]', ?, ?, ?, ?)
      `).run(crypto.randomUUID(), userId, challengeId, scorePercent, xpGained, now, now);
    }
  }

  let newXp = user.current_xp + xpGained;
  let newLevel = Math.max(user.current_level, passed ? c.level_target : user.current_level);
  const leveledUp = newLevel > user.current_level;

  if (passed) {
    db.prepare(`
      UPDATE users
      SET current_xp = ?, current_level = ?, unlocked_badges = ?, updated_at = ?
      WHERE id = ?
    `).run(newXp, newLevel, JSON.stringify(updatedBadges), now, userId);
  }

  return {
    challenge_id: challengeId,
    passed,
    score: scorePercent,
    correct_count: correctCount,
    total_questions: totalQuestions,
    question_results: questionResults,
    xp_gained: xpGained,
    total_xp: newXp,
    leveled_up: leveledUp,
    new_level: newLevel,
    new_badges: newBadges
  };
}

// Get All Badges
function getAllBadges(userId) {
  const db = getDb();
  const user = getUserById(userId);
  if (!user) throw new Error('User not found');

  const badges = db.prepare('SELECT * FROM badges ORDER BY xp_bonus ASC').all();
  return badges.map(b => ({
    ...b,
    is_unlocked: user.unlocked_badges.includes(b.id)
  }));
}

// Student Capability Analysis & Recommendation Engine
function analyzeStudentCapability({ name, age, email, experience, favoriteInterest }) {
  if (!name || !name.trim()) throw new Error('Student name is required');
  const numAge = parseInt(age, 10) || 10;
  const expStr = experience || 'Intermediate (Lego, crafting & kits)';
  const interestStr = favoriteInterest || 'Speed Racers & Drive Systems';

  let baseScore = 86;
  if (numAge >= 12) baseScore += 8;
  else if (numAge >= 10) baseScore += 5;
  else baseScore += 2;

  if (expStr.includes('Advanced')) baseScore += 6;
  else if (expStr.includes('Intermediate')) baseScore += 3;

  const score = Math.min(99, baseScore);

  let archetype = 'Kinetic Drive Pioneer';
  let archetypeIcon = '🏎️';
  let focusTrack = 'Elastic Potential & Gear Trains';
  let recommendedProjects = [];

  if (interestStr.includes('Racers') || interestStr.includes('Drive')) {
    archetype = 'Kinetic Drive Pioneer';
    archetypeIcon = '🏎️';
    focusTrack = 'Cardboard Chassis & Elastic Torque Mechanics';
    recommendedProjects = [
      {
        title: 'Smooth-Rolling Test Cart with Straw Bearings',
        diff: 'Beginner',
        time: '30 mins',
        desc: 'Precision low-friction axle bushings and zero-wobble wheels.'
      },
      {
        title: 'Rubber-Band Wind-Up Drive Racer',
        diff: 'Beginner',
        time: '35 mins',
        desc: 'Elastic potential energy transfer directly into rear-axle torque.'
      },
      {
        title: '2-Speed Cardboard Gearbox Demonstration',
        diff: 'Intermediate',
        time: '50 mins',
        desc: 'Switchable pitch diameters for torque multiplication vs speed.'
      },
      {
        title: 'Motorized Cardboard Rover Chassis',
        diff: 'Advanced',
        time: '75 mins',
        desc: 'Dual-rail DC drive train powered by 9V circuit and DPDT switch.'
      }
    ];
  } else if (interestStr.includes('Scissor') || interestStr.includes('Lifting')) {
    archetype = 'Kinematic Linkage Architect';
    archetypeIcon = '🏗️';
    focusTrack = 'Mechanical Advantage & Multi-Link Articulation';
    recommendedProjects = [
      {
        title: 'Cardboard Scissor Lift Mechanism',
        diff: 'Beginner',
        time: '35 mins',
        desc: 'Rhombus pantograph linkage converting horizontal compression into vertical lift.'
      },
      {
        title: 'Compound Pulley Crane with Ratchet Brake',
        diff: 'Intermediate',
        time: '45 mins',
        desc: '2:1 mechanical advantage hoist with cardboard pawl anti-drop lock.'
      },
      {
        title: 'Hydraulic/Pneumatic Syringe Arm',
        diff: 'Intermediate',
        time: '60 mins',
        desc: "Pascal's fluid pressure transmission across enclosed tubing."
      },
      {
        title: 'Counter-Weighted Trebuchet Siege Engine',
        diff: 'Advanced',
        time: '70 mins',
        desc: 'Class-1 lever mechanics with adjustable release trajectory angles.'
      }
    ];
  } else if (interestStr.includes('Gripper') || interestStr.includes('Robot')) {
    archetype = 'Bionic Robotics Engineer';
    archetypeIcon = '🦾';
    focusTrack = 'Tendon-Driven End Effectors & Bio-Mechanics';
    recommendedProjects = [
      {
        title: 'Articulated Cardboard Bionic Hand',
        diff: 'Intermediate',
        time: '50 mins',
        desc: 'Tendon string routing through drinking-straw knuckles with elastic spring return.'
      },
      {
        title: 'Dual-Lever Cardboard Claw Gripper',
        diff: 'Beginner',
        time: '35 mins',
        desc: 'Opposed jaw linkage mechanism designed for secure object grasping.'
      },
      {
        title: 'Automated Coin Sorter Machine',
        diff: 'Intermediate',
        time: '40 mins',
        desc: 'Gravity cascading diameter channels with zero electronics.'
      },
      {
        title: 'Servo-Controlled Robotic Cardboard Gripper',
        diff: 'Advanced',
        time: '80 mins',
        desc: 'Microcontroller actuated gripper fingers with tactile grip pads.'
      }
    ];
  } else {
    archetype = 'Gravitational Energy Specialist';
    archetypeIcon = '🎢';
    focusTrack = 'Energy Conservation, Centripetal Force & Incline Friction';
    recommendedProjects = [
      {
        title: 'Gravity-Fed Marble Coaster Run',
        diff: 'Beginner',
        time: '45 mins',
        desc: 'Curved cardboard channel geometry and momentum conservation.'
      },
      {
        title: 'Vertical Loop-the-Loop Velocity Run',
        diff: 'Intermediate',
        time: '50 mins',
        desc: 'Centripetal acceleration threshold calculations and banked rails.'
      },
      {
        title: 'Dual-Funnel Marble Vortex Spiral',
        diff: 'Intermediate',
        time: '55 mins',
        desc: 'Conservation of angular momentum and frictionless exit velocity.'
      },
      {
        title: 'Continuous Archimedes Marble Elevator',
        diff: 'Advanced',
        time: '75 mins',
        desc: 'Continuous mechanical screw lifting marbles back to the apex.'
      }
    ];
  }

  // Record lead in DB if table exists
  try {
    const db = getDb();
    const leadId = `lead_${crypto.randomBytes(6).toString('hex')}`;
    db.prepare(`
      INSERT OR REPLACE INTO leads (id, name, age, email, experience, favorite_interest, archetype, aptitude_score, created_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, datetime('now'))
    `).run(leadId, name.trim(), numAge, email ? email.trim() : '', expStr, interestStr, archetype, score);
  } catch (e) {
    // ignore
  }

  return {
    studentName: name.trim(),
    studentAge: numAge,
    studentEmail: email ? email.trim() : '',
    experienceLevel: expStr,
    favoriteInterest: interestStr,
    archetype,
    archetypeIcon,
    focusTrack,
    aptitudeScore: score,
    stemRank: `Top 4% Indian STEM Engineering Aptitude for Age ${numAge}`,
    recommendedPath: `Level 1 Foundation ➔ ${focusTrack} ➔ Level 3 Micro-Circuits`,
    recommendedProjects,
    planPrice: 199.00,
    currencySymbol: '₹',
    savingsCompare: 'Saves ₹2,500+ compared to imported plastic single-use robot kits'
  };
}

// Dummy Checkout Processor
function processDummyCheckout({ studentName, studentEmail, cardName, cardNumber, promoCode }) {
  const code = (promoCode || '').trim().toUpperCase();
  let discount = 0;
  let finalPrice = 199.00;
  let promoNote = null;

  if (code === 'MAKER100' || code === 'FREE') {
    discount = 199.00;
    finalPrice = 0.00;
    promoNote = '100% Free Cadet Scholarship Applied!';
  } else if (code === 'STEM50') {
    discount = 100.00;
    finalPrice = 99.00;
    promoNote = '50% Student STEM Discount Applied!';
  }

  const passId = `MQ-CADET-${crypto.randomBytes(4).toString('hex').toUpperCase()}`;
  const enrolledAt = new Date().toISOString();

  try {
    const db = getDb();
    db.prepare(`
      INSERT INTO enrollments (id, student_name, student_email, pass_id, final_price, promo_code, card_last4, enrolled_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    `).run(
      `enr_${crypto.randomBytes(6).toString('hex')}`,
      studentName || 'Student Maker',
      studentEmail || 'maker@stem.edu',
      passId,
      finalPrice,
      code || null,
      cardNumber ? cardNumber.slice(-4) : '4242',
      enrolledAt
    );
  } catch (e) {
    // ignore
  }

  return {
    success: true,
    passId,
    studentName: studentName || 'Cadet',
    studentEmail: studentEmail || '',
    finalPrice,
    discount,
    promoNote,
    enrolledAt,
    accessLevel: 'Cadet All-Access Lifetime Pass',
    chaptersUnlocked: 12,
    message: 'Welcome to MakerQuest STEM Academy! Your Cadet Pass is active.'
  };
}

module.exports = {
  LEVEL_CONFIG,
  getLevelInfo,
  checkLevelUnlocked,
  getDashboardData,
  getAllProjects,
  getProjectDetails,
  updateChecklist,
  toggleStep,
  submitProjectProof,
  getAllChallenges,
  getChallengeDetails,
  submitChallengeQuiz,
  getAllBadges,
  analyzeStudentCapability,
  processDummyCheckout
};

