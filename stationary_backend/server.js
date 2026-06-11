const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();

// 🔹 Import routes (Soo dejinta Jidadka API-yada)
const bookRoutes = require('./src/routes/bookRoutes');
const customerRoutes = require('./src/routes/customerRoutes');
const employeeRoutes = require('./src/routes/employeeRoutes');
const salaryRoutes = require('./src/routes/salary.routes');
const financeRoutes = require('./src/routes/financeRoutes'); 
const authRoutes = require('./src/routes/authRoutes');
const userRoutes = require('./src/routes/userRoutes'); 
const salesRoutes = require('./src/routes/saleRoutes'); // 👈 Qaybta Iibka (Sales)

// 🔹 Middleware (Wada-xiriirka iyo Akhriska Data-da)
app.use(cors()); // Wuxuu u oggolaanayaa Flutter Web/Mobile inuu la xiriiro backend-ka
app.use(express.json()); // Wuxuu u oggolaanayaa API-ga inuu akhriyo JSON data

// 🔹 Routes Endpoints (Wadooyinka rasmiga ah ee API-ga)
app.use('/api/books', bookRoutes);           // GET & POST Books
app.use('/api/customers', customerRoutes);   // Customer Management
app.use('/api/employees', employeeRoutes);   // Employee Management
app.use('/api/salaries', salaryRoutes);       // Salary Processing
app.use('/api/finance', financeRoutes);       // Income & Expenses Dashboard
app.use('/api/auth', authRoutes);             // Login & Register Authentication
app.use('/api/users', userRoutes);             // User Profile Management
app.use('/api/sales', salesRoutes);           // 👈 Endpoint-ka rasmiga ah ee Iibka (Sales Control)

// 🔹 Root route (Tijaabada inuu server-ku nool yahay)
app.get('/', (req, res) => {
  res.send('Stationary API Working ✅');
});

// 🔹 Start server (Bilaabista Server-ka)
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server running smoothly on port ${PORT}`);
});