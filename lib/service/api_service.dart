import 'dart:convert';
import 'package:http/http.dart' as http;

// =========================================================================
// SETUP-KA IP-GA CENTRAL-KA AH (Hadda wuxuu u jeedaa Render Server-kaaga)
// =========================================================================
// Beddelkan ku samee meesha aad ku qeexday globalBaseUrl
const String globalBaseUrl = "https://stationary-backend-6fh1.onrender.com/api";
// =========================================================================
// 1. QAYBTA LOGIN (AUTH) - ACTIVE ✅
// =========================================================================
class AuthApiService {
  static const String baseUrl = "$globalBaseUrl/auth";

  static Future<Map<String, dynamic>> loginUser(String username, String password) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(errorData['message'] ?? "Login failed");
      }
    } catch (e) {
      print("LOGIN ERROR: $e");
      rethrow;
    }
  }
}

// =========================================================================
// 2. QAYBTA USERS (MAAMULKA SYSTEM-KA) - ACTIVE ✅
// =========================================================================
class UserApiService {
  static const String baseUrl = "$globalBaseUrl/users";

  static Future<List> getUsers() async {
    try {
      final res = await http.get(Uri.parse(baseUrl));
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        throw Exception("Failed to load users: ${res.statusCode}");
      }
    } catch (e) {
      print("GET USERS ERROR: $e");
      rethrow;
    }
  }

  static Future<void> addUser(String username, String password, String role) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/add"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
          "role": role,
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        print("User added successfully ✅");
      } else {
        throw Exception("Failed to add user: ${res.statusCode}");
      }
    } catch (e) {
      print("POST USER ERROR: $e");
      rethrow;
    }
  }

  static Future<void> deleteUser(int id) async {
    try {
      final res = await http.delete(Uri.parse("$baseUrl/$id"));
      if (res.statusCode == 200) {
        print("User deleted successfully ✅");
      } else {
        throw Exception("Failed to delete user: ${res.statusCode}");
      }
    } catch (e) {
      print("DELETE USER ERROR: $e");
      rethrow;
    }
  }
}

// =========================================================================
// 3. QAYBTA FINANCE (MAALIYADDA) - ACTIVE ✅
// =========================================================================
class FinanceApiService {
  static const String baseUrl = "$globalBaseUrl/finance";

  static Future<List> getTransactions() async {
    try {
      final res = await http.get(Uri.parse(baseUrl));
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        throw Exception("Failed to load transactions: ${res.statusCode}");
      }
    } catch (e) {
      print("GET FINANCE ERROR: $e");
      rethrow;
    }
  }

  static Future<void> addTransaction(String type, double amount, String note) async {
    try {
      final res = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "type": type,
          "amount": amount,
          "note": note,
        }),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        print("Transaction added successfully ✅");
      } else {
        throw Exception("Failed to add transaction: ${res.statusCode}");
      }
    } catch (e) {
      print("POST FINANCE ERROR: $e");
      rethrow;
    }
  }

  static Future<void> deleteTransaction(int id) async {
    try {
      final res = await http.delete(Uri.parse("$baseUrl/$id"));
      if (res.statusCode == 200) {
        print("Transaction deleted successfully ✅");
      } else {
        throw Exception("Failed to delete transaction: ${res.statusCode}");
      }
    } catch (e) {
      print("DELETE FINANCE ERROR: $e");
      rethrow;
    }
  }
}

// =========================================================================
// 4. QAYBTA SALARY (MISHAARAADKA) - ACTIVE ✅
// =========================================================================
class SalaryApiService {
  static const String baseUrl = "$globalBaseUrl/salaries";

  static Future<List> getSalaryHistory() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/history"));
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        throw Exception("Failed to load salary history: ${res.statusCode}");
      }
    } catch (e) {
      print("GET SALARY ERROR: $e");
      rethrow;
    }
  }

  static Future<void> paySalary(Map<String, dynamic> salaryData) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/pay"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(salaryData),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        print("Salary payment recorded successfully ✅");
      } else {
        throw Exception("Failed to pay salary: ${res.statusCode}");
      }
    } catch (e) {
      print("POST SALARY ERROR: $e");
      rethrow;
    }
  }
}

// =========================================================================
// 5. QAYBTA CUSUB EE STOCK MANAGEMENT (TABLE: BOOKS) - FIXED 🛠️
// =========================================================================
class StockApiService {
  static const String baseUrl = "$globalBaseUrl/stock";

  static Future<List> getStock() async {
    try {
      final res = await http.get(Uri.parse(baseUrl));
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        throw Exception("Failed to load stock: ${res.statusCode}");
      }
    } catch (e) {
      print("GET STOCK ERROR: $e");
      rethrow;
    }
  }

  static Future<void> addBook(String title, String author, double price, int quantity) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/add"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "title": title,
          "author": author,
          "price": price,
          "quantity": quantity,
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        print("Product/Book added to stock successfully ✅");
      } else {
        throw Exception("Failed to add product: ${res.statusCode}");
      }
    } catch (e) {
      print("POST STOCK ERROR: $e");
      rethrow;
    }
  }

  static Future<void> deleteBook(int id) async {
    try {
      final res = await http.delete(Uri.parse("$baseUrl/$id"));
      if (res.statusCode == 200) {
        print("Product/Book deleted successfully ✅");
      } else {
        throw Exception("Failed to delete product: ${res.statusCode}");
      }
    } catch (e) {
      print("DELETE STOCK ERROR: $e");
      rethrow;
    }
  }
}

// =========================================================================
// 6. QAYBTA CUSUB EE CUSTOMERS (MACAAMIISHA) - FIXED 🛠️
// =========================================================================
class CustomerApiService {
  static const String baseUrl = "$globalBaseUrl/customers";

  static Future<List> getCustomers() async {
    try {
      final res = await http.get(Uri.parse(baseUrl));
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        throw Exception("Failed to load customers: ${res.statusCode}");
      }
    } catch (e) {
      print("GET CUSTOMERS ERROR: $e");
      rethrow;
    }
  }

  static Future<void> addCustomer(String name, String phone, String address) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/add"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "phone": phone,
          "address": address,
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        print("Customer added successfully ✅");
      } else {
        throw Exception("Failed to add customer: ${res.statusCode}");
      }
    } catch (e) {
      print("POST CUSTOMER ERROR: $e");
      rethrow;
    }
  }

  static Future<void> deleteCustomer(int id) async {
    try {
      final res = await http.delete(Uri.parse("$baseUrl/$id"));
      if (res.statusCode == 200) {
        print("Customer deleted successfully ✅");
      } else {
        throw Exception("Failed to delete customer: ${res.statusCode}");
      }
    } catch (e) {
      print("DELETE CUSTOMER ERROR: $e");
      rethrow;
    }
  }
}

// =========================================================================
// 7. QAYBTA CUSUB EE SALES (IIBKA PRODUCT-KASTA) - FIXED 🛠️
// =========================================================================
class SalesApiService {
  static const String baseUrl = "$globalBaseUrl/sales";

  static Future<List> getSales() async {
    try {
      final res = await http.get(Uri.parse(baseUrl));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is List) {
          return decoded;
        } else if (decoded is Map && decoded.containsKey('data')) {
          return decoded['data'] ?? [];
        }
        return [];
      } else {
        throw Exception("Failed to load sales: ${res.statusCode}");
      }
    } catch (e) {
      print("GET SALES ERROR: $e");
      rethrow;
    }
  }

  static Future<void> addSale(String productName, double price, int quantity) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/add"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "product_name": productName,
          "price": price,
          "quantity": quantity,
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        print("Sale recorded successfully ✅");
      } else {
        throw Exception("Failed to record sale: ${res.statusCode}");
      }
    } catch (e) {
      print("POST SALE ERROR: $e");
      rethrow;
    }
  }
}

// =========================================================================
// 8. QAYBTA EMPLOYEES (SHAQAALAHA) - ACTIVE ✅
// =========================================================================
class EmployeeApiService {
  static const String baseUrl = "$globalBaseUrl/employees";

  static Future<List> getEmployees() async {
    try {
      final res = await http.get(Uri.parse(baseUrl));
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        throw Exception("Failed to load employees: ${res.statusCode}");
      }
    } catch (e) {
      print("GET EMPLOYEES ERROR: $e");
      rethrow;
    }
  }

  static Future<void> addEmployee(String name, String phone, String position, double salary) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/add"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "phone": phone,
          "position": position,
          "salary": salary,
        }),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        print("Employee added successfully ✅");
      } else {
        throw Exception("Failed to add employee: ${res.statusCode}");
      }
    } catch (e) {
      print("POST EMPLOYEE ERROR: $e");
      rethrow;
    }
  }

  static Future<void> deleteEmployee(int id) async {
    try {
      final res = await http.delete(Uri.parse("$baseUrl/$id"));
      if (res.statusCode == 200) {
        print("Employee deleted successfully ✅");
      } else {
        throw Exception("Failed to delete employee: ${res.statusCode}");
      }
    } catch (e) {
      print("DELETE EMPLOYEE ERROR: $e");
      rethrow;
    }
  }

  static Future<void> updateEmployee(int id, String name, String phone, String position, double salary) async {
    try {
      final res = await http.put(
        Uri.parse("$baseUrl/$id"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "phone": phone,
          "position": position,
          "salary": salary,
        }),
      );
      if (res.statusCode == 200) {
        print("Employee updated successfully ✅");
      } else {
        throw Exception("Failed to update employee: ${res.statusCode}");
      }
    } catch (e) {
      print("UPDATE EMPLOYEE ERROR: $e");
      rethrow;
    }
  }
}