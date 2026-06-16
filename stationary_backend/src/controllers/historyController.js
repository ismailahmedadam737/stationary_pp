const History = require('../models/history.model'); // Hubi in faylku magacaan yahay

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
        console.error("❌ GET HISTORY ERROR:", error.message);
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
        console.error("❌ BULK DELETE ERROR:", error.message);
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
        // Waxaan hubinaynaa in xogtu ay jirto intaan model-ka u dirin
        if (!req.body.book_title && !req.body.product_name) {
            return res.status(400).json({ success: false, message: "Fadlan soo geli book_title ama product_name" });
        }

        const newSale = await History.createSaleHistory(req.body);
        res.status(201).json({
            success: true,
            message: "Iibka waa la kaydiyey guul! ✅",
            data: newSale
        });
    } catch (error) {
        console.error("❌ CREATE HISTORY ERROR:", error.message);
        res.status(500).json({
            success: false,
            message: "Server Error: Kaydintii iibka waa guuldaraysatay",
            error: error.message
        });
    }
};

module.exports = {
    getHistory,
    bulkDeleteHistory,
    createHistory 
};