const { Pool } = require('pg');
require('dotenv').config();

// Abuuritaanka pool-ka oo kaliya
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false // Waxaa loogu talagalay Neon/Render
  },
  max: 20, 
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 5000, 
});

// Hubinta inuu xiriirku shaqaynayo marka server-ku bilaabmo
pool.on('connect', () => {
  console.log('✅ Database-ku wuu ku xirmay si guul leh!');
});

pool.on('error', (err) => {
  console.error('❌ Unexpected error on idle client', err);
});

// Kaliya u dhoofi pool-ka, wax kale ha u dhoofin
module.exports = pool;