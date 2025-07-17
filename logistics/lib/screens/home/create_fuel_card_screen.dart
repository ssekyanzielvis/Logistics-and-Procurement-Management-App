import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/fuel_card_service.dart';
import '../home/responsive_layout.dart';

class CreateFuelCardScreen extends StatefulWidget {
  const CreateFuelCardScreen({Key? key}) : super(key: key);

  @override
  State<CreateFuelCardScreen> createState() => _CreateFuelCardScreenState();
}

class _CreateFuelCardScreenState extends State<CreateFuelCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _spendingLimitController = TextEditingController();
  final FuelCardService _fuelCardService = FuelCardService();

  String _cardType = 'physical';
  List<String> _selectedFuelTypes = ['diesel'];
  bool _isLoading = false;

  final List<String> _availableFuelTypes = [
    'diesel',
    'petrol',
    'electric',
    'hybrid',
  ];

  @override
  void dispose() {
    _cardNumberController.dispose();
    _spendingLimitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Fuel Card'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        desktop: _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildForm(),
    );
  }

  Widget _buildTabletLayout() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(24),
        child: _buildForm(),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.all(32),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: _buildPreviewCard(),
            ),
            const SizedBox(width: 32),
            Expanded(
              flex: 1,
              child: _buildForm(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fuel Card Details',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildCardTypeSelection(),
              const SizedBox(height: 20),
              _buildCardNumberField(),
              const SizedBox(height: 20),
              _buildSpendingLimitField(),
              const SizedBox(height: 20),
              _buildFuelTypeSelection(),
              const SizedBox(height: 32),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Card Type',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Physical'),
                subtitle: const Text('Physical card with chip'),
                value: 'physical',
                groupValue: _cardType,
                onChanged: (value) => setState(() => _cardType = value!),
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Digital'),
                subtitle: const Text('Mobile app integration'),
                value: 'digital',
                groupValue: _cardType,
                onChanged: (value) => setState(() => _cardType = value!),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardNumberField() {
    return TextFormField(
      controller: _cardNumberController,
      decoration: const InputDecoration(
        labelText: 'Card Number',
        hintText: '1234567890123456',
        prefixIcon: Icon(Icons.credit_card),
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(16),
        _CardNumberFormatter(),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter card number';
        }
               if (value.replaceAll(' ', '').length != 16) {
          return 'Card number must be 16 digits';
        }
        return null;
      },
    );
  }

  Widget _buildSpendingLimitField() {
    return TextFormField(
      controller: _spendingLimitController,
      decoration: const InputDecoration(
        labelText: 'Spending Limit',
        hintText: '1000.00',
        prefixIcon: Icon(Icons.attach_money),
        prefixText: '\$',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter spending limit';
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return 'Please enter a valid amount';
        }
        if (amount > 10000) {
          return 'Spending limit cannot exceed \$10,000';
        }
        return null;
      },
    );
  }

  Widget _buildFuelTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Allowed Fuel Types',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _availableFuelTypes.map((fuelType) {
            final isSelected = _selectedFuelTypes.contains(fuelType);
            return FilterChip(
              label: Text(fuelType.toUpperCase()),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedFuelTypes.add(fuelType);
                  } else {
                    _selectedFuelTypes.remove(fuelType);
                  }
                });
              },
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
            );
          }).toList(),
        ),
        if (_selectedFuelTypes.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Please select at least one fuel type',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _createFuelCard,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Create Card'),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Card Preview',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_cardType.toUpperCase()} CARD',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          _cardType == 'digital' ? Icons.smartphone : Icons.credit_card,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      _cardNumberController.text.isEmpty 
                          ? '**** **** **** ****'
                          : _cardNumberController.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'LIMIT',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _spendingLimitController.text.isEmpty
                                  ? '\$0.00'
                                  : '\$${_spendingLimitController.text}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (_selectedFuelTypes.isNotEmpty)
                          Wrap(
                            spacing: 4,
                            children: _selectedFuelTypes.take(3).map((type) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  type.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createFuelCard() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFuelTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one fuel type')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _fuelCardService.createFuelCard(
        cardNumber: _cardNumberController.text.replaceAll(' ', ''),
        cardType: _cardType,
        spendingLimit: double.parse(_spendingLimitController.text),
        allowedFuelTypes: _selectedFuelTypes,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fuel card created successfully')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating fuel card: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

