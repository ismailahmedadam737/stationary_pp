const express = require('express');
const router = express.Router();
const employeeController = require('../controllers/employeeController');

router.get('/', employeeController.getEmployees);
router.post('/', employeeController.addEmployee);

// 🔹 CUSUB: Update iyo Delete Routes
router.put('/:id', employeeController.updateEmployee);    // UPDATE (PUT)
router.delete('/:id', employeeController.deleteEmployee); // DELETE

module.exports = router;