const ProductSale = require('../models/saleModel');

const getSales = async (req, res) => {
    try {
        const sales = await ProductSale.getAllSales(); // Hadda wuu helayaa function-kan
        res.status(200).json({ success: true, data: sales });
    } catch (error) {
        console.error("GET SALES ERROR:", error);
        res.status(500).json({ success: false, message: error.message });
    }
};

const createSale = async (req, res) => {
    try {
        const { book_title, qty, price, discount, debt, invoice_no } = req.body;
        if (!book_title || !qty || !price || !invoice_no) {
            return res.status(400).json({ success: false, message: 'Fadlan xogta soo dhammaystir' });
        }
        const newSale = await ProductSale.createSale({ book_title, qty, price, discount, debt, invoice_no });
        res.status(201).json({ success: true, data: newSale });
    } catch (error) {
        console.error("CREATE SALE ERROR:", error);
        res.status(500).json({ success: false, message: error.message });
    }
};

const bulkDeleteSales = async (req, res) => {
    try {
        const deletedCount = await ProductSale.deleteOldSales();
        res.status(200).json({ 
            success: true, 
            message: `Waxaa guul lagu tirtiray ${deletedCount} iib!` 
        });
    } catch (error) {
        console.error("DELETE SALES ERROR:", error);
        res.status(500).json({ success: false, message: error.message });
    }
};

module.exports = { getSales, createSale, bulkDeleteSales };