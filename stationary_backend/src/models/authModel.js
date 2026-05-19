const pool = require('../config/db'); // Hubi in xidhiidhka DB halkan ku jiro

const Auth = {
    findByUsername: async (username) => {
        try {
            // Waxaan ka dhignay 'users' halkii ay ka ahayd 'login'
            const res = await pool.query('SELECT * FROM users WHERE username = $1', [username]);
            
            if (res.rows.length > 0) {
                return res.rows[0];
            }
            return null; // Haddii aan la helin user-ka
        } catch (err) {
            console.error("DATABASE ERROR (authModel):", err.message);
            throw err;
        }
    }
};

module.exports = Auth;