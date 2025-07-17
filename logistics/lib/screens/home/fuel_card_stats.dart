import 'package:flutter/material.dart';
import '../../../models/fuel_card_models.dart';
import '../../../widgets/responsive_layout.dart';

class FuelCardStats extends StatelessWidget {
  final List<FuelCard> fuelCards;

  const FuelCardStats({Key? key, required this.fuelCards}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();
    
    return ResponsiveLayout(
      mobile: _buildMobileStats(context, stats),
      tablet: _buildTabletStats(context, stats),
      desktop: _buildDesktopStats(context, stats),
    );
  }

  Map<String, dynamic> _calculateStats() {
    final totalCards = fuelCards.length;
    final activeCards = fuelCards.where((card) => card.status == 'active').length;
    final assignedCards = fuelCards.where((card) => card.status == 'assigned').length;
    final totalBalance = fuelCards.fold<double>(0, (sum, card) => sum + card.currentBalance);
    final totalLimit = fuelCards.fold<double>(0, (sum, card) => sum + card.spendingLimit);

    return {
      'totalCards': totalCards,
      'activeCards': activeCards,
      'assignedCards': assignedCards,
      'availableCards': fuelCards.where((card) => card.status == 'available').length,
      'totalBalance': totalBalance,
      'totalLimit': totalLimit,
      'utilizationRate': totalLimit > 0 ? ((totalLimit - totalBalance) / totalLimit * 100) : 0,
    };
  }

  Widget _buildMobileStats(BuildContext context, Map<String, dynamic> stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard(context, 'Total Cards', stats['totalCards'].toString(), Icons.credit_card, Colors.blue)),
            const SizedBox(width: 8),
            Expanded(child: _buildStatCard(context, 'Active', stats['activeCards'].toString(), Icons.check_circle, Colors.green)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildStatCard(context, 'Assigned', stats['assignedCards'].toString(), Icons.assignment, Colors.orange)),
            const SizedBox(width: 8),
            Expanded(child: _buildStatCard(context, 'Available', stats['availableCards'].toString(), Icons.inventory, Colors.purple)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildStatCard(context, 'Total Balance', '\$${stats['totalBalance'].toStringAsFixed(2)}', Icons.account_balance_wallet, Colors.teal)),
            const SizedBox(width: 8),
            Expanded(child: _buildStatCard(context, 'Utilization', '${stats['utilizationRate'].toStringAsFixed(1)}%', Icons.trending_up, Colors.red)),
          ],
        ),
      ],
    );
  }

  Widget _buildTabletStats(BuildContext context, Map<String, dynamic> stats) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(context, 'Total Cards', stats['totalCards'].toString(), Icons.credit_card, Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(context, 'Active', stats['activeCards'].toString(), Icons.check_circle, Colors.green)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(context, 'Assigned', stats['assignedCards'].toString(), Icons.assignment, Colors.orange)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(context, 'Available', stats['availableCards'].toString(), Icons.inventory, Colors.purple)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(context, 'Balance', '\$${stats['totalBalance'].toStringAsFixed(0)}', Icons.account_balance_wallet, Colors.teal)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(context, 'Utilization', '${stats['utilizationRate'].toStringAsFixed(1)}%', Icons.trending_up, Colors.red)),
      ],
    );
  }

  Widget _buildDesktopStats(BuildContext context, Map<String, dynamic> stats) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(context, 'Total Cards', stats['totalCards'].toString(), Icons.credit_card, Colors.blue)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard(context, 'Active Cards', stats['activeCards'].toString(), Icons.check_circle, Colors.green)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard(context, 'Assigned Cards', stats['assignedCards'].toString(), Icons.assignment, Colors.orange)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard(context, 'Available Cards', stats['availableCards'].toString(), Icons.inventory, Colors.purple)),
        const SizedBox(width: 16),
                Expanded(child: _buildStatCard(context, 'Total Balance', '\$${stats['totalBalance'].toStringAsFixed(2)}', Icons.account_balance_wallet, Colors.teal)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard(context, 'Utilization Rate', '${stats['utilizationRate'].toStringAsFixed(1)}%', Icons.trending_up, Colors.red)),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
