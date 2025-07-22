import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Settings model to hold all user preferences
class AppSettings {
  final bool notificationsEnabled;
  final bool biometricEnabled;
  final bool autoBackupEnabled;
  final ThemeMode themeMode;
  final String currency;
  final String language;
  final bool darkMode;
  final Color primaryColor;
  final String dateFormat;
  final bool soundEnabled;

  const AppSettings({
    this.notificationsEnabled = true,
    this.biometricEnabled = false,
    this.autoBackupEnabled = true,
    this.themeMode = ThemeMode.system,
    this.currency = 'USD',
    this.language = 'en',
    this.darkMode = false,
    this.primaryColor = Colors.blue,
    this.dateFormat = 'dd/MM/yyyy',
    this.soundEnabled = true,
  });

  AppSettings copyWith({
    bool? notificationsEnabled,
    bool? biometricEnabled,
    bool? autoBackupEnabled,
    ThemeMode? themeMode,
    String? currency,
    String? language,
    bool? darkMode,
    Color? primaryColor,
    String? dateFormat,
    bool? soundEnabled,
  }) {
    return AppSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      themeMode: themeMode ?? this.themeMode,
      currency: currency ?? this.currency,
      language: language ?? this.language,
      darkMode: darkMode ?? this.darkMode,
      primaryColor: primaryColor ?? this.primaryColor,
      dateFormat: dateFormat ?? this.dateFormat,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'biometricEnabled': biometricEnabled,
      'autoBackupEnabled': autoBackupEnabled,
      'themeMode': themeMode.index,
      'currency': currency,
      'language': language,
      'darkMode': darkMode,
      'primaryColor': primaryColor.value,
      'dateFormat': dateFormat,
      'soundEnabled': soundEnabled,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      biometricEnabled: json['biometricEnabled'] ?? false,
      autoBackupEnabled: json['autoBackupEnabled'] ?? true,
      themeMode: ThemeMode.values[json['themeMode'] ?? 0],
      currency: json['currency'] ?? 'USD',
      language: json['language'] ?? 'en',
      darkMode: json['darkMode'] ?? false,
      primaryColor: Color(json['primaryColor'] ?? Colors.blue.value),
      dateFormat: json['dateFormat'] ?? 'dd/MM/yyyy',
      soundEnabled: json['soundEnabled'] ?? true,
    );
  }
}

// Settings notifier to manage state changes
class SettingsNotifier extends StateNotifier<AppSettings> {
  static const String _settingsKey = 'app_settings';

  SettingsNotifier() : super(const AppSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);

      if (settingsJson != null) {
        // For now, load individual preferences
        state = AppSettings(
          notificationsEnabled: prefs.getBool('notificationsEnabled') ?? true,
          biometricEnabled: prefs.getBool('biometricEnabled') ?? false,
          autoBackupEnabled: prefs.getBool('autoBackupEnabled') ?? true,
          themeMode: ThemeMode.values[prefs.getInt('themeMode') ?? 0],
          currency: prefs.getString('currency') ?? 'USD',
          language: prefs.getString('language') ?? 'en',
          darkMode: prefs.getBool('darkMode') ?? false,
          primaryColor: Color(
            prefs.getInt('primaryColor') ?? Colors.blue.value,
          ),
          dateFormat: prefs.getString('dateFormat') ?? 'dd/MM/yyyy',
          soundEnabled: prefs.getBool('soundEnabled') ?? true,
        );
      }
    } catch (e) {
      // Handle error - use default settings
      state = const AppSettings();
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool('notificationsEnabled', state.notificationsEnabled);
      await prefs.setBool('biometricEnabled', state.biometricEnabled);
      await prefs.setBool('autoBackupEnabled', state.autoBackupEnabled);
      await prefs.setInt('themeMode', state.themeMode.index);
      await prefs.setString('currency', state.currency);
      await prefs.setString('language', state.language);
      await prefs.setBool('darkMode', state.darkMode);
      await prefs.setInt('primaryColor', state.primaryColor.value);
      await prefs.setString('dateFormat', state.dateFormat);
      await prefs.setBool('soundEnabled', state.soundEnabled);
    } catch (e) {
      // Handle save error
      throw Exception('Failed to save settings: $e');
    }
  }

  // Update methods for each setting
  Future<void> updateNotifications(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    await _saveSettings();
  }

  Future<void> updateBiometric(bool enabled) async {
    state = state.copyWith(biometricEnabled: enabled);
    await _saveSettings();
  }

  Future<void> updateAutoBackup(bool enabled) async {
    state = state.copyWith(autoBackupEnabled: enabled);
    await _saveSettings();
  }

  Future<void> updateThemeMode(ThemeMode themeMode) async {
    state = state.copyWith(themeMode: themeMode);
    await _saveSettings();
  }

  Future<void> updateCurrency(String currency) async {
    state = state.copyWith(currency: currency);
    await _saveSettings();
  }

  Future<void> updateLanguage(String language) async {
    state = state.copyWith(language: language);
    await _saveSettings();
  }

  Future<void> updateDarkMode(bool darkMode) async {
    state = state.copyWith(darkMode: darkMode);
    await _saveSettings();
  }

  Future<void> updatePrimaryColor(Color color) async {
    state = state.copyWith(primaryColor: color);
    await _saveSettings();
  }

  Future<void> updateDateFormat(String format) async {
    state = state.copyWith(dateFormat: format);
    await _saveSettings();
  }

  Future<void> updateSoundEnabled(bool enabled) async {
    state = state.copyWith(soundEnabled: enabled);
    await _saveSettings();
  }

  Future<void> resetToDefaults() async {
    state = const AppSettings();
    await _saveSettings();
  }
}

// Provider instances
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>(
  (ref) => SettingsNotifier(),
);

// Convenience providers for specific settings
final themeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(settingsProvider).themeMode;
});

final currencyProvider = Provider<String>((ref) {
  return ref.watch(settingsProvider).currency;
});

final primaryColorProvider = Provider<Color>((ref) {
  return ref.watch(settingsProvider).primaryColor;
});

final notificationsProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).notificationsEnabled;
});
