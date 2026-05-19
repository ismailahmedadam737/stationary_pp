import 'package:flutter/material.dart';
import 'package:stationary_app/service/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _isLoading = false; 
  final Color primaryGreen = Colors.lightBlue;

  // 🔹 FUNCTION-KA LOGIN-KA OO DATABASE-KA KU XIDHAN
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Waxaan u yeeraynaa AuthApiService si loo hubiyo user-ka
      final response = await AuthApiService.loginUser(
        _userController.text.trim(),
        _passController.text.trim(),
      );

      if (!mounted) return;

      // 🔹 Hubi haddii success uu yahay true (sida uu soo celinayo Backend-ku)
      if (response['success'] == true || response['role'] != null) {
        
        _showSnackBar("Login Successful! Soo dhawaaw", Colors.green);

        // 🔹 MUHIIM: U gudbi Dashboard-ka adiga oo raacinaya Role-ka 
        // Role-ka wuxuu noqon karaa 'Admin' ama 'User'
        Navigator.pushReplacementNamed(
          context,
          '/dashboard',
          arguments: response['role'], 
        );
      } else {
        _showSnackBar("Username ama Password waa khaldan yahay!", Colors.red);
      }
      
    } catch (e) {
      if (!mounted) return;
      // Haddii password ama username khaldan yahay ama server error
      _showSnackBar("Khalad: Username ama Password waa khaldan yahay!", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.menu_book_rounded, size: 80, color: Colors.lightBlue),
                const SizedBox(height: 10),
                const Text(
                  " Welcome Qaloon Stationary",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _userController,
                  decoration: InputDecoration(
                    labelText: "Username",
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => v!.isEmpty ? "Fadlan geli username" : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => v!.isEmpty ? "Fadlan geli password" : null,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "LOGIN",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Hadii aadan lahayn akoon, la xiriir Maamulka (SuperAdmin).",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}