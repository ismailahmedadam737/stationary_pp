const Finance = require('../models/financeModel');

exports.getTransactions = async (req, res) => {
    try {
        const transactions = await Finance.getAll();
        res.json(transactions);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.addTransaction = async (req, res) => {
    const { type, amount, note } = req.body;
    try {
        const newTransaction = await Finance.create(type, amount, note);
        res.status(201).json(newTransaction);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.deleteTransaction = async (req, res) => {
    try {
        await Finance.delete(req.params.id);
        res.json({ message: "Deleted successfully" });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};