const Auth = require('../models/authModel');

exports.login = async (req, res) => {
    // 1. Isticmaal .trim() si aad uga saarto booska madhan (space) haddii uu jiro
    const username = req.body.username ? req.body.username.trim().toLowerCase() : "";
    const password = req.body.password ? req.body.password.trim() : "";

    try {
        const user = await Auth.findByUsername(username);

        if (user) {
            // 2. Isbarbardhig Password-ka (Plain Text: 1234)
            if (user.password === password) {
                return res.status(200).json({ 
                    success: true, 
                    role: user.role, // Tani waa inay ahaato 'Admin'
                    username: user.username,
                    message: "Login Successful" 
                });
            }
        }

        // 3. Haddii aan la helin user ama password-ku khaldan yahay
        res.status(401).json({ success: false, message: "Username ama Password khaldan!" });

    } catch (err) {
        console.error("LOGIN CONTROLLER ERROR:", err.message);
        res.status(500).json({ error: err.message });
    }
};