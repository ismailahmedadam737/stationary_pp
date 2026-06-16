// SAXITAANKA: Waxaan ka soo qaadanaynaa pool-ka faylka config/db.js
// Tani waxay baabi'inaysaa Circular Dependency-ga
const pool = require('../config/db'); 

const Salary = {
    // In la keydiyo mushahar cusub
    create: async (data) => {
        const { employee_id, employee_name, basic_salary, reward, penalty, total_amount } = data;
        const query = `
            INSERT INTO salaries (employee_id, employee_name, basic_salary, reward, penalty, total_amount)
            VALUES ($1, $2, $3, $4, $5, $6) 
            RETURNING *`;
        const values = [employee_id, employee_name, basic_salary, reward, penalty, total_amount];
        
        // Hadda pool.query wuu shaqaynayaa sababtoo ah pool waa la aqoonsan yahay
        const { rows } = await pool.query(query, values);
        return rows[0];
    },

    // In la soo akhriyo dhammaan taariikhda (History)
    fetchAll: async () => {
        const query = 'SELECT * FROM salaries ORDER BY payment_date DESC';
        const { rows } = await pool.query(query);
        return rows;
    }
};

module.exports = Salary;