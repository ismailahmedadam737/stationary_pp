const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();

// 🔹 Import routes
const bookRoutes = require('./src/routes/bookRoutes');
const customerRoutes = require('./src/routes/customerRoutes');
const employeeRoutes = require('./src/routes/employeeRoutes');
const salaryRoutes = require('./src/routes/salary.routes');
const financeRoutes = require('./src/routes/financeRoutes'); 
const authRoutes = require('./src/routes/authRoutes');
const userRoutes = require('./src/routes/userRoutes'); 
const salesRoutes = require('./src/routes/saleRoutes'); // 👈 Qaybta Iibka

// 🔹 Middleware
app.use(cors());
app.use(express.json());

// 🔹 Routes
app.use('/api/books', bookRoutes);
app.use('/api/customers', customerRoutes);
app.use('/api/employees', employeeRoutes);
app.use('/api/salaries', salaryRoutes);
app.use('/api/finance', financeRoutes); 
app.use('/api/auth', authRoutes); 
app.use('/api/users', userRoutes); 
app.use('/api/sales', salesRoutes); // 👈 Endpoint-ka rasmiga ah ee Iibka

// 🔹 Root route (test)
app.get('/', (req, res) => {
  res.send('Stationary API Working ✅');
});

// 🔹 Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});