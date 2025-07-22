import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/settings_provider.dart';

class SettingsUtils {
  // Format currency based on user settings
  static String formatCurrency(WidgetRef ref, double amount) {
    final currency = ref.read(settingsProvider).currency;

    final formatters = {
      'USD': NumberFormat.currency(symbol: '\$', decimalDigits: 2),
      'EUR': NumberFormat.currency(symbol: '€', decimalDigits: 2),
      'GBP': NumberFormat.currency(symbol: '£', decimalDigits: 2),
      'JPY': NumberFormat.currency(symbol: '¥', decimalDigits: 0),
      'CAD': NumberFormat.currency(symbol: 'C\$', decimalDigits: 2),
    };

    final formatter = formatters[currency] ?? formatters['USD']!;
    return formatter.format(amount);
  }

  // Format date based on user settings
  static String formatDate(WidgetRef ref, DateTime date) {
    final dateFormat = ref.read(settingsProvider).dateFormat;
    final formatter = DateFormat(dateFormat);
    return formatter.format(date);
  }

  // Get localized strings based on user language
  static String getLocalizedString(WidgetRef ref, String key) {
    final language = ref.read(settingsProvider).language;

    // This is a simple example - you might want to use a proper localization package
    final translations = {
      'en': {
        'welcome': 'Welcome',
        'settings': 'Settings',
        'fuel_cards': 'Fuel Cards',
        'transactions': 'Transactions',
      },
      'es': {
        'welcome': 'Bienvenido',
        'settings': 'Configuración',
        'fuel_cards': 'Tarjetas de Combustible',
        'transactions': 'Transacciones',
      },
      // Add more languages as needed
    };

    return translations[language]?[key] ?? translations['en']?[key] ?? key;
  }

  // Check if notifications are enabled
  static bool areNotificationsEnabled(WidgetRef ref) {
    return ref.read(settingsProvider).notificationsEnabled;
  }

  // Check if biometric authentication is enabled
  static bool isBiometricEnabled(WidgetRef ref) {
    return ref.read(settingsProvider).biometricEnabled;
  }

  // Check if auto backup is enabled
  static bool isAutoBackupEnabled(WidgetRef ref) {
    return ref.read(settingsProvider).autoBackupEnabled;
  }

  // Get primary color
  static Color getPrimaryColor(WidgetRef ref) {
    return ref.read(settingsProvider).primaryColor;
  }

  // Check if sound effects are enabled
  static bool areSoundEffectsEnabled(WidgetRef ref) {
    return ref.read(settingsProvider).soundEnabled;
  }
}
