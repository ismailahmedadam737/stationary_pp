const History = require('../models/historyModel');

// @desc    Get all history
// @route   GET /api/history
const getHistory = async (req, res) => {
    try {
        const data = await History.getAllHistory();
        res.status(200).json({
            success: true,
            data: data
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: "Server Error: Xogtii taariikhda iibka waa la keeni waayey",
            error: error.message
        });
    }
};

// @desc    Bulk Delete history from last 30 days
// @route   DELETE /api/history/bulk-delete
const bulkDeleteHistory = async (req, res) => {
    try {
        const deletedCount = await History.deleteLast30DaysHistory();
        res.status(200).json({
            success: true,
            message: `Waa la wada tirtiray xogtii iibka ee ka horreeysay 30 maalmood. Wadajir: ${deletedCount} item.`,
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: "Server Error: Tirtiristii ma suuragalin",
            error: error.message
        });
    }
};

// @desc    Create new sale history
// @route   POST /api/history
const createHistory = async (req, res) => {
    try {
        // req.body waxaa ku jira: book_title, invoice_no, qty, price, total, sideo kale sale_date
        const newSale = await History.createSaleHistory(req.body);
        res.status(201).json({
            success: true,
            message: "Iibka waa la kaydiyey guul! ✅",
            data: newSale
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: "Server Error: Kaydintii iibka waa guuldaraysatay",
            error: error.message
        });
    }
};

// Dhammaan halkan ku dhufo si looga wada wici karo meelaha kale
module.exports = {
    getHistory,
    bulkDeleteHistory,
    createHistory 
};