const express = require('express');
const router = express.Router();
const controller = require('../controllers/customerController');

router.get('/', controller.getCustomers);       // GET all
router.post('/', controller.addCustomer);       // POST add
router.put('/:id', controller.editCustomer);    // PUT update
router.delete('/:id', controller.removeCustomer); // DELETE remove

module.exports = router;