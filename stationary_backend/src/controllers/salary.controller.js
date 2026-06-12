const Salary = require('../models/salary.model');

// Bixinta Mushaharka
exports.processPayment = async (req, res) => {
    try {
        const result = await Salary.create(req.body);
        res.status(201).json({
            message: "Mushaharka si guul leh ayaa loo keydiyay",
            data: result
        });
    } catch (error) {
        console.error("PAYMENT ERROR:", error);
        res.status(500).json({ error: error.message });
    }
};

// Soo akhrinta Taariikhda
exports.getHistory = async (req, res) => {
    try {
        const history = await Salary.fetchAll();
        res.status(200).json(history);
    } catch (error) {
        console.error("HISTORY ERROR:", error);
        res.status(500).json({ error: error.message });
    }
};