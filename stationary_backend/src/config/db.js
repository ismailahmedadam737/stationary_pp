const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false },
  // Ku dar xiriirka in la hubiyo (keep-alive)
  max: 10,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 10000,
});

// Kani waa furaha xallinta "Connection terminated"
pool.on('error', (err, client) => {
  console.error('❌ Database connection error:', err);
  // Ha xirin server-ka, u oggolow inuu isku dayo mar kale
});

module.exports = pool;