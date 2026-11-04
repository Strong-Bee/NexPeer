import Database from 'better-sqlite3';
import fs from 'node:fs';
import path from 'node:path';

export function openDatabase(filename) {
  const absolute = path.resolve(filename);
  fs.mkdirSync(path.dirname(absolute), { recursive: true });
  const db = new Database(absolute);
  db.pragma('journal_mode = WAL');
  db.pragma('foreign_keys = ON');
  db.exec(`
    CREATE TABLE IF NOT EXISTS users (
      uid TEXT PRIMARY KEY,
      username TEXT NOT NULL UNIQUE COLLATE NOCASE,
      display_name TEXT NOT NULL,
      photo_url TEXT,
      created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
      updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
    );
    CREATE TABLE IF NOT EXISTS contacts (
      owner_uid TEXT NOT NULL REFERENCES users(uid) ON DELETE CASCADE,
      contact_uid TEXT NOT NULL REFERENCES users(uid) ON DELETE CASCADE,
      created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (owner_uid, contact_uid),
      CHECK (owner_uid <> contact_uid)
    );
    CREATE INDEX IF NOT EXISTS idx_users_username ON users(username COLLATE NOCASE);
    CREATE INDEX IF NOT EXISTS idx_contacts_owner ON contacts(owner_uid);
  `);
  return db;
}