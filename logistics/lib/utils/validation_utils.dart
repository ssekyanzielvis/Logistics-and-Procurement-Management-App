import 'package:flutter/material.dart';

class ValidationUtils {
  /// Enhanced email validation that accepts various email formats
  /// Including emails like: abdulssekyanzi@gmail.com
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address';
    }

    final email = value.trim().toLowerCase();

    // Check for basic email structure
    if (!email.contains('@') || !email.contains('.')) {
      return 'Please enter a valid email address';
    }

    // Enhanced regex pattern for email validation
    // This pattern allows:
    // - Letters, numbers, dots, underscores, hyphens before @
    // - Multiple domain levels (e.g., .co.uk, .gmail.com)
    // - Common email formats
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      caseSensitive: false,
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    // Additional checks for common issues
    if (email.startsWith('.') || email.endsWith('.')) {
      return 'Email cannot start or end with a dot';
    }

    if (email.contains('..')) {
      return 'Email cannot contain consecutive dots';
    }

    final parts = email.split('@');
    if (parts.length != 2) {
      return 'Please enter a valid email address';
    }

    final domain = parts[1];
    if (domain.isEmpty || domain.startsWith('.') || domain.endsWith('.')) {
      return 'Please enter a valid email domain';
    }

    return null;
  }

  /// Validate password with strength requirements
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }

    // Check for at least one number
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }

    // Check for at least one special character
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  /// Validate phone number
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }

    // Remove all non-digit characters for validation
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length < 10) {
      return 'Please enter a valid phone number';
    }

    if (digitsOnly.length > 15) {
      return 'Phone number is too long';
    }

    return null;
  }

  /// Validate full name
  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }

    final name = value.trim();
    
    if (name.length < 2) {
      return 'Name must be at least 2 characters long';
    }

    if (name.length > 50) {
      return 'Name is too long';
    }

    // Check for at least one space (first and last name)
    if (!name.contains(' ')) {
      return 'Please enter your first and last name';
    }

    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(name)) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }

    return null;
  }

  /// Validate confirm password
  static String? validateConfirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != originalPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Test specific email addresses
  static bool testSpecificEmails() {
    final testEmails = [
      'abdulssekyanzi@gmail.com',
      'test.email@domain.com',
      'user123@example.org',
      'john.doe+test@company.co.uk',
      'admin@logistics-app.com',
    ];

    for (final email in testEmails) {
      final result = validateEmail(email);
      if (result != null) {
        debugPrint('Email validation failed for $email: $result');
        return false;
      }
    }
    
    debugPrint('All test emails passed validation');
    return true;
  }
}

/// Mixin to provide validation methods to widgets
mixin ValidationMixin {
  String? validateEmail(String? value) => ValidationUtils.validateEmail(value);
  String? validatePassword(String? value) => ValidationUtils.validatePassword(value);
  String? validatePhone(String? value) => ValidationUtils.validatePhone(value);
  String? validateFullName(String? value) => ValidationUtils.validateFullName(value);
  String? validateConfirmPassword(String? value, String originalPassword) =>
      ValidationUtils.validateConfirmPassword(value, originalPassword);
}
