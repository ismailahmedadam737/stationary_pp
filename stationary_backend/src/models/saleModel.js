const pool = require('../config/db'); 

class Sale {
  // Waxaan ka dhignay getAllSales si uu ula jaanqaado controller-ka
  static async getAllSales() {
    const { rows } = await pool.query('SELECT * FROM sales ORDER BY created_at DESC');
    return rows;
  }

  // Waxaan ka dhignay createSale
  static async createSale(data) {
    const { book_title, qty, price, discount, debt, invoice_no } = data;
    const query = `
      INSERT INTO sales (book_title, qty, price, discount, debt, invoice_no) 
      VALUES ($1, $2, $3, $4, $5, $6) 
      RETURNING *`;
    const { rows } = await pool.query(query, [book_title, qty, price, discount, debt, invoice_no]);
    return rows[0];
  }

  // Waxaan ka dhignay deleteOldSales
  static async deleteOldSales() {
    const { rowCount } = await pool.query('DELETE FROM sales');
    return rowCount;
  }
}

module.exports = Sale;