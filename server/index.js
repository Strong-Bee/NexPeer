import express from 'express';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import admin from 'firebase-admin';
import { openDatabase } from './src/database.js';

if (!admin.apps.length) admin.initializeApp();
const db = openDatabase(process.env.SQLITE_PATH || './data/nexpeer.sqlite');
const app = express();
app.disable('x-powered-by');
app.use(helmet());
app.use(express.json({ limit: '32kb' }));
app.use(rateLimit({ windowMs: 60000, limit: 120, standardHeaders: 'draft-7', legacyHeaders: false }));

app.get('/health', (_req, res) => res.json({ status: 'ok' }));
app.use('/v1', async (req, res, next) => {
  try {
    const header = req.header('authorization') || '';
    const token = header.startsWith('Bearer ') ? header.slice(7) : '';
    if (!token) return res.status(401).json({ error: 'Authentication required.' });
    req.user = await admin.auth().verifyIdToken(token);
    next();
  } catch {
    res.status(401).json({ error: 'Invalid or expired authentication token.' });
  }
});

const profileColumns = 'uid, username, display_name AS displayName, photo_url AS photoUrl';
const profile = row => row ? ({
  uid: row.uid, username: row.username,
  displayName: row.displayName, photoUrl: row.photoUrl ?? null
}) : null;

app.get('/v1/me', (req, res) => {
  const row = db.prepare('SELECT ' + profileColumns + ' FROM users WHERE uid = ?').get(req.user.uid);
  if (!row) return res.status(404).json({ error: 'Profile not found.' });
  res.json({ profile: profile(row) });
});

app.post('/v1/me', (req, res) => {
  const displayName = String(req.body.displayName || 'NexPeer User').trim().slice(0, 80);
  const photoUrl = typeof req.body.photoUrl === 'string' ? req.body.photoUrl.slice(0, 2048) : null;
  const requested = typeof req.body.username === 'string'
    ? req.body.username.trim().replace(/^@/, '').toLowerCase() : null;
  try {
    const save = db.transaction(() => {
      const existing = db.prepare('SELECT uid, username FROM users WHERE uid = ?').get(req.user.uid);
      if (existing) {
        if (requested && requested !== existing.username) {
          const error = new Error('Username cannot be changed through profile provisioning.');
          error.status = 409; throw error;
        }
        db.prepare('UPDATE users SET display_name = ?, photo_url = ?, updated_at = CURRENT_TIMESTAMP WHERE uid = ?')
          .run(displayName, photoUrl, req.user.uid);
      } else {
        const username = requested || ('user_' + req.user.uid.slice(0, 8));
        if (!/^[a-z0-9_]{3,24}$/.test(username)) {
          const error = new Error('Username must be 3-24 lowercase letters, numbers, or underscores.');
          error.status = 400; throw error;
        }
        if (db.prepare('SELECT uid FROM users WHERE username = ?').get(username)) {
          const error = new Error('Username already in use.'); error.status = 409; throw error;
        }
        db.prepare('INSERT INTO users (uid, username, display_name, photo_url) VALUES (?, ?, ?, ?)')
          .run(req.user.uid, username, displayName, photoUrl);
      }
      return db.prepare('SELECT ' + profileColumns + ' FROM users WHERE uid = ?').get(req.user.uid);
    });
    res.json({ profile: profile(save()) });
  } catch (error) {
    res.status(error.status || 500).json({ error: error.status ? error.message : 'Could not save profile.' });
  }
});

app.get('/v1/users/:identifier', (req, res) => {
  const id = req.params.identifier;
  const row = id.startsWith('np_')
    ? db.prepare('SELECT ' + profileColumns + ' FROM users WHERE uid = ?').get(id.slice(3))
    : db.prepare('SELECT ' + profileColumns + ' FROM users WHERE username = ?').get(id.replace(/^@/, '').toLowerCase());
  if (!row) return res.status(404).json({ error: 'NexPeer account not found.' });
  res.json({ profile: profile(row) });
});

app.get('/v1/contacts', (req, res) => {
  const contacts = db.prepare(`
    SELECT u.uid, u.username, u.display_name AS displayName, u.photo_url AS photoUrl,
           c.created_at AS addedAt
    FROM contacts c JOIN users u ON u.uid = c.contact_uid
    WHERE c.owner_uid = ? ORDER BY u.display_name COLLATE NOCASE
  `).all(req.user.uid);
  res.json({ contacts });
});

app.post('/v1/contacts', (req, res) => {
  const contactUid = String(req.body.contactUid || '');
  if (!contactUid || contactUid === req.user.uid) return res.status(400).json({ error: 'Invalid contact account.' });
  const contact = db.prepare('SELECT ' + profileColumns + ' FROM users WHERE uid = ?').get(contactUid);
  if (!contact) return res.status(404).json({ error: 'NexPeer account not found.' });
  db.prepare('INSERT OR IGNORE INTO contacts (owner_uid, contact_uid) VALUES (?, ?)')
    .run(req.user.uid, contactUid);
  res.status(201).json({ contact: { ...profile(contact), addedAt: new Date().toISOString() } });
});

app.use((error, _req, res, _next) => {
  console.error(error);
  res.status(500).json({ error: 'Internal server error.' });
});
const port = Number(process.env.PORT || 8080);
app.listen(port, '0.0.0.0', () => console.log('NexPeer SQLite API listening on ' + port));