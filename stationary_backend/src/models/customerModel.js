const pool = require('../config/db');

const getCustomers = async () => {
    const result = await pool.query('SELECT * FROM customers ORDER BY id DESC');
    return result.rows;
};

const createCustomer = async (name, phone, district, neighborhood) => {
    const result = await pool.query(
        'INSERT INTO customers (name, phone, district, neighborhood) VALUES ($1, $2, $3, $4) RETURNING *',
        [name, phone, district, neighborhood]
    );
    return result.rows[0];
};

const updateCustomer = async (id, name, phone, district, neighborhood) => {
    const result = await pool.query(
        'UPDATE customers SET name=$1, phone=$2, district=$3, neighborhood=$4 WHERE id=$5 RETURNING *',
        [name, phone, district, neighborhood, id]
    );
    return result.rows[0];
};

const deleteCustomer = async (id) => {
    const result = await pool.query('DELETE FROM customers WHERE id=$1 RETURNING *', [id]);
    return result.rows[0];
};

module.exports = {
    getCustomers,
    createCustomer,
    updateCustomer,
    deleteCustomer
};