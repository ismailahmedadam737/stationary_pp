const pool = require('../config/db'); // Kani waa pg pool

const History = {
    getAllHistory: async () => {
        const { rows } = await pool.query('SELECT * FROM sales ORDER BY created_at DESC');
        return rows;
    },

    createSaleHistory: async (saleData) => {
        const query = `
            INSERT INTO sales (book_title, invoice_no, qty, price, total, created_at)
            VALUES ($1, $2, $3, $4, $5, NOW()) RETURNING *`;
        const values = [
            saleData.book_title || saleData.product_name,
            saleData.invoice_no,
            saleData.qty || saleData.quantity,
            saleData.price,
            saleData.total || saleData.total_price
        ];
        const { rows } = await pool.query(query, values);
        return rows[0];
    },

    deleteLast30DaysHistory: async () => {
        const query = "DELETE FROM sales WHERE created_at < NOW() - INTERVAL '30 days'";
        const { rowCount } = await pool.query(query);
        return rowCount;
    }
};

module.exports = History;