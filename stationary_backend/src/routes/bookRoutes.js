const express = require('express');
const router = express.Router();
const controller = require('../controllers/bookController');

router.get('/', controller.getBooks);          // Get all books
router.post('/', controller.addBook);          // Add new book
router.put('/:id', controller.updateBook);     // Update book
router.delete('/:id', controller.deleteBook);  // Delete book

module.exports = router;