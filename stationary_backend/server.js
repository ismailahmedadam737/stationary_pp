const express = require('express');
const cors = require('cors');
const { Pool } = require('pg'); // 👈 Maktabadda database-ka
require('dotenv').config();

const app = express();

// 🔹 Neon Database Connection Pool
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false // Muhiim u ah Neon PostgreSQL (haddii server-ku u baahdo)
  }
});

// Tijaabinta xiriirka database-ka
pool.connect()
  .then(() => console.log('✅ Neon Database-kii wuu ku xirmay si guul leh!'))
  .catch(err => console.error('❌ Khalad ayaa dhacay xiriirka database-ka:', err.stack));

// 🔹 Middleware
app.use(cors());
app.use(express.json());

// 🔹 Import routes
const bookRoutes = require('./src/routes/bookRoutes');
const customerRoutes = require('./src/routes/customerRoutes');
const employeeRoutes = require('./src/routes/employeeRoutes');
const salaryRoutes = require('./src/routes/salary.routes');
const financeRoutes = require('./src/routes/financeRoutes'); 
const authRoutes = require('./src/routes/authRoutes');
const userRoutes = require('./src/routes/userRoutes'); 
const salesRoutes = require('./src/routes/saleRoutes');

// 🔹 Routes Endpoints
app.use('/api/books', bookRoutes);
app.use('/api/customers', customerRoutes);
app.use('/api/employees', employeeRoutes);
app.use('/api/salaries', salaryRoutes);
app.use('/api/finance', financeRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/sales', salesRoutes);

// 🔹 Root route
app.get('/', (req, res) => {
  res.send('Stationary API Working ✅');
});

// 🔹 Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server running smoothly on port ${PORT}`);
});

// Export pool-ka si aad ugu isticmaasho route-yadaada kale
module.exports = { pool };