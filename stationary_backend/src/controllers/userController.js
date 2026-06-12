const User = require('../models/userModel');

const getUsers = async (req, res) => {
    try {
        const users = await User.getAllUsers();
        res.json(users);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

const addUser = async (req, res) => {
    const { username, password, role } = req.body;
    try {
        const newUser = await User.createUser(username, password, role);
        res.status(201).json(newUser);
    } catch (err) {
        res.status(500).json({ error: "Username-ka waa la isticmaalay ama khalad ayaa dhacay!" });
    }
};

const removeUser = async (req, res) => {
    try {
        await User.deleteUser(req.params.id);
        res.json({ message: "User-ka waa la tirtiray ✅" });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

module.exports = { getUsers, addUser, removeUser };