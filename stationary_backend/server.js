const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
require('dotenv').config();

const app = express();

// 🔹 1. Neon Database Connection
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false }
});

pool.connect()
  .then(() => console.log('✅ Neon Database-kii wuu ku xirmay si guul leh!'))
  .catch(err => console.error('❌ Khalad ayaa dhacay xiriirka database-ka:', err.stack));

// 🔹 2. Middleware
app.use(cors());
app.use(express.json());

// 🔹 3. Import Routes
const bookRoutes = require('./src/routes/bookRoutes');
const customerRoutes = require('./src/routes/customerRoutes');
const employeeRoutes = require('./src/routes/employeeRoutes');
const salaryRoutes = require('./src/routes/salary.routes');
const financeRoutes = require('./src/routes/financeRoutes'); 
const authRoutes = require('./src/routes/authRoutes');
const userRoutes = require('./src/routes/userRoutes'); 
const salesRoutes = require('./src/routes/saleRoutes');

// 🔹 4. Route Endpoints
app.use('/api/books', bookRoutes);
app.use('/api/customers', customerRoutes);
app.use('/api/employees', employeeRoutes);
app.use('/api/salaries', salaryRoutes);
app.use('/api/finance', financeRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/sales', salesRoutes);

// 🔹 5. Root route
app.get('/', (req, res) => {
  res.send('Stationary API Working ✅');
});

// 🔹 6. Start Server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server running smoothly on port ${PORT}`);
});

module.exports = { pool };