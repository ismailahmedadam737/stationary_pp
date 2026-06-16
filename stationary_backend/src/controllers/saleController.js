const Sale = require('../models/saleModel');

const getSales = async (req, res) => {
    try {
        const sales = await Sale.getAllSales();
        res.status(200).json({ success: true, data: sales });
    } catch (error) {
        console.error("❌ Controller Get Sales Error:", error.message);
        res.status(500).json({ success: false, message: "Server error fetching sales" });
    }
};

const createSale = async (req, res) => {
    try {
        const { book_title, qty, price, discount, debt, invoice_no } = req.body;
        
        if (!book_title || !qty || !price || !invoice_no) {
            return res.status(400).json({ success: false, message: 'Fadlan xogta soo dhammaystir' });
        }

        const newSale = await Sale.createSale({ book_title, qty, price, discount, debt, invoice_no });
        res.status(201).json({ success: true, data: newSale });
    } catch (error) {
        console.error("❌ Controller Create Sale Error:", error.message);
        res.status(500).json({ success: false, message: "Server error saving sale" });
    }
};

const bulkDeleteSales = async (req, res) => {
    try {
        const deletedCount = await Sale.deleteOldSales();
        res.status(200).json({ success: true, message: `Waxaa tirtiray ${deletedCount} iib` });
    } catch (error) {
        console.error("❌ Controller Delete Sales Error:", error.message);
        res.status(500).json({ success: false, message: "Server error deleting sales" });
    }
};

module.exports = { getSales, createSale, bulkDeleteSales };