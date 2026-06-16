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
    // 1. Aynu aragno xogta Flutter ka timid server-ka
    console.log("📥 Request Body-ga soo gaaray:", JSON.stringify(req.body, null, 2));
    
    try {
        const { book_title, qty, price, discount, debt, invoice_no } = req.body;
        
        // 2. Hubinta xogta
        if (!book_title || !qty || !price || !invoice_no) {
            console.warn("⚠️ Xogta oo maqan:", req.body);
            return res.status(400).json({ success: false, message: 'Fadlan xogta soo dhammaystir' });
        }

        const newSale = await Sale.createSale({ book_title, qty, price, discount, debt, invoice_no });
        console.log("✅ Iibka waxaa guul lagu kaydiyay:", newSale);
        
        res.status(201).json({ success: true, data: newSale });
    } catch (error) {
        // 3. Halkan waa meesha ay ku qormayso cilada dhabta ah ee database-ka
        console.error("🚨 DATABASE ERROR (Create Sale):", error);
        console.error("🚨 Error Name:", error.name);
        console.error("🚨 Error Message:", error.message);
        console.error("🚨 Error Detail (Haddii uu jiro):", error.detail);
        
        res.status(500).json({ 
            success: false, 
            message: "Server error saving sale", 
            error: error.message 
        });
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