const express = require('express');
const router = express.Router();
const financeController = require('../controllers/financeController');

router.get('/', financeController.getTransactions);        // GET: /api/finance
router.post('/', financeController.addTransaction);      // POST: /api/finance
router.delete('/:id', financeController.deleteTransaction); // DELETE: /api/finance/1

module.exports = router;