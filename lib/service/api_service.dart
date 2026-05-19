import 'dart:convert';
import 'package:http/http.dart' as http;

// ⬇️ QAYBTA CUSUB EE USERS (MAAMULKA) ⬇️

class UserApiService {
  static const String baseUrl = "http://localhost:3000/api/users";

  // 🔹 GET ALL USERS
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

  // 🔹 ADD USER
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

  // 🔹 DELETE USER
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

// ⬇️ QAYBTA LOGIN (AUTH) ⬇️

class AuthApiService {
  static const String baseUrl = "http://localhost:3000/api/auth";

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

// ⬇️ QAYBTA CUSUB EE SALES (IIBKA) ⬇️

class SalesApiService {
  static const String baseUrl = "http://localhost:3000/api/sales";

  // 🔹 GET ALL SALES
  static Future<List> getSales() async {
    try {
      final res = await http.get(Uri.parse(baseUrl));
      if (res.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(res.body);
        return responseData['data'] ?? []; // Maadaama backend-ku uu ku soo celiyo { success: true, data: [...] }
      } else {
        throw Exception("Failed to load sales: ${res.statusCode}");
      }
    } catch (e) {
      print("GET SALES ERROR: $e");
      rethrow;
    }
  }

  // 🔹 ADD NEW SALE
  static Future<void> addSale(String productName, double price, int quantity) async {
    try {
      final res = await http.post(
        Uri.parse(baseUrl),
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

// ⬇️ QAYBTAADII HORE (CUSTOMER, EMPLOYEE, SALARY, FINANCE) ⬇️

class CustomerApiService {
  static const String baseUrl = "http://localhost:3000/api/customers";

  static Future<List> getCustomers() async {
    try {
      final res = await http.get(Uri.parse(baseUrl));
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        throw Exception("Failed to load customers: ${res.statusCode}");
      }
    } catch (e) {
      print("GET ERROR: $e");
      rethrow;
    }
  }

  static Future<void> addCustomer(
      String name, String phone, String district, String neighborhood) async {
    try {
      final res = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "phone": phone,
          "district": district,
          "neighborhood": neighborhood,
        }),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        print("Customer added successfully ✅");
      } else {
        throw Exception("Failed to add customer: ${res.statusCode}");
      }
    } catch (e) {
      print("POST ERROR: $e");
      rethrow;
    }
  }

  static Future<void> deleteCustomer(String id) async {
    try {
      final res = await http.delete(Uri.parse("$baseUrl/$id"));
      if (res.statusCode == 200) {
        print("Customer deleted successfully ✅");
      } else {
        throw Exception("Failed to delete customer: ${res.statusCode}");
      }
    } catch (e) {
      print("DELETE ERROR: $e");
      rethrow;
    }
  }

  static Future<void> updateCustomer(String id, String name, String phone,
      String district, String neighborhood) async {
    try {
      final res = await http.put(
        Uri.parse("$baseUrl/$id"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "phone": phone,
          "district": district,
          "neighborhood": neighborhood,
        }),
      );
      if (res.statusCode == 200) {
        print("Customer updated successfully ✅");
      } else {
        throw Exception("Failed to update customer: ${res.statusCode}");
      }
    } catch (e) {
      print("UPDATE ERROR: $e");
      rethrow;
    }
  }
}

class EmployeeApiService {
  static const String baseUrl = "http://localhost:3000/api/employees";

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

  static Future<void> addEmployee(
      String name, String phone, String position, double salary) async {
    try {
      final res = await http.post(
        Uri.parse(baseUrl),
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

  static Future<void> deleteEmployee(String id) async {
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

  static Future<void> updateEmployee(String id, String name, String phone,
      String position, double salary) async {
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

class SalaryApiService {
  static const String baseUrl = "http://localhost:3000/api/salaries";

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

class FinanceApiService {
  static const String baseUrl = "http://localhost:3000/api/finance";

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