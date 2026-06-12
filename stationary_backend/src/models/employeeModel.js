const { pool } = require('../../server'); // Hubi inuu pool-ku ka imanayo server.js

class Employee {
  static async getAll() {
    const { rows } = await pool.query('SELECT * FROM employees ORDER BY id DESC');
    return rows;
  }

  static async create(data) {
    const { name, phone, position, salary } = data;
    const query = 'INSERT INTO employees (name, phone, position, salary) VALUES ($1, $2, $3, $4) RETURNING *';
    const { rows } = await pool.query(query, [name, phone, position, salary]);
    return rows[0];
  }

  static async update(id, data) {
    const { name, phone, position, salary } = data;
    const query = 'UPDATE employees SET name=$1, phone=$2, position=$3, salary=$4 WHERE id=$5 RETURNING *';
    const { rows } = await pool.query(query, [name, phone, position, salary, id]);
    return rows[0];
  }

  static async delete(id) {
    const query = 'DELETE FROM employees WHERE id = $1 RETURNING *';
    const { rows } = await pool.query(query, [id]);
    return rows[0];
  }
}

module.exports = Employee;