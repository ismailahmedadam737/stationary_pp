import 'dart:convert';
import 'dart:typed_data'; 
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stationary_app/SalesHistoryPage.dart';
import 'package:pdf/pdf.dart'; 
import 'package:pdf/widgets.dart' as pw; 
import 'package:printing/printing.dart'; 

class BookApiService {
  static const String baseUrl = "https://stationary-backend-6fh1.onrender.com/api/books";

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

class FinanceApiService {
  static const String baseUrl = "https://stationary-backend-6fh1.onrender.com/api/finance";

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

class SalesApiService {
static const String baseUrl = "https://stationary-backend-6fh1.onrender.com/api/sales";
  static Future<List> getSales() async {
    try {
      final res = await http.get(Uri.parse(baseUrl));
      if (res.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(res.body);
        return responseData['data'] ?? []; 
      }
      return [];
    } catch (e) {
      print("GET SALES ERROR: $e");
      return [];
    }
  }

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

class SaleItemRow {
  String? selectedBook;
  final qtyController = TextEditingController();
  final priceController = TextEditingController();

  SaleItemRow({this.selectedBook});
}

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
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
    _loadTodaySales(); 
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

  Future<void> _loadTodaySales() async {
    List sales = await SalesApiService.getSales();
    if (mounted) {
      setState(() {
        _salesItems = sales; 
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
    List<SaleItemRow> itemsList = [SaleItemRow()];

    final totalController = TextEditingController();
    final discountController = TextEditingController();
    final debtController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<List<String>>(
          future: BookApiService.getBookNames(),
          builder: (context, snapshot) {
            List<String> booksList = snapshot.data ?? _fetchedBooks;
            
            if (itemsList[0].selectedBook == null && booksList.isNotEmpty) {
              itemsList[0].selectedBook = booksList.first;
            }

            return StatefulBuilder(
              builder: (context, setDialogState) {

                void calculateTotal() {
                  double grandTotal = 0;
                  for (var item in itemsList) {
                    double qty = double.tryParse(item.qtyController.text) ?? 0;
                    double price = double.tryParse(item.priceController.text) ?? 0;
                    grandTotal += (qty * price);
                  }
                  double discount = double.tryParse(discountController.text) ?? 0;
                  double finalTotal = grandTotal - discount;
                  totalController.text = finalTotal > 0 ? finalTotal.toStringAsFixed(2) : "";
                }

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
                            width: 420,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: itemsList.length,
                                  itemBuilder: (context, index) {
                                    final row = itemsList[index];
                                    
                                    row.qtyController.removeListener(calculateTotal);
                                    row.priceController.removeListener(calculateTotal);
                                    row.qtyController.addListener(calculateTotal);
                                    row.priceController.addListener(calculateTotal);

                                   return Container(
  margin: const EdgeInsets.only(bottom: 15),
  padding: const EdgeInsets.all(10),
  decoration: BoxDecoration(
    color: Colors.grey[50],
    borderRadius: BorderRadius.circular(15),
    border: Border.all(color: Colors.grey[200]!),
  ),
  child: Column( // Isticmaal Column halkii aad Row isticmaali lahayd si uusan isugu dhicin
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Item #${index + 1}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800])),
          if (itemsList.length > 1)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              onPressed: () {
                setDialogState(() {
                  itemsList.removeAt(index);
                  calculateTotal();
                });
              },
            )
        ],
      ),
      const SizedBox(height: 5),
      // Halkan ka saar Expanded-ka haddii uu Column yahay, kaliya isticmaal Container ama si toos ah
      DropdownButtonFormField<String>(
        isExpanded: true,
        value: row.selectedBook,
        decoration: _inputDecoration("Select Book", Icons.book),
        items: booksList
            .map((label) => DropdownMenuItem(value: label, child: Text(label, overflow: TextOverflow.ellipsis)))
            .toList(),
        onChanged: (value) {
          setDialogState(() {
            row.selectedBook = value;
          });
        },
      ),
      const SizedBox(height: 10),
      Row( // Qaybtan hoose ee Qty iyo Price waa inay xor u ahaadaan
        children: [
          Expanded(child: TextField(controller: row.qtyController, keyboardType: TextInputType.number, decoration: _inputDecoration("Qty", Icons.production_quantity_limits))),
          const SizedBox(width: 10),
          Expanded(child: TextField(controller: row.priceController, keyboardType: TextInputType.number, decoration: _inputDecoration("Price (\$)", Icons.attach_money))),
        ],
      ),
    ],
  ),
);
                                  },
                                ),
                                
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: () {
                                      setDialogState(() {
                                        String? defaultBook = booksList.isNotEmpty ? booksList.first : null;
                                        itemsList.add(SaleItemRow(selectedBook: defaultBook));
                                      });
                                    },
                                    icon: const Icon(Icons.add_circle_outline),
                                    label: const Text("Add Another Item"),
                                    style: TextButton.styleFrom(foregroundColor: Colors.blue[800]),
                                  ),
                                ),
                                const Divider(),
                                const SizedBox(height: 5),
                                
                                TextField(
                                  controller: totalController,
                                  readOnly: true,
                                  decoration: _inputDecoration("Total (\$)", Icons.calculate, isReadOnly: true),
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  children: [
                                    Expanded(child: TextField(
                                      controller: discountController, 
                                      keyboardType: TextInputType.number, 
                                      decoration: _inputDecoration("Discount", Icons.percent),
                                      onChanged: (_) => calculateTotal(),
                                    )),
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
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ),
  onPressed: itemsList.any((element) => element.selectedBook == null) ? null : () async {
    bool valid = true;
    for (var item in itemsList) {
      if (item.qtyController.text.isEmpty || item.priceController.text.isEmpty) {
        valid = false;
      }
    }

    if (valid) {
      String combinedTitles = itemsList.map((e) => e.selectedBook).join(", ");
      int totalQty = itemsList.fold(0, (sum, item) => sum + (int.tryParse(item.qtyController.text) ?? 0));
      double totalPrice = itemsList.fold(0.0, (sum, item) => sum + ((double.tryParse(item.priceController.text) ?? 0) * (int.tryParse(item.qtyController.text) ?? 0)));
      
      // Xisaabinta Total-ka
      double discount = double.tryParse(discountController.text) ?? 0.0;
      double finalTotal = totalPrice - discount;

      final Map<String, dynamic> saleData = {
        'book_title': combinedTitles,
        'qty': totalQty,
        'price': totalQty > 0 ? (totalPrice / totalQty) : 0.0,
        'discount': discount,
        'debt': double.tryParse(debtController.text) ?? 0.0,
        'invoice_no': DateTime.now().millisecondsSinceEpoch.toString().substring(7),
        'total': finalTotal, // <--- Kani waa column-ka maqnaa ee server-ku diidanaa
      };

      debugPrint("📤 Diraya Xogta: $saleData");

      bool success = await SalesApiService.saveNewSale(saleData);

      if (success) {
        if (mounted) {
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fadlan buuxi Qty iyo Price-ka dhamaan alaabta! ⚠️"), backgroundColor: Colors.orange),
      );
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

  // =========================================================================
  // 🛠️ INVOICE GENERATION & PRINT FUNCTION (DGAAR-GAAR U KALA JABINAYA)
  // =========================================================================
  void _openInvoicePage(BuildContext context, Map<String, dynamic> item) {
    final String invoiceNo = item['invoice_no'] ?? DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    final String invoiceDate = DateTime.now().toString().substring(0, 10);
    final double itemDiscount = double.tryParse(item['discount'].toString()) ?? 0.0;
    final double itemDebt = double.tryParse(item['debt'].toString()) ?? 0.0;

    // Halkan waxaan ku kala jabinaynaa magacyada alaabaha haddii ay ku jiraan comma (, )
    final String fullTitle = item['book_title'] ?? item['name'] ?? item['product_name'] ?? 'Unknown';
    List<String> explicitItems = fullTitle.split(', ').where((element) => element.isNotEmpty).toList();

    // Maadaama backend-kii hore uu hal qty iyo hal price kaydinayay, waxaan u qaybinaynaa 
    // alaabaha si siman ama loogu muujiyo qaab safaf ah rasiidka dhexdiisa.
    double baseQty = double.tryParse(item['qty'].toString()) ?? 1;
    double basePrice = double.tryParse(item['price'].toString()) ?? 0;
    
    // Haddii ay alaabo badan yihiin, qty-ga guud waxaan u qaybinaynaa inta shay ee iibka ku jirta
    double qtyPerItem = explicitItems.length > 1 ? (baseQty / explicitItems.length).ceilToDouble() : baseQty;
    double pricePerItem = basePrice; 

    Future<Uint8List> generateInvoicePdf(PdfPageFormat format) async {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.roll80, 
          margin: const pw.EdgeInsets.all(12),
          build: (pw.Context context) {
            double subTotalSum = 0.0;
            List<pw.TableRow> tableRows = [];

            // 1. Ku darista Header-ka Shaxda (Table Header)
            tableRows.add(
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.lightBlue100),
                children: [
                  pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text("No", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize:6.5))),
                  pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text("Item Name", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5))),
                  pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text("Qty", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5), textAlign: pw.TextAlign.center)),
                  pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text("Price", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5), textAlign: pw.TextAlign.right)),
                  pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text("Amount", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8), textAlign: pw.TextAlign.right)),
                ],
              ),
            );

            // 2. Wareejinta dynamic-ga ah si shay kasta saf u gaar ah u yeesho
            for (int i = 0; i < explicitItems.length; i++) {
              double currentAmount = qtyPerItem * pricePerItem;
              subTotalSum += currentAmount;

              tableRows.add(
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2), child: pw.Text("${i + 1}", style: const pw.TextStyle(fontSize: 8.5))),
                    pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2), child: pw.Text(explicitItems[i], style: const pw.TextStyle(fontSize: 8.5))),
                    pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2), child: pw.Text("${qtyPerItem.toInt()}", style: const pw.TextStyle(fontSize: 8.5), textAlign: pw.TextAlign.center)),
                    pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2), child: pw.Text("\$${pricePerItem.toStringAsFixed(2)}", style: const pw.TextStyle(fontSize: 8.5), textAlign: pw.TextAlign.right)),
                    pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2), child: pw.Text("\$${currentAmount.toStringAsFixed(2)}", style: const pw.TextStyle(fontSize: 8.5), textAlign: pw.TextAlign.right)),
                  ],
                ),
              );
            }

            double grandFinalTotal = subTotalSum - itemDiscount;

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header-ka Ganacsiga
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        "QALOON STATIONARY", 
                        style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold, color: PdfColors.lightBlue900),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        "Tel: 063-666337 // 063-4688077", 
                        style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.black),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.Text(
                        "Hargeisa, Somaliland", 
                        style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.black),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                pw.SizedBox(height: 6),
                pw.Divider(thickness: 1, color: PdfColors.grey300),
                pw.SizedBox(height: 2),

                pw.Center(
                  child: pw.Text(
                    "INVOICE", 
                    style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.red),
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text("Invoice No: #$invoiceNo", style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.black)),
                pw.Text("Date: $invoiceDate", style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.black)),
                pw.SizedBox(height: 6),

                // Shaxda Nadiifta ah ee Alaabta (Dynamic Table)
                pw.Table(
                  columnWidths: {
                    0: const pw.FlexColumnWidth(0.6),  // No
                    1: const pw.FlexColumnWidth(3.2),  // Item Name
                    2: const pw.FlexColumnWidth(0.8),  // Qty
                    3: const pw.FlexColumnWidth(1.2),  // Price
                    4: const pw.FlexColumnWidth(1.4),  // Amount
                  },
                  children: tableRows,
                ),
                
                pw.Divider(thickness: 1, color: PdfColors.black),
                
                // Qaybta Xisaabaadka hoose (Summary)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Subtotal:", style: const pw.TextStyle(fontSize: 9)),
                    pw.Text("\$${subTotalSum.toStringAsFixed(2)}", style: const pw.TextStyle(fontSize: 9)),
                  ],
                ),
                if (itemDiscount > 0) ...[
                  pw.SizedBox(height: 2),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("Discount:", style: const pw.TextStyle(fontSize: 9, color: PdfColors.red700)),
                      pw.Text("-\$${itemDiscount.toStringAsFixed(2)}", style: const pw.TextStyle(fontSize: 9, color: PdfColors.red700)),
                    ],
                  ),
                ],
                if (itemDebt > 0) ...[
                  pw.SizedBox(height: 2),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("Debt (Haraa):", style: const pw.TextStyle(fontSize: 9, color: PdfColors.orange700)),
                      pw.Text("\$${itemDebt.toStringAsFixed(2)}", style: const pw.TextStyle(fontSize: 9, color: PdfColors.orange700)),
                    ],
                  ),
                ],

                pw.SizedBox(height: 4),
                pw.Divider(thickness: 1, color: PdfColors.grey400),
                pw.SizedBox(height: 2),

                // GRAND TOTAL (Halkii mar lagu soo qoray si weyn oo qurux leh)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end, 
                  children: [
                    pw.Text("TOTAL: ", style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.lightBlue900)),
                    pw.Text("\$${grandFinalTotal.toStringAsFixed(2)}", style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.lightBlue900)),
                  ],
                ),

                pw.SizedBox(height: 15),
                
                pw.Center(
                  child: pw.Text(
                    "Thank you for your business!!", 
                    style: pw.TextStyle(fontSize: 8.5, fontStyle: pw.FontStyle.italic),
                  ),
                ),
              ],
            );
          },
        ),
      );

      return pdf.save(); 
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text("PRINT RECEIPT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            backgroundColor: Colors.blue[800],
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.print_rounded, color: Colors.white, size: 26),
                tooltip: "Print Invoice",
                onPressed: () async {
                  Uint8List pdfBytes = await generateInvoicePdf(PdfPageFormat.roll80);
                  await Printing.layoutPdf(
                    onLayout: (PdfPageFormat format) async => pdfBytes,
                    name: 'Receipt_$invoiceNo',
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.download, color: Colors.white, size: 26),
                tooltip: "Download PDF",
                onPressed: () async {
                  Uint8List pdfBytes = await generateInvoicePdf(PdfPageFormat.roll80);
                  await Printing.sharePdf(
                    bytes: pdfBytes,
                    filename: 'Receipt_$invoiceNo.pdf',
                  );
                },
              ),
              const SizedBox(width: 10),
            ],
          ),
          body: PdfPreview(
            build: (format) => generateInvoicePdf(format), 
            allowPrinting: false, 
            allowSharing: false,  
            canChangePageFormat: false,
            canDebug: false,
          ),
        ),
      ),
    );
  }
}