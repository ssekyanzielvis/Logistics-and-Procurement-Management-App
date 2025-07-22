import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistics/providers/auth_provider.dart';
import 'package:logistics/screens/client/chat_list_screen.dart';
import 'package:logistics/screens/client/create_consignment_screen.dart';
import 'package:logistics/screens/client/my_consignments_screen.dart';
import 'package:logistics/screens/client/track_consignment_screen.dart';
import 'package:logistics/screens/home/profile_screen.dart';
import 'package:logistics/services/settings_screen.dart';
import 'package:logistics/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final clientDashboardServiceProvider = Provider<ClientDashboardService>((ref) {
  return ClientDashboardService();
});

class ClientDashboard extends ConsumerStatefulWidget {
  const ClientDashboard({super.key});

  @override
  ConsumerState<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends ConsumerState<ClientDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ClientHomeScreen(),
    const CreateConsignmentScreen(),
    const MyConsignmentsScreen(),
    const TrackConsignmentScreen(),
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
        title: const Text('Client Dashboard'),
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
            tooltip: 'Chat',
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
            icon: Icon(Icons.add_box, size: fontScale * 24),
            label: 'New Order',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list, size: fontScale * 24),
            label: 'My Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes, size: fontScale * 24),
            label: 'Track',
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

class ClientHomeScreen extends ConsumerWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cardPadding = screenWidth * 0.03;
    final iconSize = screenWidth * 0.08;
    final valueFontSize = screenWidth * 0.05;
    final titleFontSize = screenWidth * 0.035;
    final childAspectRatio = screenWidth / screenHeight * 2.2;
    final dashboardService = ref.read(clientDashboardServiceProvider);
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
                        ? snapshot.data!['full_name'] ??
                            snapshot.data!['email'] ??
                            'Client'
                        : 'Client';

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
                      'Track and manage your deliveries',
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
            'Quick Actions',
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
                _buildActionCard(
                  context,
                  'Create New Order',
                  Icons.add_box,
                  Colors.green,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateConsignmentScreen(),
                      ),
                    );
                  },
                  iconSize,
                  titleFontSize,
                  cardPadding,
                ),
                _buildActionCard(
                  context,
                  'Track Order',
                  Icons.track_changes,
                  Colors.blue,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TrackConsignmentScreen(),
                      ),
                    );
                  },
                  iconSize,
                  titleFontSize,
                  cardPadding,
                ),
                FutureBuilder<int>(
                  future: dashboardService.getActiveOrders(),
                  builder:
                      (context, snapshot) => _buildStatCard(
                        context,
                        'Active Orders',
                        snapshot.hasData
                            ? snapshot.data.toString()
                            : 'Loading...',
                        Icons.list,
                        Colors.orange,
                        iconSize,
                        valueFontSize,
                        titleFontSize,
                        cardPadding,
                      ),
                ),
                FutureBuilder<int>(
                  future: dashboardService.getCompletedOrders(),
                  builder:
                      (context, snapshot) => _buildStatCard(
                        context,
                        'Completed Orders',
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
                  'Order History',
                  Icons.history,
                  Colors.amber,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyConsignmentsScreen(),
                      ),
                    );
                  },
                  iconSize,
                  titleFontSize,
                  cardPadding,
                ),
                _buildActionCard(
                  context,
                  'Support',
                  Icons.support_agent,
                  Colors.red,
                  () {
                    // Navigate to support
                  },
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

class ClientDashboardService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<int> getActiveOrders() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return 0;

    final response = await _supabase
        .from('consignments')
        .select()
        .eq('client_id', userId)
        .inFilter('status', ['pending', 'assigned', 'in_transit'])
        .count(CountOption.exact);
    return response.count;
  }

  Future<int> getCompletedOrders() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return 0;

    final response = await _supabase
        .from('consignments')
        .select()
        .eq('client_id', userId)
        .eq('status', 'delivered')
        .count(CountOption.exact);
    return response.count;
  }
}
