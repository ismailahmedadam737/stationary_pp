const pool = require('../config/db'); 

class Sale {
  static async getAllSales() {
    const { rows } = await pool.query('SELECT * FROM sales ORDER BY created_at DESC');
    return rows;
  }

  static async createSale(saleData) {
    const { book_title, qty, price, discount, debt, invoice_no } = saleData;
    const query = `
      INSERT INTO sales (book_title, qty, price, discount, debt, invoice_no) 
      VALUES ($1, $2, $3, $4, $5, $6) 
      RETURNING *
    `;
    const values = [book_title, qty, price, discount, debt, invoice_no];
    const { rows } = await pool.query(query, values);
    return rows[0];
  }

  // Magacan ayaan u beddelay si uu ula jaanqaado controller-kaaga
  static async deleteOldSales() {
    const { rowCount } = await pool.query('DELETE FROM sales');
    return rowCount; 
  }
}

module.exports = Sale;