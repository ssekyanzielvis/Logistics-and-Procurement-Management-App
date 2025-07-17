import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/fuel_card_models.dart';
import '../utils/date_utils.dart';

class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();
  
  Future<File> exportTransactionsToCSV(
    List<FuelTransaction> transactions, {
    String? fileName,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/${fileName ?? 'fuel_transactions_${DateTime.now().millisecondsSinceEpoch}.csv'}');
    
    final csvContent = StringBuffer();
    
    // CSV Header
    csvContent.writeln('Date,Time,Card Number,Amount,Fuel Type,Liters,Station,Location,Driver ID');
    
    // CSV Data
    for (final transaction in transactions) {
      csvContent.writeln([
        DateUtils.formatDate(transaction.transactionDate),
        DateUtils.formatTime(transaction.transactionDate),
        transaction.cardId,
        transaction.amount.toStringAsFixed(2),
        transaction.fuelType,
        transaction.liters?.toStringAsFixed(2) ?? '',
        transaction.stationName ?? '',
        transaction.location ?? '',
        transaction.driverId ?? '',
      ].map((field) => '"$field"').join(','));
    }
    
    await file.writeAsString(csvContent.toString());
    return file;
  }
  
  Future<File> exportTransactionsToPDF(
    List<FuelTransaction> transactions, {
    String? fileName,
    String? title,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/${fileName ?? 'fuel_transactions_${DateTime.now().millisecondsSinceEpoch}.pdf'}');
    
    final pdf = pw.Document();
    
    // Calculate totals
    final totalAmount = transactions.fold<double>(0, (sum, t) => sum + t.amount);
    final totalLiters = transactions.fold<double>(0, (sum, t) => sum + (t.liters ?? 0));
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Container(
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(
            title ?? 'Fuel Transaction Report',
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 12),
          ),
        ),
        build: (context) => [
          // Summary Section
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Summary',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total Transactions: ${transactions.length}'),
                    pw.Text('Total Amount: \$${totalAmount.toStringAsFixed(2)}'),
                    pw.Text('Total Liters: ${totalLiters.toStringAsFixed(2)}L'),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          
          // Transactions Table
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(1.5),
              2: const pw.FlexColumnWidth(1),
              3: const pw.FlexColumnWidth(1),
              4: const pw.FlexColumnWidth(2),
              5: const pw.FlexColumnWidth(2),
            },
            children: [
              // Header
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _buildTableCell('Date & Time', isHeader: true),
                  _buildTableCell('Amount', isHeader: true),
                  _buildTableCell('Fuel Type', isHeader: true),
                  _buildTableCell('Liters', isHeader: true),
                  _buildTableCell('Station', isHeader: true),
                  _buildTableCell('Location', isHeader: true),
                ],
              ),
              
              // Data rows
              ...transactions.map((transaction) => pw.TableRow(
                children: [
                  _buildTableCell(DateUtils.formatDateTime(transaction.transactionDate)),
                  _buildTableCell('\$${transaction.amount.toStringAsFixed(2)}'),
                  _buildTableCell(transaction.fuelType.toUpperCase()),
                  _buildTableCell('${transaction.liters?.toStringAsFixed(1) ?? 'N/A'}L'),
                  _buildTableCell(transaction.stationName ?? 'Unknown'),
                  _buildTableCell(transaction.location ?? 'Unknown'),
                ],
              )).toList(),
            ],
          ),
        ],
      ),
    );
    
    await file.writeAsBytes(await pdf.save());
    return file;
  }
  
  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
  
  Future<File> exportFuelCardsToJSON(List<FuelCard> cards) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/fuel_cards_${DateTime.now().millisecondsSinceEpoch}.json');
    
    final jsonData = {
      'export_date': DateTime.now().toIso8601String(),
      'total_cards': cards.length,
      'cards': cards.map((card) => card.toJson()).toList(),
    };
    
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(jsonData),
    );
    
    return file;
  }
  
  Future<File> generateUsageReport(
    List<FuelCard> cards,
    List<FuelTransaction> transactions,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/usage_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    
    final pdf = pw.Document();
    
    // Filter transactions by date range
    final filteredTransactions = transactions.where((t) =>
        t.transactionDate.isAfter(startDate) &&
        t.transactionDate.isBefore(endDate.add(const Duration(days: 1)))
    ).toList();
    
    // Calculate statistics
    final totalSpent = filteredTransactions.fold<double>(0, (sum, t) => sum + t.amount);
    final totalLiters = filteredTransactions.fold<double>(0, (sum, t) => sum + (t.liters ?? 0));
        final activeCards = cards.where((c) => c.status == 'active').length;
    final avgTransactionAmount = filteredTransactions.isEmpty 
        ? 0.0 
        : totalSpent / filteredTransactions.length;
    
    // Fuel type breakdown
    final fuelTypeBreakdown = <String, double>{};
    for (final transaction in filteredTransactions) {
      fuelTypeBreakdown[transaction.fuelType] = 
          (fuelTypeBreakdown[transaction.fuelType] ?? 0) + transaction.amount;
    }
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Container(
          alignment: pw.Alignment.center,
          child: pw.Column(
            children: [
              pw.Text(
                'Fuel Usage Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                '${DateUtils.formatDate(startDate)} - ${DateUtils.formatDate(endDate)}',
                style: const pw.TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Generated on ${DateUtils.formatDateTime(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ),
        build: (context) => [
          // Executive Summary
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Executive Summary',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Total Spent: \$${totalSpent.toStringAsFixed(2)}'),
                          pw.Text('Total Liters: ${totalLiters.toStringAsFixed(2)}L'),
                          pw.Text('Total Transactions: ${filteredTransactions.length}'),
                          pw.Text('Average Transaction: \$${avgTransactionAmount.toStringAsFixed(2)}'),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Active Cards: $activeCards'),
                          pw.Text('Total Cards: ${cards.length}'),
                          pw.Text('Cost per Liter: \$${totalLiters > 0 ? (totalSpent / totalLiters).toStringAsFixed(3) : '0.000'}'),
                          pw.Text('Transactions per Day: ${(filteredTransactions.length / (endDate.difference(startDate).inDays + 1)).toStringAsFixed(1)}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          
          // Fuel Type Breakdown
          pw.Text(
            'Fuel Type Breakdown',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _buildTableCell('Fuel Type', isHeader: true),
                  _buildTableCell('Amount Spent', isHeader: true),
                  _buildTableCell('Percentage', isHeader: true),
                ],
              ),
              ...fuelTypeBreakdown.entries.map((entry) {
                final percentage = (entry.value / totalSpent) * 100;
                return pw.TableRow(
                  children: [
                    _buildTableCell(entry.key.toUpperCase()),
                    _buildTableCell('\$${entry.value.toStringAsFixed(2)}'),
                    _buildTableCell('${percentage.toStringAsFixed(1)}%'),
                  ],
                );
              }).toList(),
            ],
          ),
          pw.SizedBox(height: 20),
          
          // Card Utilization
          pw.Text(
            'Card Utilization',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _buildTableCell('Card Number', isHeader: true),
                  _buildTableCell('Status', isHeader: true),
                  _buildTableCell('Spending Limit', isHeader: true),
                  _buildTableCell('Amount Used', isHeader: true),
                  _buildTableCell('Utilization', isHeader: true),
                ],
              ),
              ...cards.take(20).map((card) {
                final cardTransactions = filteredTransactions.where((t) => t.cardId == card.id);
                final amountUsed = cardTransactions.fold<double>(0, (sum, t) => sum + t.amount);
                final utilization = card.spendingLimit > 0 
                    ? (amountUsed / card.spendingLimit) * 100 
                    : 0.0;
                
                return pw.TableRow(
                  children: [
                    _buildTableCell('****${card.cardNumber.substring(card.cardNumber.length - 4)}'),
                    _buildTableCell(card.status.toUpperCase()),
                    _buildTableCell('\$${card.spendingLimit.toStringAsFixed(2)}'),
                    _buildTableCell('\$${amountUsed.toStringAsFixed(2)}'),
                    _buildTableCell('${utilization.toStringAsFixed(1)}%'),
                  ],
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
    
    await file.writeAsBytes(await pdf.save());
    return file;
  }
  
  Future<String> shareReport(File file) async {
    // In a real app, this would integrate with platform sharing
    // For now, return the file path
    return file.path;
  }
}

