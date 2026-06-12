const express = require('express');
const router = express.Router();
const saleController = require('../controllers/saleController'); 

// Router-ku wuxuu kaliya u yeerayaa controller-ka
router.get('/', saleController.getSales);
router.post('/', saleController.createSale);
router.delete('/bulk-delete', saleController.bulkDeleteSales);

module.exports = router;