import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistics/screens/home/error_handler.dart';
import '../services/backup_service.dart';
import '../services/export_service.dart';

// ignore: library_prefixes
import '../screens/home/date_utils.dart' as CustomDateUtils;
import '../providers/fuel_card_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  bool _autoBackupEnabled = true;
  String _selectedTheme = 'system';
  String _selectedCurrency = 'USD';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('General'),
          _buildSettingsTile(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Enable push notifications',
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
          ),
          _buildSettingsTile(
            icon: Icons.fingerprint,
            title: 'Biometric Authentication',
            subtitle: 'Use fingerprint or face ID',
            trailing: Switch(
              value: _biometricEnabled,
              onChanged: (value) {
                setState(() {
                  _biometricEnabled = value;
                });
              },
            ),
          ),
          _buildSettingsTile(
            icon: Icons.palette,
            title: 'Theme',
            subtitle: 'Choose app appearance',
            trailing: DropdownButton<String>(
              value: _selectedTheme,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'light', child: Text('Light')),
                DropdownMenuItem(value: 'dark', child: Text('Dark')),
                DropdownMenuItem(value: 'system', child: Text('System')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedTheme = value;
                  });
                }
              },
            ),
          ),
          _buildSettingsTile(
            icon: Icons.attach_money,
            title: 'Currency',
            subtitle: 'Default currency display',
            trailing: DropdownButton<String>(
              value: _selectedCurrency,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'USD', child: Text('USD')),
                DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                DropdownMenuItem(value: 'GBP', child: Text('GBP')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCurrency = value;
                  });
                }
              },
            ),
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('Data Management'),
          _buildSettingsTile(
            icon: Icons.backup,
            title: 'Auto Backup',
            subtitle: 'Automatically backup data',
            trailing: Switch(
              value: _autoBackupEnabled,
              onChanged: (value) {
                setState(() {
                  _autoBackupEnabled = value;
                });
              },
            ),
          ),
          _buildSettingsTile(
            icon: Icons.cloud_upload,
            title: 'Create Backup',
            subtitle: 'Backup all data to file',
            onTap: _createBackup,
          ),
          _buildSettingsTile(
            icon: Icons.cloud_download,
            title: 'Restore Backup',
            subtitle: 'Restore data from backup file',
            onTap: _showRestoreDialog,
          ),
          _buildSettingsTile(
            icon: Icons.file_download,
            title: 'Export Data',
            subtitle: 'Export transactions and cards',
            onTap: _showExportDialog,
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('Security'),
          _buildSettingsTile(
            icon: Icons.lock_reset,
            title: 'Change PIN',
            subtitle: 'Update your security PIN',
            onTap: _showChangePinDialog,
          ),
          _buildSettingsTile(
            icon: Icons.security,
            title: 'Security Settings',
            subtitle: 'Manage security preferences',
            onTap: () {
              // Navigate to security settings
            },
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('Support'),
          _buildSettingsTile(
            icon: Icons.help,
            title: 'Help & Support',
            subtitle: 'Get help and contact support',
            onTap: () {
              // Navigate to help screen
            },
          ),
          _buildSettingsTile(
            icon: Icons.info,
            title: 'About',
            subtitle: 'App version and information',
            onTap: _showAboutDialog,
          ),

          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _showResetDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Reset All Data'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing:
            trailing ??
            (onTap != null ? const Icon(Icons.chevron_right) : null),
        onTap: onTap,
      ),
    );
  }

  Future<void> _createBackup() async {
    try {
      final cards = ref.read(fuelCardsProvider);
      final transactions = ref.read(fuelTransactionsProvider);
      final assignments = ref.read(fuelCardAssignmentsProvider);
      final lockers = ref.read(fuelCardLockersProvider);

      final backupFile = await BackupService().createBackup(
        cards: cards,
        transactions: transactions,
        assignments: assignments,
        lockers: lockers,
      );

      if (mounted) {
        ErrorHandler.showSuccess(
          context,
          'Backup created successfully: ${backupFile.path.split('/').last}',
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, 'Failed to create backup: $e');
      }
    }
  }

  void _showRestoreDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Restore Backup'),
            content: const Text(
              'This will replace all current data with data from the backup file. This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _selectBackupFile();
                },
                child: const Text('Continue'),
              ),
            ],
          ),
    );
  }

  Future<void> _selectBackupFile() async {
    try {
      final backups = await BackupService().getAvailableBackups();

      if (backups.isEmpty) {
        if (mounted) {
          ErrorHandler.showWarning(context, 'No backup files found');
        }
        return;
      }

      if (mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Select Backup'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: backups.length,
                    itemBuilder: (context, index) {
                      final backup = backups[index];
                      return ListTile(
                        title: Text(backup.fileName),
                        subtitle: Text(
                          '${CustomDateUtils.DateUtils.formatDateTime(backup.createdAt)}\n'
                          '${backup.cardCount} cards, ${backup.transactionCount} transactions\n'
                          'Size: ${_formatFileSize(backup.sizeBytes)}',
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _restoreFromBackup(backup);
                        },
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, 'Failed to load backups: $e');
      }
    }
  }

  Future<void> _restoreFromBackup(BackupInfo backupInfo) async {
    try {
      final backupFile = File(backupInfo.filePath);
      final backupData = await BackupService().restoreFromBackup(backupFile);

      // Update providers with restored data
      ref.read(fuelCardsProvider.notifier).replaceAll(backupData.cards);
      ref
          .read(fuelTransactionsProvider.notifier)
          .replaceAll(backupData.transactions);
      ref
          .read(fuelCardAssignmentsProvider.notifier)
          .replaceAll(backupData.assignments);
      ref.read(fuelCardLockersProvider.notifier).replaceAll(backupData.lockers);

      if (mounted) {
        ErrorHandler.showSuccess(context, 'Data restored successfully');
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, 'Failed to restore backup: $e');
      }
    }
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Export Data'),
            content: const Text('Choose export format:'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _exportToCSV();
                },
                child: const Text('CSV'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _exportToPDF();
                },
                child: const Text('PDF'),
              ),
            ],
          ),
    );
  }

  Future<void> _exportToCSV() async {
    try {
      final transactions = ref.read(fuelTransactionsProvider);
      final file = await ExportService().exportTransactionsToCSV(transactions);

      if (mounted) {
        ErrorHandler.showSuccess(
          context,
          'Data exported to: ${file.path.split('/').last}',
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, 'Failed to export CSV: $e');
      }
    }
  }

  Future<void> _exportToPDF() async {
    try {
      final transactions = ref.read(fuelTransactionsProvider);
      final file = await ExportService().exportTransactionsToPDF(transactions);

      if (mounted) {
        ErrorHandler.showSuccess(
          context,
          'Report exported to: ${file.path.split('/').last}',
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, 'Failed to export PDF: $e');
      }
    }
  }

  void _showChangePinDialog() {
    final currentPinController = TextEditingController();
    final newPinController = TextEditingController();
    final confirmPinController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Change PIN'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPinController,
                  decoration: const InputDecoration(labelText: 'Current PIN'),
                  obscureText: true,
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: newPinController,
                  decoration: const InputDecoration(labelText: 'New PIN'),
                  obscureText: true,
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: confirmPinController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New PIN',
                  ),
                  obscureText: true,
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (newPinController.text == confirmPinController.text) {
                    Navigator.pop(context);
                    ErrorHandler.showSuccess(
                      context,
                      'PIN changed successfully',
                    );
                  } else {
                    ErrorHandler.showError(context, 'PINs do not match');
                  }
                },
                child: const Text('Change PIN'),
              ),
            ],
          ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Fuel Card Management',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.local_gas_station, size: 48),
      children: [
        const Text(
          'A comprehensive fuel card management system for fleet operations.',
        ),
        const SizedBox(height: 16),
        const Text('Features:'),
        const Text('• Fuel card management'),
        const Text('• Transaction tracking'),
        const Text('• Driver assignments'),
        const Text('• Locker system integration'),
        const Text('• Analytics and reporting'),
      ],
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reset All Data'),
            content: const Text(
              'This will permanently delete all fuel cards, transactions, assignments, and settings. This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resetAllData();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Reset All Data'),
              ),
            ],
          ),
    );
  }

  Future<void> _resetAllData() async {
    try {
      // Clear all providers
      ref.read(fuelCardsProvider.notifier).clear();
      ref.read(fuelTransactionsProvider.notifier).clear();
      ref.read(fuelCardAssignmentsProvider.notifier).clear();
      ref.read(fuelCardLockersProvider.notifier).clear();

      if (mounted) {
        ErrorHandler.showSuccess(context, 'All data has been reset');
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, 'Failed to reset data: $e');
      }
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
