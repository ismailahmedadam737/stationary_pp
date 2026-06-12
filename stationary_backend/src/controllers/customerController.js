const Customer = require('../models/customerModel');

const getCustomers = async (req, res) => {
    try {
        const customers = await Customer.getCustomers();
        res.status(200).json(customers);
    } catch (err) {
        console.error("❌ QALADKA getCustomers:", err.message);
        res.status(500).json({ error: "Failed to fetch customers", details: err.message });
    }
};

const addCustomer = async (req, res) => {
    try {
        const { name, phone, district, neighborhood } = req.body;
        
        // Hubinta in xogta muhiimka ah ay jirto
        if (!name || !phone) {
            return res.status(400).json({ message: 'Name and phone are required' });
        }

        console.log("📥 Xogta la helay:", { name, phone, district, neighborhood });
        
        const newCustomer = await Customer.createCustomer(name, phone, district, neighborhood);
        
        // 201 waa koodhka rasmiga ah ee macnaheedu yahay "Waa la abuuray"
        res.status(201).json(newCustomer);
    } catch (err) {
        // Halkan waxaan ku arki doonaa khaladka rasmiga ah ee Render logs
        console.error("❌ QALADKA addCustomer (Database):", err.message);
        res.status(500).json({ 
            error: "Database error", 
            details: err.message 
        });
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
        console.error("❌ QALADKA editCustomer:", err.message);
        res.status(500).json({ error: "Failed to update customer", details: err.message });
    }
};

const removeCustomer = async (req, res) => {
    try {
        const { id } = req.params;
        const deletedCustomer = await Customer.deleteCustomer(id);
        
        if (!deletedCustomer) {
            return res.status(404).json({ message: "Customer not found" });
        }
        
        res.status(200).json({ message: "Customer deleted successfully", deletedCustomer });
    } catch (err) {
        console.error("❌ QALADKA removeCustomer:", err.message);
        res.status(500).json({ error: "Failed to delete customer", details: err.message });
    }
};

module.exports = { 
    getCustomers, 
    addCustomer, 
    editCustomer, 
    removeCustomer 
};