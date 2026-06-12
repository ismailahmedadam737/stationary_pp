const pool = require('../config/db'); 

class Sale {
  // 🔹 In la soo akhriyo dhammaan xogta iibka
  static async getAllSales() {
    const query = 'SELECT * FROM sales ORDER BY created_at DESC';
    const { rows } = await pool.query(query);
    return rows;
  }

  // 🔹 In la keydiyo iib cusub
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

  // 🔹 In la tirtiro iib gaar ah (Haddii loo baahdo)
  static async deleteSale(id) {
    const query = 'DELETE FROM sales WHERE id = $1 RETURNING *';
    const { rows } = await pool.query(query, [id]);
    return rows[0];
  }

  // 🔹 In la tirtiro dhammaan taariikhda iibka
  static async deleteAll() {
    const query = 'DELETE FROM sales';
    const { rowCount } = await pool.query(query);
    return rowCount; 
  }
}

module.exports = Sale;