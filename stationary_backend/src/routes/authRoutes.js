const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

// Route-ka rasmiga ah ee login-ka
router.post('/login', authController.login);

module.exports = router;