import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CustomerApiService {
  static const String baseUrl = "https://stationary-backend-6fh1.onrender.com/api/customers";

  static Future<List> getCustomers() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception("Failed to fetch");
  }

  static Future<void> addCustomer(String name, String phone, String district, String neighborhood) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "phone": phone,
        "district": district,
        "neighborhood": neighborhood,
      }),
    );
    if (res.statusCode != 200 && res.statusCode != 201) throw Exception("Error: ${res.statusCode}");
  }

  static Future<void> deleteCustomer(String id) async {
    final res = await http.delete(Uri.parse("$baseUrl/$id"));
    if (res.statusCode != 200) throw Exception("Failed to delete");
  }

  static Future<void> updateCustomer(String id, String name, String phone, String district, String neighborhood) async {
    final res = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "phone": phone, "district": district, "neighborhood": neighborhood}),
    );
    if (res.statusCode != 200) throw Exception("Failed to update");
  }
}

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});
  @override
  _CustomerPageState createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final List<Map<String, String>> _customers = [];
  List<Map<String, String>> _filteredCustomers = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _neighborhoodController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    setState(() => _loading = true);
    try {
      List data = await CustomerApiService.getCustomers();
      setState(() {
        _customers.clear();
        _customers.addAll(data.map<Map<String, String>>((e) => {
              "id": e['id'].toString(),
              "name": e['name'] ?? "",
              "phone": e['phone'] ?? "",
              "district": e['district'] ?? "",
              "neighborhood": e['neighborhood'] ?? "",
            }));
        _filteredCustomers = List.from(_customers);
      });
    } catch (e) {
      debugPrint("Fetch error: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _addCustomer() async {
    if (_nameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      await CustomerApiService.addCustomer(
        _nameController.text.trim(),
        _phoneController.text.trim(),
        _districtController.text.trim(),
        _neighborhoodController.text.trim(),
      );
      await _fetchCustomers();
      _nameController.clear();
      _phoneController.clear();
      _districtController.clear();
      _neighborhoodController.clear();
    } catch (e) {
      debugPrint("Add error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _deleteCustomer(String id) async {
    try {
      await CustomerApiService.deleteCustomer(id);
      await _fetchCustomers();
    } catch (e) {
      debugPrint("Delete error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Customer Registry"), backgroundColor: Colors.teal),
      body: _loading ? const Center(child: CircularProgressIndicator()) : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Name")),
                TextField(controller: _phoneController, decoration: const InputDecoration(labelText: "Phone")),
                TextField(controller: _districtController, decoration: const InputDecoration(labelText: "District")),
                TextField(controller: _neighborhoodController, decoration: const InputDecoration(labelText: "Neighborhood")),
                ElevatedButton(onPressed: _addCustomer, child: const Text("Add New Customer")),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCustomers.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(_filteredCustomers[index]['name']!),
                subtitle: Text(_filteredCustomers[index]['phone']!),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteCustomer(_filteredCustomers[index]['id']!),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}