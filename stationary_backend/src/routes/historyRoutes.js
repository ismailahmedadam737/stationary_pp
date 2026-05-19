const express = require('express');
const router = express.Router();
const { getHistory, bulkDeleteHistory, createHistory } = require('../controllers/historyController');

// http://localhost:3000/api/history
router.get('/', getHistory);

// http://localhost:3000/api/history/bulk-delete
router.delete('/bulk-delete', bulkDeleteHistory);

// http://localhost:3000/api/history
router.post('/', createHistory); 

module.exports = router;