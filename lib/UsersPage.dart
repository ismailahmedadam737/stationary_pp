import 'package:flutter/material.dart';
import 'package:stationary_app/service/api_service.dart';

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

  List<dynamic> _usersList = [];
  bool _isLoading = true;

  final Color primaryGreen = const Color(0xFF00695C);

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final data = await UserApiService.getUsers();
      if (!mounted) return;
      setState(() {
        _usersList = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar("An error occurred, data could not be fetched!");
    }
  }

  void _addUser() async {
    // ⚠️ DIGNIIN: Hubinta in form-ku uu sax yahay ka hor inta aan la dirin
    if (_formKey.currentState!.validate()) {
      try {
        await UserApiService.addUser(
          _usernameController.text.trim(),
          _passwordController.text.trim(),
          _selectedRole,
        );
        
        _usernameController.clear();
        _passwordController.clear();
        _showSnackBar("User registered successfully! ✅");
        
        _fetchUsers(); 
      } catch (e) {
        _showSnackBar("Error: Username is already taken or server error!");
      }
    } else {
      _showSnackBar("Fadlan buuxi dhammaan goobaha loo baahan yahay! ⚠️");
    }
  }

  void _deleteUser(int id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
              SizedBox(width: 10),
              Text("Alert!", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text("Are you sure you want to delete this user?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await UserApiService.deleteUser(id.toString() as int);
                  _showSnackBar("User is deleted ✅");
                  _fetchUsers();
                } catch (e) {
                  _showSnackBar("Could not delete the user!");
                }
              },
              child: const Text("Yes, Delete", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
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
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () => _deleteUser(user['id']),
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
      // ⚠️ DIGNIIN: Validation-ka halkan ayaad ku arki kartaa
      validator: (v) => v == null || v.isEmpty ? "Please enter $hint" : null,
    );
  }
}