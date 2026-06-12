import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EmployeePage extends StatefulWidget {
  const EmployeePage({super.key});

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  List<Map<String, String>> _employees = [];
  List<Map<String, String>> _filteredEmployees = []; 
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _positionController = TextEditingController();
  final _salaryController = TextEditingController();
  final _searchController = TextEditingController(); 

  // IP-gaaga rasmiga ah ee server-ka
  final String baseUrl = "https://stationary-backend-6fh1.onrender.com/api/employees";

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    _salaryController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchEmployees() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _employees = data.map((e) => {
            "id": e['_id']?.toString() ?? e['id'].toString(),
            "name": e['name'].toString(),
            "phone": e['phone'].toString(),
            "position": e['position'].toString(),
            "salary": e['salary'].toString(),
          }).toList();
          _filteredEmployees = _employees; 
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  void _filterEmployees(String query) {
    setState(() {
      _filteredEmployees = _employees
          .where((emp) => emp['name']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _addEmployee() async {
    if (_nameController.text.isNotEmpty && _salaryController.text.isNotEmpty) {
      try {
        final response = await http.post(
          Uri.parse(baseUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "name": _nameController.text,
            "phone": _phoneController.text,
            "position": _positionController.text.isEmpty ? "Shaqaale" : _positionController.text,
            "salary": double.parse(_salaryController.text),
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          _fetchEmployees();
          _nameController.clear();
          _phoneController.clear();
          _positionController.clear();
          _salaryController.clear();
          FocusScope.of(context).unfocus();
          _showSnackBar("The employee is registered! ✅", Colors.teal);
        }
      } catch (e) {
        _showSnackBar("Cillad: $e", Colors.red);
      }
    }
  }

  void _updateEmployee(Map<String, String> emp) {
    final nameEdit = TextEditingController(text: emp['name']);
    final phoneEdit = TextEditingController(text: emp['phone']);
    final posEdit = TextEditingController(text: emp['position']);
    final salEdit = TextEditingController(text: emp['salary']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update the employee"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameEdit, decoration: const InputDecoration(labelText: "Magaca")),
              TextField(controller: phoneEdit, decoration: const InputDecoration(labelText: "Taleefanka")),
              TextField(controller: posEdit, decoration: const InputDecoration(labelText: "Jagada")),
              TextField(controller: salEdit, decoration: const InputDecoration(labelText: "Mushaharka"), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Ka noqo")),
          ElevatedButton(
            onPressed: () async {
              try {
                final response = await http.put(
                  Uri.parse("$baseUrl/${emp['id']}"),
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode({
                    "name": nameEdit.text,
                    "phone": phoneEdit.text,
                    "position": posEdit.text,
                    "salary": double.parse(salEdit.text),
                  }),
                );
                if (response.statusCode == 200) {
                  _fetchEmployees();
                  Navigator.pop(context);
                  _showSnackBar("The data is updated!", Colors.blue);
                }
              } catch (e) {
                _showSnackBar("Cillad: $e", Colors.red);
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void _deleteEmployee(String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Warning!"),
        content: Text("Are you sure to delete $name?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Maya")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                final response = await http.delete(Uri.parse("$baseUrl/$id"));
                if (response.statusCode == 200) {
                  _fetchEmployees();
                  Navigator.pop(context);
                  _showSnackBar("The employee is deleted !", Colors.orange);
                }
              } catch (e) {
                _showSnackBar("Cillad: $e", Colors.red);
              }
            },
            child: const Text("Yes, Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  void _showEmployeeSalary(Map<String, String> emp) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(color: Colors.teal.withOpacity(0.5), blurRadius: 20, spreadRadius: 5),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                colors: [Colors.teal.shade900, Colors.teal.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 25),
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.white,
                  child: Text(emp['name']![0].toUpperCase(),
                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.teal.shade900)),
                ),
                const SizedBox(height: 15),
                Text(emp['name']!.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                Text(emp['position']!, style: const TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      _infoRow(Icons.phone, "Phone", emp['phone']!),
                      const Divider(color: Colors.white24),
                      _infoRow(Icons.attach_money, "Salary", "\$${emp['salary']}"),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.only(bottom: 25, left: 20, right: 20),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.teal.shade900,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text("Close please", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.amberAccent, size: 24),
        const SizedBox(width: 15),
        Text("$label: ", style: const TextStyle(color: Colors.white60)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const Text("EMPLOYEE REGISTRATION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // GREEN CARD (Inputs)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: Colors.teal, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))),
            child: Column(
              children: [
                _buildInput(_nameController, "Employee Name", Icons.person),
                const SizedBox(height: 10),
                _buildInput(_phoneController, "Telephone Number", Icons.phone, inputType: TextInputType.phone),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildInput(_positionController, "Position", Icons.work)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildInput(_salaryController, "Basic Salary", Icons.attach_money, inputType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: _addEmployee,
                  icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
                  label: const Text("Add New Employee", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[700], minimumSize: const Size(double.infinity, 50)),
                ),
              ],
            ),
          ),
          
          // SEARCH SECTION 
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 5),
            child: TextField(
              controller: _searchController,
              onChanged: _filterEmployees,
              decoration: InputDecoration(
                hintText: "Search employee name...",
                prefixIcon: const Icon(Icons.search, color: Colors.teal),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.teal.shade100),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.teal.shade100),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 20, left: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("EMPLOYEES LIST", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
            ),
          ),
          
          // LIST SECTION
          Expanded(
            child: _filteredEmployees.isEmpty
                ? const Center(child: Text("No registered employee"))
                : ListView.builder(
                    itemCount: _filteredEmployees.length,
                    itemBuilder: (context, index) {
                      final emp = _filteredEmployees[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 2,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal.shade50,
                            child: Text(emp['name']![0].toUpperCase(), style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                          ),
                          title: Text(emp['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(emp['position']!),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _updateEmployee(emp)),
                              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteEmployee(emp['id']!, emp['name']!)),
                            ],
                          ),
                          onTap: () => _showEmployeeSalary(emp),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String hint, IconData icon, {TextInputType inputType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white70),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white60),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
}