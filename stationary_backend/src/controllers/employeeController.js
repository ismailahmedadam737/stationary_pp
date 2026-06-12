const Employee = require('../models/employeeModel');

exports.getEmployees = async (req, res) => {
  try {
    const employees = await Employee.getAll();
    res.status(200).json(employees);
  } catch (err) {
    console.error("GET EMPLOYEES ERROR:", err);
    res.status(500).json({ error: err.message });
  }
};

exports.addEmployee = async (req, res) => {
  try {
    const newEmployee = await Employee.create(req.body);
    res.status(201).json(newEmployee);
  } catch (err) {
    console.error("ADD EMPLOYEE ERROR:", err);
    res.status(500).json({ error: err.message });
  }
};

exports.updateEmployee = async (req, res) => {
  try {
    const updated = await Employee.update(req.params.id, req.body);
    if (!updated) return res.status(404).json({ message: "Shaqaale lama helin" });
    res.status(200).json(updated);
  } catch (err) {
    console.error("UPDATE EMPLOYEE ERROR:", err);
    res.status(500).json({ error: err.message });
  }
};

exports.deleteEmployee = async (req, res) => {
  try {
    const deleted = await Employee.delete(req.params.id);
    if (!deleted) return res.status(404).json({ message: "Shaqaale lama helin" });
    res.status(200).json({ message: "Shaqaalaha waa la tirtiray", deleted });
  } catch (err) {
    console.error("DELETE EMPLOYEE ERROR:", err);
    res.status(500).json({ error: err.message });
  }
};