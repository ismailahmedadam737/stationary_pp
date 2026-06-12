import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CustomerApiService {
  static const String baseUrl = "https://stationary-backend-6fh1.onrender.com/api/customers";

  static Future<List> getCustomers() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to fetch customers");
    }
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
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception("Failed to add customer: ${res.statusCode}");
    }
  }

  static Future<void> deleteCustomer(String id) async {
    final res = await http.delete(Uri.parse("$baseUrl/$id"));
    if (res.statusCode != 200) {
      throw Exception("Failed to delete customer");
    }
  }

  static Future<void> updateCustomer(String id, String name, String phone, String district, String neighborhood) async {
    final res = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "phone": phone,
        "district": district,
        "neighborhood": neighborhood,
      }),
    );
    if (res.statusCode != 200) {
      throw Exception("Failed to update customer");
    }
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
  String currentUserRole = 'admin';

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  void _filterCustomers(String query) {
    setState(() {
      _filteredCustomers = _customers
          .where((customer) =>
              customer['name']!.toLowerCase().contains(query.toLowerCase()) ||
              customer['phone']!.contains(query))
          .toList();
    });
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
      print("Fetch error: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _addCustomer() async {
    if (_nameController.text.isNotEmpty && _phoneController.text.isNotEmpty) {
      setState(() => _loading = true);
      try {
        await CustomerApiService.addCustomer(
          _nameController.text,
          _phoneController.text,
          _districtController.text,
          _neighborhoodController.text,
        );
        await _fetchCustomers();
        _nameController.clear();
        _phoneController.clear();
        _districtController.clear();
        _neighborhoodController.clear();
        FocusScope.of(context).unfocus();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Customer saved successfully!"), backgroundColor: Colors.teal),
        );
      } catch (e) {
        print("Add error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error saving customer!"), backgroundColor: Colors.red),
        );
      } finally {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _deleteCustomer(Map<String, String> customer) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Warning!"),
        content: Text("Are you sure you want to delete ${customer['name']}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await CustomerApiService.deleteCustomer(customer['id']!);
        await _fetchCustomers();
      } catch (e) {
        print("Delete error: $e");
      }
    }
  }

  Future<void> _showEditDialog(Map<String, String> customer) async {
    final nameController = TextEditingController(text: customer['name']);
    final phoneController = TextEditingController(text: customer['phone']);
    final districtController = TextEditingController(text: customer['district']);
    final neighborhoodController = TextEditingController(text: customer['neighborhood']);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Customer"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone')),
            TextField(controller: districtController, decoration: const InputDecoration(labelText: 'District')),
            TextField(controller: neighborhoodController, decoration: const InputDecoration(labelText: 'Neighborhood')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await CustomerApiService.updateCustomer(
                customer['id']!,
                nameController.text,
                phoneController.text,
                districtController.text,
                neighborhoodController.text,
              );
              await _fetchCustomers();
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showCustomerDetails(Map<String, String> customer) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: 40, backgroundColor: Colors.teal.withOpacity(0.1), child: const Icon(Icons.person, size: 50, color: Colors.teal)),
              const SizedBox(height: 15),
              Text(customer['name']!, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const Divider(height: 30),
              _buildDetailRow(Icons.phone_android, "Phone", customer['phone']!),
              _buildDetailRow(Icons.location_city, "District", customer['district']!),
              _buildDetailRow(Icons.home_work, "Neighborhood", customer['neighborhood']!),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("CLOSE"),
                ),
              ),
            ],
          ),
        ),
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
        hintStyle: const TextStyle(color: Colors.white60, fontSize: 13),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildCustomerCard(Map<String, String> customer, String role) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () => _showCustomerDetails(customer),
        leading: CircleAvatar(backgroundColor: Colors.teal.withOpacity(0.1), child: Text(customer['name']![0].toUpperCase(), style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold))),
        title: Text(customer['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("📞 ${customer['phone']}", style: const TextStyle(fontSize: 13)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showEditDialog(customer)),
            IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: () => _deleteCustomer(customer)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal, size: 20),
          const SizedBox(width: 15),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text("Customer Registry", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), centerTitle: true, backgroundColor: Colors.teal, elevation: 0),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(color: Colors.teal, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))),
                  child: Column(
                    children: [
                      _buildInput(_nameController, "Customer Name", Icons.person),
                      const SizedBox(height: 10),
                      _buildInput(_phoneController, "Phone", Icons.phone, inputType: TextInputType.phone),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _buildInput(_districtController, "District", Icons.location_city)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildInput(_neighborhoodController, "Neighborhood", Icons.home)),
                        ],
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton.icon(
                        onPressed: _addCustomer,
                        icon: const Icon(Icons.check_circle),
                        label: const Text("Add New Customer", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[700], foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: _filteredCustomers.isEmpty
                        ? const Center(child: Text("No customers yet", style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            itemCount: _filteredCustomers.length,
                            itemBuilder: (context, index) => _buildCustomerCard(_filteredCustomers[index], currentUserRole),
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}