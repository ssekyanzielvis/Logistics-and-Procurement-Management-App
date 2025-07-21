import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logistics/screens/home/responsive_layout.dart';
import '../../../models/fuel_card_models.dart';

class RecentTransactions extends StatelessWidget {
  final List<FuelTransaction> transactions;
  final String? cardId; // Optional cardId for navigation to full transactions

  const RecentTransactions({
    super.key,
    required this.transactions,
    this.cardId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed:
                      cardId != null
                          ? () {
                            Navigator.pushNamed(
                              context,
                              '/fuel-card/transactions',
                              arguments: cardId,
                            );
                          }
                          : null,
                  icon: const Icon(Icons.history, size: 16),
                  label: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (transactions.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No recent transactions'),
                ),
              )
            else
              ResponsiveLayout(
                mobile: _buildMobileTransactions(),
                tablet: _buildTabletTransactions(),
                desktop: _buildDesktopTransactions(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileTransactions() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length > 5 ? 5 : transactions.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _buildMobileTransactionTile(transaction);
      },
    );
  }

  Widget _buildTabletTransactions() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length > 8 ? 8 : transactions.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _buildTabletTransactionTile(transaction);
      },
    );
  }

  Widget _buildDesktopTransactions() {
    return Column(
      children: [
        _buildDesktopHeader(),
        const Divider(),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length > 10 ? 10 : transactions.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return _buildDesktopTransactionRow(transaction);
          },
        ),
      ],
    );
  }

  Widget _buildMobileTransactionTile(FuelTransaction transaction) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getTransactionTypeColor(
          transaction.type,
        ).withOpacity(0.1),
        child: Icon(
          Icons.local_gas_station,
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

  Widget _buildTabletTransactionTile(FuelTransaction transaction) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getTransactionTypeColor(
          transaction.type,
        ).withOpacity(0.1),
        child: Icon(
          Icons.local_gas_station,
          color: _getTransactionTypeColor(transaction.type),
        ),
      ),
      title: Row(
        children: [
          Text(
            '\$${transaction.amount.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _getTransactionTypeColor(
                transaction.type,
              ).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              transaction.type.name.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                color: _getTransactionTypeColor(transaction.type),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${transaction.quantity.toStringAsFixed(1)}L • ${transaction.station}',
          ),
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

  Widget _buildDesktopHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Expanded(
            flex: 2,
            child: Text(
              'Date & Time',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Expanded(
            flex: 1,
            child: Text(
              'Amount',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Expanded(
            flex: 1,
            child: Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Expanded(
            flex: 1,
            child: Text(
              'Quantity',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Expanded(
            flex: 2,
            child: Text(
              'Station',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTransactionRow(FuelTransaction transaction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat(
                    'MMM dd, yyyy',
                  ).format(transaction.transactionDate),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  DateFormat('HH:mm').format(transaction.transactionDate),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '\$${transaction.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getTransactionTypeColor(
                  transaction.type,
                ).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                transaction.type.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  color: _getTransactionTypeColor(transaction.type),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text('${transaction.quantity.toStringAsFixed(1)}L'),
          ),
          Expanded(
            flex: 2,
            child: Text(transaction.station, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Color _getTransactionTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.fuel:
        return Colors.blue;
      case TransactionType.carWash:
        return Colors.green;
      case TransactionType.convenience:
        return Colors.orange;
      case TransactionType.maintenance:
        return Colors.purple;
    }
  }
}
