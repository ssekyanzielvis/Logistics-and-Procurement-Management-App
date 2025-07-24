import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistics/providers/auth_provider.dart';
import 'package:logistics/screens/admin/analytics_screen.dart';
import 'package:logistics/screens/admin/consignment_management_screen.dart';
import 'package:logistics/screens/admin/user_management_screen.dart';
import 'package:logistics/screens/client/chat_list_screen.dart';
import 'package:logistics/screens/home/delivery_screen.dart';
import 'package:logistics/screens/home/fuel_card_dashboard.dart';
import 'package:logistics/screens/home/profile_screen.dart';
import 'package:logistics/services/settings_screen.dart';
import 'package:logistics/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final dashboardServiceProvider = Provider<DashboardService>((ref) {
  return DashboardService();
});

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AdminHomeScreen(),
    const ManageUsersScreen(),
    const ManageConsignmentsScreen(),
    const AnalyticsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontScale = screenWidth / 400;
    final toolbarHeight = screenWidth * 0.12;
    final authService = ref.read(authServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ADMIN'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        toolbarHeight: toolbarHeight,
        actions: [
          IconButton(
            icon: Icon(Icons.person, size: fontScale * 24),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.chat, size: fontScale * 24),
            tooltip: 'Chats',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatListScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, size: fontScale * 24),
            tooltip: 'Logout',
            onPressed: () => authService.signOut(),
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: Colors.grey,
        selectedFontSize: fontScale * 12,
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
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, size: fontScale * 24),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cardPadding = screenWidth * 0.03;
    final iconSize = screenWidth * 0.08;
    final valueFontSize = screenWidth * 0.05;
    final titleFontSize = screenWidth * 0.035;
    final childAspectRatio = screenWidth / screenHeight * 2.2;
    final dashboardService = ref.read(dashboardServiceProvider);
    final authService = ref.read(authServiceProvider);

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
                  AppConstants.primaryColor.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: FutureBuilder<Map<String, dynamic>?>(
              future:
                  authService.currentUser != null
                      ? authService.getUserProfile(authService.currentUser!.id)
                      : null,
              builder: (context, snapshot) {
                final displayName =
                    snapshot.hasData && snapshot.data != null
                        ? snapshot.data!['full_name'] ?? 'Administrator'
                        : 'Administrator';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, $displayName',
                      style: TextStyle(
                        fontSize: valueFontSize * 1.2,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
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
                );
              },
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
              childAspectRatio: childAspectRatio,
              shrinkWrap: true,
              children: [
                FutureBuilder<int>(
                  future: dashboardService.getTotalUsers(),
                  builder:
                      (context, snapshot) => _buildStatCard(
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
                      ),
                ),
                FutureBuilder<int>(
                  future: dashboardService.getActiveConsignments(),
                  builder:
                      (context, snapshot) => _buildStatCard(
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
                      ),
                ),
                FutureBuilder<int>(
                  future: dashboardService.getAvailableDrivers(),
                  builder:
                      (context, snapshot) => _buildStatCard(
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
                      ),
                ),
                FutureBuilder<int>(
                  future: dashboardService.getCompletedToday(),
                  builder:
                      (context, snapshot) => _buildStatCard(
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
                      ),
                ),
                _buildActionCard(
                  context,
                  'Register System Admin',
                  Icons.admin_panel_settings,
                  Colors.red,
                  () => Navigator.pushNamed(context, '/admin-register'),
                  iconSize,
                  titleFontSize,
                  cardPadding,
                ),
                _buildActionCard(
                  context,
                  'Register Client/Driver',
                  Icons.person_add,
                  Colors.teal,
                  () => Navigator.pushNamed(
                    context,
                    '/client-or-driver-register',
                  ),
                  iconSize,
                  titleFontSize,
                  cardPadding,
                ),
                _buildActionCard(
                  context,
                  'Register Other Admin',
                  Icons.supervisor_account,
                  Colors.indigo,
                  () => Navigator.pushNamed(context, '/other-admin-register'),
                  iconSize,
                  titleFontSize,
                  cardPadding,
                ),
                _buildActionCard(
                  context,
                  'Fuel Management',
                  Icons.local_gas_station,
                  Colors.amber,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => const FuelCardDashboard(driverId: ''),
                    ),
                  ),
                  iconSize,
                  titleFontSize,
                  cardPadding,
                ),
                _buildActionCard(
                  context,
                  'Delivery Management',
                  Icons.delivery_dining,
                  Colors.deepOrange,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DeliveryScreen(driverId: ''),
                    ),
                  ),
                  iconSize,
                  titleFontSize,
                  cardPadding,
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
            colors: [color.withOpacity(0.7), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
    double iconSize,
    double titleFontSize,
    double padding,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.7), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: iconSize, color: Colors.white),
              SizedBox(height: padding * 0.5),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<int> getTotalUsers() async {
    final response = await _supabase
        .from('users')
        .select()
        .count(CountOption.exact);
    return response.count;
  }

  Future<int> getActiveConsignments() async {
    final response = await _supabase
        .from('consignments')
        .select()
        .inFilter('status', ['pending', 'assigned', 'in_transit'])
        .count(CountOption.exact);
    return response.count;
  }

  Future<int> getAvailableDrivers() async {
    final response = await _supabase
        .from('users')
        .select()
        .eq('role', 'driver')
        .eq('is_active', true)
        .count(CountOption.exact);
    return response.count;
  }

  Future<int> getCompletedToday() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final response = await _supabase
        .from('consignments')
        .select()
        .eq('status', 'delivered')
        .gte('updated_at', startOfDay.toIso8601String())
        .lt('updated_at', endOfDay.toIso8601String())
        .count(CountOption.exact);
    return response.count;
  }
}
