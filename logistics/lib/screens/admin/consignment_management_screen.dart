import 'package:flutter/material.dart';
import 'package:logistics/models/consignment.dart';
import 'package:logistics/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageConsignmentsScreen extends StatefulWidget {
  const ManageConsignmentsScreen({super.key});

  @override
  State<ManageConsignmentsScreen> createState() =>
      _ManageConsignmentsScreenState();
}

class _ManageConsignmentsScreenState extends State<ManageConsignmentsScreen> {
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

      var query = _supabase.from('consignments').select();

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

  Future<void> _updateConsignmentStatus(
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

      _loadConsignments();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Consignment status updated to $newStatus'),
            backgroundColor: AppConstants.secondaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating consignment: $e'),
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
                  'Manage Consignments',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Filter Chips
          Row(
            children: [
              const Text(
                'Filter: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: SingleChildScrollView(
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
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Consignments List
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
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Text(
          'ID: ${consignment.id.substring(0, 8)}...',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(consignment.itemDescription),
            Row(
              children: [
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
                    consignment.status.toUpperCase().replaceAll('_', ' '),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${consignment.weight} kg',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Pickup', consignment.pickupLocation),
                _buildDetailRow('Delivery', consignment.deliveryLocation),
                _buildDetailRow('Weight', '${consignment.weight} kg'),
                if (consignment.specialInstructions != null)
                  _buildDetailRow(
                    'Instructions',
                    consignment.specialInstructions!,
                  ),
                _buildDetailRow(
                  'Created',
                  consignment.createdAt.toString().substring(0, 16),
                ),

                const SizedBox(height: 16),

                // Status Update Buttons
                if (consignment.status != 'delivered' &&
                    consignment.status != 'cancelled')
                  Wrap(
                    spacing: 8,
                    children: _getStatusUpdateButtons(consignment),
                  ),
              ],
            ),
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

  List<Widget> _getStatusUpdateButtons(ConsignmentModel consignment) {
    List<Widget> buttons = [];

    switch (consignment.status) {
      case 'pending':
        buttons.add(_buildStatusButton('assigned', 'Assign', Colors.blue));
        buttons.add(_buildStatusButton('cancelled', 'Cancel', Colors.red));
        break;
      case 'assigned':
        buttons.add(
          _buildStatusButton('picked_up', 'Picked Up', Colors.orange),
        );
        buttons.add(_buildStatusButton('cancelled', 'Cancel', Colors.red));
        break;
      case 'picked_up':
        buttons.add(
          _buildStatusButton('in_transit', 'In Transit', Colors.purple),
        );
        break;
      case 'in_transit':
        buttons.add(_buildStatusButton('delivered', 'Delivered', Colors.green));
        break;
    }

    return buttons;
  }

  Widget _buildStatusButton(String status, String label, Color color) {
    return ElevatedButton(
      onPressed:
          () => _updateConsignmentStatus(
            _consignments.firstWhere((c) => c.status != status),
            status,
          ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
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
