import 'package:flutter/material.dart';
import 'package:stationary_app/service/api_service.dart';

class SalaryPage extends StatefulWidget {
  const SalaryPage({super.key, required List<dynamic> employees});

  @override
  State<SalaryPage> createState() => _SalaryPageState();
}

class _SalaryPageState extends State<SalaryPage> {
  List<dynamic> _employees = [];
  List<dynamic> _salaryHistory = [];
  bool _isLoading = false;

  String? _selectedEmployeeId;
  final TextEditingController _rewardController = TextEditingController(text: "0");
  final TextEditingController _penaltyController = TextEditingController(text: "0");

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final emps = await EmployeeApiService.getEmployees();
      final history = await SalaryApiService.getSalaryHistory();
      setState(() {
        _employees = emps;
        _salaryHistory = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // 🔹 Check if already paid this month
  bool _isAlreadyPaid(String empId) {
    final now = DateTime.now();
    return _salaryHistory.any((log) {
      DateTime payDate = DateTime.parse(log['payment_date']);
      return log['employee_id'].toString() == empId &&
          payDate.month == now.month &&
          payDate.year == now.year;
    });
  }

  void _processPayment() async {
    if (_selectedEmployeeId == null) return;
    
    final emp = _employees.firstWhere((e) => (e['id'] ?? e['_id']).toString() == _selectedEmployeeId);
    double basic = double.tryParse(emp['salary'].toString()) ?? 0;
    double reward = double.tryParse(_rewardController.text) ?? 0;
    double penalty = double.tryParse(_penaltyController.text) ?? 0;
    double total = basic + reward - penalty;

    Map<String, dynamic> data = {
      "employee_id": _selectedEmployeeId,
      "employee_name": emp['name'],
      "basic_salary": basic,
      "reward": reward,
      "penalty": penalty,
      "total_amount": total,
      "payment_date": DateTime.now().toIso8601String(),
    };

    try {
      await SalaryApiService.paySalary(data);
      _loadData();
      setState(() => _selectedEmployeeId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Salary has been paid successfully ✅"), backgroundColor: Colors.green)
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: const Text("SALARY MANAGEMENT", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: 18)),
        backgroundColor: const Color(0xFF0D47A1),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : Column(
            children: [
              // 1. Top Section (Form)
              _buildTopForm(),

              // 2. Bottom Section (History List)
              const Padding(
                padding: EdgeInsets.only(top: 20, left: 20, bottom: 10),
                child: Align(
                  alignment: Alignment.centerLeft, 
                  child: Text("RECENT PAYMENTS", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 1.2))
                ),
              ),
              Expanded(child: _buildHistoryList()),
            ],
          ),
    );
  }

  Widget _buildTopForm() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: const BoxDecoration(
        color: Color(0xFF0D47A1),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35)),
      ),
      child: Column(
        children: [
          // Beautiful Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
            child: DropdownButton<String>(
              isExpanded: true,
              underline: const SizedBox(),
              hint: const Text("Select Employee"),
              value: _selectedEmployeeId,
              items: _employees.map((e) => DropdownMenuItem(
                value: (e['id'] ?? e['_id']).toString(),
                child: Text(e['name']),
              )).toList(),
              onChanged: (val) => setState(() => _selectedEmployeeId = val),
            ),
          ),
          
          if (_selectedEmployeeId != null) ...[
            const SizedBox(height: 20),
            _buildActionCard(),
          ]
        ],
      ),
    );
  }

  Widget _buildActionCard() {
    final emp = _employees.firstWhere((e) => (e['id'] ?? e['_id']).toString() == _selectedEmployeeId);
    double basic = double.tryParse(emp['salary'].toString()) ?? 0;
    double reward = double.tryParse(_rewardController.text) ?? 0;
    double penalty = double.tryParse(_penaltyController.text) ?? 0;
    double total = basic + reward - penalty;
    bool alreadyPaid = _isAlreadyPaid(_selectedEmployeeId!);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          _inputRow("Basic Salary", "\$${basic.toStringAsFixed(2)}", isText: true),
          const Divider(),
          _inputRow("Reward (+)", "", controller: _rewardController, color: Colors.green),
          _inputRow("Penalty (-)", "", controller: _penaltyController, color: Colors.red),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Amount", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text("\$${total.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF0D47A1))),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: alreadyPaid ? null : _processPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: alreadyPaid ? Colors.grey : Colors.orange[800],
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(alreadyPaid ? "ALREADY PAID" : "PAY NOW", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _salaryHistory.length,
      itemBuilder: (context, index) {
        final log = _salaryHistory[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              const CircleAvatar(backgroundColor: Color(0xFFE3F2FD), child: Icon(Icons.check_circle, color: Colors.green, size: 20)),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(log['employee_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(log['payment_date'].toString().split('T')[0], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("\$${log['total_amount']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  const Text("PAID", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _inputRow(String label, String val, {TextEditingController? controller, bool isText = false, Color color = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          isText 
            ? Text(val, style: const TextStyle(fontWeight: FontWeight.bold))
            : SizedBox(
                width: 80,
                height: 35,
                child: TextField(
                  controller: controller,
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.number,
                  onChanged: (v) => setState(() {}),
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}