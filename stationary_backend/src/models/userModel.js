const pool = require('../config/db'); 

const User = {
    getAllUsers: async () => {
        const res = await pool.query('SELECT id, username, role FROM users ORDER BY id DESC');
        return res.rows;
    },

    createUser: async (username, password, role) => {
        const res = await pool.query(
            'INSERT INTO users (username, password, role) VALUES ($1, $2, $3) RETURNING id, username, role',
            [username, password, role]
        );
        return res.rows[0];
    },

    deleteUser: async (id) => {
        await pool.query('DELETE FROM users WHERE id = $1', [id]);
        return { message: "User deleted" };
    }
};

module.exports = User;