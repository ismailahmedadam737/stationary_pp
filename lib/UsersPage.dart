import 'package:flutter/material.dart';
import 'package:stationary_app/service/api_service.dart';
// Hubi in magaca file-ka ApiService uu sax yahay

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  String _selectedRole = 'User';
  final List<String> _roles = ['User', 'Admin'];

  // Liiska Users-ka oo hadda madhan (Database ayaa laga soo rarayaa)
  List<dynamic> _usersList = [];
  bool _isLoading = true;

  final Color primaryGreen = const Color(0xFF00695C);

  @override
  void initState() {
    super.initState();
    _fetchUsers(); // Marka boggu kaco xogta keen
  }

  // 🔹 FUNCTION: Xogta ka keenaysa Database-ka
  Future<void> _fetchUsers() async {
    try {
      final data = await UserApiService.getUsers();
      setState(() {
        _usersList = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar("Khalad ayaa dhacay xogta lama keeni karo!");
    }
  }

  // 🔹 FUNCTION: Keydinta User-ka cusub (Database)
  void _addUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        await UserApiService.addUser(
          _usernameController.text.trim(),
          _passwordController.text.trim(),
          _selectedRole,
        );
        
        _usernameController.clear();
        _passwordController.clear();
        _showSnackBar("Isticmaalaha waa la diiwaangeliyey! ✅");
        
        // Dib u soo rari liiska si uu kan cusub ugu soo biiro
        _fetchUsers(); 
      } catch (e) {
        _showSnackBar("Username-ka waa la isticmaalay ama khalad baa jira!");
      }
    }
  }

  // 🔹 FUNCTION: Tirtirista User-ka
  void _deleteUser(int id) async {
    try {
      await UserApiService.deleteUser(id);
      _showSnackBar("User is deleted ✅");
      _fetchUsers();
    } catch (e) {
      _showSnackBar("Waa la tirtiri waayey user-ka!");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("USERS MANAGEMENT ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // --- QAYBTA DIIWAANGELINTA (Input Form) ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryGreen,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildInput(_usernameController, "Username", Icons.person_add),
                  const SizedBox(height: 10),
                  _buildInput(_passwordController, "Password", Icons.lock_outline, isPass: true),
                  const SizedBox(height: 10),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedRole,
                        dropdownColor: primaryGreen,
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        isExpanded: true,
                        items: _roles.map((String role) {
                          return DropdownMenuItem(
                            value: role,
                            child: Text(role),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedRole = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _addUser,
                    icon: const Icon(Icons.save, color: Color(0xFF00695C)),
                    label: const Text("Add New User ", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00695C))),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- QAYBTA LIISKA USERS-KA ---
          const Padding(
            padding: EdgeInsets.only(top: 20, left: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Users List", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
            ),
          ),
          
          Expanded(
            child: _isLoading 
              ? Center(child: CircularProgressIndicator(color: primaryGreen))
              : _usersList.isEmpty 
                ? const Center(child: Text("No Users registered"))
                : ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: _usersList.length,
                    itemBuilder: (context, index) {
                      final user = _usersList[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: primaryGreen.withOpacity(0.1),
                            child: Icon(Icons.person, color: primaryGreen),
                          ),
                          title: Text(user['username'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Role: ${user['role']}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Chip(
                                label: Text(user['role'] ?? '', style: const TextStyle(fontSize: 10, color: Colors.white)),
                                backgroundColor: user['role'] == 'Admin' ? Colors.orange : Colors.blueGrey,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () => _deleteUser(user['id']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String hint, IconData icon, {bool isPass = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPass,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white70),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white60),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      validator: (v) => v!.isEmpty ? "enter $hint" : null,
    );
  }
}