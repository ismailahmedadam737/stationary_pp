const express = require('express');
const router = express.Router();
// 🔹 XALKA: Isticmaal 'controllers' (2 'l' iyo leh 's')
const userController = require('../controllers/userController');

router.get('/', userController.getUsers);
router.post('/add', userController.addUser);
router.delete('/:id', userController.removeUser);

module.exports = router;