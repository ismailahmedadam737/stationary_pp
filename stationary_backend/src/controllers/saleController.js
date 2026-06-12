const Sale = require('../models/saleModel');

exports.getSales = async (req, res) => {
  try {
    const sales = await Sale.getAll();
    res.json(sales);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.createSale = async (req, res) => {
  try {
    const newSale = await Sale.create(req.body);
    res.status(201).json(newSale);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.bulkDeleteSales = async (req, res) => {
  try {
    await Sale.deleteAll();
    res.json({ message: "Dhammaan iibka waa la tirtiray" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};