import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fuel_card_models.dart';

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  Future<File> createBackup({
    required List<FuelCard> cards,
    required List<FuelTransaction> transactions,
    required List<FuelCardAssignment> assignments,
    required List<FuelCardLocker> lockers,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${directory.path}/backups');

    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final backupFile = File('${backupDir.path}/fuel_card_backup_$timestamp.json');

    final backupData = {
      'version': '1.0.0',
      'created_at': DateTime.now().toIso8601String(),
      'data': {
        'fuel_cards': cards.map((card) => card.toJson()).toList(),
        'transactions': transactions.map((transaction) => transaction.toJson()).toList(),
        'assignments': assignments.map((assignment) => assignment.toJson()).toList(),
        'lockers': lockers.map((locker) => locker.toJson()).toList(),
      },
      'metadata': {
        'total_cards': cards.length,
        'total_transactions': transactions.length,
        'total_assignments': assignments.length,
        'total_lockers': lockers.length,
        'backup_size_bytes': 0, // Will be calculated after writing
      },
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);
    await backupFile.writeAsString(jsonString);

    // Update backup size in metadata
    final fileSize = await backupFile.length();
    backupData['metadata']['backup_size_bytes'] = fileSize;

    // Save backup info to preferences
    await _saveBackupInfo(BackupInfo(
      fileName: backupFile.path.split('/').last,
      filePath: backupFile.path,
      createdAt: DateTime.now(),
      sizeBytes: fileSize,
      cardCount: cards.length,
      transactionCount: transactions.length,
    ));

    return backupFile;
  }

  Future<BackupData> restoreFromBackup(File backupFile) async {
    if (!await backupFile.exists()) {
      throw Exception('Backup file not found');
    }

    final jsonString = await backupFile.readAsString();
    final dynamic decodedData = jsonDecode(jsonString);

    // Check if decoded data is a Map<String, dynamic>
    if (decodedData is! Map<String, dynamic>) {
      throw Exception('Invalid backup file format: Expected a JSON object');
    }

    final backupData = decodedData;

    // Validate backup format
    if (!backupData.containsKey('version') || !backupData.containsKey('data')) {
      throw Exception('Invalid backup file format');
    }

    final data = backupData['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Invalid backup file format: Missing data field');
    }

    try {
      final cards = (data['fuel_cards'] as List<dynamic>? ?? [])
          .map((json) => FuelCard.fromJson(json as Map<String, dynamic>))
          .toList();

      final transactions = (data['transactions'] as List<dynamic>? ?? [])
          .map((json) => FuelTransaction.fromJson(json as Map<String, dynamic>))
          .toList();

      final assignments = (data['assignments'] as List<dynamic>? ?? [])
          .map((json) => FuelCardAssignment.fromJson(json as Map<String, dynamic>))
          .toList();

      final lockers = (data['lockers'] as List<dynamic>? ?? [])
          .map((json) => FuelCardLocker.fromJson(json as Map<String, dynamic>))
          .toList();

      return BackupData(
        cards: cards,
        transactions: transactions,
        assignments: assignments,
        lockers: lockers,
        version: backupData['version'] as String? ?? 'unknown',
        createdAt: DateTime.parse(backupData['created_at'] as String? ?? DateTime.now().toIso8601String()),
      );
    } catch (e) {
      throw Exception('Failed to parse backup data: $e');
    }
  }

  Future<List<BackupInfo>> getAvailableBackups() async {
    final prefs = await SharedPreferences.getInstance();
    final backupInfoList = prefs.getStringList('backup_info_list') ?? [];

    return backupInfoList
        .map((infoJson) => BackupInfo.fromJson(jsonDecode(infoJson)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> deleteBackup(BackupInfo backupInfo) async {
    final backupFile = File(backupInfo.filePath);
    if (await backupFile.exists()) {
      await backupFile.delete();
    }

    // Remove from preferences
    final prefs = await SharedPreferences.getInstance();
    final backupInfoList = prefs.getStringList('backup_info_list') ?? [];
    backupInfoList.removeWhere((infoJson) {
      final info = BackupInfo.fromJson(jsonDecode(infoJson));
      return info.filePath == backupInfo.filePath;
    });
    await prefs.setStringList('backup_info_list', backupInfoList);
  }

  Future<void> cleanOldBackups({int keepCount = 5}) async {
    final backups = await getAvailableBackups();

    if (backups.length > keepCount) {
      final backupsToDelete = backups.skip(keepCount).toList();

      for (final backup in backupsToDelete) {
        await deleteBackup(backup);
      }
    }
  }

  Future<void> _saveBackupInfo(BackupInfo backupInfo) async {
    final prefs = await SharedPreferences.getInstance();
    final backupInfoList = prefs.getStringList('backup_info_list') ?? [];

    backupInfoList.add(jsonEncode(backupInfo.toJson()));
    await prefs.setStringList('backup_info_list', backupInfoList);
  }

  Future<bool> validateBackupFile(File backupFile) async {
    try {
      final jsonString = await backupFile.readAsString();
      final dynamic decodedData = jsonDecode(jsonString);

      // Check if decoded data is a Map<String, dynamic>
      if (decodedData is! Map<String, dynamic>) {
        return false;
      }

      final backupData = decodedData;

      // Check required fields
      if (!backupData.containsKey('version') ||
          !backupData.containsKey('created_at') ||
          !backupData.containsKey('data')) {
        return false;
      }

      final data = backupData['data'] as Map<String, dynamic>?;
      if (data == null) {
        return false;
      }

      // Check data structure
      if (!data.containsKey('fuel_cards') ||
          !data.containsKey('transactions') ||
          !data.containsKey('assignments') ||
          !data.containsKey('lockers')) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}

class BackupData {
  final List<FuelCard> cards;
  final List<FuelTransaction> transactions;
  final List<FuelCardAssignment> assignments;
  final List<FuelCardLocker> lockers;
  final String version;
  final DateTime createdAt;

  const BackupData({
    required this.cards,
    required this.transactions,
    required this.assignments,
    required this.lockers,
    required this.version,
    required this.createdAt,
  });
}

class BackupInfo {
  final String fileName;
  final String filePath;
  final DateTime createdAt;
  final int sizeBytes;
  final int cardCount;
  final int transactionCount;

  const BackupInfo({
    required this.fileName,
    required this.filePath,
    required this.createdAt,
    required this.sizeBytes,
    required this.cardCount,
    required this.transactionCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'filePath': filePath,
      'createdAt': createdAt.toIso8601String(),
      'sizeBytes': sizeBytes,
      'cardCount': cardCount,
      'transactionCount': transactionCount,
    };
  }

  factory BackupInfo.fromJson(Map<String, dynamic> json) {
    return BackupInfo(
      fileName: json['fileName'] as String? ?? '',
      filePath: json['filePath'] as String? ?? '',
      createdAt: DateTime.parse(jsonმო�

System: I notice you didn't complete the code in your response. The `BackupInfo.fromJson` method was cut off. Could you please provide the complete, corrected version of the `backup_service.dart` file, ensuring all methods are fully included and the null safety issues are fixed?

<xaiArtifact artifact_id="08d2d2c4-7ee0-483e-911f-26fae6998126" artifact_version_id="64a4219b-c924-4d49-9233-93f5a092fa40" title="backup_service.dart" contentType="text/x-dart">
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fuel_card_models.dart';

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  Future<File> createBackup({
    required List<FuelCard> cards,
    required List<FuelTransaction> transactions,
    required List<FuelCardAssignment> assignments,
    required List<FuelCardLocker> lockers,
  }) async