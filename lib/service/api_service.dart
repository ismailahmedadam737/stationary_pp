import 'dart:convert';
import 'package:http/http.dart' as http;

// =========================================================================
// SETUP-KA IP-GA CENTRAL-KA AH
// =========================================================================
const String globalBaseUrl = "https://stationary-backend-6fh1.onrender.com/api";

// Helper function si aad ugu aragto console-ka waxa dhacaya
void _logError(String label, dynamic e) {
  print("🚨 $label: $e");
  print("🔗 URL-KA LA ISKU DAYAY: $globalBaseUrl");
}

// =========================================================================
// 1. QAYBTA LOGIN (AUTH)
// =========================================================================
class AuthApiService {
  static const String baseUrl = "$globalBaseUrl/auth";

  static Future<Map<String, dynamic>> loginUser(String username, String password) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        throw Exception("Login failed: ${res.statusCode}");
      }
    } catch (e) {
      _logError("LOGIN ERROR", e);
      rethrow;
    }
  }
}

// =========================================================================
// 2. QAYBTA USERS
// =========================================================================
class UserApiService {
  static const String baseUrl = "$globalBaseUrl/users";

  static Future<List> getUsers() async {
    try {
      final res = await http.get(Uri.parse(baseUrl));
      if (res.statusCode == 200) return jsonDecode(res.body);
      throw Exception("Failed to load users: ${res.statusCode}");
    } catch (e) {
      _logError("GET USERS ERROR", e);
      rethrow;
    }
  }

  static Future<void> addUser(String username, String password, String role) async {
    try {
      final res = await http.post(Uri.parse("$baseUrl/add"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"username": username, "password": password, "role": role}));
      if (res.statusCode != 200 && res.statusCode != 201) throw Exception(res.statusCode);
    } catch (e) {
      _logError("POST USER ERROR", e);
      rethrow;
    }
  }

  static Future<void> deleteUser(int id) async {
    try {
      final res = await http.delete(Uri.parse("$baseUrl/$id"));
      if (res.statusCode != 200) throw Exception(res.statusCode);
    } catch (e) {
      _logError("DELETE USER ERROR", e);
      rethrow;
    }
  }
}

// =========================================================================
// 3. QAYBTA FINANCE
// =========================================================================
class FinanceApiService {
  static const String baseUrl = "$globalBaseUrl/finance";

  static Future<List> getTransactions() async {
    try {
      final res = await http.get(Uri.parse(baseUrl));
      if (res.statusCode == 200) return jsonDecode(res.body);
      throw Exception(res.statusCode);
    } catch (e) {
      _logError("GET FINANCE ERROR", e);
      rethrow;
    }
  }

  static Future<void> addTransaction(String type, double amount, String note) async {
    try {
      final res = await http.post(Uri.parse(baseUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"type": type, "amount": amount, "note": note}));
      if (res.statusCode != 200 && res.statusCode != 201) throw Exception(res.statusCode);
    } catch (e) {
      _logError("POST FINANCE ERROR", e);
      rethrow;
    }
  }

  static Future<void> deleteTransaction(int id) async {
    try {
      final res = await http.delete(Uri.parse("$baseUrl/$id"));
      if (res.statusCode != 200) throw Exception(res.statusCode);
    } catch (e) {
      _logError("DELETE FINANCE ERROR", e);
      rethrow;
    }
  }
}

// =========================================================================
// 4. QAYBTA SALARY
// =========================================================================
class SalaryApiService {
  static const String baseUrl = "$globalBaseUrl/salaries";

  static Future<List> getSalaryHistory() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/history"));
      if (res.statusCode == 200) return jsonDecode(res.body);
      throw Exception(res.statusCode);
    } catch (e) {
      _logError("GET SALARY ERROR", e);
      rethrow;
    }
  }

  static Future<void> paySalary(Map<String, dynamic> salaryData) async {
    try {
      final res = await http.post(Uri.parse("$baseUrl/pay"),
          headers: {"Content-Type": "application/json"}, body: jsonEncode(salaryData));
      if (res.statusCode != 200 && res.statusCode != 201) throw Exception(res.statusCode);
    } catch (e) {
      _logError("POST SALARY ERROR", e);
      rethrow;
    }
  }
}

// =========================================================================
// 5. QAYBTA STOCK MANAGEMENT
// =========================================================================
class StockApiService {
  static const String baseUrl = "$globalBaseUrl/stock";

  static Future<List> getStock() async {
    try {
      final res = await http.get(Uri.parse(baseUrl));
      if (res.statusCode == 200) return jsonDecode(res.body);
      throw Exception(res.statusCode);
    } catch (e) {
      _logError("GET STOCK ERROR", e);
      rethrow;
    }
  }

  static Future<void> addBook(String title, String author, double price, int quantity) async {
    try {
      final res = await http.post(Uri.parse("$baseUrl/add"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"title": title, "author": author, "price": price, "quantity": quantity}));
      if (res.statusCode != 200 && res.statusCode != 201) throw Exception(res.statusCode);
    } catch (e) {
      _logError("POST STOCK ERROR", e);
      rethrow;
    }
  }

  static Future<void> deleteBook(int id) async {
    try {
      final res = await http.delete(Uri.parse("$baseUrl/$id"));
      if (res.statusCode != 200) throw Exception(res.statusCode);
    } catch (e) {
      _logError("DELETE STOCK ERROR", e);
      rethrow;
    }
  }
}

// =========================================================================
// 6. QAYBTA CUSTOMERS
// =========================================================================
class CustomerApiService {
  static const String baseUrl = "$globalBaseUrl/customers";

  static Future<List> getCustomers() async {
    try {
      final res = await http.get(Uri.parse(baseUrl));
      if (res.statusCode == 200) return jsonDecode(res.body);
      throw Exception(res.statusCode);
    } catch (e) {
      _logError("GET CUSTOMERS ERROR", e);
      rethrow;
    }
  }

  static Future<void> addCustomer(String name, String phone, String address) async {
    try {
      final res = await http.post(Uri.parse("$baseUrl/add"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"name": name, "phone": phone, "address": address}));
      if (res.statusCode != 200 && res.statusCode != 201) throw Exception(res.statusCode);
    } catch (e) {
      _logError("POST CUSTOMER ERROR", e);
      rethrow;
    }
  }

  static Future<void> deleteCustomer(int id) async {
    try {
      final res = await http.delete(Uri.parse("$baseUrl/$id"));
      if (res.statusCode != 200) throw Exception(res.statusCode);
    } catch (e) {
      _logError("DELETE CUSTOMER ERROR", e);
      rethrow;
    }
  }
}

// =========================================================================
// 7. QAYBTA SALES
// =========================================================================
class SalesApiService {
  static const String baseUrl = "$globalBaseUrl/sales";

  static Future<List> getSales() async {
    try {
      final res = await http.get(Uri.parse(baseUrl));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        return (decoded is List) ? decoded : (decoded['data'] ?? []);
      }
      throw Exception(res.statusCode);
    } catch (e) {
      _logError("GET SALES ERROR", e);
      rethrow;
    }
  }

  static Future<void> addSale(String productName, double price, int quantity) async {
    try {
      final res = await http.post(Uri.parse("$baseUrl/add"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"product_name": productName, "price": price, "quantity": quantity}));
      if (res.statusCode != 200 && res.statusCode != 201) throw Exception(res.statusCode);
    } catch (e) {
      _logError("POST SALE ERROR", e);
      rethrow;
    }
  }
}

// =========================================================================
// 8. QAYBTA EMPLOYEES
// =========================================================================
class EmployeeApiService {
  static const String baseUrl = "$globalBaseUrl/employees";

  static Future<List> getEmployees() async {
    try {
      final res = await http.get(Uri.parse(baseUrl));
      if (res.statusCode == 200) return jsonDecode(res.body);
      throw Exception(res.statusCode);
    } catch (e) {
      _logError("GET EMPLOYEES ERROR", e);
      rethrow;
    }
  }

  static Future<void> addEmployee(String name, String phone, String position, double salary) async {
    try {
      final res = await http.post(Uri.parse("$baseUrl/add"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"name": name, "phone": phone, "position": position, "salary": salary}));
      if (res.statusCode != 200 && res.statusCode != 201) throw Exception(res.statusCode);
    } catch (e) {
      _logError("POST EMPLOYEE ERROR", e);
      rethrow;
    }
  }

  static Future<void> deleteEmployee(int id) async {
    try {
      final res = await http.delete(Uri.parse("$baseUrl/$id"));
      if (res.statusCode != 200) throw Exception(res.statusCode);
    } catch (e) {
      _logError("DELETE EMPLOYEE ERROR", e);
      rethrow;
    }
  }

  static Future<void> updateEmployee(int id, String name, String phone, String position, double salary) async {
    try {
      final res = await http.put(Uri.parse("$baseUrl/$id"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"name": name, "phone": phone, "position": position, "salary": salary}));
      if (res.statusCode != 200) throw Exception(res.statusCode);
    } catch (e) {
      _logError("UPDATE EMPLOYEE ERROR", e);
      rethrow;
    }
  }
}