const Finance = require('../models/financeModel');

exports.getTransactions = async (req, res) => {
    try {
        const transactions = await Finance.getAll();
        res.status(200).json(transactions);
    } catch (err) {
        console.error("GET FINANCE ERROR:", err);
        res.status(500).json({ error: err.message });
    }
};

exports.addTransaction = async (req, res) => {
    const { type, amount, note } = req.body;
    try {
        const newTransaction = await Finance.create(type, amount, note);
        res.status(201).json(newTransaction);
    } catch (err) {
        console.error("ADD FINANCE ERROR:", err);
        res.status(500).json({ error: err.message });
    }
};

exports.deleteTransaction = async (req, res) => {
    try {
        const deleted = await Finance.delete(req.params.id);
        if (!deleted) return res.status(404).json({ message: "Transaction-ka lama helin" });
        res.status(200).json({ message: "Deleted successfully", data: deleted });
    } catch (err) {
        console.error("DELETE FINANCE ERROR:", err);
        res.status(500).json({ error: err.message });
    }
};