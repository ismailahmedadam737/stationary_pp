const pool = require('../config/db'); 

const Finance = {
    getAll: async () => {
        // Halkan waxaan ka dhignay 'finance' sidii aad u bixisay
        const res = await pool.query('SELECT * FROM finance ORDER BY date DESC');
        return res.rows;
    },

    create: async (type, amount, note) => {
        const res = await pool.query(
            'INSERT INTO finance (type, amount, note) VALUES ($1, $2, $3) RETURNING *',
            [type, amount, note]
        );
        return res.rows[0];
    },

    delete: async (id) => {
        await pool.query('DELETE FROM finance WHERE id = $1', [id]);
        return { message: "Transaction deleted" };
    }
};

module.exports = Finance;