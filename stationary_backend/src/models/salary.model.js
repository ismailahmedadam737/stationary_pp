const pool = require('../config/db');

const Salary = {
    create: async (data) => {
        const { employee_id, employee_name, basic_salary, reward, penalty, total_amount } = data;
        const query = `
            INSERT INTO salaries (employee_id, employee_name, basic_salary, reward, penalty, total_amount)
            VALUES ($1, $2, $3, $4, $5, $6) 
            RETURNING *`;
        const values = [employee_id, employee_name, basic_salary, reward, penalty, total_amount];
        const { rows } = await pool.query(query, values);
        return rows[0];
    },

    fetchAll: async () => {
        // Halkan ayaan ku dareynaa hubin (check)
        if (!pool || typeof pool.query !== 'function') {
            console.error("❌ CRITICAL: Pool is undefined in salary.model.js");
            throw new Error("Database pool is not ready");
        }
        const query = 'SELECT * FROM salaries ORDER BY payment_date DESC';
        const { rows } = await pool.query(query);
        return rows;
    }
};

module.exports = Salary;