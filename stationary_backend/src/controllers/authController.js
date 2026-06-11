const Auth = require('../models/authModel');

exports.login = async (req, res) => {
    const username = req.body.username ? req.body.username.trim() : "";
    const password = req.body.password ? req.body.password.trim() : "";

    // 🔹 REQ LOG: Waa maxay xogta uu talifanku soo diray?
    console.log("--- ISKU-DAY LOGIN CUSUB ---");
    console.log(`Talifanku wuxuu soo diray -> Username: "${username}", Password: "${password}"`);

    try {
        const user = await Auth.findByUsername(username);

        if (user) {
            // 🔹 DB LOG: Waa maxay xogta ku dhex jirta Database-ka?
            console.log(`Database-ka waxaa laga helay -> Username: "${user.username}", Password: "${user.password}"`);

            const dbPassword = user.password ? user.password.toString().trim() : "";
            
            if (dbPassword === password) {
                console.log("MAALINKA MAALIN! Login-ku wuxuu u guulaystay guul ✅");
                return res.status(200).json({ 
                    success: true, 
                    role: user.role, 
                    username: user.username,
                    message: "Login Successful" 
                });
            } else {
                console.log(`XALNA MA LEH: Password-ka DB (${dbPassword}) iyo kii la soo qoray (${password}) ISMA LAHA ❌`);
            }
        } else {
            console.log(`XALNA MA LEH: Magaca "${username}" lagama helin database-ka dhexdiisa ❌`);
        }

        return res.status(401).json({ success: false, message: "Username ama Password khaldan!" });

    } catch (err) {
        console.error("LOGIN CONTROLLER ERROR:", err.message);
        return res.status(500).json({ error: err.message });
    }
};