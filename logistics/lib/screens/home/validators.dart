class Validators {
  static String? validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Card number is required';
    }
    
    final cleanValue = value.replaceAll(RegExp(r'\s+'), '');
    
    if (cleanValue.length < 16 || cleanValue.length > 19) {
      return 'Card number must be 16-19 digits';
    }
    
    if (!RegExp(r'^\d+$').hasMatch(cleanValue)) {
      return 'Card number must contain only digits';
    }
    
    if (!_isValidLuhn(cleanValue)) {
      return 'Invalid card number';
    }
    
    return null;
  }
  
  static String? validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return 'CVV is required';
    }
    
    if (value.length != 3) {
      return 'CVV must be 3 digits';
    }
    
    if (!RegExp(r'^\d{3}$').hasMatch(value)) {
      return 'CVV must contain only digits';
    }
    
    return null;
  }
  
  static String? validatePin(String? value) {
    if (value == null || value.isEmpty) {
      return 'PIN is required';
    }
    
    if (value.length != 4) {
      return 'PIN must be 4 digits';
    }
    
    if (!RegExp(r'^\d{4}$').hasMatch(value)) {
      return 'PIN must contain only digits';
    }
    
    return null;
  }
  
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }
    
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid amount';
    }
    
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    
    if (amount > 10000) {
      return 'Amount cannot exceed \$10,000';
    }
    
    return null;
  }
  
  static String? validateSpendingLimit(String? value) {
    if (value == null || value.isEmpty) {
      return 'Spending limit is required';
    }
    
    final limit = double.tryParse(value);
    if (limit == null) {
      return 'Please enter a valid limit';
    }
    
    if (limit < 50) {
      return 'Minimum spending limit is \$50';
    }
    
    if (limit > 50000) {
      return 'Maximum spending limit is \$50,000';
    }
    
    return null;
  }
  
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }
  
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
  
  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }
  
  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return '$fieldName cannot exceed $maxLength characters';
    }
    return null;
  }
  
  static bool _isValidLuhn(String cardNumber) {
    int sum = 0;
    bool alternate = false;
    
    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cardNumber[i]);
      
      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit = (digit % 10) + 1;
        }
      }
      
      sum += digit;
      alternate = !alternate;
    }
    
    return sum % 10 == 0;
  }
}
