import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tracking_management_app/core/constants.dart';
import 'dart:async';
import '../../../core/local_storage.dart';
import '../../company_module/screens/add_trek.dart';
import '../../company_module/screens/bookings_screen.dart';
import '../../company_module/screens/company_details.dart';
import '../../company_module/screens/update_trek.dart';

class CompanyDashboard extends StatefulWidget {
  const CompanyDashboard({super.key});

  @override
  State<CompanyDashboard> createState() => _CompanyDashboardState();
}

class _CompanyDashboardState extends State<CompanyDashboard>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // Dummy data for demonstration
  int totalTreks = 0;
  int activeTreks = 0;
  int totalBookings = 0;
  double totalRevenue = 0;
  int pendingBookings = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadTreksAndCalculateMetrics();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadTreksAndCalculateMetrics();
    }
  }

  Future<void> _loadTreksAndCalculateMetrics() async {
    List<Map<String, dynamic>> treks = await LocalStorage.getTreks();
    List<Map<String, dynamic>> bookings = await LocalStorage.getBookings();
    _calculateMetrics(treks, bookings);
  }

  void _calculateMetrics(
    List<Map<String, dynamic>> treks,
    List<Map<String, dynamic>> bookings,
  ) {
    int total = treks.length;
    int active = treks.where((trek) => trek['status'] == 'Active').length;
    int totalBookingsCount = bookings.length;
    double revenue = treks.fold(0.0, (sum, trek) {
      String revenueStr = trek['revenue'] ?? '₹0';
      double rev = double.tryParse(revenueStr.replaceAll('₹', '')) ?? 0.0;
      return sum + rev;
    });
    int pending = bookings
        .where((booking) => booking['status'] == 'Pending')
        .length;

    setState(() {
      totalTreks = total;
      activeTreks = active;
      totalBookings = totalBookingsCount;
      totalRevenue = revenue;
      pendingBookings = pending;
    });
  }

  // Navigation
  int _currentIndex = 0;
  final List<Widget> _pages = [
    Container(), // Placeholder for home
    BookingsScreen(),
    AddTrek(),
    UpdateTrek(),
  ];

  void _onPopInvokedWithResult(bool didPop, dynamic result) {
    if (!didPop) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Exit App'),
          content: Text('Do you want to exit the app?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                SystemNavigator.pop();
              },
              child: Text('Yes'),
            ),
          ],
        ),
      );
    }
  }

  Widget _getCurrentPage() {
    if (_currentIndex == 0) {
      return _buildHomeContent();
    } else {
      return _pages[_currentIndex];
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _onPopInvokedWithResult,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Company Dashboard'),
          backgroundColor: primaryColor,
          actions: [
            IconButton(
              icon: Icon(Icons.business),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CompanyDetailsScreen(),
                  ),
                );
              },
              tooltip: 'Company Profile',
            ),
          ],
        ),
        body: _getCurrentPage(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == 0) {
              _loadTreksAndCalculateMetrics();
            }
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: const Color.fromARGB(255, 246, 247, 247),
          selectedItemColor: const Color.fromARGB(255, 3, 130, 58),
          unselectedItemColor: const Color.fromARGB(179, 3, 123, 37),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_online),
              label: 'Bookings',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add Trek'),
            BottomNavigationBarItem(
              icon: Icon(Icons.edit),
              label: 'Update Trek',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(
        defaultPadding,
      ).copyWith(top: 24, bottom: 24 + 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to $appName',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Company Overview',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Total Treks', totalTreks.toString()),
              ),
              SizedBox(width: 12),
              Expanded(child: _buildStatCard('Active', activeTreks.toString())),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('Bookings', totalBookings.toString()),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Revenue',
                  '₹${totalRevenue.toStringAsFixed(0)}',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('Pending', pendingBookings.toString()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String statValue) {
    // Get appropriate icon for each metric
    IconData getIconForTitle(String title) {
      switch (title) {
        case 'Total Treks':
          return Icons.hiking;
        case 'Active':
          return Icons.play_arrow;
        case 'Bookings':
          return Icons.book_online;
        case 'Revenue':
          return Icons.attach_money;
        case 'Pending':
          return Icons.pending;
        default:
          return Icons.bar_chart;
      }
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600),
      builder: (context, animationValue, child) {
        return Transform.scale(
          scale: animationValue,
          child: Opacity(
            opacity: animationValue,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(defaultBorderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(getIconForTitle(title), color: Colors.green, size: 32),
                    SizedBox(height: 8),
                    Text(
                      statValue,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
