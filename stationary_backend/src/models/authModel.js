const pool = require('../config/db'); // Hubi in xidhiidhka DB halkan ku jiro

const Auth = {
    findByUsername: async (username) => {
        try {
            // Waxaan u beddelnay ILIKE si uuna u kala saarin xarfaha waaweyn iyo kuwa yaryar (Case-Insensitive)
            const res = await pool.query('SELECT * FROM users WHERE username ILIKE $1', [username.trim()]);
            
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