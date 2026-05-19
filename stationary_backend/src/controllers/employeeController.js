const Employee = require('../models/employeeModel');

exports.getEmployees = async (req, res) => {
  try {
    const employees = await Employee.getAll();
    res.json(employees);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.addEmployee = async (req, res) => {
  try {
    const newEmployee = await Employee.create(req.body);
    res.status(201).json(newEmployee);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// 🔹 UPDATE Controller
exports.updateEmployee = async (req, res) => {
  try {
    const updated = await Employee.update(req.params.id, req.body);
    if (!updated) return res.status(404).json({ message: "Shaqaale lama helin" });
    res.json(updated);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// 🔹 DELETE Controller
exports.deleteEmployee = async (req, res) => {
  try {
    const deleted = await Employee.delete(req.params.id);
    if (!deleted) return res.status(404).json({ message: "Shaqaale lama helin" });
    res.json({ message: "Shaqaalaha waa la tirtiray", deleted });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};