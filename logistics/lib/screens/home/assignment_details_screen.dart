import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/fuel_card_models.dart';
import '../../services/fuel_card_service.dart';
import '../home/responsive_layout.dart';

class AssignmentDetailsScreen extends StatefulWidget {
  final FuelCardAssignment assignment;

  const AssignmentDetailsScreen({super.key, required this.assignment});

  @override
  State<AssignmentDetailsScreen> createState() =>
      _AssignmentDetailsScreenState();
}

class _AssignmentDetailsScreenState extends State<AssignmentDetailsScreen> {
  final FuelCardService _fuelCardService = FuelCardService();
  List<FuelTransaction> _transactions = [];
  FuelCard? _fuelCard;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Load transactions
      final transactions = await _fuelCardService.getAllTransactions(
        fuelCardId: widget.assignment.fuelCardId,
      );

      // Load fuel card details
      final cards = await _fuelCardService.getAllCards();
      final card = cards.firstWhere(
        (card) => card.id == widget.assignment.fuelCardId,
      );

      setState(() {
        _transactions = transactions;
        _fuelCard = card;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignment Details'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        desktop: _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildAssignmentInfo(),
          const SizedBox(height: 20),
          _buildCardInfo(),
          const SizedBox(height: 20),
          _buildTransactionsList(),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildAssignmentInfo()),
              const SizedBox(width: 20),
              Expanded(child: _buildCardInfo()),
            ],
          ),
          const SizedBox(height: 24),
          _buildTransactionsList(),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildAssignmentInfo(),
                const SizedBox(height: 20),
                _buildCardInfo(),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _buildTransactionsList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAssignmentInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assignment Information',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Assigned Date',
              DateFormat(
                'MMM dd, yyyy HH:mm',
              ).format(widget.assignment.assignedDate),
            ),
            if (widget.assignment.unassignedDate != null)
              _buildInfoRow(
                'Unassigned Date',
                DateFormat(
                  'MMM dd, yyyy HH:mm',
                ).format(widget.assignment.unassignedDate!),
              ),
            _buildInfoRow('Assigned By', widget.assignment.assignedBy),
            if (widget.assignment.notes != null)
              _buildInfoRow('Notes', widget.assignment.notes!),
          ],
        ),
      ),
    );
  }

  Widget _buildCardInfo() {
    if (_fuelCard == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fuel Card Information',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _fuelCard!.cardType.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '**** **** **** ${_fuelCard!.cardNumber.substring(_fuelCard!.cardNumber.length - 4)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
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
                            '\$${_fuelCard!.currentBalance.toStringAsFixed(2)}',
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
                            '\$${_fuelCard!.spendingLimit.toStringAsFixed(2)}',
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
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children:
                  _fuelCard!.fuelTypeRestrictions.map((type) {
                    return Chip(
                      label: Text(
                        type.toUpperCase(),
                        style: const TextStyle(fontSize: 10),
                      ),
                      backgroundColor: Theme.of(
                        context,
                      ).primaryColor.withOpacity(0.1),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transactions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_transactions.isNotEmpty)
                  Text(
                    '${_transactions.length} transactions',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_transactions.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No transactions found'),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _transactions.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final transaction = _transactions[index];
                  return _buildTransactionTile(transaction);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTile(FuelTransaction transaction) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getTransactionTypeColor(
          transaction.type,
        ).withOpacity(0.1),
        child: Icon(
          _getTransactionTypeIcon(transaction.type),
          color: _getTransactionTypeColor(transaction.type),
        ),
      ),
      title: Text(
        '\$${transaction.amount.toStringAsFixed(2)}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${transaction.type.name.toUpperCase()} • ${transaction.quantity.toStringAsFixed(1)}L',
          ),
          Text(transaction.station),
          Text(
            DateFormat(
              'MMM dd, yyyy HH:mm',
            ).format(transaction.transactionDate),
          ),
        ],
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTransactionTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.fuel:
        return Colors.orange;
      case TransactionType.carWash:
        return Colors.blue;
      case TransactionType.convenience:
        return Colors.green;
      case TransactionType.maintenance:
        return Colors.purple;
    }
  }

  IconData _getTransactionTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.fuel:
        return Icons.local_gas_station;
      case TransactionType.carWash:
        return Icons.car_crash;
      case TransactionType.convenience:
        return Icons.shopping_cart;
      case TransactionType.maintenance:
        return Icons.build;
    }
  }
}
