import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Waxaan u beddelnay IP-gaaga rasmiga ah ee mishiinka dhabta ah
static const String baseUrl = "https://stationary-backend-6fh1.onrender.com/api/books";
  static Future<List<Map<String, String>>> getItems() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      List data = jsonDecode(res.body);
      return data.map<Map<String, String>>((e) => {
            "id": e['id'].toString(),
            "title": e['title'] ?? "",
            "author": e['author'] ?? "", 
            "price": e['price']?.toString() ?? "",
            "type": e['type'] ?? "book", 
          }).toList();
    } else {
      throw Exception("Failed to fetch items");
    }
  }

  static Future<void> addBook(String title, String author, String price) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "title": title,
        "author": author,
        "price": price,
        "type": "book", 
      }),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception("Failed to add book");
    }
  }

  static Future<void> addGeneralItem(String name, String qty, String price) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "title": name,      
        "author": "Qty: $qty", 
        "price": price,      
        "type": "item",      
      }),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception("Failed to add item");
    }
  }

  static Future<void> deleteItem(String id) async {
    final res = await http.delete(Uri.parse("$baseUrl/$id"));
    if (res.statusCode != 200) {
      throw Exception("Failed to delete item");
    }
  }

  static Future<void> updateItem(String id, String title, String author, String price, String type) async {
    final res = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "title": title,
        "author": author,
        "price": price,
        "type": type,
      }),
    );
    if (res.statusCode != 200) {
      throw Exception("Failed to update item");
    }
  }

  static Future<List<Map<String, String>>> getBooks() async {
    List<Map<String, String>> allItems = await getItems();
    return allItems.where((item) => item['type'] == 'book').toList();
  }
}

class BookRegisterPage extends StatefulWidget {
  const BookRegisterPage({super.key});

  @override
  _BookRegisterPageState createState() => _BookRegisterPageState();
}

class _BookRegisterPageState extends State<BookRegisterPage> {
  final List<Map<String, String>> _allItems = [];
  List<Map<String, String>> _filteredItems = []; 
  
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _priceController = TextEditingController();
  
  final _itemNameController = TextEditingController();
  final _qtyController = TextEditingController();
  final _itemPriceController = TextEditingController();
  final _totalController = TextEditingController(text: "0.00");

  final _searchController = TextEditingController(); 
  
  bool _loading = false;
  bool _isBookForm = true; 

  String currentUserRole = 'admin'; 

  @override
  void initState() {
    super.initState();
    _refreshData();

    _qtyController.addListener(_calculateTotal);
    _itemPriceController.addListener(_calculateTotal);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _priceController.dispose();
    _itemNameController.dispose();
    _qtyController.dispose();
    _itemPriceController.dispose();
    _totalController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    double qty = double.tryParse(_qtyController.text) ?? 0;
    double price = double.tryParse(_itemPriceController.text) ?? 0;
    double total = qty * price;
    _totalController.text = total.toStringAsFixed(2);
  }

  Future<void> _refreshData() async {
    setState(() => _loading = true);
    try {
      List<Map<String, String>> data = await ApiService.getItems();
      setState(() {
        _allItems.clear();
        _allItems.addAll(data);
        _applyCurrentFilter();
      });
    } catch (e) {
      print("Fetch data error: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _applyCurrentFilter() {
    String query = _searchController.text.toLowerCase();
    String targetType = _isBookForm ? 'book' : 'item';

    _filteredItems = _allItems.where((item) {
      bool matchesType = item['type'] == targetType;
      bool matchesSearch = item['title']!.toLowerCase().contains(query) ||
          item['author']!.toLowerCase().contains(query);
      return matchesType && matchesSearch;
    }).toList();
  }

  void _filterItems(String query) {
    setState(() {
      _applyCurrentFilter();
    });
  }

  Future<void> _addBook() async {
    if (_titleController.text.isNotEmpty && _priceController.text.isNotEmpty) {
      try {
        await ApiService.addBook(_titleController.text, _authorController.text, _priceController.text);
        await _refreshData();
        _titleController.clear();
        _authorController.clear();
        _priceController.clear();
        FocusScope.of(context).unfocus();
      } catch (e) {
        print("Add book error: $e");
      }
    }
  }

  Future<void> _addItem() async {
    if (_itemNameController.text.isNotEmpty && _itemPriceController.text.isNotEmpty) {
      try {
        await ApiService.addGeneralItem(
          _itemNameController.text, 
          _qtyController.text.isEmpty ? "1" : _qtyController.text, 
          _itemPriceController.text
        );
        await _refreshData(); 
        
        _itemNameController.clear();
        _qtyController.clear();
        _itemPriceController.clear();
        _totalController.text = "0.00";
        FocusScope.of(context).unfocus();
      } catch (e) {
        print("Add item error: $e");
      }
    }
  }

  Future<void> _confirmDelete(Map<String, String> item) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), color: Colors.white),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 60, color: Colors.redAccent),
              const SizedBox(height: 15),
              Text(
                "Are you sure you want to delete '${item['title']}'?",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                "This action cannot be undone.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[300]),
                      child: const Text("CANCEL", style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await ApiService.deleteItem(item['id']!);
                        await _refreshData();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      child: const Text("DELETE", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEditDialog(Map<String, String> item) async {
    final titleController = TextEditingController(text: item['title']);
    final authorController = TextEditingController(text: item['author']);
    final priceController = TextEditingController(text: item['price']);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item['type'] == 'book' ? "Edit Book" : "Edit Item"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: InputDecoration(labelText: item['type'] == 'book' ? 'Title' : 'Item Name')),
            TextField(controller: authorController, decoration: InputDecoration(labelText: item['type'] == 'book' ? 'Author' : 'Quantity Info')),
            TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await ApiService.updateItem(item['id']!, titleController.text, authorController.text, priceController.text, item['type']!);
              await _refreshData();
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showItemDetails(Map<String, String> item) {
    bool isBook = item['type'] == 'book';
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
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(isBook ? Icons.menu_book_rounded : Icons.shopping_bag, size: 50, color: Colors.orange),
              ),
              const SizedBox(height: 15),
              Text(item['title']!, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 5),
              Text(isBook ? "Author: ${item['author']}" : "${item['author']}", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
              const Divider(height: 30),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text("Price: ", style: TextStyle(fontSize: 18)),
                Text("\$${item['price']}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
              ]),
              const SizedBox(height: 25),
              Theme(
                data: ThemeData(),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), padding: const EdgeInsets.symmetric(vertical: 15)),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("CLOSE", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange[800],
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: Row(
                  children: [
                    const Icon(Icons.book, size: 18),
                    Theme(data: ThemeData(), child: const SizedBox(width: 5)),
                    const Text("Add Book", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                selected: _isBookForm,
                selectedColor: Colors.white,
                backgroundColor: Colors.orange[900],
                labelStyle: TextStyle(color: _isBookForm ? Colors.orange[800] : Colors.white),
                onSelected: (val) {
                  setState(() {
                    _isBookForm = true;
                    _applyCurrentFilter();
                  });
                },
              ),
              const SizedBox(width: 15),
              ChoiceChip(
                label: Row(
                  children: [
                    const Icon(Icons.category, size: 18),
                    Theme(data: ThemeData(), child: const SizedBox(width: 5)),
                    const Text("Other Items", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                selected: !_isBookForm,
                selectedColor: Colors.white,
                backgroundColor: Colors.orange[900],
                labelStyle: TextStyle(color: !_isBookForm ? Colors.orange[800] : Colors.white),
                onSelected: (val) {
                  setState(() {
                    _isBookForm = false;
                    _applyCurrentFilter();
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 15),
          _isBookForm ? _buildBookFormFields() : _buildItemFormFields(),
        ],
      ),
    );
  }

  Widget _buildBookFormFields() {
    return Column(
      children: [
        _buildField(_titleController, "Book Title", Icons.book),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildField(_authorController, "Author Name", Icons.person_outline)),
            const SizedBox(width: 10),
            Expanded(child: _buildField(_priceController, "Price (\$)", Icons.attach_money, isNumber: true)),
          ],
        ),
        const SizedBox(height: 15),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.orange[800], minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
          onPressed: _addBook,
          child: const Text("Add New Book", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildItemFormFields() {
    return Column(
      children: [
        _buildField(_itemNameController, "Item Name", Icons.shopping_bag),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildField(_qtyController, "Qty", Icons.production_quantity_limits, isNumber: true)),
            const SizedBox(width: 10),
            Expanded(child: _buildField(_itemPriceController, "Price (\$)", Icons.attach_money, isNumber: true)),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _totalController,
          readOnly: true,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          decoration: InputDecoration(
            hintText: "Total",
            labelText: "Total Cost (\$)",
            labelStyle: const TextStyle(color: Colors.white70),
            prefixIcon: const Icon(Icons.calculate, color: Colors.white70),
            filled: true,
            fillColor: Colors.black.withOpacity(0.15),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 15),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.orange[800], minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
          onPressed: _addItem,
          child: const Text("Add New Item", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildField(TextEditingController controller, String hint, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white60, fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildItemCard(Map<String, String> item) {
    bool isBook = item['type'] == 'book';
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () => _showItemDetails(item),
        leading: Icon(isBook ? Icons.menu_book : Icons.shopping_bag, color: Colors.orange),
        title: Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(isBook ? "Author: ${item['author']}" : "${item['author']}"),
        trailing: currentUserRole == 'admin'
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showEditDialog(item)),
                  IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _confirmDelete(item)),
                ],
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("INVENTORY & BOOK REGISTRY", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.orange[800],
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildInputSection(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 15, 15, 5),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterItems,
                    decoration: InputDecoration(
                      hintText: "Search items, books or authors...",
                      prefixIcon: const Icon(Icons.search, color: Colors.orange),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.orange.shade100),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Colors.orange),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _isBookForm ? "REGISTERED BOOKS" : "REGISTERED ITEMS", 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)
                    ),
                  ),
                ),
                Expanded(
                  child: _filteredItems.isEmpty
                      ? const Center(child: Text("No items found."))
                      : ListView.builder(
                          padding: const EdgeInsets.all(15),
                          itemCount: _filteredItems.length,
                          itemBuilder: (context, index) => _buildItemCard(_filteredItems[index]),
                        ),
                ),
              ],
            ),
    );
  }
}

// ====================================================================
//    KALA SOOCIDDA SERVICE-YADA KALE EE CODHKAAGA (DHAMMAAN WAA LA SAXAY IP-ga)
// ====================================================================

class UserApiService {
  static const String baseUrl = "https://stationary-backend-6fh1.onrender.com/api/users";
  static Future<List> getUsers() async {
    try {
      final res = await http.get(Uri.parse(baseUrl));
      if (res.statusCode == 200) { return jsonDecode(res.body); } 
      else { throw Exception("Failed to load users: ${res.statusCode}"); }
    } catch (e) { print("GET USERS ERROR: $e"); rethrow; }
  }
  static Future<void> addUser(String username, String password, String role) async {
    try {
      final res = await http.post(Uri.parse("$baseUrl/add"), headers: {"Content-Type": "application/json"}, body: jsonEncode({"username": username, "password": password, "role": role}));
      if (res.statusCode == 200 || res.statusCode == 201) { print("User added successfully ✅"); } 
      else { throw Exception("Failed to add user: ${res.statusCode}"); }
    } catch (e) { print("POST USER ERROR: $e"); rethrow; }
  }
  static Future<void> deleteUser(String id) async {
    try {
      final res = await http.delete(Uri.parse("$baseUrl/$id"));
      if (res.statusCode == 200) { print("User deleted successfully ✅"); } 
      else { throw Exception("Failed to delete user: ${res.statusCode}"); }
    } catch (e) { print("DELETE USER ERROR: $e"); rethrow; }
  }
}

class AuthApiService {
  static const String baseUrl = "https://stationary-backend-6fh1.onrender.com/api/auth";
  static Future<Map<String, dynamic>> loginUser(String username, String password) async {
    try {
      final res = await http.post(Uri.parse("$baseUrl/login"), headers: {"Content-Type": "application/json"}, body: jsonEncode({"username": username, "password": password}));
      if (res.statusCode == 200) { return jsonDecode(res.body); } 
      else { final errorData = jsonDecode(res.body); throw Exception(errorData['message'] ?? "Login failed"); }
    } catch (e) { print("LOGIN ERROR: $e"); rethrow; }
  }
}

class SalesApiService {
  static const String baseUrl = "https://stationary-backend-6fh1.onrender.com/api/sales";
  static Future<List> getSales() async {
    try {
      final res = await http.get(Uri.parse(baseUrl));
      if (res.statusCode == 200) { final Map<String, dynamic> responseData = jsonDecode(res.body); return responseData['data'] ?? []; } 
      else { throw Exception("Failed to load sales: ${res.statusCode}"); }
    } catch (e) { print("GET SALES ERROR: $e"); rethrow; }
  }
  static Future<void> addSale(String productName, double price, int quantity) async {
    try {
      final res = await http.post(Uri.parse(baseUrl), headers: {"Content-Type": "application/json"}, body: jsonEncode({"product_name": productName, "price": price, "quantity": quantity}));
      if (res.statusCode == 200 || res.statusCode == 201) { print("Sale recorded successfully ✅"); } 
      else { throw Exception("Failed to record sale: ${res.statusCode}"); }
    } catch (e) { print("POST SALE ERROR: $e"); rethrow; }
  }
}

class EmployeeApiService {
  static const String baseUrl = "https://stationary-backend-6fh1.onrender.com/api/employees";
  static Future<List> getEmployees() async {
    try {
      final res = await http.get(Uri.parse(baseUrl));
      if (res.statusCode == 200) { return jsonDecode(res.body); } 
      else { throw Exception("Failed to load employees: ${res.statusCode}"); }
    } catch (e) { print("GET EMPLOYEES ERROR: $e"); rethrow; }
  }
  static Future<void> addEmployee(String name, String phone, String position, double salary) async {
    try {
      final res = await http.post(Uri.parse(baseUrl), headers: {"Content-Type": "application/json"}, body: jsonEncode({"name": name, "phone": phone, "position": position, "salary": salary}));
      if (res.statusCode == 200 || res.statusCode == 201) { print("Employee added successfully ✅"); } 
      else { throw Exception("Failed to add employee: ${res.statusCode}"); }
    } catch (e) { print("POST EMPLOYEE ERROR: $e"); rethrow; }
  }
  static Future<void> deleteEmployee(String id) async {
    try {
      final res = await http.delete(Uri.parse("$baseUrl/$id"));
      if (res.statusCode == 200) { print("Employee deleted successfully ✅"); } 
      else { throw Exception("Failed to delete employee: ${res.statusCode}"); }
    } catch (e) { print("DELETE EMPLOYEE ERROR: $e"); rethrow; }
  }
  static Future<void> updateEmployee(String id, String name, String phone, String position, double salary) async {
    try {
      final res = await http.put(Uri.parse("$baseUrl/$id"), headers: {"Content-Type": "application/json"}, body: jsonEncode({"name": name, "phone": phone, "position": position, "salary": salary}));
      if (res.statusCode == 200) { print("Employee updated successfully ✅"); } 
      else { throw Exception("Failed to update employee: ${res.statusCode}"); }
    } catch (e) { print("UPDATE EMPLOYEE ERROR: $e"); rethrow; }
  }
}

class SalaryApiService {
  static const String baseUrl = "https://stationary-backend-6fh1.onrender.com/api/salaries";
  static Future<List> getSalaryHistory() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/history"));
      if (res.statusCode == 200) { return jsonDecode(res.body); } 
      else { throw Exception("Failed to load salary history: ${res.statusCode}"); }
    } catch (e) { print("GET SALARY ERROR: $e"); rethrow; }
  }
  static Future<void> paySalary(Map<String, dynamic> salaryData) async {
    try {
      final res = await http.post(Uri.parse("$baseUrl/pay"), headers: {"Content-Type": "application/json"}, body: jsonEncode(salaryData));
      if (res.statusCode == 200 || res.statusCode == 201) { print("Salary payment recorded successfully ✅"); } 
      else { throw Exception("Failed to pay salary: ${res.statusCode}"); }
    } catch (e) { print("POST SALARY ERROR: $e"); rethrow; }
  }
}

class FinanceApiService {
  static const String baseUrl = "https://stationary-backend-6fh1.onrender.com/api/finance";
  static Future<List> getTransactions() async {
    try {
      final res = await http.get(Uri.parse(baseUrl));
      if (res.statusCode == 200) { return jsonDecode(res.body); } 
      else { throw Exception("Failed to load transactions: ${res.statusCode}"); }
    } catch (e) { print("GET FINANCE ERROR: $e"); rethrow; }
  }
  static Future<void> addTransaction(String type, double amount, String note) async {
    try {
      final res = await http.post(Uri.parse(baseUrl), headers: {"Content-Type": "application/json"}, body: jsonEncode({"type": type, "amount": amount, "note": note}));
      if (res.statusCode == 200 || res.statusCode == 201) { print("Transaction added successfully ✅"); } 
      else { throw Exception("Failed to add transaction: ${res.statusCode}"); }
    } catch (e) { print("POST FINANCE ERROR: $e"); rethrow; }
  }
  static Future<void> deleteTransaction(String id) async {
    try {
      final res = await http.delete(Uri.parse("$baseUrl/$id"));
      if (res.statusCode == 200) { print("Transaction deleted successfully ✅"); } 
      else { throw Exception("Failed to delete transaction: ${res.statusCode}"); }
    } catch (e) { print("DELETE FINANCE ERROR: $e"); rethrow; }
  }
}