const pool = require('../config/db');

const Customer = {
    getCustomers: async () => {
        const result = await pool.query('SELECT * FROM customers ORDER BY id DESC');
        return result.rows;
    },
    createCustomer: async (name, phone, district, neighborhood) => {
        const query = 'INSERT INTO customers (name, phone, district, neighborhood) VALUES ($1, $2, $3, $4) RETURNING *';
        const values = [name, phone, district, neighborhood];
        const result = await pool.query(query, values);
        return result.rows[0];
    },
    updateCustomer: async (id, name, phone, district, neighborhood) => {
        const query = 'UPDATE customers SET name=$1, phone=$2, district=$3, neighborhood=$4 WHERE id=$5 RETURNING *';
        const values = [name, phone, district, neighborhood, id];
        const result = await pool.query(query, values);
        return result.rows[0];
    },
    deleteCustomer: async (id) => {
        const result = await pool.query('DELETE FROM customers WHERE id=$1 RETURNING *', [id]);
        return result.rows[0];
    }
};

module.exports = Customer;