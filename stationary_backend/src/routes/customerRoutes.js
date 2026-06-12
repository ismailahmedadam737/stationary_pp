const { pool } = require('../../server'); // Hubi inuu sax yahay path-ka pool-ka

exports.getCustomers = async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM customers ORDER BY id ASC');
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.addCustomer = async (req, res) => {
    const { name, phone, district, neighborhood } = req.body;
    
    // Log si aan u aragno waxa Flutter ka yimid
    console.log("Xogta la helay:", req.body);

    try {
        const query = `
            INSERT INTO customers (name, phone, district, neighborhood) 
            VALUES ($1, $2, $3, $4) 
            RETURNING *;
        `;
        const values = [name, phone, district, neighborhood];
        
        const result = await pool.query(query, values);
        res.status(201).json(result.rows[0]);
    } catch (err) {
        // Halkan ayaan ku arki doonaa sababta 500-ka
        console.error("QALADKA DATABASE-KA:", err.message);
        res.status(500).json({ error: "Database error", details: err.message });
    }
};

exports.editCustomer = async (req, res) => {
    const { id } = req.params;
    const { name, phone, district, neighborhood } = req.body;
    try {
        const result = await pool.query(
            'UPDATE customers SET name=$1, phone=$2, district=$3, neighborhood=$4 WHERE id=$5 RETURNING *',
            [name, phone, district, neighborhood, id]
        );
        res.json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.removeCustomer = async (req, res) => {
    const { id } = req.params;
    try {
        await pool.query('DELETE FROM customers WHERE id=$1', [id]);
        res.json({ message: "Customer deleted" });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};