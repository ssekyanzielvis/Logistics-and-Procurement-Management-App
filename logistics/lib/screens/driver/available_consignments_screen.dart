import 'package:flutter/material.dart';
import 'package:logistics/models/consignment.dart';
import 'package:logistics/services/auth_service.dart';
import 'package:logistics/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AvailableConsignmentsScreen extends StatefulWidget {
  const AvailableConsignmentsScreen({super.key});

  @override
  State<AvailableConsignmentsScreen> createState() =>
      _AvailableConsignmentsScreenState();
}

class _AvailableConsignmentsScreenState
    extends State<AvailableConsignmentsScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<ConsignmentModel> _availableConsignments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAvailableConsignments();
  }

  Future<void> _loadAvailableConsignments() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await _supabase
          .from('consignments')
          .select()
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      setState(() {
        _availableConsignments =
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

  Future<void> _acceptConsignment(ConsignmentModel consignment) async {
    try {
      final user = Provider.of<AuthService>(context, listen: false).currentUser;

      await _supabase
          .from('consignments')
          .update({
            'driver_id': user!.id,
            'status': 'assigned',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', consignment.id);

      _loadAvailableConsignments();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Consignment accepted successfully!'),
            backgroundColor: AppConstants.secondaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accepting consignment: $e'),
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
                  'Available Consignments',
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
                    : _availableConsignments.isEmpty
                    ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.local_shipping_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No available consignments',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                    : RefreshIndicator(
                      onRefresh: _loadAvailableConsignments,
                      child: ListView.builder(
                        itemCount: _availableConsignments.length,
                        itemBuilder: (context, index) {
                          final consignment = _availableConsignments[index];
                          return _buildConsignmentCard(consignment);
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsignmentCard(ConsignmentModel consignment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_shipping, color: AppConstants.primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    consignment.itemDescription,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${consignment.weight} kg',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _buildLocationRow(
              Icons.location_on,
              'Pickup',
              consignment.pickupLocation,
              Colors.blue,
            ),

            const SizedBox(height: 8),

            _buildLocationRow(
              Icons.location_off,
              'Delivery',
              consignment.deliveryLocation,
              Colors.red,
            ),

            if (consignment.specialInstructions != null) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.note, size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      consignment.specialInstructions!,
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

            Row(
              children: [
                Text(
                  'Created: ${consignment.createdAt.toString().substring(0, 16)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => _showAcceptDialog(consignment),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Accept'),
                ),
              ],
            ),
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

  void _showAcceptDialog(ConsignmentModel consignment) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Accept Consignment'),
            content: Text(
              'Are you sure you want to accept this delivery?\n\nFrom: ${consignment.pickupLocation}\nTo: ${consignment.deliveryLocation}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _acceptConsignment(consignment);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Accept'),
              ),
            ],
          ),
    );
  }
}
