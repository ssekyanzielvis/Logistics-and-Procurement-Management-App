import 'package:flutter/material.dart';
import 'package:logistics/services/auth_service.dart';
import 'package:logistics/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:uuid/uuid.dart';

class CreateConsignmentScreen extends StatefulWidget {
  const CreateConsignmentScreen({super.key});

  @override
  State<CreateConsignmentScreen> createState() =>
      _CreateConsignmentScreenState();
}

class _CreateConsignmentScreenState extends State<CreateConsignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pickupController = TextEditingController();
  final _deliveryController = TextEditingController();
  final _itemDescriptionController = TextEditingController();
  final _weightController = TextEditingController();
  final _instructionsController = TextEditingController();

  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isLoading = false;

  @override
  void dispose() {
    _pickupController.dispose();
    _deliveryController.dispose();
    _itemDescriptionController.dispose();
    _weightController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _createConsignment() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final user =
            Provider.of<AuthService>(context, listen: false).currentUser;
        const uuid = Uuid();

        final consignmentData = {
          'id': uuid.v4(),
          'client_id': user!.id,
          'pickup_location': _pickupController.text.trim(),
          'delivery_location': _deliveryController.text.trim(),
          'item_description': _itemDescriptionController.text.trim(),
          'weight': double.parse(_weightController.text),
          'status': AppConstants.statusPending,
          'special_instructions':
              _instructionsController.text.trim().isEmpty
                  ? null
                  : _instructionsController.text.trim(),
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        await _supabase.from('consignments').insert(consignmentData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Consignment created successfully!'),
              backgroundColor: AppConstants.secondaryColor,
            ),
          );

          // Clear form
          _formKey.currentState!.reset();
          _pickupController.clear();
          _deliveryController.clear();
          _itemDescriptionController.clear();
          _weightController.clear();
          _instructionsController.clear();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating consignment: $e'),
              backgroundColor: AppConstants.errorColor,
            ),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create New Consignment',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              // Pickup Location
              TextFormField(
                controller: _pickupController,
                decoration: InputDecoration(
                  labelText: 'Pickup Location',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter pickup location';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Delivery Location
              TextFormField(
                controller: _deliveryController,
                decoration: InputDecoration(
                  labelText: 'Delivery Location',
                  prefixIcon: const Icon(Icons.location_off),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter delivery location';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Item Description
              TextFormField(
                controller: _itemDescriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Item Description',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter item description';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Weight
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Weight (kg)',
                  prefixIcon: const Icon(Icons.scale),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter weight';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid weight';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Special Instructions
              TextFormField(
                controller: _instructionsController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Special Instructions (Optional)',
                  prefixIcon: const Icon(Icons.note),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),

              const SizedBox(height: 24),

              // Create Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createConsignment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Create Consignment',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
