import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:stationary_app/customer_page.dart';
import 'package:stationary_app/service/api_service.dart' hide CustomerApiService;

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  
  Future<Map<String, dynamic>> _fetchGeneralReportData() async {
    try {
      final results = await Future.wait([
        CustomerApiService.getCustomers(),
        SalesApiService.getSales(),
        FinanceApiService.getTransactions(),
        EmployeeApiService.getEmployees(),
      ]);

      List customers = results[0];
      List sales = results[1];
      List transactions = results[2];
      List employees = results[3];

      double totalIncome = 0;
      double totalExpense = 0;

      for (var tx in transactions) {
        double amount = double.tryParse(tx['amount']?.toString() ?? '0') ?? 0.0;
        if (tx['type'].toString().toLowerCase() == 'income') {
          totalIncome += amount;
        } else if (tx['type'].toString().toLowerCase() == 'expense') {
          totalExpense += amount;
        }
      }

      for (var sale in sales) {
        double price = double.tryParse(sale['price']?.toString() ?? '0') ?? 0.0;
        int qty = int.tryParse(sale['quantity']?.toString() ?? '1') ?? 1;
        totalIncome += (price * qty);
      }

      return {
        'customerCount': customers.length,
        'salesCount': sales.length,
        'employeeCount': employees.length,
        'totalIncome': totalIncome,
        'totalExpense': totalExpense,
        'netFinance': totalIncome - totalExpense,
      };
    } catch (e) {
      print("REPORT FETCH ERROR: $e");
      return {
        'customerCount': 0,
        'salesCount': 0,
        'employeeCount': 0,
        'totalIncome': 0.0,
        'totalExpense': 0.0,
        'netFinance': 0.0,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final dynamic args = ModalRoute.of(context)?.settings.arguments;
    final String userRole = (args is String ? args : 'admin').toLowerCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text(
          "GENERAL REPORT", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)
        ),
        backgroundColor: Colors.blue[800],
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white, size: 28),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchGeneralReportData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("An error occurred: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("No data available"));
          }

          final data = snapshot.data!;
          int customerCount = data['customerCount'];
          int salesCount = data['salesCount'];
          int employeeCount = data['employeeCount'];
          double netFinance = data['netFinance'];
          double totalIncome = data['totalIncome'];
          double totalExpense = data['totalExpense'];

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text(
                  "General Report",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
                const SizedBox(height: 20),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildReportCard("Customers", "$customerCount", Icons.people, Colors.teal, () => Navigator.pushNamed(context, '/customers', arguments: userRole)),
                      _buildReportCard("Total Sales", "$salesCount", Icons.shopping_cart, Colors.orange, () => Navigator.pushNamed(context, '/sales', arguments: userRole)),
                      _buildReportCard("Finance Balance", "\$${netFinance.toStringAsFixed(2)}", Icons.monetization_on, Colors.green, () => Navigator.pushNamed(context, '/finance', arguments: userRole)),
                      _buildReportCard("Employees", "$employeeCount", Icons.badge, Colors.purple, () => Navigator.pushNamed(context, '/employees', arguments: userRole)),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                const Text(
                  "BUSINESS GROWTH",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                _buildLineChartCard(),
                const SizedBox(height: 30),

                const Text(
                  "FINANCIAL DISTRIBUTION",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                _buildDistributionCard(totalIncome, totalExpense, customerCount.toDouble()),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReportCard(String title, String value, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 15, bottom: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
          ],
          border: Border(
            bottom: BorderSide(color: color, width: 4),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                Icon(icon, color: color, size: 22),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChartCard() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                const FlSpot(0, 2),
                const FlSpot(1, 4),
                const FlSpot(2, 3.2),
                const FlSpot(3, 6),
                const FlSpot(4, 4.5),
                const FlSpot(5, 7),
              ],
              isCurved: true,
              color: Colors.blue[700],
              barWidth: 4,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionCard(double income, double expense, double customers) {
    double total = income + expense + customers;
    
    double incomePercent = total > 0 ? (income / total) * 100 : 33.3;
    double expensePercent = total > 0 ? (expense / total) * 100 : 33.3;
    double customerPercent = total > 0 ? (customers / total) * 100 : 33.3;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          SizedBox(
            height: 120,
            width: 120,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 30,
                sections: [
                  PieChartSectionData(color: Colors.blue, value: customerPercent, title: '${customerPercent.toStringAsFixed(0)}%', radius: 20, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                  PieChartSectionData(color: Colors.teal, value: incomePercent, title: '${incomePercent.toStringAsFixed(0)}%', radius: 20, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                  PieChartSectionData(color: Colors.orange, value: expensePercent, title: '${expensePercent.toStringAsFixed(0)}%', radius: 20, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 25),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegendItem("Customers (${customers.toInt()})", Colors.blue),
                const SizedBox(height: 10),
                _buildLegendItem("Total Revenue (\$$income)", Colors.teal),
                const SizedBox(height: 10),
                _buildLegendItem("Total Expenses (\$$expense)", Colors.orange),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87), overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}