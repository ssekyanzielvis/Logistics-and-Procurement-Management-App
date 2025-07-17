import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/fuel_card_models.dart';
import '../../services/fuel_card_service.dart';
import '../home/responsive_layout.dart';

class DriverFuelCardScreen extends ConsumerStatefulWidget {
  final String driverId;

  const DriverFuelCardScreen({Key? key, required this.driverId}) : super(key: key);

  @override
  ConsumerState<DriverFuelCardScreen> createState() => _DriverFuelCardScreenState();
}

class _DriverFuelCardScreenState extends ConsumerState<DriverFuelCardScreen> {
  final FuelCardService _fuelCardService = FuelCardService();
  List<FuelCardAssignment> _assignments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    setState(() => _isLoading = true);
    try {
      final assignments = await _fuelCardService.getDriverAssignments(widget.driverId);
      setState(() {
        _assignments = assignments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading assignments: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Fuel Cards'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAssignments,
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
      onRefresh: _loadAssignments,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActiveAssignments(),
            const SizedBox(height: 20),
            _buildAssignmentHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return RefreshIndicator(
      onRefresh: _loadAssignments,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildActiveAssignments(),
            const SizedBox(height: 24),
            _buildAssignmentHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return RefreshIndicator(
      onRefresh: _loadAssignments,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _buildActiveAssignments(),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 1,
              child: _buildAssignmentHistory(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveAssignments() {
    final activeAssignments = _assignments.where((a) => 
        a.status == 'assigned' || a.status == 'picked_up').toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Active Fuel Cards',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (activeAssignments.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No active fuel card assignments'),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activeAssignments.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final assignment = activeAssignments[index];
                  return _buildAssignmentCard(assignment);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentCard(FuelCardAssignment assignment) {
    final card = assignment.fuelCard;
    if (card == null) return const SizedBox();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  card.cardType == 'digital' ? 'DIGITAL CARD' : 'PHYSICAL CARD',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  card.cardType == 'digital' ? Icons.smartphone : Icons.credit_card,
                  color: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '**** **** **** ${card.cardNumber.substring(card.cardNumber.length - 4)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BALANCE',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${card.currentBalance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'LIMIT',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${card.spendingLimit.toStringAsFixed(2)}',
                                            style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (assignment.status == 'assigned' && assignment.pickupCode != null)
              _buildPickupSection(assignment)
            else if (assignment.status == 'picked_up')
              _buildActiveCardSection(assignment),
          ],
        ),
      ),
    );
  }

  Widget _buildPickupSection(FuelCardAssignment assignment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pickup Location: ${assignment.pickupLocation ?? 'Main Depot'}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'PICKUP CODE',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        assignment.pickupCode!,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  const Text(
                    'QR CODE',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: QrImageView(
                      data: assignment.pickupCode!,
                      version: QrVersions.auto,
                      size: 60,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _confirmPickup(assignment),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).primaryColor,
              ),
              child: const Text('Confirm Pickup'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCardSection(FuelCardAssignment assignment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              const Text(
                'Card Active - Ready to Use',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (assignment.expectedConsumption != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.local_gas_station, color: Colors.white70, size: 14),
                const SizedBox(width: 8),
                Text(
                  'Expected Consumption: ${assignment.expectedConsumption!.toStringAsFixed(1)}L',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _viewTransactions(assignment),
                  icon: const Icon(Icons.history, size: 16),
                  label: const Text('Transactions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _recordTransaction(assignment),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Fuel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentHistory() {
    final completedAssignments = _assignments.where((a) => 
        a.status == 'completed' || a.status == 'returned').toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assignment History',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (completedAssignments.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No assignment history'),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: completedAssignments.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final assignment = completedAssignments[index];
                  return _buildHistoryTile(assignment);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTile(FuelCardAssignment assignment) {
    final card = assignment.fuelCard;
    if (card == null) return const SizedBox();

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getStatusColor(assignment.status).withOpacity(0.1),
        child: Icon(
          card.cardType == 'digital' ? Icons.smartphone : Icons.credit_card,
          color: _getStatusColor(assignment.status),
        ),
      ),
      title: Text(
        '**** **** **** ${card.cardNumber.substring(card.cardNumber.length - 4)}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Status: ${assignment.status.toUpperCase()}'),
          Text('Assigned: ${DateFormat('MMM dd, yyyy').format(assignment.assignedAt)}'),
          if (assignment.expectedConsumption != null)
            Text('Expected: ${assignment.expectedConsumption!.toStringAsFixed(1)}L'),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.info_outline),
        onPressed: () => _showAssignmentDetails(assignment),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'assigned':
        return Colors.orange;
      case 'picked_up':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'returned':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Future<void> _confirmPickup(FuelCardAssignment assignment) async {
    try {
      await _fuelCardService.updateAssignmentStatus(assignment.id, 'picked_up');
      _loadAssignments();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fuel card pickup confirmed')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error confirming pickup: $e')),
      );
    }
  }

  void _viewTransactions(FuelCardAssignment assignment) {
    Navigator.pushNamed(
      context,
      '/fuel-card/transactions',
      arguments: assignment.fuelCardId,
    );
  }

  void _recordTransaction(FuelCardAssignment assignment) {
    Navigator.pushNamed(
      context,
      '/fuel-card/add-transaction',
      arguments: assignment,
    );
  }

  void _showAssignmentDetails(FuelCardAssignment assignment) {
    Navigator.pushNamed(
      context,
      '/fuel-card/assignment-details',
      arguments: assignment,
    );
  }
}
