import 'package:flutter/material.dart';
import '../../models/fuel_card_models.dart';

enum LockerSlotStatus {
  empty,
  occupied,
  maintenance,
}

class LockerSlot {
  final String id;
  final int slotNumber;
  final LockerSlotStatus status;
  final String? fuelCardId;
  final DateTime? lastUpdated;

  const LockerSlot({
    required this.id,
    required this.slotNumber,
    required this.status,
    this.fuelCardId,
    this.lastUpdated,
  });

  LockerSlot copyWith({
    String? id,
    int? slotNumber,
    LockerSlotStatus? status,
    String? fuelCardId,
    DateTime? lastUpdated,
  }) {
    return LockerSlot(
      id: id ?? this.id,
      slotNumber: slotNumber ?? this.slotNumber,
      status: status ?? this.status,
      fuelCardId: fuelCardId ?? this.fuelCardId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class FuelCardLockersScreen extends StatefulWidget {
  const FuelCardLockersScreen({super.key});

  @override
  State<FuelCardLockersScreen> createState() => _FuelCardLockersScreenState();
}

class _FuelCardLockersScreenState extends State<FuelCardLockersScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  int _selectedLockerIndex = 0;
  bool _isLoading = false;

  // Mock data - replace with actual service calls
  final List<FuelCardLocker> _lockers = [
    FuelCardLocker(
      id: '1',
      name: 'Main Office Locker',
      location: 'Building A - Ground Floor',
      capacity: 20,
      currentOccupancy: 15,
      fuelCardIds: ['card1', 'card2', 'card3', 'card4', 'card5'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    FuelCardLocker(
      id: '2',
      name: 'Warehouse Locker',
      location: 'Warehouse B - Security Desk',
      capacity: 15,
      currentOccupancy: 8,
      fuelCardIds: ['card6', 'card7', 'card8'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    FuelCardLocker(
      id: '3',
      name: 'Field Office Locker',
      location: 'Field Office - Reception',
      capacity: 10,
      currentOccupancy: 6,
      fuelCardIds: ['card9', 'card10'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  List<LockerSlot> _generateSlotsForLocker(FuelCardLocker locker) {
    final slots = <LockerSlot>[];
    for (int i = 1; i <= locker.capacity; i++) {
      final isOccupied = i <= locker.currentOccupancy;
      slots.add(LockerSlot(
        id: '${locker.id}_slot_$i',
        slotNumber: i,
        status: isOccupied ? LockerSlotStatus.occupied : LockerSlotStatus.empty,
        fuelCardId: isOccupied ? 'card_$i' : null,
        lastUpdated: DateTime.now(),
      ));
    }
    return slots;
  }

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
        title: const Text('Fuel Card Lockers'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildLockerSelector(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildLockerGrid(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCardDialog,
        child: const Icon(Icons.add_card),
      ),
    );
  }

  Widget _buildLockerSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Locker',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _lockers.asMap().entries.map((entry) {
                final index = entry.key;
                final locker = entry.value;
                final isSelected = _selectedLockerIndex == index;
                
                return GestureDetector(
                  onTap: () => _selectLocker(index),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          locker.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : null,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          locker.location,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8)
                                    : Colors.grey[600],
                              ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.inventory_2,
                              size: 16,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${locker.currentOccupancy}/${locker.capacity}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.onPrimary
                                        : Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockerGrid() {
    final selectedLocker = _lockers[_selectedLockerIndex];
    final slots = _generateSlotsForLocker(selectedLocker);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLockerStats(selectedLocker),
          const SizedBox(height: 16),
          _buildGridLegend(),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: slots.length,
              itemBuilder: (context, index) {
                return _buildSlotCard(slots[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockerStats(FuelCardLocker locker) {
    final occupancyPercentage = (locker.currentOccupancy / locker.capacity * 100).round();
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'Total Capacity',
                locker.capacity.toString(),
                Icons.inventory_2,
                Colors.blue,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                'Occupied',
                locker.currentOccupancy.toString(),
                Icons.credit_card,
                Colors.green,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                'Available',
                (locker.capacity - locker.currentOccupancy).toString(),
                Icons.inbox,
                Colors.orange,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                'Occupancy',
                '$occupancyPercentage%',
                Icons.pie_chart,
                Colors.purple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildGridLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem('Empty', Colors.grey[200]!, Colors.grey[800]!),
        _buildLegendItem('Occupied', Colors.green[100]!, Colors.green[800]!),
        _buildLegendItem('Maintenance', Colors.red[100]!, Colors.red[800]!),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color backgroundColor, Color textColor) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: textColor.withValues(alpha: 0.3)),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: textColor,
              ),
        ),
      ],
    );
  }

  Widget _buildSlotCard(LockerSlot slot) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData icon;

    switch (slot.status) {
      case LockerSlotStatus.empty:
        backgroundColor = Colors.grey[200]!;
        borderColor = Colors.grey[400]!;
        textColor = Colors.grey[800]!;
        icon = Icons.inbox_outlined;
        break;
      case LockerSlotStatus.occupied:
        backgroundColor = Colors.green[100]!;
        borderColor = Colors.green[400]!;
        textColor = Colors.green[800]!;
        icon = Icons.credit_card;
        break;
      case LockerSlotStatus.maintenance:
        backgroundColor = Colors.red[100]!;
        borderColor = Colors.red[400]!;
        textColor = Colors.red[800]!;
        icon = Icons.build;
        break;
    }

    return GestureDetector(
      onTap: () => _onSlotTapped(slot),
      child: Card(
        elevation: 2,
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: borderColor, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor, size: 20),
              const SizedBox(height: 4),
              Text(
                slot.slotNumber.toString(),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectLocker(int index) {
    setState(() {
      _selectedLockerIndex = index;
    });
  }

  void _refreshData() {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data refreshed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _onSlotTapped(LockerSlot slot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Slot ${slot.slotNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${_getStatusText(slot.status)}'),
            if (slot.fuelCardId != null) ...[
              const SizedBox(height: 8),
              Text('Fuel Card: ${slot.fuelCardId}'),
            ],
            if (slot.lastUpdated != null) ...[
              const SizedBox(height: 8),
              Text('Last Updated: ${_formatDateTime(slot.lastUpdated!)}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (slot.status == LockerSlotStatus.occupied)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _removeCard(slot);
              },
              child: const Text('Remove Card'),
            ),
          if (slot.status == LockerSlotStatus.empty)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _addCardToSlot(slot);
              },
              child: const Text('Add Card'),
            ),
        ],
      ),
    );
  }

  void _showAddCardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Fuel Card'),
        content: const Text('This feature will allow you to add a fuel card to an empty slot.'),
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
                  content: Text('Add card feature coming soon!'),
                ),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _removeCard(LockerSlot slot) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Card removed from slot ${slot.slotNumber}'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _addCardToSlot(LockerSlot slot) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Card added to slot ${slot.slotNumber}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _getStatusText(LockerSlotStatus status) {
    switch (status) {
      case LockerSlotStatus.empty:
        return 'Empty';
      case LockerSlotStatus.occupied:
        return 'Occupied';
      case LockerSlotStatus.maintenance:
        return 'Under Maintenance';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
