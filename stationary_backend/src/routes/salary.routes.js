const express = require('express');
const router = express.Router();
const salaryController = require('../controllers/salary.controller');

// Post: http://localhost:3000/api/salaries/pay
router.post('/pay', salaryController.processPayment);

// Get: http://localhost:3000/api/salaries/history
router.get('/history', salaryController.getHistory);

module.exports = router;