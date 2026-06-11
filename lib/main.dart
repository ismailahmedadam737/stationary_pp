import 'package:flutter/material.dart';
import 'package:stationary_app/ReportPage.dart';
import 'package:stationary_app/SalaryPage.dart';
import 'package:stationary_app/UsersPage.dart'; 
import 'package:stationary_app/employee.dart';
import 'package:stationary_app/sales_page.dart.dart';
import 'login_page.dart';
import 'admin_dashboard.dart';
import 'customer_page.dart';
import 'book_register.dart';
import 'finance_page.dart';

void main() {
  runApp(const StationaryApp());
}

class StationaryApp extends StatelessWidget {
  const StationaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Qaloon Stationary',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      initialRoute: '/', 
      routes: {
        '/': (context) => const LoginPage(),
        '/dashboard': (context) => const AdminDashboard(),
        '/customers': (context) => const CustomerPage(),
        '/books': (context) => const BookRegisterPage(),
        '/finance': (context) => FinancePage(),
        '/salary': (context) => const SalaryPage(employees: []),
        '/employees': (context) => const EmployeePage(),
        '/users': (context) => const UsersPage(), 
        '/reports': (context) => const ReportPage(),
        
        // 🌟 2. HALKAN HOOSE AYAA LAGU DARAY ROUTE-KA CUSUB EE /sales
        '/sales': (context) => const SalesPage(), 
      },
    );
  }
}