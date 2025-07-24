import 'package:flutter/material.dart';
import 'package:logistics/models/consignment.dart';
import 'package:logistics/services/auth_service.dart';
import 'package:logistics/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyConsignmentsScreen extends StatefulWidget {
  const MyConsignmentsScreen({super.key});

  @override
  State<MyConsignmentsScreen> createState() => _MyConsignmentsScreenState();
}

class _MyConsignmentsScreenState extends State<MyConsignmentsScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<ConsignmentModel> _consignments = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadConsignments();
  }

  Future<void> _loadConsignments() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final user = Provider.of<AuthService>(context, listen: false).currentUser;
      var query = _supabase
          .from('consignments')
          .select()
          .eq('client_id', user!.id);

      if (_selectedFilter != 'all') {
        query = query.eq('status', _selectedFilter);
      }

      final response = await query.order('created_at', ascending: false);

      setState(() {
        _consignments =
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
            content: Text('Error loading consignments: $e'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Consignments',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', 'All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('pending', 'Pending'),
                  const SizedBox(width: 8),
                  _buildFilterChip('assigned', 'Assigned'),
                  const SizedBox(width: 8),
                  _buildFilterChip('in_transit', 'In Transit'),
                  const SizedBox(width: 8),
                  _buildFilterChip('delivered', 'Delivered'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _consignments.isEmpty
                      ? const Center(
                        child: Text(
                          'No consignments found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                      : RefreshIndicator(
                        onRefresh: _loadConsignments,
                        child: ListView.builder(
                          itemCount: _consignments.length,
                          itemBuilder: (context, index) {
                            final consignment = _consignments[index];
                            return _buildConsignmentCard(consignment);
                          },
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    return FilterChip(
      label: Text(label),
      selected: _selectedFilter == value,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
        _loadConsignments();
      },
      selectedColor: AppConstants.primaryColor.withOpacity(0.2),
      checkmarkColor: AppConstants.primaryColor,
    );
  }

  Widget _buildConsignmentCard(ConsignmentModel consignment) {
    Color statusColor = _getStatusColor(consignment.status);
    IconData statusIcon = _getStatusIcon(consignment.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Text(
          consignment.itemDescription,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('From: ${consignment.pickupLocation}'),
            Text('To: ${consignment.deliveryLocation}'),
            Text('Weight: ${consignment.weight} kg'),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                consignment.status.toUpperCase().replaceAll('_', ' '),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          _showConsignmentDetails(consignment);
        },
        isThreeLine: true,
      ),
    );
  }

  void _showConsignmentDetails(ConsignmentModel consignment) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Consignment Details'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow('ID', '${consignment.id.substring(0, 8)}...'),
                  _buildDetailRow('Item', consignment.itemDescription),
                  _buildDetailRow('Weight', '${consignment.weight} kg'),
                  _buildDetailRow('Pickup', consignment.pickupLocation),
                  _buildDetailRow('Delivery', consignment.deliveryLocation),
                  _buildDetailRow(
                    'Status',
                    consignment.status.toUpperCase().replaceAll('_', ' '),
                  ),
                  if (consignment.specialInstructions != null)
                    _buildDetailRow(
                      'Instructions',
                      consignment.specialInstructions!,
                    ),
                  _buildDetailRow(
                    'Created',
                    consignment.createdAt.toString().substring(0, 16),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'assigned':
        return Colors.blue;
      case 'picked_up':
        return Colors.purple;
      case 'in_transit':
        return Colors.indigo;
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
      case 'pending':
        return Icons.hourglass_empty;
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
