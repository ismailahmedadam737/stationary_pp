import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stationary_app/book_register.dart';
import 'package:stationary_app/customer_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  Timer? _timer;
  
  final int _totalCards = 6; 

  @override
  void initState() {
    super.initState();
    
    _timer = Timer.periodic(const Duration(seconds: 10), (Timer timer) {
      if (_pageController.hasClients) {
        if (_currentPage < _totalCards - 1) {
          _currentPage++;
        } else {
          _currentPage = 0; 
        }

        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 1200), 
          curve: Curves.easeInOutQuart,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<Map<String, int>> _fetchStats() async {
    int booksCount = 0;
    int customersCount = 0;

    try {
      final results = await Future.wait([
        ApiService.getBooks(),         
        CustomerApiService.getCustomers(), 
      ] as Iterable<Future<dynamic>>);
      
      if (results[0] != null && results[0] is List) {
        booksCount = results[0].length;
      }
      if (results[1] != null && results[1] is List) {
        customersCount = results[1].length;
      }
    } catch (e) {
      print("Dashboard Stats Error: $e");
      
      try {
        final books = await ApiService.getBooks();
        booksCount = books.length;
      } catch (_) {}

      try {
        final customers = await CustomerApiService.getCustomers();
        customersCount = customers.length;
      } catch (_) {}
    }

    return {
      'books': booksCount,
      'customers': customersCount,
    };
  }

  @override
  Widget build(BuildContext context) {
    final dynamic args = ModalRoute.of(context)?.settings.arguments;
    final String userRole = (args is String ? args : 'admin').toLowerCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text(
          " QALOON STATIONARY ",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white, size: 28),
      ),
      drawer: _buildAdminDrawer(context, userRole), 
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              
              SizedBox(
                height: 230,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    _buildBigCard("Welcome back", userRole.toUpperCase(), "Work efficiently today!", Colors.blue[800]!, Icons.waving_hand_rounded, "https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?q=80&w=600&auto=format&fit=crop"),
                    _buildBigCard("Total Sales", "\$12,450.00", "Revenue increased by 15%.", Colors.teal[700]!, Icons.payments_rounded, "https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?q=80&w=600&auto=format&fit=crop"),
                    _buildBigCard("Notifications", "New Stock", "New stationery arrived.", Colors.orange[800]!, Icons.inventory_2_rounded, "https://images.unsplash.com/photo-1513542789411-b6a5d4f31634?q=80&w=600&auto=format&fit=crop"),
                    _buildBigCard("Management", "Employees", "Manage all staff members.", Colors.pink[800]!, Icons.people_outline_rounded, "https://images.unsplash.com/photo-1507842217343-583bb7270b66?auto=format&fit=crop&q=80&w=1000"),
                    _buildBigCard("Accounting", "Financial Analytics", "Check real-time revenues.", Colors.green[800]!, Icons.analytics_rounded, "https://images.unsplash.com/photo-1460925895917-afdab827c52f?q=80&w=600&auto=format&fit=crop"),
                    _buildBigCard("System Security", " Qaloon Stationary", "Modern secured system.", Colors.deepPurple[800]!, Icons.security_rounded, "https://images.unsplash.com/photo-1563986768609-322da13575f3?q=80&w=600&auto=format&fit=crop"),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Today's Overview",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                    const SizedBox(height: 20),
                    FutureBuilder<Map<String, int>>(
                      future: _fetchStats(),
                      builder: (context, snapshot) {
                        String bCount = snapshot.hasData ? snapshot.data!['books'].toString() : "...";
                        String cCount = snapshot.hasData ? snapshot.data!['customers'].toString() : "...";
                        return Row(
                          children: [
                            _buildStatCard("Books Registered", bCount, Icons.menu_book_rounded, Colors.indigo, () => Navigator.pushNamed(context, '/books', arguments: userRole)),
                            const SizedBox(width: 15),
                            _buildStatCard("Total Customers", cCount, Icons.people_alt_rounded, Colors.teal, () => Navigator.pushNamed(context, '/customers', arguments: userRole)),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 25),
                    _buildStatusBanner(userRole),
                    const SizedBox(height: 40),
                    _buildFooter(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBigCard(String topText, String mainTitle, String subText, Color color, IconData icon, String imageUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08), 
            blurRadius: 12, 
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[50],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: color.withOpacity(0.1),
                    child: Center(child: Icon(icon, color: color, size: 40)),
                  );
                },
              ),
            ),
            
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.65),
                      Colors.black.withOpacity(0.0),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),
            
            Positioned(
              right: 15, 
              top: 15, 
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.9),
                radius: 18,
                child: Icon(icon, color: color, size: 20),
              ),
            ),
            
            Positioned(
              left: 20,
              bottom: 15,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    topText.toUpperCase(), 
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9), 
                      fontSize: 11, 
                      fontWeight: FontWeight.bold, 
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    mainTitle, 
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 24, 
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subText, 
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12, 
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminDrawer(BuildContext context, String role) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: const BorderRadius.only(bottomRight: Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: SafeArea(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF00E676), 
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E676).withOpacity(0.4), 
                        blurRadius: 12,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: const Text(
                    "QALOON STATIONARY",
                    style: TextStyle(
                      color: Color(0xFF00C853), 
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10), 
                  _drawerTile(Icons.dashboard_rounded, "Dashboard", () => Navigator.pop(context), Colors.blue),
                  _drawerTile(Icons.people_alt_rounded, "Customers", () => Navigator.pushNamed(context, '/customers', arguments: role), Colors.teal),
                  _drawerTile(Icons.menu_book_rounded, "Stock Management", () => Navigator.pushNamed(context, '/books', arguments: role), Colors.orange),
                  
                  if (role == 'admin')
                    _drawerTile(Icons.analytics_rounded, "General report", () => Navigator.pushNamed(context, '/reports', arguments: role), Colors.purple),
                  
                  _drawerTile(Icons.shopping_cart_rounded, "Sales product", () => Navigator.pushNamed(context, '/sales', arguments: role), Colors.pink),
                  
                  if (role == 'admin') ...[
                    const Divider(),
                    _drawerTile(Icons.manage_accounts_rounded, "Users", () => Navigator.pushNamed(context, '/users', arguments: 'admin'), Colors.blueGrey),
                    _drawerTile(Icons.badge_rounded, "Employees", () => Navigator.pushNamed(context, '/employees', arguments: 'admin'), Colors.deepOrange),
                    _drawerTile(Icons.monetization_on_rounded, "Finance", () => Navigator.pushNamed(context, '/finance', arguments: 'admin'), Colors.green),
                    _drawerTile(Icons.payments_rounded, "Salary", () => Navigator.pushNamed(context, '/salary', arguments: 'admin'), Colors.deepPurple),
                  ],
                ],
              ),
            ),
          ),
          const Divider(),
          _drawerTile(Icons.logout_rounded, "Logout", () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false), Colors.red),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _drawerTile(IconData icon, String title, VoidCallback onTap, Color color) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
      onTap: onTap,
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 12),
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(title, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBanner(String role) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: role == 'admin' ? Colors.indigo[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: role == 'admin' ? Colors.indigo.shade100 : Colors.orange.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: role == 'admin' ? Colors.indigo : Colors.orange),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              role == 'admin' ? "Admin : You have full access ." : "User : You have limited access .",
              style: TextStyle(color: role == 'admin' ? Colors.indigo : Colors.orange.shade900, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 8),
              Text(
                " Developer:",
                style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 6),
              Text(
                "Ismail Ahmed Adam",
                style: TextStyle(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
        ],
      ),
    ); 
  }
}