// Waxaan si toos ah u soo dhoofinaynaa pool-ka ka yimid faylka config/db.js
const pool = require('../config/db'); 

const Finance = {
    // Helitaanka dhammaan xogta finance
    getAll: async () => {
        try {
            const res = await pool.query('SELECT * FROM finance ORDER BY date DESC');
            return res.rows;
        } catch (err) {
            console.error("❌ Error in financeModel.getAll:", err.message);
            throw err;
        }
    },

    // Abuuritaanka xog cusub
    create: async (type, amount, note) => {
        try {
            const res = await pool.query(
                'INSERT INTO finance (type, amount, note) VALUES ($1, $2, $3) RETURNING *',
                [type, amount, note]
            );
            return res.rows[0];
        } catch (err) {
            console.error("❌ Error in financeModel.create:", err.message);
            throw err;
        }
    },

    // Tirtiridda xogta
    delete: async (id) => {
        try {
            const res = await pool.query('DELETE FROM finance WHERE id = $1 RETURNING *', [id]);
            return res.rows[0]; 
        } catch (err) {
            console.error("❌ Error in financeModel.delete:", err.message);
            throw err;
        }
    }
};

module.exports = Finance;