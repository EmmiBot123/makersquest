// MakerQuest Full-Stack Server
const http = require('node:http');
const fs = require('node:fs');
const path = require('node:path');
const { initDb } = require('./db');
const { registerUser, loginUser, getUserByToken, logout } = require('./auth');
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
  getAllBadges,
  analyzeStudentCapability,
  processDummyCheckout
} = require('./api');

// Initialize Database on boot
initDb();

const PORT = process.env.PORT || 3000;
const FLUTTER_WEB_DIR = path.join(__dirname, '..', 'build', 'web');
const FALLBACK_PUBLIC_DIR = path.join(__dirname, '..', 'public');

function getPublicDir() {
  return fs.existsSync(path.join(FLUTTER_WEB_DIR, 'index.html'))
    ? FLUTTER_WEB_DIR
    : FALLBACK_PUBLIC_DIR;
}

const MIME_TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.webp': 'image/webp',
  '.wasm': 'application/wasm',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf'
};

function sendJson(res, statusCode, data) {
  res.writeHead(statusCode, {
    'Content-Type': 'application/json; charset=utf-8',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization'
  });
  res.end(JSON.stringify(data));
}

function sendError(res, statusCode, message) {
  sendJson(res, statusCode, { error: message });
}

function parseCookies(req) {
  const list = {};
  const rc = req.headers.cookie;
  if (!rc) return list;
  rc.split(';').forEach(cookie => {
    const parts = cookie.split('=');
    list[parts.shift().trim()] = decodeURI(parts.join('='));
  });
  return list;
}

function extractToken(req) {
  const authHeader = req.headers['authorization'];
  if (authHeader && authHeader.startsWith('Bearer ')) {
    return authHeader.substring(7).trim();
  }
  const cookies = parseCookies(req);
  return cookies['mq_session'] || null;
}

function getAuthUser(req) {
  const token = extractToken(req);
  if (!token) return null;
  return getUserByToken(token);
}

function parseJsonBody(req) {
  return new Promise((resolve, reject) => {
    let body = '';
    req.on('data', chunk => {
      body += chunk.toString();
      if (body.length > 5 * 1024 * 1024) { // 5MB limit
        reject(new Error('Payload too large'));
      }
    });
    req.on('end', () => {
      if (!body) return resolve({});
      try {
        resolve(JSON.parse(body));
      } catch (err) {
        reject(new Error('Invalid JSON payload'));
      }
    });
    req.on('error', reject);
  });
}

function serveStatic(req, res, pathname) {
  let safePath = path.normalize(pathname);
  if (safePath === '/' || safePath === '') {
    safePath = '/index.html';
  }

  const publicDir = getPublicDir();
  const filePath = path.join(publicDir, safePath);

  // Security check: ensure path stays inside publicDir
  if (!filePath.startsWith(publicDir)) {
    res.writeHead(403);
    return res.end('Forbidden');
  }

  fs.stat(filePath, (err, stats) => {
    if (err || !stats.isFile()) {
      // Fallback for SPA routing: serve index.html if file not found and not an API call
      if (!pathname.startsWith('/api')) {
        const indexPath = path.join(publicDir, 'index.html');
        return fs.readFile(indexPath, (readErr, content) => {
          if (readErr) {
            res.writeHead(404);
            return res.end('MakerQuest UI Not Found');
          }
          res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
          res.end(content);
        });
      }
      res.writeHead(404);
      return res.end('Not Found');
    }

    const ext = path.extname(filePath).toLowerCase();
    const contentType = MIME_TYPES[ext] || 'application/octet-stream';

    res.writeHead(200, {
      'Content-Type': contentType,
      'Cache-Control': 'no-cache'
    });
    fs.createReadStream(filePath).pipe(res);
  });
}

const server = http.createServer(async (req, res) => {
  // CORS Preflight
  if (req.method === 'OPTIONS') {
    res.writeHead(204, {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization'
    });
    return res.end();
  }

  const url = new URL(req.url, `http://${req.headers.host || 'localhost'}`);
  const pathname = url.pathname;
  const method = req.method;

  try {
    // -------------------------------------------------------------
    // API: AUTHENTICATION
    // -------------------------------------------------------------
    if (pathname === '/api/auth/register' && method === 'POST') {
      const body = await parseJsonBody(req);
      const result = registerUser(body);
      return sendJson(res, 201, result);
    }

    if (pathname === '/api/auth/login' && method === 'POST') {
      const body = await parseJsonBody(req);
      const result = loginUser(body);
      return sendJson(res, 200, result);
    }

    if (pathname === '/api/auth/demo-login' && method === 'POST') {
      const body = await parseJsonBody(req);
      const email = body.email || 'alex@makerquest.edu';
      const result = loginUser({ email, password: 'maker123' });
      return sendJson(res, 200, result);
    }

    if (pathname === '/api/auth/me' && method === 'GET') {
      const user = getAuthUser(req);
      if (!user) return sendError(res, 401, 'Not authenticated');
      return sendJson(res, 200, { user });
    }

    if (pathname === '/api/auth/logout' && method === 'POST') {
      const token = extractToken(req);
      logout(token);
      return sendJson(res, 200, { success: true });
    }

    // -------------------------------------------------------------
    // API: MARKETING & CAPABILITY ASSESSMENT (PUBLIC)
    // -------------------------------------------------------------
    if (pathname === '/api/marketing/diagnostic' && method === 'POST') {
      const body = await parseJsonBody(req);
      const result = analyzeStudentCapability(body);
      return sendJson(res, 200, result);
    }

    if (pathname === '/api/marketing/checkout' && method === 'POST') {
      const body = await parseJsonBody(req);
      const result = processDummyCheckout(body);
      return sendJson(res, 200, result);
    }

    // Direct /marketing route
    if (pathname === '/marketing' || pathname === '/marketing.html') {
      const marketingFile = path.join(FALLBACK_PUBLIC_DIR, 'marketing.html');
      if (fs.existsSync(marketingFile)) {
        res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
        return fs.createReadStream(marketingFile).pipe(res);
      }
    }

    // -------------------------------------------------------------
    // AUTH GUARD FOR PROTECTED ENDPOINTS
    // -------------------------------------------------------------
    if (pathname.startsWith('/api/')) {
      const user = getAuthUser(req);
      if (!user) {
        return sendError(res, 401, 'Please log in to access your MakerQuest workshop.');
      }

      // GET /api/dashboard
      if (pathname === '/api/dashboard' && method === 'GET') {
        const data = getDashboardData(user.id);
        return sendJson(res, 200, data);
      }

      // GET /api/projects
      if (pathname === '/api/projects' && method === 'GET') {
        const projects = getAllProjects(user.id);
        return sendJson(res, 200, { projects });
      }

      // GET /api/projects/:id
      const projectDetailMatch = pathname.match(/^\/api\/projects\/([a-zA-Z0-9_-]+)$/);
      if (projectDetailMatch && method === 'GET') {
        const projectId = projectDetailMatch[1];
        const project = getProjectDetails(user.id, projectId);
        return sendJson(res, 200, { project });
      }

      // POST /api/projects/:id/checklist
      const checklistMatch = pathname.match(/^\/api\/projects\/([a-zA-Z0-9_-]+)\/checklist$/);
      if (checklistMatch && method === 'POST') {
        const projectId = checklistMatch[1];
        const body = await parseJsonBody(req);
        const result = updateChecklist(user.id, projectId, body.checkedIds || []);
        return sendJson(res, 200, result);
      }

      // POST /api/projects/:id/step-toggle
      const stepMatch = pathname.match(/^\/api\/projects\/([a-zA-Z0-9_-]+)\/step-toggle$/);
      if (stepMatch && method === 'POST') {
        const projectId = stepMatch[1];
        const body = await parseJsonBody(req);
        const result = toggleStep(user.id, projectId, body.stepNumber, !!body.completed);
        return sendJson(res, 200, result);
      }

      // POST /api/projects/:id/submit-proof
      const proofMatch = pathname.match(/^\/api\/projects\/([a-zA-Z0-9_-]+)\/submit-proof$/);
      if (proofMatch && method === 'POST') {
        const projectId = proofMatch[1];
        const body = await parseJsonBody(req);
        const result = submitProjectProof(user.id, projectId, body.proofNotes, body.proofImage);
        return sendJson(res, 200, result);
      }

      // GET /api/challenges
      if (pathname === '/api/challenges' && method === 'GET') {
        const challenges = getAllChallenges(user.id);
        return sendJson(res, 200, { challenges });
      }

      // GET /api/challenges/:id
      const challengeDetailMatch = pathname.match(/^\/api\/challenges\/([a-zA-Z0-9_-]+)$/);
      if (challengeDetailMatch && method === 'GET') {
        const challengeId = challengeDetailMatch[1];
        const challenge = getChallengeDetails(user.id, challengeId);
        return sendJson(res, 200, { challenge });
      }

      // POST /api/challenges/:id/submit
      const challengeSubmitMatch = pathname.match(/^\/api\/challenges\/([a-zA-Z0-9_-]+)\/submit$/);
      if (challengeSubmitMatch && method === 'POST') {
        const challengeId = challengeSubmitMatch[1];
        const body = await parseJsonBody(req);
        const result = submitChallengeQuiz(user.id, challengeId, body.answers || {});
        return sendJson(res, 200, result);
      }

      // GET /api/badges
      if (pathname === '/api/badges' && method === 'GET') {
        const badges = getAllBadges(user.id);
        return sendJson(res, 200, { badges });
      }

      return sendError(res, 404, `API endpoint not found: ${pathname}`);
    }

    // -------------------------------------------------------------
    // STATIC FILE SERVING
    // -------------------------------------------------------------
    serveStatic(req, res, pathname);

  } catch (err) {
    console.error(`[Server Error] ${method} ${pathname}:`, err.message);
    return sendError(res, 400, err.message || 'Internal server error');
  }
});

if (require.main === module) {
  server.listen(PORT, () => {
    console.log(`🚀 MakerQuest Server running at http://localhost:${PORT}`);
  });
}

module.exports = server;
