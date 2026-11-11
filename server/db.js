// MakerQuest Database Layer using Node.js built-in SQLite (node:sqlite)
const { DatabaseSync } = require('node:sqlite');
const crypto = require('node:crypto');
const path = require('node:path');
const fs = require('node:fs');
const { BADGES, PROJECTS, CHALLENGES, DEMO_USERS } = require('./seed_data');

let dbInstance = null;

function hashPassword(password, salt) {
  return crypto.scryptSync(password, salt, 64).toString('hex');
}

function verifyPassword(password, salt, storedHash) {
  const hash = hashPassword(password, salt);
  return crypto.timingSafeEqual(Buffer.from(hash, 'hex'), Buffer.from(storedHash, 'hex'));
}

function initDb(dbPath = null) {
  if (dbInstance) return dbInstance;

  const targetPath = dbPath || path.join(__dirname, 'makerquest.db');
  const db = new DatabaseSync(targetPath);
  dbInstance = db;

  // Enable WAL and foreign keys
  try {
    db.exec('PRAGMA foreign_keys = ON;');
  } catch (e) {
    // ignore pragma warning if any
  }

  // Create tables
  db.exec(`
    CREATE TABLE IF NOT EXISTS users (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      email TEXT UNIQUE NOT NULL,
      password_hash TEXT NOT NULL,
      salt TEXT NOT NULL,
      avatar TEXT NOT NULL DEFAULT '🚀',
      current_xp INTEGER NOT NULL DEFAULT 0,
      current_level INTEGER NOT NULL DEFAULT 1,
      unlocked_badges TEXT NOT NULL DEFAULT '[]',
      streak_days INTEGER NOT NULL DEFAULT 1,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );

    CREATE TABLE IF NOT EXISTS sessions (
      token TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      created_at TEXT NOT NULL,
      expires_at TEXT NOT NULL,
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    );

    CREATE TABLE IF NOT EXISTS badges (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      description TEXT NOT NULL,
      icon TEXT NOT NULL,
      category TEXT NOT NULL,
      xp_bonus INTEGER NOT NULL DEFAULT 50
    );

    CREATE TABLE IF NOT EXISTS projects (
      id TEXT PRIMARY KEY,
      level_required INTEGER NOT NULL,
      title TEXT NOT NULL,
      description TEXT NOT NULL,
      category TEXT NOT NULL,
      difficulty TEXT NOT NULL,
      estimated_time TEXT NOT NULL,
      xp_reward INTEGER NOT NULL,
      badge_reward TEXT,
      materials_list TEXT NOT NULL,
      steps TEXT NOT NULL,
      order_index INTEGER NOT NULL DEFAULT 1
    );

    CREATE TABLE IF NOT EXISTS challenges (
      id TEXT PRIMARY KEY,
      level_required INTEGER NOT NULL,
      level_target INTEGER NOT NULL,
      title TEXT NOT NULL,
      description TEXT NOT NULL,
      category TEXT NOT NULL,
      type TEXT NOT NULL,
      xp_reward INTEGER NOT NULL,
      badge_reward TEXT,
      questions TEXT NOT NULL
    );

    CREATE TABLE IF NOT EXISTS user_progress (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      item_type TEXT NOT NULL,
      item_id TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'in_progress',
      checklist_state TEXT NOT NULL DEFAULT '[]',
      completed_steps TEXT NOT NULL DEFAULT '[]',
      proof_image TEXT,
      proof_notes TEXT,
      score INTEGER NOT NULL DEFAULT 0,
      xp_awarded INTEGER NOT NULL DEFAULT 0,
      completed_at TEXT,
      updated_at TEXT NOT NULL,
      UNIQUE(user_id, item_type, item_id),
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    );

    CREATE TABLE IF NOT EXISTS leads (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      age INTEGER NOT NULL,
      email TEXT NOT NULL,
      experience TEXT NOT NULL,
      favorite_interest TEXT NOT NULL,
      archetype TEXT NOT NULL,
      aptitude_score INTEGER NOT NULL,
      created_at TEXT NOT NULL
    );

    CREATE TABLE IF NOT EXISTS enrollments (
      id TEXT PRIMARY KEY,
      student_name TEXT NOT NULL,
      student_email TEXT NOT NULL,
      pass_id TEXT NOT NULL,
      final_price REAL NOT NULL,
      promo_code TEXT,
      card_last4 TEXT,
      enrolled_at TEXT NOT NULL
    );
  `);

  seedIfEmpty(db);

  return db;
}

function seedIfEmpty(db) {
  // Check if badges already exist
  const countRow = db.prepare('SELECT count(*) as count FROM badges').get();
  if (countRow && countRow.count > 0) {
    return; // Already seeded
  }

  console.log('[DB] Seeding MakerQuest master badges...');
  const insertBadge = db.prepare(`
    INSERT INTO badges (id, title, description, icon, category, xp_bonus)
    VALUES (?, ?, ?, ?, ?, ?)
  `);
  for (const b of BADGES) {
    insertBadge.run(b.id, b.title, b.description, b.icon, b.category, b.xp_bonus);
  }

  console.log('[DB] Seeding MakerQuest DIY projects...');
  const insertProject = db.prepare(`
    INSERT INTO projects (id, level_required, title, description, category, difficulty, estimated_time, xp_reward, badge_reward, materials_list, steps, order_index)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `);
  for (const p of PROJECTS) {
    insertProject.run(
      p.id,
      p.level_required,
      p.title,
      p.description,
      p.category,
      p.difficulty,
      p.estimated_time,
      p.xp_reward,
      p.badge_reward || null,
      JSON.stringify(p.materials_list),
      JSON.stringify(p.steps),
      p.order_index
    );
  }

  console.log('[DB] Seeding MakerQuest Checkpoint challenges...');
  const insertChallenge = db.prepare(`
    INSERT INTO challenges (id, level_required, level_target, title, description, category, type, xp_reward, badge_reward, questions)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `);
  for (const c of CHALLENGES) {
    insertChallenge.run(
      c.id,
      c.level_required,
      c.level_target,
      c.title,
      c.description,
      c.category,
      c.type,
      c.xp_reward,
      c.badge_reward || null,
      JSON.stringify(c.questions)
    );
  }

  console.log('[DB] Seeding Demo students...');
  const now = new Date().toISOString();
  const insertUser = db.prepare(`
    INSERT INTO users (id, name, email, password_hash, salt, avatar, current_xp, current_level, unlocked_badges, streak_days, created_at, updated_at)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `);
  const insertProgress = db.prepare(`
    INSERT INTO user_progress (id, user_id, item_type, item_id, status, checklist_state, completed_steps, proof_image, proof_notes, score, xp_awarded, completed_at, updated_at)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `);

  for (const u of DEMO_USERS) {
    const salt = crypto.randomBytes(16).toString('hex');
    const hash = hashPassword(u.password, salt);
    insertUser.run(
      u.id,
      u.name,
      u.email,
      hash,
      salt,
      u.avatar,
      u.current_xp,
      u.current_level,
      JSON.stringify(u.unlocked_badges),
      u.streak_days,
      now,
      now
    );

    if (u.progress && u.progress.length > 0) {
      for (const pr of u.progress) {
        insertProgress.run(
          crypto.randomUUID(),
          u.id,
          pr.item_type,
          pr.item_id,
          pr.status,
          JSON.stringify(pr.checklist_state || []),
          JSON.stringify(pr.completed_steps || []),
          pr.proof_image || null,
          pr.proof_notes || '',
          pr.score || 0,
          pr.xp_awarded || 0,
          pr.status === 'completed' ? now : null,
          now
        );
      }
    }
  }

  console.log('[DB] Seeding complete!');
}

function getDb() {
  if (!dbInstance) {
    return initDb();
  }
  return dbInstance;
}

module.exports = {
  initDb,
  getDb,
  hashPassword,
  verifyPassword
};

