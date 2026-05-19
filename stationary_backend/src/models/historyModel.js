const db = require('../config/db'); // database connection-kaaga

const History = {
    // 1. Soo qaadista dhamaan iibka
    getAllHistory: async () => {
        // Haddii aad isticmaali lahayd SQL direct ah: SELECT * FROM sales ORDER BY created_at DESC
        return await db('sales').select('*').orderBy('created_at', 'desc');
    },

    // 2. Kaydinta iib cusub
    createSaleHistory: async (saleData) => {
        const [id] = await db('sales').insert({
            book_title: saleData.book_title || saleData.product_name,
            invoice_no: saleData.invoice_no,
            qty: saleData.qty || saleData.quantity,
            price: saleData.price,
            total: saleData.total || saleData.total_price,
            created_at: new Date() // ama saleData.sale_date
        });
        return { id, ...saleData };
    },

    // 3. Tirtirista iibka ka weyn 30 maalmood
    deleteLast30DaysHistory: async () => {
        const thirtyDaysAgo = new Date();
        thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

        // Waxay tirtiraysaa wixii ka yar (ka horreeyey) 30 maalmood ka hor
        return await db('sales').where('created_at', '<', thirtyDaysAgo).del();
    }
};

module.exports = History;