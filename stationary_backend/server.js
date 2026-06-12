const express = require('express');
const cors = require('cors');
require('dotenv').config();

// Waxaan ka keenaynaa pool-ka faylka config/db.js
const pool = require('./src/config/db');

const app = express();

// 🔹 Middleware
app.use(cors({
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(express.json());

// 🔹 Database Connection (Error Handling-ka waxaa lagu xaliyay db.js, 
// halkan waxaan kaliya ku hubineynaa inuu shaqaynayo bilowga)
pool.connect()
    .then(() => console.log('✅ Neon Database-kii wuu ku xirmay si guul leh!'))
    .catch(err => {
        console.error('❌ Khalad ayaa dhacay xiriirka database-ka bilowga:', err.stack);
        // Halkan kama xireyno server-ka (process.exit), 
        // si uu u sii wado isku dayga marka database-ku soo noqdo.
    });

// 🔹 Import Routes
const bookRoutes = require('./src/routes/bookRoutes');
const customerRoutes = require('./src/routes/customerRoutes');
const employeeRoutes = require('./src/routes/employeeRoutes');
const salaryRoutes = require('./src/routes/salary.routes');
const financeRoutes = require('./src/routes/financeRoutes'); 
const authRoutes = require('./src/routes/authRoutes');
const userRoutes = require('./src/routes/userRoutes'); 
const salesRoutes = require('./src/routes/saleRoutes');

// 🔹 Route Endpoints
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

// 🔹 Global Error Handler (Si uu server-ku u "crash"-in haddii wax qaldamaan)
app.use((err, req, res, next) => {
    console.error('❌ Server Error:', err.stack);
    res.status(500).json({ success: false, message: 'Server-ka ayaa cilad yeeshay' });
});

// 🔹 Start Server
const PORT = process.env.PORT || 10000;
app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Server running smoothly on port ${PORT}`);
});