import 'package:flutter/material.dart';
import 'package:stationary_app/service/api_service.dart';

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  List<dynamic> _transactions = []; // Made dynamic to synchronize with the API
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String _transactionType = 'Income';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData(); // Fetch data from database when the page opens
  }

  // 🔹 Function to fetch data from the Database
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await FinanceApiService.getTransactions();
      setState(() {
        _transactions = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print("Error loading data: $e");
    }
  }

  double get _totalIncome => _transactions
      .where((t) => t['type'] == 'Income')
      .fold(0.0, (sum, item) => sum + (double.tryParse(item['amount'].toString()) ?? 0));

  double get _totalExpenses => _transactions
      .where((t) => t['type'] == 'Expense')
      .fold(0.0, (sum, item) => sum + (double.tryParse(item['amount'].toString()) ?? 0));

  double get _netProfit => _totalIncome - _totalExpenses;

  // 🔹 Function to add data (Sends it to the Database)
  void _addTransaction() async {
    double? amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    try {
      await FinanceApiService.addTransaction(
        _transactionType,
        amount,
        _noteController.text.isEmpty ? "No note" : _noteController.text,
      );
      
      _amountController.clear();
      _noteController.clear();
      Navigator.pop(context);
      _loadData(); // Refresh the data
    } catch (e) {
      print("Error adding: $e");
    }
  }

  // 🔹 Function to delete data (Deletes it from the Database)
  void _deleteTransaction(int id) async {
    try {
      await FinanceApiService.deleteTransaction(id);
      _loadData(); // Refresh the data
    } catch (e) {
      print("Error deleting: $e");
    }
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("RECORD TRANSACTION", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue[900])),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _typeButton(setModalState, "Income", Colors.green),
                  const SizedBox(width: 20),
                  _typeButton(setModalState, "Expense", Colors.red),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Amount", border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(labelText: "Note", border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _transactionType == 'Income' ? Colors.green : Colors.red,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("SAVE TRANSACTION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeButton(StateSetter setModalState, String type, Color color) {
    bool isSelected = _transactionType == type;
    return GestureDetector(
      onTap: () => setModalState(() => _transactionType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color),
        ),
        child: Text(type, style: TextStyle(color: isSelected ? Colors.white : color, fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: const Text("PROFIT & EXPENSES", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0D47A1),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading 
      ? const Center(child: CircularProgressIndicator()) 
      : Column(
          children: [
            _buildSummaryHeader(),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Align(alignment: Alignment.centerLeft, child: Text("TRANSACTION HISTORY", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey))),
            ),
            Expanded(child: _buildTransactionList()),
          ],
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFF0D47A1),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF0D47A1),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("NET PROFIT", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    Text("\$${_netProfit.toStringAsFixed(2)}", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _netProfit >= 0 ? Colors.green : Colors.red)),
                  ],
                ),
                const Icon(Icons.account_balance_wallet, size: 40, color: Color(0xFF0D47A1)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _miniSummaryCard("INCOME", "\$${_totalIncome.toStringAsFixed(2)}", Icons.arrow_downward, Colors.green),
              const SizedBox(width: 15),
              _miniSummaryCard("EXPENSES", "\$${_totalExpenses.toStringAsFixed(2)}", Icons.arrow_upward, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniSummaryCard(String title, String amount, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text(amount, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    if (_transactions.isEmpty) {
      return const Center(child: Text("No data available yet"));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final item = _transactions[index];
        bool isIncome = item['type'] == 'Income';
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isIncome ? Colors.green[50] : Colors.red[50],
              child: Icon(isIncome ? Icons.add : Icons.remove, color: isIncome ? Colors.green : Colors.red),
            ),
            title: Text(item['note'] ?? "No note", style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(item['date'].toString().split('T')[0]),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${isIncome ? '+' : '-'}\$${item['amount']}",
                  style: TextStyle(fontWeight: FontWeight.bold, color: isIncome ? Colors.green : Colors.red, fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                  onPressed: () => _deleteTransaction(item['id']),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}