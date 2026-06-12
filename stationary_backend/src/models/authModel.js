const pool = require('../config/db'); // Waxaan ka saarnay { pool } maxaa yeelay db.js wuxuu export-garaynayaa pool-ka laftiisa

const Auth = {
    findByUsername: async (username) => {
        try {
            // Hubi in username-ku uusan ahayn null
            if (!username) return null;

            const query = 'SELECT * FROM users WHERE username ILIKE $1';
            const values = [username.trim()];
            
            const res = await pool.query(query, values);
            
            return res.rows.length > 0 ? res.rows[0] : null;
        } catch (err) {
            // Waxaan kordhinay faahfaahinta khaladka si loo ogaado sababta
            console.error("DATABASE ERROR (authModel) FAHFAAHIN:", err.message);
            throw err;
        }
    }
};

module.exports = Auth;