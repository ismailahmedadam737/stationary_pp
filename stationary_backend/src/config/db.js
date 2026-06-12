const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false },
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Kani wuxuu ka hortagayaa in server-ku istaago markuu database-ku go'o
pool.on('error', (err) => {
  console.error('❌ Database unexpected error:', err);
});

module.exports = pool;