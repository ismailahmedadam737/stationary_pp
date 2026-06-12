const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
require('dotenv').config();

const app = express();

// 🔹 Neon Database Connection Pool
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false }
});

// Middleware
app.use(cors());
app.use(express.json());

// 🔹 Import routes
// FIIRO GAAR AH: Waxaan routes-ka halkan u soo dhoofinaynaa
const bookRoutes = require('./src/routes/bookRoutes');
const customerRoutes = require('./src/routes/customerRoutes');
const employeeRoutes = require('./src/routes/employeeRoutes');
const salaryRoutes = require('./src/routes/salary.routes');
const financeRoutes = require('./src/routes/financeRoutes'); 
const authRoutes = require('./src/routes/authRoutes');
const userRoutes = require('./src/routes/userRoutes'); 
const salesRoutes = require('./src/routes/saleRoutes');

// 🔹 Routes Endpoints
// Hubi in mid kasta oo ka mid ah faylalkan uu leeyahay 'module.exports = router;'
app.use('/api/books', bookRoutes);
app.use('/api/customers', customerRoutes);
app.use('/api/employees', employeeRoutes);
app.use('/api/salaries', salaryRoutes);
app.use('/api/finance', financeRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/sales', salesRoutes);

// Root route
app.get('/', (req, res) => {
  res.send('Stationary API Working ✅');
});

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server running smoothly on port ${PORT}`);
});

module.exports = { pool };