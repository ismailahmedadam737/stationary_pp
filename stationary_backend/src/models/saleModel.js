const pool = require('../config/db');

class Sale {
  static async getAllSales() {
    try {
      const { rows } = await pool.query('SELECT * FROM sales ORDER BY created_at DESC');
      return rows;
    } catch (error) {
      throw error;
    }
  }

  static async createSale(data) {
    // Waxaan ku darnay 'total' halkan
    const { book_title, qty, price, discount, debt, invoice_no, total } = data;
    
    // Query-ga waxaa lagu daray 'total' iyo $7
    const query = `
      INSERT INTO sales (book_title, qty, price, discount, debt, invoice_no, total) 
      VALUES ($1, $2, $3, $4, $5, $6, $7) 
      RETURNING *`;
      
    try {
      const { rows } = await pool.query(query, [
        book_title, 
        qty, 
        price, 
        discount, 
        debt, 
        invoice_no, 
        total // Qiimaha total oo la gudbiyay
      ]);
      return rows[0];
    } catch (error) {
      throw error;
    }
  }

  static async deleteOldSales() {
    try {
      const { rowCount } = await pool.query('DELETE FROM sales');
      return rowCount;
    } catch (error) {
      throw error;
    }
  }
}

module.exports = Sale;