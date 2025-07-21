import 'package:flutter/material.dart';
import 'package:logistics/models/consignment.dart';
import 'package:logistics/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TrackConsignmentScreen extends StatefulWidget {
  const TrackConsignmentScreen({super.key});

  @override
  State<TrackConsignmentScreen> createState() => _TrackConsignmentScreenState();
}

class _TrackConsignmentScreenState extends State<TrackConsignmentScreen> {
  final _trackingController = TextEditingController();
  final SupabaseClient _supabase = Supabase.instance.client;
  ConsignmentModel? _consignment;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _trackingController.dispose();
    super.dispose();
  }

  Future<void> _trackConsignment() async {
    if (_trackingController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a tracking ID';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _consignment = null;
    });

    try {
      final response =
          await _supabase
              .from('consignments')
              .select()
              .eq('id', _trackingController.text.trim())
              .single();

      setState(() {
        _consignment = ConsignmentModel.fromJson(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Consignment not found. Please check your tracking ID.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Track Consignment',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          // Tracking Input
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _trackingController,
                  decoration: InputDecoration(
                    labelText: 'Enter Tracking ID',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _isLoading ? null : _trackConsignment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text(
                          'Track',
                          style: TextStyle(color: Colors.white),
                        ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Results
          Expanded(child: _buildTrackingResults()),
        ],
      ),
    );
  }

  Widget _buildTrackingResults() {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_consignment == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.track_changes, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Enter a tracking ID to track your consignment',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Consignment Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Consignment Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'Tracking ID',
                    '${_consignment!.id.substring(0, 8)}...',
                  ),
                  _buildInfoRow('Item', _consignment!.itemDescription),
                  _buildInfoRow('Weight', '${_consignment!.weight} kg'),
                  _buildInfoRow('From', _consignment!.pickupLocation),
                  _buildInfoRow('To', _consignment!.deliveryLocation),
                  if (_consignment!.specialInstructions != null)
                    _buildInfoRow(
                      'Instructions',
                      _consignment!.specialInstructions!,
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Status Timeline
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delivery Status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatusTimeline(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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

  Widget _buildStatusTimeline() {
    final statuses = [
      {
        'status': 'pending',
        'title': 'Order Placed',
        'description': 'Your order has been received',
      },
      {
        'status': 'assigned',
        'title': 'Driver Assigned',
        'description': 'A driver has been assigned to your order',
      },
      {
        'status': 'picked_up',
        'title': 'Picked Up',
        'description': 'Your package has been picked up',
      },
      {
        'status': 'in_transit',
        'title': 'In Transit',
        'description': 'Your package is on the way',
      },
      {
        'status': 'delivered',
        'title': 'Delivered',
        'description': 'Your package has been delivered',
      },
    ];

    int currentStatusIndex = statuses.indexWhere(
      (s) => s['status'] == _consignment!.status,
    );

    return Column(
      children:
          statuses.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, String> statusInfo = entry.value;

            bool isCompleted = index <= currentStatusIndex;
            bool isCurrent = index == currentStatusIndex;

            return _buildTimelineItem(
              statusInfo['title']!,
              statusInfo['description']!,
              isCompleted,
              isCurrent,
              index < statuses.length - 1,
            );
          }).toList(),
    );
  }

  Widget _buildTimelineItem(
    String title,
    String description,
    bool isCompleted,
    bool isCurrent,
    bool hasNext,
  ) {
    Color color = isCompleted ? AppConstants.secondaryColor : Colors.grey;
    if (isCurrent) color = AppConstants.primaryColor;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child:
                  isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 12)
                      : null,
            ),
            if (hasNext)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? color : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
