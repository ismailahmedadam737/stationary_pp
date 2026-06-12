import 'dart:convert';
import 'package:http/http.dart' as http;

class CustomerApiService {
  static const String baseUrl = "https://stationary-backend-6fh1.onrender.com/api/customers";

  static Future<void> addCustomer(String name, String phone, String district, String neighborhood) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "phone": phone,
        "district": district,
        "neighborhood": neighborhood,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Server Error: ${response.statusCode} - ${response.body}");
    }
  }
}