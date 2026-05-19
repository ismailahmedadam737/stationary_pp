import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stationary_app/SalesHistoryPage.dart';

// ⬇️ BACKEND TEAM: BOOKS API SERVICE ⬇️
class BookApiService {
  static const String baseUrl = "http://localhost:3000/api/books";

  static Future<List<String>> getBookNames() async {
    try {
      final res = await http.get(Uri.parse(baseUrl));
      if (res.statusCode == 200) {
        final List dynamicList = jsonDecode(res.body);
        return dynamicList.map((book) => book['title'].toString()).toList();
      } else {
        throw Exception("Failed to load books");
      }
    } catch (e) {
      print("GET BOOKS ERROR: $e");
      return []; 
    }
  }
}

// ⬇️ BACKEND TEAM: FINANCE API SERVICE ⬇️
class FinanceApiService {
  static const String baseUrl = "http://localhost:3000/api/finance";

  static Future<List> getTransactions() async {
    try {
      final res = await http.get(Uri.parse(baseUrl));
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        throw Exception("Failed to load transactions");
      }
    } catch (e) {
      print("GET FINANCE ERROR: $e");
      return [];
    }
  }
}

// ⬇️ BACKEND TEAM: SALES API SERVICE ⬇️
class SalesApiService {
  static const String baseUrl = "http://localhost:3000/api/sales";

  // Function 1: Loogu talogalay in iibka maanta la soo akhriyo
  static Future<List> getSales() async {
    try {
      final res = await http.get(Uri.parse(baseUrl));
      if (res.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(res.body);
        return responseData['data'] ?? []; // Wuxuu soo celinayaa liiska iibka dhabta ah
      }
      return [];
    } catch (e) {
      print("GET SALES ERROR: $e");
      return [];
    }
  }

  // Function 2: Loogu talogalay in iib cusub lagu kaydiyo DB
  static Future<bool> saveNewSale(Map<String, dynamic> saleData) async {
    try {
      final res = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'book_title': saleData['book_title'],
          'qty': saleData['qty'],
          'price': saleData['price'],
          'discount': saleData['discount'],
          'debt': saleData['debt'],
          'invoice_no': saleData['invoice_no'],
        }),
      );
      
      if (res.statusCode == 200 || res.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(res.body);
        return responseData['success'] ?? false;
      }
      return false;
    } catch (e) {
      print("POST SALE ERROR: $e");
      return false;
    }
  }
}

// ==========================================
// 1. MAIN SALES PAGE (DAILY SALES CONTROL)
// ==========================================
class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  // Waxaa laga dhigay firfirconi si uu database-ka xogta uga soo qaato
  List<dynamic> _salesItems = []; 

  double income = 0.0;
  double expenses = 0.0;
  
  double get netProfit => income - expenses;
  List<String> _fetchedBooks = [];

  @override
  void initState() {
    super.initState();
    _loadInitialBooks();
    _loadFinanceData(); 
    _loadTodaySales(); // 🆕 Halkan ku dar si uu u rido marka bogga la soo furo
  }

  void _loadInitialBooks() {
    BookApiService.getBookNames().then((books) {
      if (mounted) {
        setState(() {
          _fetchedBooks = books;
        });
      }
    });
  }

  // 🆕 Function-kan cusub wuxuu iibka ka soo dhex helayaa Database-ka rasmiga ah
  Future<void> _loadTodaySales() async {
    List sales = await SalesApiService.getSales();
    if (mounted) {
      setState(() {
        _salesItems = sales; // Halkan xogtii kumeel-gaadhka ahayd waxaa beddelay DB rasmiga ah
      });
    }
  }

  Future<void> _loadFinanceData() async {
    List transactions = await FinanceApiService.getTransactions();
    
    double tempIncome = 0.0;
    double tempExpenses = 0.0;

    for (var tx in transactions) {
      String type = (tx['type'] ?? '').toString().toLowerCase();
      double amount = double.tryParse(tx['amount'].toString()) ?? 0.0;

      if (type == 'income') {
        tempIncome += amount;
      } else if (type == 'expense' || type == 'expenses') {
        tempExpenses += amount;
      }
    }

    if (mounted) {
      setState(() {
        income = tempIncome;
        expenses = tempExpenses;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text(
          "SALES CONTROL", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)
        ),
        backgroundColor: Colors.blue[800],
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white, size: 28),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, size: 26),
            tooltip: "Sales History",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SalesHistoryPage()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildTopCard("Income", "\$${income.toStringAsFixed(2)}", Icons.arrow_upward_rounded, Colors.green),
                const SizedBox(width: 12),
                _buildTopCard("Expenses", "\$${expenses.toStringAsFixed(2)}", Icons.arrow_downward_rounded, Colors.red),
                const SizedBox(width: 12),
                _buildTopCard("Net Profit", "\$${netProfit.toStringAsFixed(2)}", Icons.gavel_rounded, Colors.blue),
              ],
            ),
            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Today's Sales", 
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddSaleDialog(context),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text("Add Sale", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _salesItems.isEmpty
                      ? const Center(child: Text("No sales items recorded today.", style: TextStyle(color: Colors.grey)))
                      : ListView.separated(
                          itemCount: _salesItems.length,
                          separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F3F9)),
                          itemBuilder: (context, index) {
                            final item = _salesItems[index];
                            
                            // Database total-ka isaga ayaa xisaabiya marka halkan xisaabtiisa ku dar UI-ga
                            double itemQty = double.tryParse(item['qty'].toString()) ?? 0;
                            double itemPrice = double.tryParse(item['price'].toString()) ?? 0;
                            double itemDiscount = double.tryParse(item['discount'].toString()) ?? 0;
                            double calculatedTotal = (itemQty * itemPrice) - itemDiscount;

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              title: Text(item['book_title'] ?? item['name'] ?? item['product_name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              subtitle: Text("Qty: ${item['qty']} | Price: \$${item['price']} | Debt: \$${item['debt']}"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "\$${calculatedTotal.toStringAsFixed(2)}", 
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[800]),
                                  ),
                                  const SizedBox(width: 15),
                                  IconButton(
                                    icon: const Icon(Icons.print_rounded, color: Colors.teal),
                                    onPressed: () => _openInvoicePage(context, item),
                                  ),
                                ],
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

  Widget _buildTopCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))],
          border: Border(top: BorderSide(color: color, width: 4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  void _showAddSaleDialog(BuildContext context) {
    final qtyController = TextEditingController();
    final priceController = TextEditingController();
    final totalController = TextEditingController();
    final discountController = TextEditingController();
    final debtController = TextEditingController();

    void calculateTotal() {
      double qty = double.tryParse(qtyController.text) ?? 0;
      double price = double.tryParse(priceController.text) ?? 0;
      double discount = double.tryParse(discountController.text) ?? 0;
      
      double total = (qty * price) - discount;
      totalController.text = total > 0 ? total.toStringAsFixed(2) : "";
    }

    qtyController.addListener(calculateTotal);
    priceController.addListener(calculateTotal);
    discountController.addListener(calculateTotal);

    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<List<String>>(
          future: BookApiService.getBookNames(),
          builder: (context, snapshot) {
            List<String> booksList = snapshot.data ?? _fetchedBooks;
            String? selectedBook = booksList.isNotEmpty ? booksList.first : null;

            return StatefulBuilder(
              builder: (context, setDialogState) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  backgroundColor: Colors.white,
                  title: Center(
                    child: Text(
                      "NEW SALE",
                      style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  content: snapshot.connectionState == ConnectionState.waiting && booksList.isEmpty
                      ? const SizedBox(
                          height: 100,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : SingleChildScrollView(
                          child: SizedBox(
                            width: 380,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                DropdownButtonFormField<String>(
                                  value: selectedBook,
                                  decoration: _inputDecoration("Select Book", Icons.book),
                                  items: booksList
                                      .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                                      .toList(),
                                  onChanged: (value) {
                                    setDialogState(() {
                                      selectedBook = value;
                                    });
                                  },
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  children: [
                                    Expanded(child: TextField(controller: qtyController, keyboardType: TextInputType.number, decoration: _inputDecoration("Qty", Icons.production_quantity_limits))),
                                    const SizedBox(width: 10),
                                    Expanded(child: TextField(controller: priceController, keyboardType: TextInputType.number, decoration: _inputDecoration("Price (\$)", Icons.attach_money))),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                TextField(
                                  controller: totalController,
                                  readOnly: true,
                                  decoration: _inputDecoration("Total (\$)", Icons.calculate, isReadOnly: true),
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  children: [
                                    Expanded(child: TextField(controller: discountController, keyboardType: TextInputType.number, decoration: _inputDecoration("Discount", Icons.percent))),
                                    const SizedBox(width: 10),
                                    Expanded(child: TextField(controller: debtController, keyboardType: TextInputType.number, decoration: _inputDecoration("Debt", Icons.money_off))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800], 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                      ),
                      onPressed: selectedBook == null ? null : () async {
                        if (qtyController.text.isNotEmpty && priceController.text.isNotEmpty) {
                          
                          // Diyaari xogta loo dirayo Backend-ka
                          final Map<String, dynamic> saleData = {
                            'book_title': selectedBook,
                            'qty': int.parse(qtyController.text),
                            'price': double.parse(priceController.text),
                            'discount': double.tryParse(discountController.text) ?? 0.0,
                            'debt': double.tryParse(debtController.text) ?? 0.0,
                            'invoice_no': DateTime.now().millisecondsSinceEpoch.toString().substring(7),
                          };

                          // U dir Database-ka oo sug inta uu ka jawaabayo
                          bool success = await SalesApiService.saveNewSale(saleData);

                          if (success) {
                            if (mounted) {
                              // Hadda si toos ah ayaan xogta DB uga soo aqrinaynaa si uusan u dhiman liisku
                              _loadTodaySales(); 
                              _loadFinanceData(); 
                              Navigator.pop(context);
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Iibka waa la kaydiyay! 💾"), backgroundColor: Colors.green),
                              );
                            }
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Iibka laguma kaydin karo database-ka! ❌"), backgroundColor: Colors.redAccent),
                              );
                            }
                          }
                        }
                      },
                      child: const Text("Save Sale", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, {bool isReadOnly = false}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blue[800], size: 20),
      filled: true,
      fillColor: isReadOnly ? Colors.grey[100] : const Color(0xFFF8FAFF),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
    );
  }

  void _openInvoicePage(BuildContext context, Map<String, dynamic> item) {
    double itemQty = double.tryParse(item['qty'].toString()) ?? 0;
    double itemPrice = double.tryParse(item['price'].toString()) ?? 0;
    double itemDiscount = double.tryParse(item['discount'].toString()) ?? 0;
    double calculatedTotal = (itemQty * itemPrice) - itemDiscount;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.grey[100], 
          appBar: AppBar(
            title: const Text("PRINT INVOICE", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black87),
          ),
          body: SingleChildScrollView(
            child: Center(
              child: Container(
                width: 500,
                padding: const EdgeInsets.all(30),
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Text("QALOON STATIONARY", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                          const Text("Tel: 063-666337 // 063-4688077", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          const Divider(height: 30),
                        ],
                      ),
                    ),
                    const Center(child: Text("INVOICE", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red))),
                    const SizedBox(height: 15),
                    Text("Date: ${DateTime.now().toString().substring(0, 10)}"),
                    const SizedBox(height: 25),
                    Table(
                      children: [
                        TableRow(
                          decoration: BoxDecoration(color: Colors.grey[100]),
                          children: const [
                            Padding(padding: EdgeInsets.all(8.0), child: Text("Item", style: TextStyle(fontWeight: FontWeight.bold))),
                            Padding(padding: EdgeInsets.all(8.0), child: Text("Qty", style: TextStyle(fontWeight: FontWeight.bold))),
                            Padding(padding: EdgeInsets.all(8.0), child: Text("Price", style: TextStyle(fontWeight: FontWeight.bold))),
                            Padding(padding: EdgeInsets.all(8.0), child: Text("Total", style: TextStyle(fontWeight: FontWeight.bold))),
                          ]
                        ),
                        TableRow(
                          children: [
                            Padding(padding: const EdgeInsets.all(8.0), child: Text(item['book_title'] ?? item['name'] ?? item['product_name'] ?? 'Unknown')),
                            Padding(padding: const EdgeInsets.all(8.0), child: Text("${item['qty'] ?? 0}")),
                            Padding(padding: const EdgeInsets.all(8.0), child: Text("\$${item['price'] ?? 0}")),
                            Padding(padding: const EdgeInsets.all(8.0), child: Text("\$${calculatedTotal.toStringAsFixed(2)}")),
                          ]
                        )
                      ],
                    ),
                    const Divider(),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Discount:"), Text("\$${item['discount'] ?? 0}")]),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Debt:"), Text("\$${item['debt'] ?? 0}")]),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("GRAND TOTAL:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                        Text("\$${calculatedTotal.toStringAsFixed(2)}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}