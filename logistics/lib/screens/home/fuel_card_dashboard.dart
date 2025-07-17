import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/fuel_card_models.dart';
import '../../services/fuel_card_service.dart';
import '../home/responsive_layout.dart';
import '../home/fuel_card_stats.dart';
import '../home/fuel_card_list.dart';
import '../home/recent_transactions.dart';

class FuelCardDashboard extends ConsumerStatefulWidget {
  const FuelCardDashboard({Key? key}) : super(key: key);

  @override
  ConsumerState<FuelCardDashboard> createState() => _FuelCardDashboardState();
}

class _FuelCardDashboardState extends ConsumerState<FuelCardDashboard> {
  final FuelCardService _fuelCardService = FuelCardService();
  List<FuelCard> _fuelCards = [];
  List<FuelTransaction> _recentTransactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final cards = await _fuelCardService.getFuelCards();
      final transactions = await _fuelCardService.getFuelTransactions();
      
      setState(() {
        _fuelCards = cards;
        _recentTransactions = transactions.take(10).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fuel Card Management'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateFuelCardDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ResponsiveLayout(
              mobile: _buildMobileLayout(),
              tablet: _buildTabletLayout(),
              desktop: _buildDesktopLayout(),
            ),
    );
  }

  Widget _buildMobileLayout() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FuelCardStats(fuelCards: _fuelCards),
            const SizedBox(height: 20),
            _buildQuickActions(),
            const SizedBox(height: 20),
            FuelCardList(
              fuelCards: _fuelCards,
              onCardTap: _showFuelCardDetails,
              onStatusChange: _updateCardStatus,
            ),
            const SizedBox(height: 20),
            RecentTransactions(transactions: _recentTransactions),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            FuelCardStats(fuelCards: _fuelCards),
            const SizedBox(height: 24),
            _buildQuickActions(),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: FuelCardList(
                    fuelCards: _fuelCards,
                    onCardTap: _showFuelCardDetails,
                    onStatusChange: _updateCardStatus,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 1,
                  child: RecentTransactions(transactions: _recentTransactions),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            FuelCardStats(fuelCards: _fuelCards),
            const SizedBox(height: 32),
            _buildQuickActions(),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: FuelCardList(
                    fuelCards: _fuelCards,
                    onCardTap: _showFuelCardDetails,
                    onStatusChange: _updateCardStatus,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 2,
                  child: RecentTransactions(transactions: _recentTransactions),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ResponsiveLayout(
              mobile: _buildMobileQuickActions(),
              tablet: _buildTabletQuickActions(),
              desktop: _buildDesktopQuickActions(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileQuickActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildActionButton('Create Card', Icons.add_card, _showCreateFuelCardDialog)),
            const SizedBox(width: 8),
            Expanded(child: _buildActionButton('Assign Card', Icons.assignment, _showAssignCardDialog)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildActionButton('View Reports', Icons.analytics, _showReports)),
            const SizedBox(width: 8),
            Expanded(child: _buildActionButton('Lockers', Icons.locker, _showLockers)),
          ],
        ),
      ],
    );
  }

  Widget _buildTabletQuickActions() {
    return Row(
      children: [
        Expanded(child: _buildActionButton('Create Card', Icons.add_card, _showCreateFuelCardDialog)),
        const SizedBox(width: 12),
        Expanded(child: _buildActionButton('Assign Card', Icons.assignment, _showAssignCardDialog)),
        const SizedBox(width: 12),
        Expanded(child: _buildActionButton('View Reports', Icons.analytics, _showReports)),
        const SizedBox(width: 12),
        Expanded(child: _buildActionButton('Lockers', Icons.locker, _showLockers)),
      ],
    );
  }

  Widget _buildDesktopQuickActions() {
    return Row(
      children: [
        _buildActionButton('Create Card', Icons.add_card, _showCreateFuelCardDialog),
        const SizedBox(width: 16),
        _buildActionButton('Assign Card', Icons.assignment, _showAssignCardDialog),
        const SizedBox(width: 16),
        _buildActionButton('View Reports', Icons.analytics, _showReports),
        const SizedBox(width: 16),
        _buildActionButton('Lockers', Icons.locker, _showLockers),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  void _showCreateFuelCardDialog() {
    Navigator.pushNamed(context, '/fuel-card/create').then((_) => _loadData());
  }

  void _showAssignCardDialog() {
    Navigator.pushNamed(context, '/fuel-card/assign').then((_) => _loadData());
  }

  void _showReports() {
    Navigator.pushNamed(context, '/fuel-card/reports');
  }

  void _showLockers() {
    Navigator.pushNamed(context, '/fuel-card/lockers');
  }

  void _showFuelCardDetails(FuelCard card) {
    Navigator.pushNamed(context, '/fuel-card/details', arguments: card);
  }

  Future<void> _updateCardStatus(String cardId, String status) async {
    try {
      await _fuelCardService.updateFuelCardStatus(cardId, status);
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Card status updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating card status: $e')),
      );
    }
  }
}
