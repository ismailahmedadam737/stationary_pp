const ProductSale = require('../models/saleModel');

// 1. Get All Sales
const getSales = async (req, res) => {
    try {
        const sales = await ProductSale.getAllSales();
        res.status(200).json({ success: true, data: sales });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// 2. Create New Sale
const createSale = async (req, res) => {
    const { book_title, qty, price, discount, debt, invoice_no } = req.body;
    if (!book_title || !qty || !price || !invoice_no) {
        return res.status(400).json({ success: false, message: 'Fadlan xogta soo dhammaystir' });
    }
    try {
        const newSale = await ProductSale.createSale({ book_title, qty, price, discount, debt, invoice_no });
        res.status(201).json({ success: true, data: newSale });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// 3. Bulk Delete Sales (Kii Taariikhda Tirtirayay)
const bulkDeleteSales = async (req, res) => {
    try {
        const deletedCount = await ProductSale.deleteOldSales();
        res.status(200).json({ 
            success: true, 
            message: `Waxaa guul lagu tirtiray ${deletedCount} iib oo ka horreeyey 30 maalmood! 🗑️` 
        });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// Hubi in dhammaan saddexdan halkan lagu dhoofiyey
module.exports = { getSales, createSale, bulkDeleteSales };