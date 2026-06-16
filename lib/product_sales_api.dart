import 'dart:convert';
import 'package:http/http.dart' as http;

// ⬇️ ADEEGGA IIBKA BUUGAAGTA (PRODUCT SALES API SERVICE) ⬇️
class ProductSalesApiService {
static const String baseUrl = "https://stationary-backend-6fh1.onrender.com/api/sales";
  // Tikitka iibka oo dhan ka soo akhri Database-ka
  static Future<List<Map<String, dynamic>>> getSales() async {
    try {
      final res = await http.get(Uri.parse(baseUrl));
      if (res.statusCode == 200) {
        final List dynamicList = jsonDecode(res.body);
        return List<Map<String, dynamic>>.from(dynamicList);
      } else {
        throw Exception("Failed to load sales");
      }
    } catch (e) {
      print("GET SALES ERROR: $e");
      return [];
    }
  }

  // Toos ugu keydi iibka cusub database-ka
  static Future<bool> addSale(Map<String, dynamic> saleData) async {
    try {
      final res = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(saleData),
      );
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      print("POST SALE ERROR: $e");
      return false;
    }
  }
}

// ⬇️ REER BACKEND: ADEEGGA BUUGAAGTA (BOOKS API SERVICE) ⬇️
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

// ⬇️ REER BACKEND: ADEEGGA MAALIYADDA (FINANCE API SERVICE) ⬇️
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