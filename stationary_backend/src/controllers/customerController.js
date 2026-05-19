const Customer = require('../models/customerModel');

const getCustomers = async (req, res) => {
    try {
        const customers = await Customer.getCustomers();
        res.json(customers);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

const addCustomer = async (req, res) => {
    try {
        const { name, phone, district, neighborhood } = req.body;
        if (!name || !phone) {
            return res.status(400).json({ message: 'Name and phone are required' });
        }
        const newCustomer = await Customer.createCustomer(name, phone, district, neighborhood);
        res.json(newCustomer);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

const editCustomer = async (req, res) => {
    try {
        const { id } = req.params;
        const { name, phone, district, neighborhood } = req.body;
        const updatedCustomer = await Customer.updateCustomer(id, name, phone, district, neighborhood);
        res.json(updatedCustomer);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

const removeCustomer = async (req, res) => {
    try {
        const { id } = req.params;
        const deletedCustomer = await Customer.deleteCustomer(id);
        res.json(deletedCustomer);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

module.exports = {
    getCustomers,
    addCustomer,
    editCustomer,
    removeCustomer
};