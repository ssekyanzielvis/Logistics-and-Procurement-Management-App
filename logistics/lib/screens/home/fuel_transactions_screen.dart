import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/fuel_card_models.dart';
import '../../services/fuel_card_service.dart';
import '../../widgets/responsive_layout.dart';

class FuelTransactionsScreen extends StatefulWidget {
  final String cardId;

  const FuelTransactionsScreen({Key? key, required this.cardId}) : super(key: key);

  @override
  State<FuelTransactionsScreen> createState() => _FuelTransactionsScreenState();
}

class _FuelTransactionsScreenState extends State<FuelTransactionsScreen> {
  final FuelCardService _fuelCardService = FuelCardService();
  List<FuelTransaction> _transactions = [];
  List<FuelTransaction> _filteredTransactions = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';
  DateTimeRange? _selectedDateRange;

  final List<String> _filterOptions = ['all', 'diesel', 'petrol', 'electric', 'hybrid'];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    try {
      final transactions = await _fuelCardService.getFuelTransactions(
        cardId: widget.cardId,
      );
      setState(() {
        _transactions = transactions;
        _filteredTransactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading transactions: $e')),
      );
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredTransactions = _transactions.where((transaction) {
        bool matchesFilter = _selectedFilter == 'all' || 
                           transaction.fuelType == _selectedFilter;
        
        bool matchesDateRange = _selectedDateRange == null ||
                              (transaction.transactionDate.isAfter(_selectedDateRange!.start) &&
                               transaction.transactionDate.isBefore(_selectedDateRange!.end.add(const Duration(days: 1))));
        
        return matchesFilter && matchesDateRange;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fuel Transactions'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTransactions,
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
    return Column(
      children: [
        _buildSummaryCard(),
        _buildFilterChips(),
        Expanded(child: _buildTransactionsList()),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(flex: 2, child: _buildSummaryCard()),
              const SizedBox(width: 16),
              Expanded(flex: 1, child: _buildStatsCard()),
            ],
          ),
        ),
        _buildFilterChips(),
        Expanded(child: _buildTransactionsList()),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSummaryCard(),
                const SizedBox(height: 16),
                _buildStatsCard(),
                const SizedBox(height: 16),
                _buildFilterCard(),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: _buildTransactionsList(),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    final totalAmount = _filteredTransactions.fold<double>(
      0, (sum, transaction) => sum + transaction.amount);
    final totalLiters = _filteredTransactions.fold<double>(
      0, (sum, transaction) => sum + (transaction.liters ?? 0));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Total Spent',
                    '\$${totalAmount.toStringAsFixed(2)}',
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Total Liters',
                    '${totalLiters.toStringAsFixed(1)}L',
                    Icons.local_gas_station,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Transactions',
                    _filteredTransactions.length.toString(),
                    Icons.receipt,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Avg per Transaction',
                    _filteredTransactions.isEmpty 
                        ? '\$0.00'
                        : '\$${(totalAmount / _filteredTransactions.length).toStringAsFixed(2)}',
                    Icons.trending_up,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    final fuelTypeStats = <String, double>{};
    for (final transaction in _filteredTransactions) {
      fuelTypeStats[transaction.fuelType] = 
          (fuelTypeStats[transaction.fuelType] ?? 0) + transaction.amount;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fuel Type Breakdown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...fuelTypeStats.entries.map((entry) {
              final percentage = fuelTypeStats.values.isEmpty 
                  ? 0.0 
                  : (entry.value / fuelTypeStats.values.reduce((a, b) => a + b)) * 100;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getFuelTypeColor(entry.key),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.key.toUpperCase(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ..._filterOptions.map((filter) {
              final isSelected = _selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(filter == 'all' ? 'All' : filter.toUpperCase()),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedFilter = filter);
                    _applyFilters();
                  },
                  selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  checkmarkColor: Theme.of(context).primaryColor,
                ),
              );
            }).toList(),
            if (_selectedDateRange != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Chip(
                  label: Text(
                    '${DateFormat('MMM dd').format(_selectedDateRange!.start)} - ${DateFormat('MMM dd').format(_selectedDateRange!.end)}',
                  ),
                  onDeleted: () {
                    setState(() => _selectedDateRange = null);
                    _applyFilters();
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filters',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedFilter,
              decoration: const InputDecoration(
                labelText: 'Fuel Type',
                border: OutlineInputBorder(),
              ),
              items: _filterOptions.map((filter) {
                return DropdownMenuItem(
                  value: filter,
                  child: Text(filter == 'all' ? 'All Types' : filter.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedFilter = value!);
                _applyFilters();
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _selectDateRange,
                icon: const Icon(Icons.date_range),
                label: Text(_selectedDateRange == null 
                    ? 'Select Date Range' 
                    : 'Date Range Selected'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    if (_filteredTransactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No transactions found'),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredTransactions.length,
      itemBuilder: (context, index) {
        final transaction = _filteredTransactions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getFuelTypeColor(transaction.fuelType).withOpacity(0.1),
              child: Icon(
                Icons.local_gas_station,
                color: _getFuelTypeColor(transaction.fuelType),
              ),
            ),
            title: Text(
              '\$${transaction.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${transaction.fuelType.toUpperCase()} • ${transaction.liters?.toStringAsFixed(1) ?? 'N/A'}L'),
                Text(transaction.stationName ?? 'Unknown Station'),
                                Text(transaction.location ?? 'Unknown Location'),
                Text(DateFormat('MMM dd, yyyy HH:mm').format(transaction.transactionDate)),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'details',
                  child: Row(
                    children: [
                      Icon(Icons.info_outline),
                      SizedBox(width: 8),
                      Text('View Details'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'receipt',
                  child: Row(
                    children: [
                      Icon(Icons.receipt),
                      SizedBox(width: 8),
                      Text('View Receipt'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'details') {
                  _showTransactionDetails(transaction);
                } else if (value == 'receipt') {
                  _showReceipt(transaction);
                }
              },
            ),
          ),
        );
      },
    );
  }

  Color _getFuelTypeColor(String fuelType) {
    switch (fuelType.toLowerCase()) {
      case 'diesel':
        return Colors.orange;
      case 'petrol':
      case 'gasoline':
        return Colors.blue;
      case 'electric':
        return Colors.green;
      case 'hybrid':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Transactions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedFilter,
              decoration: const InputDecoration(
                labelText: 'Fuel Type',
                border: OutlineInputBorder(),
              ),
              items: _filterOptions.map((filter) {
                return DropdownMenuItem(
                  value: filter,
                  child: Text(filter == 'all' ? 'All Types' : filter.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedFilter = value!);
              },
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _selectDateRange,
              icon: const Icon(Icons.date_range),
              label: Text(_selectedDateRange == null 
                  ? 'Select Date Range' 
                  : 'Date Range Selected'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedFilter = 'all';
                _selectedDateRange = null;
              });
              _applyFilters();
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _applyFilters();
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );

    if (dateRange != null) {
      setState(() => _selectedDateRange = dateRange);
    }
  }

  void _showTransactionDetails(FuelTransaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transaction Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Amount', '\$${transaction.amount.toStringAsFixed(2)}'),
            _buildDetailRow('Fuel Type', transaction.fuelType.toUpperCase()),
            _buildDetailRow('Liters', '${transaction.liters?.toStringAsFixed(2) ?? 'N/A'}L'),
            _buildDetailRow('Station', transaction.stationName ?? 'Unknown'),
            _buildDetailRow('Location', transaction.location ?? 'Unknown'),
            _buildDetailRow('Date', DateFormat('MMM dd, yyyy HH:mm').format(transaction.transactionDate)),
            if (transaction.driverId != null)
              _buildDetailRow('Driver ID', transaction.driverId!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReceipt(FuelTransaction transaction) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'FUEL RECEIPT',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.stationName ?? 'Gas Station',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(transaction.location ?? 'Location'),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildReceiptRow('Date:', DateFormat('MMM dd, yyyy HH:mm').format(transaction.transactionDate)),
                    _buildReceiptRow('Fuel Type:', transaction.fuelType.toUpperCase()),
                    _buildReceiptRow('Quantity:', '${transaction.liters?.toStringAsFixed(2) ?? 'N/A'} L'),
                    _buildReceiptRow('Price per L:', transaction.liters != null && transaction.liters! > 0 
                        ? '\$${(transaction.amount / transaction.liters!).toStringAsFixed(3)}'
                        : 'N/A'),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildReceiptRow('TOTAL:', '\$${transaction.amount.toStringAsFixed(2)}', bold: true),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Implement share functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Receipt shared')),
                        );
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
