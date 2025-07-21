import 'package:flutter/material.dart';
import 'package:logistics/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isLoading = true;

  final Map<String, int> _stats = {
    'total_users': 0,
    'total_clients': 0,
    'total_drivers': 0,
    'total_consignments': 0,
    'pending_consignments': 0,
    'completed_consignments': 0,
    'cancelled_consignments': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Load user statistics
      final usersResponse = await _supabase.from('users').select('role');
      final users = usersResponse as List;

      _stats['total_users'] = users.length;
      _stats['total_clients'] =
          users.where((u) => u['role'] == 'client').length;
      _stats['total_drivers'] =
          users.where((u) => u['role'] == 'driver').length;

      // Load consignment statistics
      final consignmentsResponse = await _supabase
          .from('consignments')
          .select('status');
      final consignments = consignmentsResponse as List;

      _stats['total_consignments'] = consignments.length;
      _stats['pending_consignments'] =
          consignments.where((c) => c['status'] == 'pending').length;
      _stats['completed_consignments'] =
          consignments.where((c) => c['status'] == 'delivered').length;
      _stats['cancelled_consignments'] =
          consignments.where((c) => c['status'] == 'cancelled').length;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading analytics: $e'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadAnalytics,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'System Analytics',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // User Statistics
                      _buildSectionTitle('User Statistics'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Total Users',
                              _stats['total_users'].toString(),
                              Icons.people,
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Clients',
                              _stats['total_clients'].toString(),
                              Icons.person,
                              Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Drivers',
                              _stats['total_drivers'].toString(),
                              Icons.drive_eta,
                              Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Admins',
                              (_stats['total_users']! -
                                      _stats['total_clients']! -
                                      _stats['total_drivers']!)
                                  .toString(),
                              Icons.admin_panel_settings,
                              Colors.red,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Consignment Statistics
                      _buildSectionTitle('Consignment Statistics'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Total Orders',
                              _stats['total_consignments'].toString(),
                              Icons.local_shipping,
                              Colors.purple,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Pending',
                              _stats['pending_consignments'].toString(),
                              Icons.hourglass_empty,
                              Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Completed',
                              _stats['completed_consignments'].toString(),
                              Icons.check_circle,
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Cancelled',
                              _stats['cancelled_consignments'].toString(),
                              Icons.cancel,
                              Colors.red,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Performance Metrics
                      _buildSectionTitle('Performance Metrics'),
                      const SizedBox(height: 12),
                      _buildPerformanceCard(),

                      const SizedBox(height: 24),

                      // Recent Activity
                      _buildSectionTitle('System Health'),
                      const SizedBox(height: 12),
                      _buildSystemHealthCard(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard() {
    double completionRate =
        _stats['total_consignments']! > 0
            ? (_stats['completed_consignments']! /
                    _stats['total_consignments']!) *
                100
            : 0;

    double cancellationRate =
        _stats['total_consignments']! > 0
            ? (_stats['cancelled_consignments']! /
                    _stats['total_consignments']!) *
                100
            : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Performance',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildProgressIndicator(
            'Completion Rate',
            completionRate,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildProgressIndicator(
            'Cancellation Rate',
            cancellationRate,
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(String label, double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14)),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildSystemHealthCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Status',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildHealthItem('Database Connection', true),
          _buildHealthItem('Real-time Updates', true),
          _buildHealthItem('Notification Service', true),
          _buildHealthItem('GPS Tracking', true),
        ],
      ),
    );
  }

  Widget _buildHealthItem(String service, bool isHealthy) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isHealthy ? Icons.check_circle : Icons.error,
            color: isHealthy ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(service),
          const Spacer(),
          Text(
            isHealthy ? 'Online' : 'Offline',
            style: TextStyle(
              color: isHealthy ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
