const pool = require('../config/db'); 

class Sale {
  // In la soo akhriyo dhammaan iibka
  static async getAll() {
    const { rows } = await pool.query('SELECT * FROM sales ORDER BY created_at DESC');
    return rows;
  }

  // In la sameeyo iib cusub
  static async create(data) {
    const { book_title, qty, price, discount, debt, invoice_no } = data;
    const query = `
      INSERT INTO sales (book_title, qty, price, discount, debt, invoice_no) 
      VALUES ($1, $2, $3, $4, $5, $6) 
      RETURNING *`;
    const { rows } = await pool.query(query, [book_title, qty, price, discount, debt, invoice_no]);
    return rows[0];
  }

  // In la tirtiro iib gaar ah (Haddii aad u baahato)
  static async delete(id) {
    const query = 'DELETE FROM sales WHERE id = $1 RETURNING *';
    const { rows } = await pool.query(query, [id]);
    return rows[0];
  }

  // In la tirtiro dhammaan taariikhda iibka
  static async deleteAll() {
    const { rowCount } = await pool.query('DELETE FROM sales');
    return rowCount;
  }
}

module.exports = Sale;