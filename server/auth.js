// MakerQuest Authentication and Session Management
const crypto = require('node:crypto');
const { getDb, hashPassword, verifyPassword } = require('./db');

const SESSION_TTL_MS = 30 * 24 * 60 * 60 * 1000; // 30 days

function registerUser({ name, email, password, avatar = '🚀' }) {
  const db = getDb();

  if (!name || name.trim().length < 2) {
    throw new Error('Name must be at least 2 characters long.');
  }
  if (!email || !email.includes('@')) {
    throw new Error('Please enter a valid student email address.');
  }
  if (!password || password.length < 4) {
    throw new Error('Password must be at least 4 characters long.');
  }

  const normalizedEmail = email.trim().toLowerCase();

  // Check if email already exists
  const existing = db.prepare('SELECT id FROM users WHERE email = ?').get(normalizedEmail);
  if (existing) {
    throw new Error('An account with this email already exists.');
  }

  const userId = 'usr_' + crypto.randomUUID();
  const salt = crypto.randomBytes(16).toString('hex');
  const passwordHash = hashPassword(password, salt);
  const now = new Date().toISOString();

  // New students start with "First Spark" badge and 50 XP bonus!
  const initialBadges = ['badge_first_spark'];
  const initialXp = 50;

  db.prepare(`
    INSERT INTO users (id, name, email, password_hash, salt, avatar, current_xp, current_level, unlocked_badges, streak_days, created_at, updated_at)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `).run(
    userId,
    name.trim(),
    normalizedEmail,
    passwordHash,
    salt,
    avatar || '🚀',
    initialXp,
    1,
    JSON.stringify(initialBadges),
    1,
    now,
    now
  );

  const session = createSession(userId);
  const user = getUserById(userId);

  return { user, token: session.token };
}

function loginUser({ email, password }) {
  const db = getDb();

  if (!email || !password) {
    throw new Error('Email and password are required.');
  }

  const normalizedEmail = email.trim().toLowerCase();
  const row = db.prepare('SELECT * FROM users WHERE email = ?').get(normalizedEmail);

  if (!row) {
    throw new Error('Invalid email or password.');
  }

  const isValid = verifyPassword(password, row.salt, row.password_hash);
  if (!isValid) {
    throw new Error('Invalid email or password.');
  }

  const session = createSession(row.id);
  const user = formatUser(row);

  return { user, token: session.token };
}

function createSession(userId) {
  const db = getDb();
  const token = crypto.randomBytes(32).toString('hex');
  const now = new Date();
  const expires = new Date(now.getTime() + SESSION_TTL_MS);

  db.prepare(`
    INSERT INTO sessions (token, user_id, created_at, expires_at)
    VALUES (?, ?, ?, ?)
  `).run(token, userId, now.toISOString(), expires.toISOString());

  return { token, expiresAt: expires.toISOString() };
}

function getUserByToken(token) {
  if (!token) return null;
  const db = getDb();

  const session = db.prepare(`
    SELECT s.user_id, s.expires_at, u.*
    FROM sessions s
    JOIN users u ON s.user_id = u.id
    WHERE s.token = ?
  `).get(token);

  if (!session) return null;

  if (new Date(session.expires_at) < new Date()) {
    // Session expired
    db.prepare('DELETE FROM sessions WHERE token = ?').run(token);
    return null;
  }

  return formatUser(session);
}

function getUserById(userId) {
  const db = getDb();
  const row = db.prepare('SELECT * FROM users WHERE id = ?').get(userId);
  if (!row) return null;
  return formatUser(row);
}

function formatUser(row) {
  let badges = [];
  try {
    badges = JSON.parse(row.unlocked_badges || '[]');
  } catch (e) {
    badges = [];
  }

  return {
    id: row.id,
    name: row.name,
    email: row.email,
    avatar: row.avatar || '🚀',
    current_xp: Number(row.current_xp) || 0,
    current_level: Number(row.current_level) || 1,
    unlocked_badges: badges,
    streak_days: Number(row.streak_days) || 1,
    created_at: row.created_at
  };
}

function logout(token) {
  if (!token) return;
  const db = getDb();
  db.prepare('DELETE FROM sessions WHERE token = ?').run(token);
}

module.exports = {
  registerUser,
  loginUser,
  getUserByToken,
  getUserById,
  logout
};

