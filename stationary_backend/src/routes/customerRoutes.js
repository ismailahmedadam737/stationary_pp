const express = require('express');
const router = express.Router();
const controller = require('../controllers/customerController');

router.get('/', controller.getCustomers);
router.post('/', controller.addCustomer);
router.put('/:id', controller.editCustomer);
router.delete('/:id', controller.removeCustomer);

// HUBI IN KHADKAN UGU DAMBEEYO:
module.exports = router;