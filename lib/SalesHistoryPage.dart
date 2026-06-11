import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SalesHistoryPage extends StatefulWidget {
  const SalesHistoryPage({super.key});

  @override
  State<SalesHistoryPage> createState() => _SalesHistoryPageState();
}

class _SalesHistoryPageState extends State<SalesHistoryPage> {
  List<dynamic> _allSales = [];
  List<dynamic> _filteredSales = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();

  final String _apiUrl = "http://localhost:3000/api/sales";

  @override
  void initState() {
    super.initState();
    _fetchSalesHistory();
  }

  Future<void> _fetchSalesHistory() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final res = await http.get(Uri.parse(_apiUrl));
      if (res.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(res.body);
        List<dynamic> rawSales = responseData['data'] ?? [];

        final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
        
        List<dynamic> recentSales = rawSales.where((sale) {
          if (sale == null || sale is! Map) return false;
          
          String rawDate = (sale['created_at'] ?? sale['sale_date'] ?? '').toString();
          if (rawDate.isEmpty) return false;
          try {
            DateTime saleDate = DateTime.parse(rawDate);
            return saleDate.isAfter(thirtyDaysAgo);
          } catch (e) {
            return true; 
          }
        }).toList();

        if (mounted) {
          setState(() {
            _allSales = recentSales;
            _filteredSales = _allSales;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      print("HISTORY FETCH ERROR: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _clearOldSales() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final res = await http.delete(Uri.parse("$_apiUrl/bulk-delete"));
      
      if (res.statusCode == 200) {
        await _fetchSalesHistory();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("All sales data older than 30 days has been deleted! 🗑️"), 
              backgroundColor: Colors.redAccent
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Deletion failed! ❌"), backgroundColor: Colors.orange),
          );
        }
      }
    } catch (e) {
      print("BULK DELETE ERROR: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterSales(String query) {
    setState(() {
      _filteredSales = _allSales.where((sale) {
        if (sale == null || sale is! Map) return false;

        String title = (sale['book_title'] ?? sale['product_name'] ?? '').toString().toLowerCase();
        String invoice = (sale['invoice_no'] ?? '').toString().toLowerCase();
        String searchQuery = query.toLowerCase();

        return title.contains(searchQuery) || invoice.contains(searchQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text("SALES HISTORY", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.indigo[900], 
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: "Refresh",
            onPressed: _fetchSalesHistory,
          ),
          IconButton(
            icon: const Icon(Icons.auto_delete_outlined, color: Colors.white, size: 26),
            tooltip: "Delete sales from the last 30 days",
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  title: const Text("Confirm Deletion"),
                  content: const Text("Are you sure you want to delete all sales older than 30 days?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _clearOldSales();
                      },
                      child: const Text("Yes", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: _filterSales,
              decoration: InputDecoration(
                hintText: "Search by Book Title or Invoice No...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredSales.isEmpty
                      ? const Center(child: Text("No transaction history found in the last 30 days.", style: TextStyle(color: Colors.grey)))
                      : Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: ListView.separated(
                              itemCount: _filteredSales.length,
                              separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F3F9)),
                              itemBuilder: (context, index) {
                                final sale = _filteredSales[index];
                                if (sale == null || sale is! Map) return const SizedBox.shrink();

                                String rawDate = (sale['created_at'] ?? sale['sale_date'] ?? '').toString();
                                String date = rawDate.length > 10 ? rawDate.substring(0, 10) : rawDate;

                                double qty = double.tryParse(sale['qty'].toString()) ?? 0;
                                double price = double.tryParse(sale['price'].toString()) ?? 0;
                                double discount = double.tryParse(sale['discount'].toString()) ?? 0;
                                double total = (qty * price) - discount;

                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          (sale['book_title'] ?? sale['product_name'] ?? 'Unknown Book').toString(), 
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text("#${sale['invoice_no'] ?? 'N/A'}", style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      "Qty: ${sale['qty'] ?? 0} | Price: \$${sale['price'] ?? 0} | Date: $date", 
                                      style: const TextStyle(fontSize: 13)
                                    ),
                                  ),
                                  trailing: Text(
                                    "\$${total.toStringAsFixed(2)}", 
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.indigo[900])
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}