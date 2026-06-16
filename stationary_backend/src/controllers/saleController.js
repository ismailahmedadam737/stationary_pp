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
    console.log("📥 Request Body-ga soo gaaray:", JSON.stringify(req.body, null, 2));
    
    try {
        // Halkan 'total' kama rabno maadaama DB uu isagu xisaabinayo
        const { book_title, qty, price, discount, debt, invoice_no } = req.body;
        
        // 2. Hubinta xogta (Waxaan ka saarnay total)
        if (!book_title || qty === undefined || price === undefined || !invoice_no) {
            console.warn("⚠️ Xogta oo maqan (Hubi qty iyo price):", req.body);
            return res.status(400).json({ success: false, message: 'Fadlan xogta soo dhammaystir (qty, price, invoice_no)' });
        }

        // 3. U dir Model-ka xogta aan 'total'-ka lahayn
        const newSale = await Sale.createSale({ 
            book_title, 
            qty, 
            price, 
            discount: discount || 0, 
            debt: debt || 0, 
            invoice_no 
        });

        console.log("✅ Iibka waxaa guul lagu kaydiyay:", newSale);
        res.status(201).json({ success: true, data: newSale });

    } catch (error) {
        console.error("🚨 DATABASE ERROR (Create Sale):", error);
        
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