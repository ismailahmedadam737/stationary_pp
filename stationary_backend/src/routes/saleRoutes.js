const express = require('express');
const router = express.Router();

// 🟢 HALKAN KA EEG: Waxaa loo baddalay saleController (iyadoo aanay dhibic ku jirin)
const saleController = require('../controllers/saleController'); 

// GET: http://localhost:3000/api/sales
router.get('/', saleController.getSales);

// POST: http://localhost:3000/api/sales
router.post('/', saleController.createSale);

// DELETE: http://localhost:3000/api/sales/bulk-delete
router.delete('/bulk-delete', saleController.bulkDeleteSales);

module.exports = router;