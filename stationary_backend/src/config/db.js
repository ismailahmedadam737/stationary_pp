const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false },
  max: 20, 
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 5000, // Waxaan ka dhignay 5s si uusan u sugidda u dheeraan
});

// Qaybtan waa muhiim: Waxay qabanaysaa error-ka ku dhaca pool-ka 
// si uusan server-ku u "crash"-in
pool.on('error', (err, client) => {
  console.error('❌ Unexpected error on idle database client', err);
});

module.exports = pool;