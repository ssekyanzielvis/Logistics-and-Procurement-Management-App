import 'package:flutter/material.dart';

class FuelCardManagementScreen extends StatefulWidget {
  const FuelCardManagementScreen({super.key});

  @override
  State<FuelCardManagementScreen> createState() =>
      _FuelCardManagementScreenState();
}

class _FuelCardManagementScreenState extends State<FuelCardManagementScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fuel Card Management'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCard(),
              const SizedBox(height: 16),
              _buildQuickActions(),
              const SizedBox(height: 16),
              _buildRecentActivity(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFuelCardDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fuel Card Summary',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Total Cards',
                    '12',
                    Icons.credit_card,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Active Cards',
                    '10',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Blocked Cards',
                    '2',
                    Icons.block,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Add Card',
                    Icons.add_card,
                    Colors.blue,
                    _showAddFuelCardDialog,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    'View All',
                    Icons.list,
                    Colors.green,
                    _navigateToAllCards,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    'Reports',
                    Icons.analytics,
                    Colors.orange,
                    _navigateToReports,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Expanded(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return _buildActivityItem(index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(int index) {
    final activities = [
      {
        'title': 'Card Created',
        'subtitle': 'New fuel card added for Driver #001',
        'icon': Icons.add_circle,
        'color': Colors.green,
        'time': '2 hours ago',
      },
      {
        'title': 'Transaction Alert',
        'subtitle': 'High spending on Card #1234',
        'icon': Icons.warning,
        'color': Colors.orange,
        'time': '4 hours ago',
      },
      {
        'title': 'Card Blocked',
        'subtitle': 'Card #5678 temporarily blocked',
        'icon': Icons.block,
        'color': Colors.red,
        'time': '1 day ago',
      },
      {
        'title': 'Limit Updated',
        'subtitle': 'Spending limit changed for Card #9012',
        'icon': Icons.edit,
        'color': Colors.blue,
        'time': '2 days ago',
      },
      {
        'title': 'Card Activated',
        'subtitle': 'Card #3456 activated successfully',
        'icon': Icons.check_circle,
        'color': Colors.green,
        'time': '3 days ago',
      },
    ];

    final activity = activities[index];

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: (activity['color'] as Color).withValues(alpha: 0.1),
        child: Icon(
          activity['icon'] as IconData,
          color: activity['color'] as Color,
        ),
      ),
      title: Text(activity['title'] as String),
      subtitle: Text(activity['subtitle'] as String),
      trailing: Text(
        activity['time'] as String,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  void _showAddFuelCardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Fuel Card'),
        content: const Text('This feature will allow you to add a new fuel card.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Add fuel card feature coming soon!'),
                ),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _navigateToAllCards() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('View all cards feature coming soon!'),
      ),
    );
  }

  void _navigateToReports() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reports feature coming soon!'),
      ),
    );
  }
}
