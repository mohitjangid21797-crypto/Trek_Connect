import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tracking_management_app/core/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:shimmer/shimmer.dart';
import '../../../core/local_storage.dart';
import '../../room_management/screens/qr_scanner.dart';
import '../../../shared_widgets/room_popup.dart';
import '../../company_module/screens/add_trek.dart';
import '../../company_module/screens/trek_history.dart';
import '../../user_module/screens/user_profile.dart';
import '../../user_module/screens/search_page.dart';
import '../../company_module/screens/company_details.dart';

class CombinedDashboard extends StatefulWidget {
  const CombinedDashboard({super.key});

  @override
  State<CombinedDashboard> createState() => _CombinedDashboardState();
}

class _CombinedDashboardState extends State<CombinedDashboard>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  bool _isLoading = true;

  // Dummy data for demonstration
  int totalTreks = 0;
  int activeTreks = 0;
  int totalParticipants = 0;
  double totalRevenue = 0;
  int scheduledTreks = 0;
  double totalDistance = 0;
  List<String> recentTreks = [
    'Everest Base Camp',
    'Annapurna Circuit',
    'Manaslu',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadTreksAndCalculateMetrics();
    // Simulate loading for shimmer effect
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
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
    _calculateMetrics(treks);
  }

  void _calculateMetrics(List<Map<String, dynamic>> treks) {
    int total = treks.length;
    int active = treks.where((trek) => trek['status'] == 'Active').length;
    int participants = treks.fold(
      0,
      (sum, trek) => sum + ((trek['participants'] as int?) ?? 0),
    );
    double revenue = treks.fold(0.0, (sum, trek) {
      String revenueStr = trek['revenue'] ?? '₹0';
      double rev = double.tryParse(revenueStr.replaceAll('₹', '')) ?? 0.0;
      return sum + rev;
    });
    int scheduled = treks.where((trek) => trek['status'] == 'Upcoming').length;

    setState(() {
      totalTreks = total;
      activeTreks = active;
      totalParticipants = participants;
      totalRevenue = revenue;
      scheduledTreks = scheduled;
    });
  }

  // Popular treks with images
  List<Map<String, dynamic>> popularTreks = [
    {
      'image': 'assets/images/everest.jpg',
      'name': 'Everest',
      'company': 'Adventure Nepal',
      'duration': '14 days',
      'difficulty': 'Hard',
      'price': '₹2500',
      'rating': 4.8,
    },
    {
      'image': 'assets/images/annapurna.jpg',
      'name': 'Annapurna',
      'company': 'Himalayan Treks',
      'duration': '10 days',
      'difficulty': 'Moderate',
      'price': '₹1800',
      'rating': 4.6,
    },
    {
      'image': 'assets/images/manaslu.jpg',
      'name': 'Manaslu',
      'company': 'Peak Adventures',
      'duration': '18 days',
      'difficulty': 'Hard',
      'price': '₹3000',
      'rating': 4.9,
    },
  ];

  // Camping adventures with images
  List<Map<String, dynamic>> campingAdventures = [
    {
      'image': 'assets/images/rishikesh.jpg',
      'name': 'Rishikesh',
      'company': 'River Adventures',
      'duration': '3 days',
      'difficulty': 'Easy',
      'price': '₹300',
      'rating': 4.5,
    },
    {
      'image': 'assets/images/valley_flowers.jpg',
      'name': 'Valley Flowers',
      'company': 'Nature Camps',
      'duration': '5 days',
      'difficulty': 'Moderate',
      'price': '₹500',
      'rating': 4.7,
    },
  ];

  // Quad view images
  final List<File?> _quadImages = [null, null, null, null];

  // Navigation
  int _currentIndex = 0;
  final List<Widget> _pages = [
    Container(), // Placeholder for home
    AddTrek(),
    TrekHistory(),
    UserProfile(),
    SearchPage(),
  ];

  void _showJoinByCodeDialog() {
    final TextEditingController codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(joinByCodeTitle),
        content: TextField(
          controller: codeController,
          decoration: InputDecoration(
            hintText: 'Enter room code',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle join by code logic
              String code = codeController.text.trim().toUpperCase();
              if (code.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Joining room with code: $code')),
                );
                Navigator.pop(context);
              }
            },
            child: Text('Join'),
          ),
        ],
      ),
    );
  }

  void _navigateToQRScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QrScanner()),
    );
  }

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
      return Stack(
        children: [
          _buildHomeContent(),
          Positioned(
            bottom: 16,
            right: 16,
            child: RoomPopup(
              onCodePressed: _showJoinByCodeDialog,
              onQRPressed: _navigateToQRScanner,
            ),
          ),
        ],
      );
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
          title: Text('Dashboard'),
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
            BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add Trek'),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
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
          _buildQuadView(),
          SizedBox(height: 24),
          Text(
            'Welcome to $appName',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Overview',
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
                child: _buildStatCard(
                  'Participants',
                  totalParticipants.toString(),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Revenue',
                  '\$${totalRevenue.toStringAsFixed(0)}',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Scheduled Treks',
                  scheduledTreks.toString(),
                ),
              ),
            ],
          ),

          Text(
            'Popular Treks',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          _isLoading
              ? _buildShimmerHorizontal()
              : SizedBox(
                  height: 300,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: popularTreks.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 200,
                        margin: EdgeInsets.only(right: 12),
                        child: _buildStaggeredPopularTrekCard(
                          popularTreks[index],
                          index,
                        ),
                      );
                    },
                  ),
                ),
          SizedBox(height: 24),
          Text(
            'Camping Adventures',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          _isLoading
              ? _buildShimmerHorizontal()
              : SizedBox(
                  height: 300,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: campingAdventures.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 200,
                        margin: EdgeInsets.only(right: 12),
                        child: _buildStaggeredPopularTrekCard(
                          campingAdventures[index],
                          index,
                        ),
                      );
                    },
                  ),
                ),
          SizedBox(height: 24),
          // Quick Actions
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 800),
                  builder: (context, animationValue, child) {
                    return Transform.scale(
                      scale: animationValue,
                      child: Opacity(
                        opacity: animationValue,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [textColor, primaryColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: textColor.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Scaffold(
                                    appBar: AppBar(
                                      title: Text('Add Trek'),
                                      backgroundColor: primaryColor,
                                    ),
                                    body: AddTrek(),
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Start New Trek',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
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
        case 'Participants':
          return Icons.people;
        case 'Revenue':
          return Icons.attach_money;
        case 'Scheduled Treks':
          return Icons.calendar_today;
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

  Widget _buildTrekInfoRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: primaryColor.withValues(alpha: 0.7)),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuadView() {
    return SizedBox(
      height: 200,
      child: GridView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 4,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _pickImage(index),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withValues(alpha: 0.1),
                    secondaryColor.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: _quadImages[index] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        _quadImages[index]!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    )
                  : Icon(
                      Icons.add_a_photo,
                      size: 40,
                      color: primaryColor.withValues(alpha: 0.7),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerHorizontal() {
    return SizedBox(
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 200,
            margin: EdgeInsets.only(right: 12),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStaggeredPopularTrekCard(Map<String, dynamic> trek, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 150)),
      builder: (context, animationValue, child) {
        return Transform.scale(
          scale: animationValue,
          child: Opacity(
            opacity: animationValue,
            child: GestureDetector(
              onTap: () {
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Trek: ${trek['name']} tapped'),
                    backgroundColor: primaryColor,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Card(
                  elevation: defaultElevation + 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          backgroundColor.withValues(alpha: 0.2),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Stack(
                              children: [
                                Image.asset(
                                  trek['image']!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: Icon(
                                        Icons.image,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.3),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: Container(
                                      margin: EdgeInsets.all(8),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withValues(
                                          alpha: 0.9,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.star,
                                            size: 14,
                                            color: Colors.amber,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            '${trek['rating']}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trek['name']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: textColor,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 6),
                              _buildTrekInfoRow(
                                Icons.business,
                                'Company: ${trek['company']}',
                              ),
                              _buildTrekInfoRow(
                                Icons.schedule,
                                'Duration: ${trek['duration']}',
                              ),
                              _buildTrekInfoRow(
                                Icons.terrain,
                                'Difficulty: ${trek['difficulty']}',
                              ),
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  trek['price']!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(int index) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _quadImages[index] = File(image.path);
      });
    }
  }
}
