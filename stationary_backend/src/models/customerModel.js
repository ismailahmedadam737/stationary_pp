const pool = require('../config/db');

const Customer = {
    getCustomers: async () => {
        const result = await pool.query('SELECT * FROM customers ORDER BY id DESC');
        return result.rows;
    },
    createCustomer: async (name, phone, district, neighborhood) => {
        // Query-ga saxda ah oo aan id ku jirin (db-ga ayaa si otomaatig ah u samaynaya)
        const query = 'INSERT INTO customers (name, phone, district, neighborhood) VALUES ($1, $2, $3, $4) RETURNING *';
        const values = [name, phone, district, neighborhood];
        const result = await pool.query(query, values);
        return result.rows[0];
    },
    // ... update iyo delete waa sidoodii
};
module.exports = Customer;