const Customer = require('../models/customerModel');

// Function-ka hubinta inuu yahay qoraal (text)
const isOnlyLetters = (str) => /^[a-zA-Z\s]+$/.test(str);

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
        
        // Validation: Hubinta in magaca aanu ahayn lambaro
        if (!name || !isOnlyLetters(name)) {
            return res.status(400).json({ 
                message: 'Magaca waa inuu ahaadaa xarfo oo kaliya (xarfo), lambaro lama oggola.' 
            });
        }

        if (!phone) {
            return res.status(400).json({ message: 'Phone is required' });
        }

        console.log("📥 Xogta la helay:", { name, phone, district, neighborhood });
        
        const newCustomer = await Customer.createCustomer(name, phone, district, neighborhood);
        
        res.status(201).json(newCustomer);
    } catch (err) {
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
        
        // Validation: Hubinta in magaca la cusboonaysiinayo aanu ahayn lambaro
        if (name && !isOnlyLetters(name)) {
            return res.status(400).json({ 
                message: "Magaca waa inuu ahaadaa xarfo oo kaliya." 
            });
        }
        
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