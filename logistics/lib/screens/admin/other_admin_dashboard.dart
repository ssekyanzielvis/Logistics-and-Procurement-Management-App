import 'package:flutter/material.dart';
import 'package:logistics/screens/admin/analytics_screen.dart';
import 'package:logistics/screens/admin/consignment_management_screen.dart';
import 'package:logistics/screens/admin/user_management_screen.dart';
import 'package:logistics/screens/client/chat_list_screen.dart';
import 'package:logistics/services/auth_service.dart';
import 'package:logistics/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OtherAdminDashboard extends StatefulWidget {
  const OtherAdminDashboard({super.key});

  @override
  State<OtherAdminDashboard> createState() => _OtherAdminDashboardState();
}

class _OtherAdminDashboardState extends State<OtherAdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    OtherAdminHomeScreen(),
    const ManageUsersScreen(),
    const ManageConsignmentsScreen(),
    const AnalyticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final fontScale = screenWidth / 400; // Base scale for font/icon sizes
    // e.g., 12px on 400px screen
    final toolbarHeight = screenWidth * 0.12; // e.g., 48px on 400px screen

    return Scaffold(
      appBar: AppBar(
        title: const Text('Board Members Dashboard'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        toolbarHeight: toolbarHeight, // Reduced to save vertical space
        actions: [
          IconButton(
            icon: Icon(Icons.chat, size: fontScale * 24), // Scaled icon size
            tooltip: 'Chats',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatListScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, size: fontScale * 24),
            tooltip: 'Logout',
            onPressed: () {
              Provider.of<AuthService>(context, listen: false).signOut();
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: Colors.grey,
        selectedFontSize: fontScale * 12, // Responsive font size
        unselectedFontSize: fontScale * 10,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard, size: fontScale * 24),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people, size: fontScale * 24),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping, size: fontScale * 24),
            label: 'Consignments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics, size: fontScale * 24),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }
}

class OtherAdminHomeScreen extends StatelessWidget {
  OtherAdminHomeScreen({super.key});

  final DashboardService _dashboardService = DashboardService();

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // Base scale for font/icon sizes
    final cardPadding = screenWidth * 0.03; // e.g., 12px on 400px screen
    final iconSize = screenWidth * 0.08; // e.g., 32px
    final valueFontSize = screenWidth * 0.05; // e.g., 20px
    final titleFontSize = screenWidth * 0.035; // e.g., 14px
    final childAspectRatio =
        screenWidth / screenHeight * 2.2; // Dynamic aspect ratio

    return Padding(
      padding: EdgeInsets.all(cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(cardPadding * 1.5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppConstants.primaryColor,
                  AppConstants.primaryColor.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<AuthService>(
                  builder: (context, authService, child) {
                    return FutureBuilder<Map<String, dynamic>?>(
                      future:
                          authService.currentUser != null
                              ? authService.getUserProfile(
                                authService.currentUser!.id,
                              )
                              : null,
                      builder: (context, snapshot) {
                        String displayName = 'Administrator';
                        if (snapshot.hasData && snapshot.data != null) {
                          displayName =
                              snapshot.data!['full_name'] ?? 'Administrator';
                        }
                        return Text(
                          'Welcome, $displayName',
                          style: TextStyle(
                            fontSize: valueFontSize * 1.2,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        );
                      },
                    );
                  },
                ),
                SizedBox(height: cardPadding * 0.5),
                Text(
                  'Manage your logistics operations efficiently',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    color: Colors.white70,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          SizedBox(height: cardPadding * 1.5),
          Text(
            'Quick Overview',
            style: TextStyle(
              fontSize: valueFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: cardPadding),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: cardPadding,
              mainAxisSpacing: cardPadding,
              padding: EdgeInsets.all(cardPadding),
              childAspectRatio: childAspectRatio, // Dynamic aspect ratio
              shrinkWrap: true,
              children: [
                FutureBuilder<int>(
                  future: _dashboardService.getTotalUsers(),
                  builder: (context, snapshot) {
                    return _buildStatCard(
                      context,
                      'Total Users',
                      snapshot.hasData
                          ? snapshot.data.toString()
                          : 'Loading...',
                      Icons.people,
                      Colors.blue,
                      iconSize,
                      valueFontSize,
                      titleFontSize,
                      cardPadding,
                    );
                  },
                ),
                FutureBuilder<int>(
                  future: _dashboardService.getActiveConsignments(),
                  builder: (context, snapshot) {
                    return _buildStatCard(
                      context,
                      'Active Consignments',
                      snapshot.hasData
                          ? snapshot.data.toString()
                          : 'Loading...',
                      Icons.local_shipping,
                      Colors.orange,
                      iconSize,
                      valueFontSize,
                      titleFontSize,
                      cardPadding,
                    );
                  },
                ),
                FutureBuilder<int>(
                  future: _dashboardService.getAvailableDrivers(),
                  builder: (context, snapshot) {
                    return _buildStatCard(
                      context,
                      'Available Drivers',
                      snapshot.hasData
                          ? snapshot.data.toString()
                          : 'Loading...',
                      Icons.drive_eta,
                      Colors.green,
                      iconSize,
                      valueFontSize,
                      titleFontSize,
                      cardPadding,
                    );
                  },
                ),
                FutureBuilder<int>(
                  future: _dashboardService.getCompletedToday(),
                  builder: (context, snapshot) {
                    return _buildStatCard(
                      context,
                      'Completed Today',
                      snapshot.hasData
                          ? snapshot.data.toString()
                          : 'Loading...',
                      Icons.check_circle,
                      Colors.purple,
                      iconSize,
                      valueFontSize,
                      titleFontSize,
                      cardPadding,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    double iconSize,
    double valueFontSize,
    double titleFontSize,
    double padding,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.7), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: iconSize, color: Colors.white),
            SizedBox(height: padding * 0.5),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: valueFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
            SizedBox(height: padding * 0.5),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Service to fetch dashboard statistics
class DashboardService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<int> getTotalUsers() async {
    final response = await _supabase.from('users').select().count();
    return response.count;
  }

  Future<int> getActiveConsignments() async {
    final response =
        await _supabase.from('consignments').select().inFilter('status', [
          'pending',
          'assigned',
          'in_transit',
        ]).count();
    return response.count;
  }

  Future<int> getAvailableDrivers() async {
    final response =
        await _supabase
            .from('users')
            .select()
            .eq('role', 'driver')
            .eq('is_active', true)
            .count();
    return response.count;
  }

  Future<int> getCompletedToday() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final response =
        await _supabase
            .from('consignments')
            .select()
            .eq('status', 'delivered')
            .gte('updated_at', startOfDay.toIso8601String())
            .lt('updated_at', endOfDay.toIso8601String())
            .count();
    return response.count;
  }
}
