const User = require('../models/userModel');

const getUsers = async (req, res) => {
    try {
        const users = await User.getAllUsers();
        res.json(users);
    } catch (err) {
        console.error("DEBUG GET ERROR: ", err);
        res.status(500).json({ error: err.message });
    }
};

const addUser = async (req, res) => {
    const { username, password, role } = req.body;
    
    // Hubinta in xogtu aysan bannaanayn
    if (!username || !password || !role) {
        return res.status(400).json({ error: "Fadlan soo buuxi dhammaan goobaha (Username, Password, Role)!" });
    }

    try {
        const newUser = await User.createUser(username, password, role);
        res.status(201).json(newUser);
    } catch (err) {
        // 🔹 DIB U EEG LOGS-KAAGA: Fariintan ayaa ku soo bixi doonta Render logs
        console.error("DEBUG ADD USER ERROR: ", err); 
        
        // Waxaan diraynaa err.message si aan u ogaano khaladka saxda ah (tusaale: table missing?)
        res.status(500).json({ error: err.message }); 
    }
};

const removeUser = async (req, res) => {
    try {
        await User.deleteUser(req.params.id);
        res.json({ message: "User-ka waa la tirtiray ✅" });
    } catch (err) {
        console.error("DEBUG DELETE ERROR: ", err);
        res.status(500).json({ error: err.message });
    }
};

module.exports = { getUsers, addUser, removeUser };