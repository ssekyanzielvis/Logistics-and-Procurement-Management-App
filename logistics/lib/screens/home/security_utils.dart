import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class SecurityUtils {
  static String generatePickupCode({int length = 6}) {
    const chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final random = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }
  
  static String generateCardNumber() {
    final random = Random.secure();
    final prefix = '4532'; // Visa test prefix
    final middle = List.generate(8, (_) => random.nextInt(10)).join();
    final partial = prefix + middle;
    
    // Calculate Luhn check digit
    final checkDigit = _calculateLuhnCheckDigit(partial);
    return partial + checkDigit.toString();
  }
  
  static String generateCVV() {
    final random = Random.secure();
    return List.generate(3, (_) => random.nextInt(10)).join();
  }
  
  static String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  static bool verifyPin(String pin, String hashedPin) {
    return hashPin(pin) == hashedPin;
  }
  
  static String maskCardNumber(String cardNumber) {
    if (cardNumber.length < 4) return cardNumber;
    final last4 = cardNumber.substring(cardNumber.length - 4);
    return '**** **** **** $last4';
  }
  
  static bool isValidCardNumber(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(RegExp(r'\s+'), '');
    if (cleanNumber.length < 13 || cleanNumber.length > 19) return false;
    
    return _isValidLuhn(cleanNumber);
  }
  
  static String encryptSensitiveData(String data, String key) {
    // In production, use proper encryption like AES
    // This is a simple XOR for demonstration
    final keyBytes = utf8.encode(key);
    final dataBytes = utf8.encode(data);
    final encrypted = <int>[];
    
    for (int i = 0; i < dataBytes.length; i++) {
      encrypted.add(dataBytes[i] ^ keyBytes[i % keyBytes.length]);
    }
    
    return base64.encode(encrypted);
  }
  
  static String decryptSensitiveData(String encryptedData, String key) {
    try {
      final keyBytes = utf8.encode(key);
      final encryptedBytes = base64.decode(encryptedData);
      final decrypted = <int>[];
      
      for (int i = 0; i < encryptedBytes.length; i++) {
        decrypted.add(encryptedBytes[i] ^ keyBytes[i % keyBytes.length]);
      }
      
      return utf8.decode(decrypted);
    } catch (e) {
      throw Exception('Failed to decrypt data');
    }
  }
  
  static bool isStrongPin(String pin) {
    if (pin.length != 4) return false;
    
    // Check for sequential numbers
    bool isSequential = true;
    for (int i = 1; i < pin.length; i++) {
      if (int.parse(pin[i]) != int.parse(pin[i-1]) + 1) {
        isSequential = false;
        break;
      }
    }
    if (isSequential) return false;
    
    // Check for repeated digits
    final uniqueDigits = pin.split('').toSet();
    if (uniqueDigits.length < 3) return false;
    
    // Check for common weak PINs
    const weakPins = ['0000', '1111', '2222', '3333', '4444', '5555', 
                      '6666', '7777', '8888', '9999', '1234', '4321'];
    if (weakPins.contains(pin)) return false;
    
    return true;
  }
  
  static int _calculateLuhnCheckDigit(String number) {
    int sum = 0;
    bool alternate = true;
    
    for (int i = number.length - 1; i >= 0; i--) {
      int digit = int.parse(number[i]);
      
      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit = (digit % 10) + 1;
        }
      }
      
      sum += digit;
      alternate = !alternate;
    }
    
    return (10 - (sum % 10)) % 10;
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
