const Customer = require('../models/customerModel');

const getCustomers = async (req, res) => {
    try {
        const customers = await Customer.getCustomers();
        res.status(200).json(customers);
    } catch (err) {
        console.error("Error in getCustomers:", err.message);
        res.status(500).json({ error: "Failed to fetch customers", details: err.message });
    }
};

const addCustomer = async (req, res) => {
    try {
        const { name, phone, district, neighborhood } = req.body;
        
        // Validation
        if (!name || !phone) {
            return res.status(400).json({ message: 'Name and phone are required' });
        }

        console.log("Adding customer:", { name, phone, district, neighborhood });
        
        const newCustomer = await Customer.createCustomer(name, phone, district, neighborhood);
        res.status(201).json(newCustomer);
    } catch (err) {
        console.error("❌ QALADKA DATABASE-KA (addCustomer):", err.message);
        // Si aan u ogaano sababta 500-ka
        res.status(500).json({ error: "Database error", details: err.message });
    }
};

const editCustomer = async (req, res) => {
    try {
        const { id } = req.params;
        const { name, phone, district, neighborhood } = req.body;
        const updatedCustomer = await Customer.updateCustomer(id, name, phone, district, neighborhood);
        
        if (!updatedCustomer) {
            return res.status(404).json({ message: "Customer not found" });
        }
        
        res.status(200).json(updatedCustomer);
    } catch (err) {
        console.error("Error in editCustomer:", err.message);
        res.status(500).json({ error: "Failed to update customer", details: err.message });
    }
};

const removeCustomer = async (req, res) => {
    try {
        const { id } = req.params;
        const deletedCustomer = await Customer.deleteCustomer(id);
        res.status(200).json({ message: "Customer deleted successfully", deletedCustomer });
    } catch (err) {
        console.error("Error in removeCustomer:", err.message);
        res.status(500).json({ error: "Failed to delete customer", details: err.message });
    }
};

module.exports = { getCustomers, addCustomer, editCustomer, removeCustomer };