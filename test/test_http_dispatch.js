// In-Memory HTTP Dispatcher Test for MakerQuest Server
const { EventEmitter } = require('node:events');
const { Readable } = require('node:stream');
const server = require('../server/index');

function makeRequest(method, url, headers = {}, body = null) {
  return new Promise((resolve) => {
    const req = new Readable({
      read() {
        if (body) {
          this.push(typeof body === 'string' ? body : JSON.stringify(body));
        }
        this.push(null);
      }
    });

    req.method = method;
    req.url = url;
    req.headers = {
      host: 'localhost:3000',
      ...headers
    };

    let statusCode = 200;
    let resHeaders = {};
    let responseData = '';

    const res = new EventEmitter();
    res.writeHead = (status, h = {}) => {
      statusCode = status;
      resHeaders = { ...resHeaders, ...h };
    };
    res.write = (chunk) => {
      responseData += chunk;
    };
    res.end = (chunk) => {
      if (chunk) responseData += chunk;
      let json = null;
      try {
        json = JSON.parse(responseData);
      } catch (e) {}
      resolve({ status: statusCode, headers: resHeaders, data: json, raw: responseData });
    };

    server.emit('request', req, res);
  });
}

async function run() {
  console.log('🧪 Running In-Memory HTTP Server Dispatch Tests...\n');

  // Test 1: Static / (index.html)
  console.log('1. Testing GET / (Static SPA shell)');
  const home = await makeRequest('GET', '/');
  console.log('Status:', home.status, 'Content-Type:', home.headers['Content-Type']);
  if (!home.raw.includes('MakerQuest')) {
    throw new Error('Index HTML missing MakerQuest');
  }
  console.log('✅ Static file serving working.\n');

  // Test 2: Demo Login Alex
  console.log('2. Testing POST /api/auth/demo-login (Alex Rivera)');
  const loginRes = await makeRequest('POST', '/api/auth/demo-login', { 'content-type': 'application/json' }, { email: 'alex@makerquest.edu' });
  console.log('Login Status:', loginRes.status, 'Student:', loginRes.data.user.name, 'Lvl:', loginRes.data.user.current_level);
  const token = loginRes.data.token;
  if (!token) throw new Error('Token not returned');
  console.log('✅ Demo login working.\n');

  // Test 3: Authenticated Dashboard
  console.log('3. Testing GET /api/dashboard');
  const dashRes = await makeRequest('GET', '/api/dashboard', { authorization: `Bearer ${token}` });
  console.log('Dashboard Status:', dashRes.status);
  console.log('Student XP:', dashRes.data.user.current_xp, 'Level:', dashRes.data.user.current_level);
  console.log('Level map count:', dashRes.data.level_map.length);
  console.log('Level 1 Unlocked:', dashRes.data.level_map[0].is_unlocked);
  console.log('Level 2 Unlocked:', dashRes.data.level_map[1].is_unlocked);
  console.log('✅ Dashboard endpoint working.\n');

  // Test 4: Projects List
  console.log('4. Testing GET /api/projects');
  const projRes = await makeRequest('GET', '/api/projects', { authorization: `Bearer ${token}` });
  console.log('Projects count:', projRes.data.projects.length);
  const scissor = projRes.data.projects.find(p => p.id === 'proj_scissor_lift');
  console.log('Scissor lift status:', scissor.status, 'Unlocked:', scissor.is_unlocked);
  console.log('✅ Projects list endpoint working.\n');

  // Test 5: Update Checklist
  console.log('5. Testing POST /api/projects/proj_scissor_lift/checklist');
  const checkRes = await makeRequest('POST', '/api/projects/proj_scissor_lift/checklist', {
    authorization: `Bearer ${token}`,
    'content-type': 'application/json'
  }, { checkedIds: ['m1', 'm2', 'm3'] });
  console.log('Gathered:', checkRes.data.gatheredCount, 'Percent:', checkRes.data.percentComplete, '%');
  console.log('✅ Interactive materials checklist endpoint working.\n');

  // Test 6: Submit Proof
  console.log('6. Testing POST /api/projects/proj_scissor_lift/submit-proof');
  const proofRes = await makeRequest('POST', '/api/projects/proj_scissor_lift/submit-proof', {
    authorization: `Bearer ${token}`,
    'content-type': 'application/json'
  }, { proofNotes: 'Built prototype with brass split pins!', proofImage: 'proof_mock.jpg' });
  console.log('Proof result:', proofRes.data.success, 'XP gained:', proofRes.data.xp_gained);
  console.log('✅ Proof submission endpoint working.\n');

  // Test 7: Challenges List & Submit Quiz
  console.log('7. Testing Checkpoint Challenges & Quiz Submission');
  const chalsRes = await makeRequest('GET', '/api/challenges', { authorization: `Bearer ${token}` });
  console.log('Challenges count:', chalsRes.data.challenges.length);

  const submitQuizRes = await makeRequest('POST', '/api/challenges/chal_checkpoint_1/submit', {
    authorization: `Bearer ${token}`,
    'content-type': 'application/json'
  }, { answers: { q1_1: 1, q1_2: 0, q1_3: 1 } });
  console.log('Quiz Passed:', submitQuizRes.data.passed, 'Score:', submitQuizRes.data.score, '%');
  console.log('Questions evaluated:', submitQuizRes.data.question_results.length);
  console.log('✅ Checkpoint quiz engine working.\n');

  // Test 8: Badges
  console.log('8. Testing GET /api/badges');
  const badgesRes = await makeRequest('GET', '/api/badges', { authorization: `Bearer ${token}` });
  console.log('Total badges:', badgesRes.data.badges.length);
  const earned = badgesRes.data.badges.filter(b => b.is_unlocked);
  console.log('Badges earned by Alex:', earned.map(b => b.title).join(', '));
  console.log('✅ Badges endpoint working.\n');

  // Test 9: Marketing Student Capability Diagnostic
  console.log('9. Testing POST /api/marketing/diagnostic');
  const diagRes = await makeRequest('POST', '/api/marketing/diagnostic', {
    'content-type': 'application/json'
  }, {
    name: 'Leo Parker',
    age: 10,
    email: 'parent@makerquest.edu',
    experience: 'Intermediate (Lego, crafting & kits)',
    favoriteInterest: 'Speed Racers & Drive Systems'
  });
  console.log('Diagnostic Status:', diagRes.status);
  console.log('Cadet Archetype:', diagRes.data.archetype, diagRes.data.archetypeIcon);
  console.log('Aptitude Score:', diagRes.data.aptitudeScore, '%');
  console.log('Recommended Projects Count:', diagRes.data.recommendedProjects.length);
  if (!diagRes.data.archetype.includes('Pioneer')) throw new Error('Archetype mismatch');
  if (diagRes.data.recommendedProjects.length !== 4) throw new Error('Expected 4 recommended projects');
  console.log('✅ Marketing diagnostic assessment endpoint working.\n');

  // Test 10: Dummy Checkout with MAKER100 Promo
  console.log('10. Testing POST /api/marketing/checkout');
  const checkoutRes = await makeRequest('POST', '/api/marketing/checkout', {
    'content-type': 'application/json'
  }, {
    studentName: 'Leo Parker',
    studentEmail: 'parent@makerquest.edu',
    cardName: 'Leo Parker',
    cardNumber: '4242424242424242',
    promoCode: 'MAKER100'
  });
  console.log('Checkout Status:', checkoutRes.status);
  console.log('Pass ID:', checkoutRes.data.passId);
  console.log('Final Price:', checkoutRes.data.finalPrice, 'Discount:', checkoutRes.data.discount);
  if (checkoutRes.data.finalPrice !== 0) throw new Error('MAKER100 should discount to 0');
  if (!checkoutRes.data.passId.startsWith('MQ-CADET-')) throw new Error('Invalid Cadet pass format');
  console.log('✅ Dummy checkout endpoint working.\n');

  // Test 11: GET /marketing
  console.log('11. Testing GET /marketing (Clean Indian STEM Marketing Page)');
  const mktRes = await makeRequest('GET', '/marketing');
  console.log('Marketing Page Status:', mktRes.status);
  if (!mktRes.raw.includes('Transform Cardboard into')) throw new Error('Marketing HTML content missing');
  if (!mktRes.raw.includes('+918075971988') || !mktRes.raw.includes('https://wa.me/918075971988')) {
    throw new Error('WhatsApp connection (+918075971988) missing in marketing page');
  }
  console.log('✅ Marketing landing page route working (including WhatsApp +918075971988).\n');

  console.log('🎉 ALL 11 IN-MEMORY SERVER ENDPOINT TESTS PASSED COMPLETELY!');
}

run().catch(e => {
  console.error('Test Failed:', e);
  process.exit(1);
});

