// 🔹 XALKA: Dib uga bax 'models' (../) -> gal 'config' -> soo qaad 'db'
const pool = require('../config/db'); 

const User = {
    // Keento dhamaan users-ka
    getAllUsers: async () => {
        const res = await pool.query('SELECT id, username, role FROM users ORDER BY id DESC');
        return res.rows;
    },

    // Mid cusub ku daro
    createUser: async (username, password, role) => {
        const res = await pool.query(
            'INSERT INTO users (username, password, role) VALUES ($1, $2, $3) RETURNING id, username, role',
            [username, password, role]
        );
        return res.rows[0];
    },

    // Tirtirto user
    deleteUser: async (id) => {
        await pool.query('DELETE FROM users WHERE id = $1', [id]);
        return { message: "User deleted" };
    }
};

module.exports = User;