const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const { Pool } = require('pg');
const bcrypt = require('bcryptjs');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 5000;

// CORS — allow web app, mobile app, and local dev
const allowedOrigins = [
  'https://calx-three.vercel.app',
  'http://localhost:3000',
  'http://localhost:5173',
  'http://localhost:5000',
];
app.use(cors({
  origin: (origin, callback) => {
    // Allow requests with no origin (e.g. mobile apps, curl, Postman)
    if (!origin) return callback(null, true);
    if (allowedOrigins.includes(origin)) return callback(null, true);
    return callback(null, true); // allow all for now — mobile has no origin header
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));
app.use(express.json());
app.use(morgan('dev'));
app.use(express.static('public'));

// Strip channel_binding from Neon URL if present (causes pg client errors on some versions)
const rawDbUrl = process.env.DATABASE_URL || '';
const cleanDbUrl = rawDbUrl.replace('&channel_binding=require', '').replace('?channel_binding=require', '');

// PostgreSQL Connection Pool Setup
const pool = new Pool({
  connectionString: cleanDbUrl,
  ssl: {
    rejectUnauthorized: false
  },
  // Production-grade pool settings
  max: 10,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 10000,
});

// Database Schema Initialization & Migrations
const initDb = async () => {
  try {
    // Create Users table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        username VARCHAR(50) UNIQUE NOT NULL,
        phone_number VARCHAR(20) NOT NULL,
        email VARCHAR(100) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Run Migrations (to support password and full_name if user has existing table)
    await pool.query(`ALTER TABLE users ADD COLUMN IF NOT EXISTS full_name VARCHAR(100);`);
    await pool.query(`ALTER TABLE users ADD COLUMN IF NOT EXISTS password VARCHAR(255);`);

    // Create Scores table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS scores (
        id SERIAL PRIMARY KEY,
        user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
        player VARCHAR(100) NOT NULL,
        score INTEGER NOT NULL,
        total_questions INTEGER NOT NULL,
        timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Migrate scores table to include duration
    await pool.query(`ALTER TABLE scores ADD COLUMN IF NOT EXISTS duration INTEGER DEFAULT 60;`);

    console.log("✓ Neon PostgreSQL Tables & Migrations Initialized successfully.");
  } catch (err) {
    console.error("✗ Failed to initialize database tables:", err.message);
  }
};

// Run initialization
initDb();

// Routes
app.get('/', (req, res) => {
  res.json({
    name: "Calx Math Trainer API",
    version: "4.0.0",
    status: "Healthy",
    db_connected: true
  });
});

// User Auth APIs

// SIGN UP Endpoint (with full name and password)
app.post('/api/auth/signup', async (req, res) => {
  const { full_name, username, password, phone_number, email } = req.body;

  if (!full_name || !username || !password || !phone_number || !email) {
    return res.status(400).json({ 
      success: false, 
      error: "Full name, username, password, phone number, and email are required." 
    });
  }

  const cleanUsername = username.trim().toLowerCase();

  try {
    // Check if username already exists
    const userCheck = await pool.query('SELECT id FROM users WHERE LOWER(username) = $1', [cleanUsername]);
    if (userCheck.rows.length > 0) {
      return res.status(400).json({ 
        success: false, 
        error: "Username is already taken." 
      });
    }

    // Hash the password
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(password.trim(), saltRounds);

    // Insert new user
    const insertResult = await pool.query(
      'INSERT INTO users (full_name, username, password, phone_number, email) VALUES ($1, $2, $3, $4, $5) RETURNING id, full_name, username, phone_number, email',
      [full_name.trim(), username.trim(), hashedPassword, phone_number.trim(), email.trim()]
    );

    res.status(201).json({
      success: true,
      message: "Sign Up completed successfully!",
      user: insertResult.rows[0]
    });
  } catch (err) {
    console.error("Signup DB Error:", err.message);
    res.status(500).json({ success: false, error: "Internal Server Error during registration." });
  }
});

// SIGN IN Endpoint (with password verification)
app.post('/api/auth/signin', async (req, res) => {
  const { username, password } = req.body;

  if (!username || !password) {
    return res.status(400).json({ 
      success: false, 
      error: "Username and password are required to sign in." 
    });
  }

  const cleanUsername = username.trim().toLowerCase();

  try {
    // Verify user exists
    const userResult = await pool.query('SELECT id, full_name, username, password, phone_number, email FROM users WHERE LOWER(username) = $1', [cleanUsername]);
    
    if (userResult.rows.length === 0) {
      return res.status(404).json({ 
        success: false, 
        error: "User not found. Please sign up first." 
      });
    }

    const dbUser = userResult.rows[0];

    // Check if password exists (older users from prior database states might not have passwords)
    if (!dbUser.password) {
      return res.status(400).json({
        success: false,
        error: "This account was created without a password. Please sign up with a new username."
      });
    }

    // Verify password hash
    const isPasswordValid = await bcrypt.compare(password.trim(), dbUser.password);
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        error: "Invalid username or password."
      });
    }

    delete dbUser.password;

    res.json({
      success: true,
      message: "Sign In completed successfully!",
      user: dbUser
    });
  } catch (err) {
    console.error("Signin DB Error:", err.message);
    res.status(500).json({ success: false, error: "Internal Server Error during authentication." });
  }
});

// GOOGLE Auth Sign-In / Sign-Up
app.post('/api/auth/google', async (req, res) => {
  const { email, name } = req.body;

  if (!email || !name) {
    return res.status(400).json({
      success: false,
      error: "Google user email and name are required."
    });
  }

  const cleanEmail = email.trim().toLowerCase();

  try {
    // Check if user already exists with this email address
    let userResult = await pool.query('SELECT id, full_name, username, phone_number, email FROM users WHERE LOWER(email) = $1', [cleanEmail]);
    
    if (userResult.rows.length > 0) {
      // User exists, return profile session (Sign In)
      return res.json({
        success: true,
        message: "Google Sign In successful!",
        user: userResult.rows[0]
      });
    }

    // Auto-generate unique username from email prefix
    let baseUsername = cleanEmail.split('@')[0].replace(/[^a-zA-Z0-9]/g, '');
    if (baseUsername.length < 3) baseUsername = "user" + Math.floor(Math.random() * 1000);
    
    let finalUsername = baseUsername;
    let isUnique = false;
    let iteration = 0;
    
    while (!isUnique) {
      const checkResult = await pool.query('SELECT id FROM users WHERE LOWER(username) = $1', [finalUsername]);
      if (checkResult.rows.length === 0) {
        isUnique = true;
      } else {
        iteration++;
        finalUsername = baseUsername + iteration;
      }
    }

    const dummyPassword = await bcrypt.hash("google_auth_dummy_pass_" + Math.random(), 10);

    // Create new Google user in DB
    const insertResult = await pool.query(
      'INSERT INTO users (full_name, username, password, phone_number, email) VALUES ($1, $2, $3, $4, $5) RETURNING id, full_name, username, phone_number, email',
      [name.trim(), finalUsername, dummyPassword, "0000000000", cleanEmail]
    );

    res.status(201).json({
      success: true,
      message: "Google Sign Up successful!",
      user: insertResult.rows[0]
    });
  } catch (err) {
    console.error("Google Auth DB Error:", err.message);
    res.status(500).json({ success: false, error: "Internal Server Error during Google Auth." });
  }
});

// Scores Persist APIs

// GET global scoreboard history (flat log list)
app.get('/api/scores', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT s.id, u.username as player, s.score, s.total_questions as "totalQuestions", s.timestamp 
      FROM scores s 
      JOIN users u ON s.user_id = u.id 
      ORDER BY s.timestamp DESC 
      LIMIT 30
    `);
    
    res.json({
      success: true,
      data: result.rows
    });
  } catch (err) {
    console.error("Get scores DB Error:", err.message);
    res.status(500).json({ success: false, error: "Failed to fetch session scores." });
  }
});

// GET speed-based leaderboard (Max APM achieved by each user)
app.get('/api/leaderboard', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        u.username as "username",
        COALESCE(u.full_name, u.username) as "fullName",
        MAX(ROUND((s.score::float / COALESCE(NULLIF(s.duration, 0), 60)) * 60))::int as "maxSpeed"
      FROM scores s
      JOIN users u ON s.user_id = u.id
      WHERE s.score > 0
      GROUP BY u.id, u.username, u.full_name
      ORDER BY "maxSpeed" DESC
      LIMIT 10
    `);
    
    res.json({
      success: true,
      data: result.rows
    });
  } catch (err) {
    console.error("Get leaderboard DB Error:", err.message);
    res.status(500).json({ success: false, error: "Failed to load speed leaderboard." });
  }
});

// POST score run persistence (accepts duration parameter now)
app.post('/api/scores', async (req, res) => {
  const { username, score, totalQuestions, player, duration } = req.body;

  if (score === undefined || totalQuestions === undefined) {
    return res.status(400).json({ 
      success: false, 
      error: "Fields 'score' and 'totalQuestions' are required." 
    });
  }

  const targetUsername = username ? username.trim().toLowerCase() : "guest_mobile_user";
  const runDuration = duration ? parseInt(duration, 10) : 60;

  try {
    // Find or auto-create the user id matching username
    let userResult = await pool.query('SELECT id FROM users WHERE LOWER(username) = $1', [targetUsername]);
    
    if (userResult.rows.length === 0) {
      const dummyPassword = await bcrypt.hash("guest_mobile_pass_123", 10);
      userResult = await pool.query(
        'INSERT INTO users (full_name, username, password, phone_number, email) VALUES ($1, $2, $3, $4, $5) RETURNING id',
        ["Guest Mobile User", targetUsername, dummyPassword, "0000000000", "guest@calx.com"]
      );
    }

    const userId = userResult.rows[0].id;
    const platformLabel = player || "Web Console";

    // Insert score with duration column
    await pool.query(
      'INSERT INTO scores (user_id, player, score, total_questions, duration) VALUES ($1, $2, $3, $4, $5)',
      [userId, platformLabel, parseInt(score, 10), parseInt(totalQuestions, 10), runDuration]
    );

    // Calculate updated community stats
    const statsResult = await pool.query(`
      SELECT 
        COUNT(*)::int as "totalPracticeRuns", 
        COALESCE(AVG(score), 0)::int as "averageScore", 
        COUNT(DISTINCT user_id)::int as "dailyActiveStreaks", 
        COALESCE(SUM(total_questions), 0)::int as "totalAnswersSubmitted" 
      FROM scores
    `);

    res.json({
      success: true,
      message: "Score submitted and stored successfully!",
      currentStats: statsResult.rows[0]
    });
  } catch (err) {
    console.error("Post score DB Error:", err.message);
    res.status(500).json({ success: false, error: "Failed to store practice score." });
  }
});

// GET status overview
app.get('/api/status', async (req, res) => {
  try {
    const statsResult = await pool.query(`
      SELECT 
        COUNT(*)::int as "totalPracticeRuns", 
        COALESCE(AVG(score), 0)::int as "averageScore", 
        COUNT(DISTINCT user_id)::int as "dailyActiveStreaks", 
        COALESCE(SUM(total_questions), 0)::int as "totalAnswersSubmitted" 
      FROM scores
    `);

    res.json({
      success: true,
      data: {
        ...statsResult.rows[0],
        uptime: process.uptime()
      }
    });
  } catch (err) {
    console.error("Get status DB Error:", err.message);
    res.status(500).json({ success: false, error: "Failed to calculate statistics." });
  }
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ success: false, error: 'Internal Server Error' });
});

// Start Server
app.listen(PORT, () => {
  console.log(`===========================================`);
  console.log(` Calx DB Express Server Active             `);
  console.log(` Listening on Port: ${PORT}                `);
  console.log(` Connecting to: Neon Cloud PostgreSQL     `);
  console.log(`===========================================`);

  // Self-ping every 14 minutes to prevent Render free-tier cold starts
  // Render spins down free dynos after 15 minutes of inactivity
  const SELF_URL = process.env.RENDER_EXTERNAL_URL || `http://localhost:${PORT}`;
  setInterval(async () => {
    try {
      const https = require('https');
      const http = require('http');
      const client = SELF_URL.startsWith('https') ? https : http;
      client.get(`${SELF_URL}/`, (res) => {
        console.log(`[KeepAlive] Self-ping OK — status ${res.statusCode}`);
      }).on('error', (e) => {
        console.warn('[KeepAlive] Self-ping failed:', e.message);
      });
    } catch (e) {
      console.warn('[KeepAlive] Error:', e.message);
    }
  }, 14 * 60 * 1000); // every 14 minutes
});
