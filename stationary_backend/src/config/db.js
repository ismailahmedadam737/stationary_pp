const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false // Tani waxay xallinaysaa dhibaatada SSL ee Neon/Render
  },
  max: 20, // Tirada ugu badan ee connections-ka
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Waxaan ku darnaa hubin yar si aan u ogaano haddii uu pool-ku shaqaynayo
pool.on('error', (err) => {
  console.error('❌ Unexpected error on idle client', err);
});

module.exports = pool;