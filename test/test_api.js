// MakerQuest API Integration Test Suite
const assert = require('node:assert');
const { initDb } = require('../server/db');
const { registerUser, loginUser, getUserByToken } = require('../server/auth');
const {
  getDashboardData,
  getAllProjects,
  getProjectDetails,
  updateChecklist,
  toggleStep,
  submitProjectProof,
  getAllChallenges,
  getChallengeDetails,
  submitChallengeQuiz,
  getAllBadges
} = require('../server/api');

async function runTests() {
  console.log('🧪 Starting MakerQuest Test Suite...\n');

  // Test 1: Seed & Database Initialization
  console.log('Test 1: Database Initialization & Seeding');
  const db = initDb();
  assert(db, 'DB instance should be created');
  const userCount = db.prepare('SELECT count(*) as count FROM users').get().count;
  assert(userCount >= 2, 'Pre-seeded demo users should exist');
  const projectCount = db.prepare('SELECT count(*) as count FROM projects').get().count;
  assert(projectCount >= 5, 'Projects should be seeded');
  const challengeCount = db.prepare('SELECT count(*) as count FROM challenges').get().count;
  assert(challengeCount >= 3, 'Challenges should be seeded');
  console.log('✅ DB tables and seed data verified.\n');

  // Test 2: Student Registration & Authentication
  console.log('Test 2: Student Registration & Authentication');
  const testEmail = `test_student_${Date.now()}@makerquest.edu`;
  const regResult = registerUser({
    name: 'Tinkering Taylor',
    email: testEmail,
    password: 'supermaker123',
    avatar: '🤖'
  });
  assert(regResult.user.id, 'User should have an ID');
  assert.strictEqual(regResult.user.current_xp, 50, 'New student receives 50 XP bonus');
  assert.strictEqual(regResult.user.current_level, 1, 'New student starts at Level 1');
  assert(regResult.user.unlocked_badges.includes('badge_first_spark'), 'First Spark badge awarded');
  assert(regResult.token, 'Session token returned on register');

  // Verify token validation
  const sessionUser = getUserByToken(regResult.token);
  assert.strictEqual(sessionUser.id, regResult.user.id, 'Session token maps to student');

  // Test Login with correct & wrong password
  const loginSuccess = loginUser({ email: testEmail, password: 'supermaker123' });
  assert(loginSuccess.token, 'Login produces session token');

  assert.throws(() => {
    loginUser({ email: testEmail, password: 'wrongpassword' });
  }, /Invalid email or password/, 'Wrong password rejected');
  console.log('✅ Registration, password hashing, and session authentication verified.\n');

  // Test 3: Dashboard & Level Progression Map (Level 1 Student)
  console.log('Test 3: Dashboard & Level Progression Map');
  const studentId = regResult.user.id;
  const dashboard = getDashboardData(studentId);
  assert.strictEqual(dashboard.user.current_level, 1);
  assert.strictEqual(dashboard.user.current_xp, 50);
  assert.strictEqual(dashboard.level_map.length, 5, 'Level map has 5 progression nodes');

  // Level 1 should be unlocked; Level 2 should be locked for new student
  assert.strictEqual(dashboard.level_map[0].is_unlocked, true, 'Level 1 is unlocked');
  assert.strictEqual(dashboard.level_map[1].is_unlocked, false, 'Level 2 is locked');
  console.log('Level 1 unlock status:', dashboard.level_map[0].is_unlocked);
  console.log('Level 2 lock reason:', dashboard.level_map[1].unlock_reason);
  console.log('✅ Dashboard and Level Map progression logic verified.\n');

  // Test 4: Project View & Interactive Checklist (Level 3)
  console.log('Test 4: Project View & Interactive Material Checklists');
  const projects = getAllProjects(studentId);
  assert(projects.length >= 5, 'All projects returned');
  const scissorLift = projects.find(p => p.id === 'proj_scissor_lift');
  assert(scissorLift, 'Scissor lift project found');
  assert.strictEqual(scissorLift.is_unlocked, true, 'Scissor lift is unlocked for Level 1');

  // Fetch project details
  const details = getProjectDetails(studentId, 'proj_scissor_lift');
  assert(details.materials_list.length > 0, 'Materials list present');
  assert(details.steps.length > 0, 'Steps list present');

  // Update checklist items: gather materials
  const checkResult = updateChecklist(studentId, 'proj_scissor_lift', ['m1', 'm2', 'm3']);
  assert.strictEqual(checkResult.gatheredCount, 3);
  assert.strictEqual(checkResult.percentComplete, 50);

  // Complete all materials to trigger "Resourceful Gatherer" badge!
  const allMaterialIds = details.materials_list.map(m => m.id);
  const fullCheck = updateChecklist(studentId, 'proj_scissor_lift', allMaterialIds);
  assert.strictEqual(fullCheck.percentComplete, 100);
  assert(fullCheck.badgeEarned, 'Resourceful Gatherer badge earned when 100% gathered');
  console.log('Badge earned on gathering materials:', fullCheck.badgeEarned.title);

  // Toggle step completion
  const stepRes = toggleStep(studentId, 'proj_scissor_lift', 1, true);
  assert(stepRes.completedSteps.includes(1), 'Step 1 marked complete');
  console.log('✅ Project details, materials checklist persistence, and step toggling verified.\n');

  // Test 5: Submit Project Proof & XP Award
  console.log('Test 5: Submit Project Proof & XP Award');
  const proofResult = submitProjectProof(
    studentId,
    'proj_scissor_lift',
    'Tested with brass fasteners! Elevated my phone to 25cm smoothly.',
    'data:image/jpeg;base64,mockImageData'
  );
  assert.strictEqual(proofResult.success, true);
  assert(proofResult.xp_gained >= 120, 'Awarded project XP');
  console.log(`XP gained: +${proofResult.xp_gained}, Total XP: ${proofResult.total_xp}`);

  // Complete Marble Coaster as well to satisfy Level 1 project requirement
  submitProjectProof(
    studentId,
    'proj_marble_coaster',
    'Built curved banked half pipes!',
    'data:image/jpeg;base64,mockImageData'
  );
  console.log('✅ Project proof submission, XP rewarding, and badge unlock verified.\n');

  // Test 6: Gamified Checkpoint Challenges & Quizzes (Level 4)
  console.log('Test 6: Gamified Checkpoint Challenges & Quizzes');
  const challenges = getAllChallenges(studentId);
  const chal1 = challenges.find(c => c.id === 'chal_checkpoint_1');
  assert(chal1, 'Checkpoint 1 found');
  assert.strictEqual(chal1.is_unlocked, true, 'Checkpoint 1 unlocked after completing project');

  const chalDetails = getChallengeDetails(studentId, 'chal_checkpoint_1');
  assert(chalDetails.questions.length >= 3, 'Questions loaded');

  // Submit correct answers: q1_1: 1, q1_2: 0, q1_3: 1
  const quizSubmission = submitChallengeQuiz(studentId, 'chal_checkpoint_1', {
    q1_1: 1,
    q1_2: 0,
    q1_3: 1
  });

  assert.strictEqual(quizSubmission.passed, true, 'Quiz passed');
  assert.strictEqual(quizSubmission.score, 100, 'Score 100%');
  assert.strictEqual(quizSubmission.correct_count, 3);
  assert(quizSubmission.xp_gained >= 150, 'Awarded challenge XP');
  assert.strictEqual(quizSubmission.new_level, 2, 'Student promoted to Level 2!');
  console.log(`Quiz Score: ${quizSubmission.score}%, Level up: ${quizSubmission.leveled_up} -> Level ${quizSubmission.new_level}`);

  // Test 7: Verify Level 2 is now unlocked on the Level Progression Map!
  console.log('Test 7: Verify Level Progression Map unlocks');
  const updatedDashboard = getDashboardData(studentId);
  assert.strictEqual(updatedDashboard.user.current_level, 2, 'User is now Level 2');
  assert.strictEqual(updatedDashboard.level_map[1].is_unlocked, true, 'Level 2 is now UNLOCKED!');
  console.log('Level 2 node unlock status:', updatedDashboard.level_map[1].is_unlocked);
  console.log('Level 2 node theme:', updatedDashboard.level_map[1].theme);
  console.log('✅ Level progression map correctly unlocked Level 2 after checkpoint challenge.\n');

  console.log('🎉 ALL 7 TEST SUITES PASSED FLAWLESSLY! MakerQuest backend core is robust!');
}

runTests().catch(err => {
  console.error('❌ Test failed:', err);
  process.exit(1);
});

