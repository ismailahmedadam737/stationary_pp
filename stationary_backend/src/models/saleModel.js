const { pool } = require('../../server'); // Hubi inuu pool-ku ka imanayo server.js ama config/db.js

const ProductSale = {
    getAllSales: async () => {
        const query = 'SELECT * FROM sales ORDER BY created_at DESC';
        const result = await pool.query(query);
        return result.rows;
    },

    createSale: async (saleData) => {
        const { book_title, qty, price, discount, debt, invoice_no } = saleData;
        // id-ga halkan lagama rabo, DB-ga ayaa samaynaya
        const query = `
            INSERT INTO sales (book_title, qty, price, discount, debt, invoice_no) 
            VALUES ($1, $2, $3, $4, $5, $6) 
            RETURNING *
        `;
        const values = [book_title, qty, price, discount, debt, invoice_no];
        const result = await pool.query(query, values);
        return result.rows[0];
    },

    deleteOldSales: async () => {
        const query = 'DELETE FROM sales';
        const result = await pool.query(query);
        return result.rowCount; 
    }
};

module.exports = ProductSale;