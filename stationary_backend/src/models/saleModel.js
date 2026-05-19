const pool = require('../config/db');

const ProductSale = {
    // 1. Soo aqri dhammaan iibka (GET)
    getAllSales: async () => {
        const query = 'SELECT * FROM sales ORDER BY created_at DESC';
        const result = await pool.query(query);
        return result.rows;
    },

    // 2. Ku dar iib cusub (POST)
    createSale: async (saleData) => {
        const { book_title, qty, price, discount, debt, invoice_no } = saleData;
        const query = `
            INSERT INTO sales (book_title, qty, price, discount, debt, invoice_no) 
            VALUES ($1, $2, $3, $4, $5, $6) 
            RETURNING *
        `;
        const values = [book_title, qty, price, discount, debt, invoice_no];
        const result = await pool.query(query, values);
        return result.rows[0];
    },

    // 3. Tirtirista Guud (Nadiif ah oo aan Terminal-ka waxba ku qorayn)
    deleteOldSales: async () => {
        const query = `
            DELETE FROM sales 
            RETURNING *
        `;
        const result = await pool.query(query);
        
        // Waxaa laga saaray console.log-yadii si uu terminal-ku nadiif u ahaado
        return result.rowCount; 
    }
};

module.exports = ProductSale;