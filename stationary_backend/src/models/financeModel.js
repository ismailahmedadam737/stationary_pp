const { pool } = require('../../server'); 

const Finance = {
    getAll: async () => {
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
        const res = await pool.query('DELETE FROM finance WHERE id = $1 RETURNING *', [id]);
        return res.rows[0]; // Waxaan soo celinaynaa xogtii la tirtiray
    }
};

module.exports = Finance;