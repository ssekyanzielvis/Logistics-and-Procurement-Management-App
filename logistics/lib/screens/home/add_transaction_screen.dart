import 'package:flutter/material.dart';
import '../../models/fuel_card_models.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Form controllers
  final _stationController = TextEditingController();
  final _locationController = TextEditingController();
  final _amountController = TextEditingController();
  final _quantityController = TextEditingController();
  final _pricePerUnitController = TextEditingController();
  final _authCodeController = TextEditingController();
  final _receiptController = TextEditingController();

  // Form data
  String? _selectedFuelCardId;
  TransactionType _selectedType = TransactionType.fuel;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  // Mock data - replace with actual service calls
  final List<FuelCard> _availableCards = [
    FuelCard(
      id: '1',
      cardNumber: '1234-5678-9012',
      cardHolderName: 'John Doe',
      provider: FuelCardProvider.shell,
      status: FuelCardStatus.active,
      issueDate: DateTime.now().subtract(const Duration(days: 365)),
      spendingLimit: 500.0,
      currentBalance: 250.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    FuelCard(
      id: '2',
      cardNumber: '2345-6789-0123',
      cardHolderName: 'Jane Smith',
      provider: FuelCardProvider.bp,
      status: FuelCardStatus.active,
      issueDate: DateTime.now().subtract(const Duration(days: 300)),
      spendingLimit: 750.0,
      currentBalance: 425.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
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
    _stationController.dispose();
    _locationController.dispose();
    _amountController.dispose();
    _quantityController.dispose();
    _pricePerUnitController.dispose();
    _authCodeController.dispose();
    _receiptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Transaction Details'),
                const SizedBox(height: 16),
                _buildFuelCardDropdown(),
                const SizedBox(height: 16),
                _buildTransactionTypeSelector(),
                const SizedBox(height: 16),
                _buildDateSelector(),
                const SizedBox(height: 24),
                _buildSectionHeader('Location Information'),
                const SizedBox(height: 16),
                _buildStationField(),
                const SizedBox(height: 16),
                _buildLocationField(),
                const SizedBox(height: 24),
                _buildSectionHeader('Amount Details'),
                const SizedBox(height: 16),
                _buildAmountFields(),
                const SizedBox(height: 24),
                _buildSectionHeader('Additional Information'),
                const SizedBox(height: 16),
                _buildAuthCodeField(),
                const SizedBox(height: 16),
                _buildReceiptField(),
                const SizedBox(height: 32),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildFuelCardDropdown() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Fuel Card',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedFuelCardId,
              decoration: const InputDecoration(
                labelText: 'Fuel Card',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.credit_card),
              ),
              items: _availableCards.map((card) {
                return DropdownMenuItem<String>(
                  value: card.id,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(card.cardHolderName),
                      Text(
                        '${card.cardNumber} - ${card.provider.name.toUpperCase()}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedFuelCardId = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a fuel card';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTypeSelector() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction Type',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: TransactionType.values.map((type) {
                return ChoiceChip(
                  label: Text(_getTransactionTypeLabel(type)),
                  selected: _selectedType == type,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedType = type;
                      });
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.date_range),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transaction Date',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    _formatDate(_selectedDate),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: _selectDate,
              child: const Text('Change'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStationField() {
    return TextFormField(
      controller: _stationController,
      decoration: const InputDecoration(
        labelText: 'Gas Station',
        hintText: 'Shell, BP, Exxon, etc.',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.local_gas_station),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter the gas station name';
        }
        return null;
      },
    );
  }

  Widget _buildLocationField() {
    return TextFormField(
      controller: _locationController,
      decoration: const InputDecoration(
        labelText: 'Location',
        hintText: 'Address or location details',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.location_on),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter the location';
        }
        return null;
      },
    );
  }

  Widget _buildAmountFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Total Amount',
                  hintText: '0.00',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Invalid amount';
                  }
                  return null;
                },
                onChanged: _calculatePricePerUnit,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  hintText: '0.00',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_gas_station),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Invalid quantity';
                  }
                  return null;
                },
                onChanged: _calculatePricePerUnit,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _pricePerUnitController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Price per Unit',
            hintText: '0.00',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.speed),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter price per unit';
            }
            if (double.tryParse(value) == null) {
              return 'Invalid price';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAuthCodeField() {
    return TextFormField(
      controller: _authCodeController,
      decoration: const InputDecoration(
        labelText: 'Authorization Code (Optional)',
        hintText: 'Enter authorization code',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.security),
      ),
    );
  }

  Widget _buildReceiptField() {
    return TextFormField(
      controller: _receiptController,
      decoration: const InputDecoration(
        labelText: 'Receipt Number (Optional)',
        hintText: 'Enter receipt number',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.receipt),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Add Transaction',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  String _getTransactionTypeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.fuel:
        return 'Fuel';
      case TransactionType.carWash:
        return 'Car Wash';
      case TransactionType.convenience:
        return 'Convenience';
      case TransactionType.maintenance:
        return 'Maintenance';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    final month = months[date.month - 1];
    final day = date.day.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    
    return '$month $day, $year - $hour:$minute $ampm';
  }

  void _calculatePricePerUnit(String value) {
    final amount = double.tryParse(_amountController.text);
    final quantity = double.tryParse(_quantityController.text);

    if (amount != null && quantity != null && quantity > 0) {
      final pricePerUnit = amount / quantity;
      _pricePerUnitController.text = pricePerUnit.toStringAsFixed(2);
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (time != null && mounted) {
        setState(() {
          _selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _submitTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Create transaction object
      final transaction = FuelTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fuelCardId: _selectedFuelCardId!,
        type: _selectedType,
        amount: double.parse(_amountController.text),
        quantity: double.parse(_quantityController.text),
        pricePerUnit: double.parse(_pricePerUnitController.text),
        station: _stationController.text,
        location: _locationController.text,
        transactionDate: _selectedDate,
        authorizationCode: _authCodeController.text.isEmpty
            ? null
            : _authCodeController.text,
        receiptNumber: _receiptController.text.isEmpty
            ? null
            : _receiptController.text,
        createdAt: DateTime.now(),
      );

      // TODO: Submit to service
      // await fuelCardService.recordTransaction(transaction);
      print('Transaction created: ${transaction.toJson()}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
