import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// --------------------
// API Service
// --------------------
class ApiService {
  static const String baseUrl = "http://localhost:3000/api/books";

  static Future<List<Map<String, String>>> getBooks() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      List data = jsonDecode(res.body);
      return data.map<Map<String, String>>((e) => {
            "id": e['id'].toString(),
            "title": e['title'] ?? "",
            "author": e['author'] ?? "",
            "price": e['price']?.toString() ?? "",
          }).toList();
    } else {
      throw Exception("Failed to fetch books");
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
      }),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception("Failed to add book");
    }
  }

  static Future<void> deleteBook(String id) async {
    final res = await http.delete(Uri.parse("$baseUrl/$id"));
    if (res.statusCode != 200) {
      throw Exception("Failed to delete book");
    }
  }

  static Future<void> updateBook(String id, String title, String author, String price) async {
    final res = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "title": title,
        "author": author,
        "price": price,
      }),
    );
    if (res.statusCode != 200) {
      throw Exception("Failed to update book");
    }
  }
}

// --------------------
// BookRegisterPage
// --------------------
class BookRegisterPage extends StatefulWidget {
  const BookRegisterPage({super.key});

  @override
  _BookRegisterPageState createState() => _BookRegisterPageState();
}

class _BookRegisterPageState extends State<BookRegisterPage> {
  final List<Map<String, String>> _books = [];
  List<Map<String, String>> _filteredBooks = []; // Liiska raadinta lagu soo bandhigayo
  
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _priceController = TextEditingController();
  final _searchController = TextEditingController(); // Controller-ka raadinta
  
  bool _loading = false;

  // Set current user role here ('admin' or 'user')
  String currentUserRole = 'admin'; 

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    setState(() => _loading = true);
    try {
      List<Map<String, String>> data = await ApiService.getBooks();
      setState(() {
        _books.clear();
        _books.addAll(data);
        _filteredBooks = _books; // Marka hore dhamaan buugaagta tus
      });
    } catch (e) {
      print("Fetch books error: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  // Shaqada raadinta (Filtering)
  void _filterBooks(String query) {
    setState(() {
      _filteredBooks = _books
          .where((book) =>
              book['title']!.toLowerCase().contains(query.toLowerCase()) ||
              book['author']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _addBook() async {
    if (_titleController.text.isNotEmpty && _priceController.text.isNotEmpty) {
      try {
        await ApiService.addBook(_titleController.text, _authorController.text, _priceController.text);
        await _fetchBooks();
        _titleController.clear();
        _authorController.clear();
        _priceController.clear();
        FocusScope.of(context).unfocus();
      } catch (e) {
        print("Add book error: $e");
      }
    }
  }

  Future<void> _confirmDelete(Map<String, String> book) async {
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
              Icon(Icons.warning_amber_rounded, size: 60, color: Colors.redAccent),
              const SizedBox(height: 15),
              Text(
                "Are you sure you want to delete the book '${book['title']}'?",
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
                        await ApiService.deleteBook(book['id']!);
                        await _fetchBooks();
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

  Future<void> _showEditDialog(Map<String, String> book) async {
    final titleController = TextEditingController(text: book['title']);
    final authorController = TextEditingController(text: book['author']);
    final priceController = TextEditingController(text: book['price']);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Book"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: authorController, decoration: const InputDecoration(labelText: 'Author')),
            TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await ApiService.updateBook(book['id']!, titleController.text, authorController.text, priceController.text);
              await _fetchBooks();
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showBookDetails(Map<String, String> book) {
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
                child: const Icon(Icons.menu_book_rounded, size: 50, color: Colors.orange),
              ),
              const SizedBox(height: 15),
              Text(book['title']!, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 5),
              Text("Author: ${book['author']}", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
              const Divider(height: 30),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text("Price: ", style: TextStyle(fontSize: 18)),
                Text("\$${book['price']}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
              ]),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), padding: const EdgeInsets.symmetric(vertical: 15)),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("CLOSE PAGE", style: TextStyle(fontWeight: FontWeight.bold)),
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
      ),
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

  Widget _buildBookCard(Map<String, String> book) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () => _showBookDetails(book),
        leading: const Icon(Icons.menu_book, color: Colors.orange),
        title: Text(book['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Author: ${book['author']}"),
        trailing: currentUserRole == 'admin'
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showEditDialog(book)),
                  IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _confirmDelete(book)),
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
        title: const Text("BOOK REGISTRY", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                
                // --- SEARCH SECTION ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 15, 15, 5),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterBooks,
                    decoration: InputDecoration(
                      hintText: "Search book or author...",
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
                // -----------------------
                // --- BOOK LIST SECTION ---
                const Padding(
                  padding: EdgeInsets.only(top: 20, left: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("BOOK LIST", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
                  ),
                ),
                Expanded(
                  child: _filteredBooks.isEmpty
                      ? const Center(child: Text("No books found."))
                      : ListView.builder(
                          padding: const EdgeInsets.all(15),
                          itemCount: _filteredBooks.length,
                          itemBuilder: (context, index) => _buildBookCard(_filteredBooks[index]),
                        ),
                ),
              ],
            ),
    );
  }
}