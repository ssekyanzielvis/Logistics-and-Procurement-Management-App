import 'package:flutter/material.dart';
import 'package:logistics/models/consignment.dart';
import 'package:logistics/services/auth_service.dart';
import 'package:logistics/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyDeliveriesScreen extends StatefulWidget {
  const MyDeliveriesScreen({super.key});

  @override
  State<MyDeliveriesScreen> createState() => _MyDeliveriesScreenState();
}

class _MyDeliveriesScreenState extends State<MyDeliveriesScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<ConsignmentModel> _myDeliveries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyDeliveries();
  }

  Future<void> _loadMyDeliveries() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final user = Provider.of<AuthService>(context, listen: false).currentUser;
      final response = await _supabase
          .from('consignments')
          .select()
          .eq('driver_id', user!.id)
          .order('created_at', ascending: false);

      setState(() {
        _myDeliveries =
            response
                .map<ConsignmentModel>(
                  (json) => ConsignmentModel.fromJson(json),
                )
                .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading deliveries: $e'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _updateDeliveryStatus(
    ConsignmentModel consignment,
    String newStatus,
  ) async {
    try {
      await _supabase
          .from('consignments')
          .update({
            'status': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', consignment.id);

      _loadMyDeliveries();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Status updated to ${newStatus.replaceAll('_', ' ')}',
            ),
            backgroundColor: AppConstants.secondaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: $e'),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back Button and Title Row
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Back',
              ),
              const Expanded(
                child: Text(
                  'My Deliveries',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _myDeliveries.isEmpty
                    ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No deliveries assigned yet',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                    : RefreshIndicator(
                      onRefresh: _loadMyDeliveries,
                      child: ListView.builder(
                        itemCount: _myDeliveries.length,
                        itemBuilder: (context, index) {
                          final delivery = _myDeliveries[index];
                          return _buildDeliveryCard(delivery);
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard(ConsignmentModel delivery) {
    Color statusColor = _getStatusColor(delivery.status);
    IconData statusIcon = _getStatusIcon(delivery.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: statusColor.withOpacity(0.2),
                  child: Icon(statusIcon, color: statusColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        delivery.itemDescription,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          delivery.status.toUpperCase().replaceAll('_', ' '),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${delivery.weight} kg',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _buildLocationRow(
              Icons.location_on,
              'Pickup',
              delivery.pickupLocation,
              Colors.blue,
            ),

            const SizedBox(height: 8),

            _buildLocationRow(
              Icons.location_off,
              'Delivery',
              delivery.deliveryLocation,
              Colors.red,
            ),

            if (delivery.specialInstructions != null) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.note, size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      delivery.specialInstructions!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),

            // Action Buttons
            if (delivery.status != 'delivered' &&
                delivery.status != 'cancelled')
              Row(children: _getActionButtons(delivery)),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow(
    IconData icon,
    String label,
    String location,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Expanded(child: Text(location, style: const TextStyle(fontSize: 12))),
      ],
    );
  }

  List<Widget> _getActionButtons(ConsignmentModel delivery) {
    List<Widget> buttons = [];

    switch (delivery.status) {
      case 'assigned':
        buttons.add(
          ElevatedButton(
            onPressed: () => _updateDeliveryStatus(delivery, 'picked_up'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Mark Picked Up'),
          ),
        );
        break;
      case 'picked_up':
        buttons.add(
          ElevatedButton(
            onPressed: () => _updateDeliveryStatus(delivery, 'in_transit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Start Transit'),
          ),
        );
        break;
      case 'in_transit':
        buttons.add(
          ElevatedButton(
            onPressed: () => _updateDeliveryStatus(delivery, 'delivered'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Mark Delivered'),
          ),
        );
        break;
    }

    return buttons;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'assigned':
        return Colors.blue;
      case 'picked_up':
        return Colors.orange;
      case 'in_transit':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'assigned':
        return Icons.assignment;
      case 'picked_up':
        return Icons.local_shipping;
      case 'in_transit':
        return Icons.directions_car;
      case 'delivered':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
}
