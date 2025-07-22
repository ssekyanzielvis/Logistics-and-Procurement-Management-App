import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistics/providers/auth_provider.dart';
import 'package:logistics/screens/driver/available_consignments_screen.dart';
import 'package:logistics/screens/driver/my_deliveries_screen.dart';
import 'package:logistics/screens/client/chat_list_screen.dart';
import 'package:logistics/screens/home/delivery_screen.dart';
import 'package:logistics/screens/home/driver_fuel_card_screen.dart';
import 'package:logistics/screens/home/profile_screen.dart';
import 'package:logistics/services/settings_screen.dart';
import 'package:logistics/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final driverDashboardServiceProvider = Provider<DriverDashboardService>((ref) {
  return DriverDashboardService();
});

class DriverDashboard extends ConsumerStatefulWidget {
  const DriverDashboard({super.key});

  @override
  ConsumerState<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends ConsumerState<DriverDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DriverHomeScreen(),
    const AvailableConsignmentsScreen(),
    const MyDeliveriesScreen(),
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
        title: const Text('Driver Dashboard'),
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
            icon: Icon(Icons.home, size: fontScale * 24),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping, size: fontScale * 24),
            label: 'Available',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment, size: fontScale * 24),
            label: 'My Deliveries',
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

class DriverHomeScreen extends ConsumerWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cardPadding = screenWidth * 0.03;
    final iconSize = screenWidth * 0.08;
    final valueFontSize = screenWidth * 0.05;
    final titleFontSize = screenWidth * 0.035;
    final childAspectRatio = screenWidth / screenHeight * 2.2;
    final dashboardService = ref.read(driverDashboardServiceProvider);
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
                        ? snapshot.data!['full_name'] ?? 'Driver'
                        : 'Driver';

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
                      'Ready to make deliveries today?',
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
            'Today\'s Overview',
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
                  future: dashboardService.getAvailableJobs(),
                  builder:
                      (context, snapshot) => _buildStatCard(
                        context,
                        'Available Jobs',
                        snapshot.hasData
                            ? snapshot.data.toString()
                            : 'Loading...',
                        Icons.local_shipping,
                        Colors.blue,
                        iconSize,
                        valueFontSize,
                        titleFontSize,
                        cardPadding,
                      ),
                ),
                FutureBuilder<int>(
                  future: dashboardService.getMyDeliveries(),
                  builder:
                      (context, snapshot) => _buildStatCard(
                        context,
                        'My Deliveries',
                        snapshot.hasData
                            ? snapshot.data.toString()
                            : 'Loading...',
                        Icons.assignment,
                        Colors.orange,
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
                        Colors.green,
                        iconSize,
                        valueFontSize,
                        titleFontSize,
                        cardPadding,
                      ),
                ),
                FutureBuilder<double>(
                  future: dashboardService.getEarningsToday(),
                  builder:
                      (context, snapshot) => _buildStatCard(
                        context,
                        'Earnings Today',
                        snapshot.hasData ? '\$${snapshot.data}' : 'Loading...',
                        Icons.attach_money,
                        Colors.purple,
                        iconSize,
                        valueFontSize,
                        titleFontSize,
                        cardPadding,
                      ),
                ),
                _buildActionCard(
                  context,
                  'Fuel Cards',
                  Icons.credit_card,
                  Colors.teal,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => const DriverFuelCardScreen(driverId: ''),
                    ),
                  ),
                  iconSize,
                  titleFontSize,
                  cardPadding,
                ),
                _buildActionCard(
                  context,
                  'Start Delivery',
                  Icons.directions_car,
                  Colors.red,
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

class DriverDashboardService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<int> getAvailableJobs() async {
    final response = await _supabase
        .from('consignments')
        .select()
        .eq('status', 'pending')
        .count(CountOption.exact);
    return response.count;
  }

  Future<int> getMyDeliveries() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return 0;

    final response = await _supabase
        .from('consignments')
        .select()
        .eq('driver_id', userId)
        .inFilter('status', ['assigned', 'in_transit'])
        .count(CountOption.exact);
    return response.count;
  }

  Future<int> getCompletedToday() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return 0;

    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final response = await _supabase
        .from('consignments')
        .select()
        .eq('driver_id', userId)
        .eq('status', 'delivered')
        .gte('updated_at', startOfDay.toIso8601String())
        .lt('updated_at', endOfDay.toIso8601String())
        .count(CountOption.exact);
    return response.count;
  }

  Future<double> getEarningsToday() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return 0.0;

    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final response = await _supabase
        .from('consignments')
        .select('driver_fee')
        .eq('driver_id', userId)
        .eq('status', 'delivered')
        .gte('updated_at', startOfDay.toIso8601String())
        .lt('updated_at', endOfDay.toIso8601String());

    if (response.isEmpty) return 0.0;

    double total = 0;
    for (final item in response) {
      total += (item['driver_fee'] as num).toDouble();
    }
    return total;
  }
}
