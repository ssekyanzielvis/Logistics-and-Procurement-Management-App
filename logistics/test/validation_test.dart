import 'package:flutter_test/flutter_test.dart';
import '../lib/utils/validation_utils.dart';

void main() {
  group('Email Validation Tests', () {
    test('should accept valid emails including the specific format mentioned', () {
      // Test the specific email format that was failing
      expect(ValidationUtils.validateEmail('abdulssekyanzi@gmail.com'), isNull);
      
      // Test other common email formats
      expect(ValidationUtils.validateEmail('user@example.com'), isNull);
      expect(ValidationUtils.validateEmail('test.email@domain.org'), isNull);
      expect(ValidationUtils.validateEmail('user+tag@domain.co.uk'), isNull);
      expect(ValidationUtils.validateEmail('firstname.lastname@company.com'), isNull);
      expect(ValidationUtils.validateEmail('user123@test-domain.net'), isNull);
    });

    test('should reject invalid email formats', () {
      expect(ValidationUtils.validateEmail(''), isNotNull);
      expect(ValidationUtils.validateEmail('invalid-email'), isNotNull);
      expect(ValidationUtils.validateEmail('@domain.com'), isNotNull);
      expect(ValidationUtils.validateEmail('user@'), isNotNull);
      expect(ValidationUtils.validateEmail('user.domain.com'), isNotNull);
    });

    test('should handle null input', () {
      expect(ValidationUtils.validateEmail(null), isNotNull);
    });
  });

  group('Password Validation Tests', () {
    test('should accept valid passwords', () {
      expect(ValidationUtils.validatePassword('Password123!'), isNull);
      expect(ValidationUtils.validatePassword('StrongP@ss1'), isNull);
    });

    test('should reject weak passwords', () {
      expect(ValidationUtils.validatePassword('weak'), isNotNull);
      expect(ValidationUtils.validatePassword('12345678'), isNotNull);
      expect(ValidationUtils.validatePassword('password'), isNotNull);
    });
  });

  group('Phone Validation Tests', () {
    test('should accept valid phone numbers', () {
      expect(ValidationUtils.validatePhone('1234567890'), isNull);
      expect(ValidationUtils.validatePhone('+1234567890'), isNull);
      expect(ValidationUtils.validatePhone('123-456-7890'), isNull);
      expect(ValidationUtils.validatePhone('(123) 456-7890'), isNull);
    });

    test('should reject invalid phone numbers', () {
      expect(ValidationUtils.validatePhone('123'), isNotNull);
      expect(ValidationUtils.validatePhone(''), isNotNull);
      expect(ValidationUtils.validatePhone(null), isNotNull);
    });
  });

  group('Full Name Validation Tests', () {
    test('should accept valid names', () {
      expect(ValidationUtils.validateFullName('John Doe'), isNull);
      expect(ValidationUtils.validateFullName('Mary Jane Smith'), isNull);
      expect(ValidationUtils.validateFullName("John O'Connor"), isNull);
      expect(ValidationUtils.validateFullName('Anna-Marie Johnson'), isNull);
    });

    test('should reject invalid names', () {
      expect(ValidationUtils.validateFullName(''), isNotNull);
      expect(ValidationUtils.validateFullName('John'), isNotNull); // No last name
      expect(ValidationUtils.validateFullName('John123'), isNotNull); // Contains numbers
      expect(ValidationUtils.validateFullName(null), isNotNull);
    });
  });

  group('Confirm Password Validation Tests', () {
    test('should accept matching passwords', () {
      expect(ValidationUtils.validateConfirmPassword('Password123!', 'Password123!'), isNull);
    });

    test('should reject non-matching passwords', () {
      expect(ValidationUtils.validateConfirmPassword('Password123!', 'DifferentPassword!'), isNotNull);
      expect(ValidationUtils.validateConfirmPassword('', 'Password123!'), isNotNull);
      expect(ValidationUtils.validateConfirmPassword(null, 'Password123!'), isNotNull);
    });
  });
}
