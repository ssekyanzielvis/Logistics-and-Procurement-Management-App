import 'package:flutter/material.dart';
import '../../../models/fuel_card_models.dart';
import '../home/responsive_layout.dart';

class FuelCardList extends StatelessWidget {
  final List<FuelCard> fuelCards;
  final Function(FuelCard) onCardTap;
  final Function(String, FuelCardStatus) onStatusChange;

  const FuelCardList({
    super.key,
    required this.fuelCards,
    required this.onCardTap,
    required this.onStatusChange,
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
                  'Fuel Cards',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // Navigate to full fuel cards list
                  },
                  icon: const Icon(Icons.view_list, size: 16),
                  label: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (fuelCards.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No fuel cards available'),
                ),
              )
            else
              ResponsiveLayout(
                mobile: _buildMobileList(),
                tablet: _buildTabletList(),
                desktop: _buildDesktopList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: fuelCards.length > 5 ? 5 : fuelCards.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final card = fuelCards[index];
        return _buildMobileCardTile(card);
      },
    );
  }

  Widget _buildTabletList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: fuelCards.length > 8 ? 8 : fuelCards.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final card = fuelCards[index];
        return _buildTabletCardTile(card);
      },
    );
  }

  Widget _buildDesktopList() {
    return Column(
      children: [
        _buildDesktopHeader(),
        const Divider(),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: fuelCards.length > 10 ? 10 : fuelCards.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final card = fuelCards[index];
            return _buildDesktopCardRow(card);
          },
        ),
      ],
    );
  }

  Widget _buildMobileCardTile(FuelCard card) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getStatusColor(card.status).withOpacity(0.1),
        child: Icon(
          card.cardType == CardType.virtual
              ? Icons.smartphone
              : Icons.credit_card,
          color: _getStatusColor(card.status),
        ),
      ),
      title: Text(
        '**** **** **** ${card.cardNumber.substring(card.cardNumber.length - 4)}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Balance: \$${card.currentBalance.toStringAsFixed(2)}'),
          Text('Type: ${_formatEnum(card.cardType)}'),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStatusChip(card.status),
          PopupMenuButton<FuelCardStatus>(
            onSelected: (status) => onStatusChange(card.id, status),
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: FuelCardStatus.active,
                    child: Text('Activate'),
                  ),
                  const PopupMenuItem(
                    value: FuelCardStatus.inactive,
                    child: Text('Deactivate'),
                  ),
                  const PopupMenuItem(
                    value: FuelCardStatus.blocked,
                    child: Text('Block'),
                  ),
                ],
            child: const Icon(Icons.more_vert),
          ),
        ],
      ),
      onTap: () => onCardTap(card),
    );
  }

  Widget _buildTabletCardTile(FuelCard card) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getStatusColor(card.status).withOpacity(0.1),
        child: Icon(
          card.cardType == CardType.virtual
              ? Icons.smartphone
              : Icons.credit_card,
          color: _getStatusColor(card.status),
        ),
      ),
      title: Text(
        '**** **** **** ${card.cardNumber.substring(card.cardNumber.length - 4)}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Row(
        children: [
          Text('Balance: \$${card.currentBalance.toStringAsFixed(2)}'),
          const SizedBox(width: 16),
          Text('Limit: \$${card.spendingLimit.toStringAsFixed(2)}'),
          const SizedBox(width: 16),
          Text('Type: ${_formatEnum(card.cardType)}'),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatusChip(card.status),
          const SizedBox(width: 8),
          PopupMenuButton<FuelCardStatus>(
            onSelected: (status) => onStatusChange(card.id, status),
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: FuelCardStatus.active,
                    child: Text('Activate'),
                  ),
                  const PopupMenuItem(
                    value: FuelCardStatus.inactive,
                    child: Text('Deactivate'),
                  ),
                  const PopupMenuItem(
                    value: FuelCardStatus.blocked,
                    child: Text('Block'),
                  ),
                ],
            child: const Icon(Icons.more_vert),
          ),
        ],
      ),
      onTap: () => onCardTap(card),
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
              'Card Number',
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
              'Balance',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Expanded(
            flex: 1,
            child: Text('Limit', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Expanded(
            flex: 1,
            child: Text(
              'Status',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Expanded(
            flex: 1,
            child: Text(
              'Actions',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopCardRow(FuelCard card) {
    return InkWell(
      onTap: () => onCardTap(card),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Icon(
                    card.cardType == CardType.virtual
                        ? Icons.smartphone
                        : Icons.credit_card,
                    color: _getStatusColor(card.status),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '**** **** **** ${card.cardNumber.substring(card.cardNumber.length - 4)}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Expanded(flex: 1, child: Text(_formatEnum(card.cardType))),
            Expanded(
              flex: 1,
              child: Text('\$${card.currentBalance.toStringAsFixed(2)}'),
            ),
            Expanded(
              flex: 1,
              child: Text('\$${card.spendingLimit.toStringAsFixed(2)}'),
            ),
            Expanded(flex: 1, child: _buildStatusChip(card.status)),
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: () => onCardTap(card),
                    tooltip: 'Edit Card',
                  ),
                  PopupMenuButton<FuelCardStatus>(
                    onSelected: (status) => onStatusChange(card.id, status),
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: FuelCardStatus.active,
                            child: Text('Activate'),
                          ),
                          const PopupMenuItem(
                            value: FuelCardStatus.inactive,
                            child: Text('Deactivate'),
                          ),
                          const PopupMenuItem(
                            value: FuelCardStatus.blocked,
                            child: Text('Block'),
                          ),
                        ],
                    child: const Icon(Icons.more_vert, size: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(FuelCardStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor(status).withOpacity(0.3)),
      ),
      child: Text(
        _formatEnum(status),
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor(FuelCardStatus status) {
    switch (status) {
      case FuelCardStatus.active:
        return Colors.green;
      case FuelCardStatus.inactive:
        return Colors.orange;
      case FuelCardStatus.blocked:
        return Colors.red;
      case FuelCardStatus.expired:
        return Colors.grey;
    }
  }

  String _formatEnum(dynamic enumValue) {
    return enumValue.toString().split('.').last.toUpperCase();
  }
}
