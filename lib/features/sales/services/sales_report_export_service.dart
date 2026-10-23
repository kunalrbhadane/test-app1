import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../company/models/company_model.dart';
import '../../home/models/bill_model.dart';

class SalesReportExportService {
  static const PdfColor _primaryColor = PdfColor.fromInt(0xFF003B95);
  static const PdfColor _darkTextColor = PdfColor.fromInt(0xFF1E293B);
  static const PdfColor _lightBgColor = PdfColor.fromInt(0xFFF8FAFC);
  static const PdfColor _headerBgColor = PdfColor.fromInt(0xFFF1F5F9);
  static const PdfColor _borderColor = PdfColor.fromInt(0xFFE2E8F0);
  static const PdfColor _greenColor = PdfColor.fromInt(0xFF16A34A);
  static const PdfColor _redColor = PdfColor.fromInt(0xFFDC2626);

  // ---------------------------------------------------------------------------
  // 1. PDF GENERATION
  // ---------------------------------------------------------------------------

  /// Generates multi-page PDF document bytes for a list of bills.
  static Future<Uint8List> generateSalesReportPdf({
    required List<BillModel> bills,
    CompanyModel? company,
    String filter = 'All',
  }) async {
    final pdf = pw.Document();

    final fontRegular = await PdfGoogleFonts.interRegular();
    final fontBold = await PdfGoogleFonts.interBold();
    final fontSemiBold = await PdfGoogleFonts.interSemiBold();

    final now = DateTime.now();
    final formattedGeneratedDate =
        DateFormat('dd MMM yyyy, hh:mm a').format(now);

    final companyName =
        company?.name.isNotEmpty == true ? company!.name : 'R.K. PLAST';
    final companyAddress = company?.address ?? '';
    final companyGst = company?.gstNo ?? '';
    final companyCity = company?.city ?? '';

    // Aggregated Metrics
    final totalInvoices = bills.length;
    final totalSales = bills.fold(0.0, (sum, b) => sum + b.amount);
    final totalSubTotal = bills.fold(0.0, (sum, b) => sum + b.subTotal);
    final totalGst = bills.fold(0.0, (sum, b) => sum + b.gstAmount);
    final totalPaid = bills.fold(0.0, (sum, b) => sum + b.amountPaid);
    final totalDue = bills.fold(0.0, (sum, b) => sum + b.dueAmount);
    final totalQty = bills.fold(
      0,
      (sum, b) =>
          sum +
          (b.totalQty > 0
              ? b.totalQty
              : b.lines.fold(0, (s, l) => s + l.qty)),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
        ),
        header: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Top Company & Report Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        companyName,
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 18,
                          color: _primaryColor,
                        ),
                      ),
                      if (companyAddress.isNotEmpty || companyCity.isNotEmpty)
                        pw.Text(
                          [companyAddress, companyCity]
                              .where((s) => s.isNotEmpty)
                              .join(', '),
                          style: pw.TextStyle(
                            font: fontRegular,
                            fontSize: 9,
                            color: PdfColors.grey700,
                          ),
                        ),
                      if (companyGst.isNotEmpty)
                        pw.Text(
                          'GSTIN: $companyGst',
                          style: pw.TextStyle(
                            font: fontSemiBold,
                            fontSize: 9,
                            color: PdfColors.grey800,
                          ),
                        ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: pw.BoxDecoration(
                          color: _primaryColor,
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Text(
                          'SALES REPORT',
                          style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 12,
                            color: PdfColors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        'Generated: $formattedGeneratedDate',
                        style: pw.TextStyle(
                          font: fontRegular,
                          fontSize: 8.5,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.Text(
                        'Filter: $filter ($totalInvoices Invoices)',
                        style: pw.TextStyle(
                          font: fontSemiBold,
                          fontSize: 8.5,
                          color: PdfColors.grey800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(color: _borderColor, thickness: 1),
              pw.SizedBox(height: 6),
            ],
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.only(top: 8),
            decoration: const pw.BoxDecoration(
              border: pw.Border(top: pw.BorderSide(color: _borderColor, width: 0.8)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Confidential - Generated via R.K. Plast Management System',
                  style: pw.TextStyle(
                    font: fontRegular,
                    fontSize: 8,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.Text(
                  'Page ${context.pageNumber} of ${context.pagesCount}',
                  style: pw.TextStyle(
                    font: fontSemiBold,
                    fontSize: 8,
                    color: PdfColors.grey800,
                  ),
                ),
              ],
            ),
          );
        },
        build: (pw.Context context) {
          return [
            // Executive Summary Strip
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: pw.BoxDecoration(
                color: _lightBgColor,
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(color: _borderColor, width: 1),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildSummaryItem(fontBold, fontRegular, 'Total Invoices', '$totalInvoices'),
                  _buildSummaryItem(fontBold, fontRegular, 'Total Qty', '$totalQty NOS'),
                  _buildSummaryItem(fontBold, fontRegular, 'Sub Total', 'Rs. ${_formatCurrency(totalSubTotal)}'),
                  _buildSummaryItem(fontBold, fontRegular, 'Total GST', 'Rs. ${_formatCurrency(totalGst)}'),
                  _buildSummaryItem(fontBold, fontRegular, 'Total Sales', 'Rs. ${_formatCurrency(totalSales)}', valueColor: _primaryColor),
                  _buildSummaryItem(fontBold, fontRegular, 'Total Paid', 'Rs. ${_formatCurrency(totalPaid)}', valueColor: _greenColor),
                  _buildSummaryItem(fontBold, fontRegular, 'Total Due', 'Rs. ${_formatCurrency(totalDue)}', valueColor: totalDue > 0 ? _redColor : _greenColor),
                ],
              ),
            ),
            pw.SizedBox(height: 12),

            // Unified Invoices & Grand Total Table
            pw.Table(
              border: pw.TableBorder.all(
                color: const PdfColor.fromInt(0xFFCBD5E1),
                width: 0.5,
              ),
              columnWidths: const {
                0: pw.FixedColumnWidth(18), // #
                1: pw.FixedColumnWidth(48), // Date
                2: pw.FixedColumnWidth(44), // Invoice #
                3: pw.FixedColumnWidth(28), // Type
                4: pw.FlexColumnWidth(2.5), // Customer / Party
                5: pw.FlexColumnWidth(1.4), // City
                6: pw.FlexColumnWidth(1.2), // Items
                7: pw.FixedColumnWidth(28), // Qty
                8: pw.FixedColumnWidth(48), // Sub Total
                9: pw.FixedColumnWidth(40), // GST
                10: pw.FixedColumnWidth(52), // Total Amount
                11: pw.FixedColumnWidth(48), // Paid
                12: pw.FixedColumnWidth(48), // Due
                13: pw.FixedColumnWidth(34), // Mode
                14: pw.FixedColumnWidth(36), // Status
              },
              children: [
                // 1. Table Header Row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: _primaryColor),
                  children: [
                    _buildPdfHeaderCell(fontBold, '#', align: pw.Alignment.center),
                    _buildPdfHeaderCell(fontBold, 'Date'),
                    _buildPdfHeaderCell(fontBold, 'Invoice #'),
                    _buildPdfHeaderCell(fontBold, 'Type', align: pw.Alignment.center),
                    _buildPdfHeaderCell(fontBold, 'Customer / Party'),
                    _buildPdfHeaderCell(fontBold, 'City'),
                    _buildPdfHeaderCell(fontBold, 'Items', align: pw.Alignment.center),
                    _buildPdfHeaderCell(fontBold, 'Qty', align: pw.Alignment.centerRight),
                    _buildPdfHeaderCell(fontBold, 'Sub Total', align: pw.Alignment.centerRight),
                    _buildPdfHeaderCell(fontBold, 'GST', align: pw.Alignment.centerRight),
                    _buildPdfHeaderCell(fontBold, 'Total Amt', align: pw.Alignment.centerRight),
                    _buildPdfHeaderCell(fontBold, 'Paid', align: pw.Alignment.centerRight),
                    _buildPdfHeaderCell(fontBold, 'Due', align: pw.Alignment.centerRight),
                    _buildPdfHeaderCell(fontBold, 'Mode', align: pw.Alignment.center),
                    _buildPdfHeaderCell(fontBold, 'Status', align: pw.Alignment.center),
                  ],
                ),

                // 2. Data Rows
                ...List<pw.TableRow>.generate(bills.length, (index) {
                  final bill = bills[index];
                  final isOdd = index % 2 != 0;
                  final totalItemQty = bill.totalQty > 0
                      ? bill.totalQty
                      : bill.lines.fold(0, (s, l) => s + l.qty);
                  final statusText = bill.status == BillStatus.paid
                      ? 'Paid'
                      : bill.status == BillStatus.partial
                          ? 'Partial'
                          : 'Pending';

                  return pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: isOdd ? const PdfColor.fromInt(0xFFF8FAFC) : PdfColors.white,
                      border: const pw.Border(
                        bottom: pw.BorderSide(color: _borderColor, width: 0.5),
                      ),
                    ),
                    children: [
                      _buildPdfDataCell(fontRegular, '${index + 1}', align: pw.Alignment.center),
                      _buildPdfDataCell(fontRegular, bill.date.isNotEmpty ? bill.date.split('|').first.trim() : '-'),
                      _buildPdfDataCell(fontRegular, bill.invoiceNumber),
                      _buildPdfDataCell(fontRegular, bill.type == BillType.gstInvoice ? 'GST' : 'Cash', align: pw.Alignment.center),
                      _buildPdfDataCell(fontRegular, bill.isWalkIn ? '${bill.partyName} (Walk-in)' : bill.partyName),
                      _buildPdfDataCell(fontRegular, bill.customerCity ?? '-'),
                      _buildPdfDataCell(fontRegular, bill.lines.isNotEmpty ? '${bill.lines.length} items' : '-', align: pw.Alignment.center),
                      _buildPdfDataCell(fontRegular, '$totalItemQty', align: pw.Alignment.centerRight),
                      _buildPdfDataCell(fontRegular, _formatCurrency(bill.subTotal), align: pw.Alignment.centerRight),
                      _buildPdfDataCell(fontRegular, _formatCurrency(bill.gstAmount), align: pw.Alignment.centerRight),
                      _buildPdfDataCell(fontRegular, _formatCurrency(bill.amount), align: pw.Alignment.centerRight),
                      _buildPdfDataCell(fontRegular, _formatCurrency(bill.amountPaid), align: pw.Alignment.centerRight),
                      _buildPdfDataCell(fontRegular, _formatCurrency(bill.dueAmount), align: pw.Alignment.centerRight),
                      _buildPdfDataCell(fontRegular, bill.formattedPaymentMode, align: pw.Alignment.center),
                      _buildPdfDataCell(fontRegular, statusText, align: pw.Alignment.center),
                    ],
                  );
                }),

                // 3. Grand Total Row (Aligned directly in respective columns)
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    color: _headerBgColor,
                    border: pw.Border(
                      top: pw.BorderSide(color: _primaryColor, width: 1.2),
                      bottom: pw.BorderSide(color: _primaryColor, width: 1.2),
                    ),
                  ),
                  children: [
                    _buildPdfTotalCell(fontBold, ''),
                    _buildPdfTotalCell(fontBold, ''),
                    _buildPdfTotalCell(fontBold, ''),
                    _buildPdfTotalCell(fontBold, ''),
                    _buildPdfTotalCell(fontBold, 'GRAND TOTAL', textColor: _primaryColor),
                    _buildPdfTotalCell(fontBold, ''),
                    _buildPdfTotalCell(fontBold, '${bills.length} Invoices', align: pw.Alignment.center, textColor: PdfColors.grey700),
                    _buildPdfTotalCell(fontBold, '$totalQty', align: pw.Alignment.centerRight),
                    _buildPdfTotalCell(fontBold, _formatCurrency(totalSubTotal), align: pw.Alignment.centerRight),
                    _buildPdfTotalCell(fontBold, _formatCurrency(totalGst), align: pw.Alignment.centerRight),
                    _buildPdfTotalCell(fontBold, _formatCurrency(totalSales), align: pw.Alignment.centerRight, textColor: _primaryColor),
                    _buildPdfTotalCell(fontBold, _formatCurrency(totalPaid), align: pw.Alignment.centerRight, textColor: _greenColor),
                    _buildPdfTotalCell(fontBold, _formatCurrency(totalDue), align: pw.Alignment.centerRight, textColor: totalDue > 0 ? _redColor : _greenColor),
                    _buildPdfTotalCell(fontBold, ''),
                    _buildPdfTotalCell(fontBold, ''),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildPdfHeaderCell(
    pw.Font font,
    String text, {
    pw.Alignment align = pw.Alignment.centerLeft,
  }) {
    return pw.Container(
      alignment: align,
      padding: const pw.EdgeInsets.symmetric(horizontal: 3.5, vertical: 5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: 7.5,
          color: PdfColors.white,
        ),
      ),
    );
  }

  static pw.Widget _buildPdfDataCell(
    pw.Font font,
    String text, {
    pw.Alignment align = pw.Alignment.centerLeft,
  }) {
    return pw.Container(
      alignment: align,
      padding: const pw.EdgeInsets.symmetric(horizontal: 3.5, vertical: 4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: 7.2,
          color: _darkTextColor,
        ),
      ),
    );
  }

  static pw.Widget _buildPdfTotalCell(
    pw.Font font,
    String text, {
    pw.Alignment align = pw.Alignment.centerLeft,
    PdfColor? textColor,
  }) {
    return pw.Container(
      alignment: align,
      padding: const pw.EdgeInsets.symmetric(horizontal: 3.5, vertical: 5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: 7.5,
          color: textColor ?? _darkTextColor,
        ),
      ),
    );
  }

  static pw.Widget _buildSummaryItem(
    pw.Font fontBold,
    pw.Font fontRegular,
    String label,
    String value, {
    PdfColor? valueColor,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            font: fontRegular,
            fontSize: 7.5,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 1.5),
        pw.Text(
          value,
          style: pw.TextStyle(
            font: fontBold,
            fontSize: 9,
            color: valueColor ?? _darkTextColor,
          ),
        ),
      ],
    );
  }

  /// Generates CSV format string for all sales including grand totals and KPI summary.
  static String generateSalesReportCsv({
    required List<BillModel> bills,
    CompanyModel? company,
    String filter = 'All',
  }) {
    final buffer = StringBuffer();

    // UTF-8 BOM for Microsoft Excel compatibility
    buffer.write('\uFEFF');

    // Totals calculations
    final totalSubTotal = bills.fold(0.0, (s, b) => s + b.subTotal);
    final totalGst = bills.fold(0.0, (s, b) => s + b.gstAmount);
    final totalSales = bills.fold(0.0, (s, b) => s + b.amount);
    final totalPaid = bills.fold(0.0, (s, b) => s + b.amountPaid);
    final totalDue = bills.fold(0.0, (s, b) => s + b.dueAmount);
    final totalQuantity = bills.fold(0, (s, b) => s + (b.totalQty > 0 ? b.totalQty : b.lines.fold(0, (lSum, l) => lSum + l.qty)));

    // 1. Table Header
    buffer.writeln(
      'Sr No,Invoice No,Date,Bill Type,Customer Name,City,Customer Type,Products Summary,Total Qty,Sub Total (INR),GST Amount (INR),Grand Total (INR),Amount Paid (INR),Due Amount (INR),Payment Mode,Payment Status,Billed By',
    );

    // 2. Data Rows
    for (int i = 0; i < bills.length; i++) {
      final b = bills[i];
      final itemsSummary = b.lines.map((l) => '${l.displayName} x ${l.qty}').join('; ');
      final totalQty = b.totalQty > 0 ? b.totalQty : b.lines.fold(0, (s, l) => s + l.qty);

      buffer.writeln([
        '${i + 1}',
        '"${b.invoiceNumber}"',
        '"${b.date}"',
        '"${b.typeLabel}"',
        '"${b.partyName}"',
        '"${b.customerCity ?? ''}"',
        b.isWalkIn ? 'Walk-in' : 'Registered',
        '"$itemsSummary"',
        '$totalQty',
        b.subTotal.toStringAsFixed(2),
        b.gstAmount.toStringAsFixed(2),
        b.amount.toStringAsFixed(2),
        b.amountPaid.toStringAsFixed(2),
        b.dueAmount.toStringAsFixed(2),
        '"${b.formattedPaymentMode}"',
        '"${b.statusLabel.replaceAll('•', '').trim()}"',
        '"${b.createdByName ?? ''}"',
      ].join(','));
    }

    // 3. Grand Totals Row (Aligned in respective numeric columns)
    buffer.writeln([
      '""',
      '""',
      '""',
      '""',
      '"GRAND TOTAL"',
      '""',
      '""',
      '"${bills.length} Invoices"',
      '$totalQuantity',
      totalSubTotal.toStringAsFixed(2),
      totalGst.toStringAsFixed(2),
      totalSales.toStringAsFixed(2),
      totalPaid.toStringAsFixed(2),
      totalDue.toStringAsFixed(2),
      '""',
      '""',
      '""',
    ].join(','));

    return buffer.toString();
  }

  // ---------------------------------------------------------------------------
  // 3. ACTION HANDLERS: PRINT, SHARE, DOWNLOAD
  // ---------------------------------------------------------------------------

  /// Opens native print dialog / layout for sales report PDF
  static Future<void> printReport({
    required List<BillModel> bills,
    CompanyModel? company,
    String filter = 'All',
  }) async {
    final bytes = await generateSalesReportPdf(
      bills: bills,
      company: company,
      filter: filter,
    );

    final filename = 'SalesReport_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}';

    await Printing.layoutPdf(
      onLayout: (format) async => bytes,
      name: filename,
    );
  }

  /// Opens native share sheet for sales report PDF
  static Future<void> sharePdf({
    required List<BillModel> bills,
    CompanyModel? company,
    String filter = 'All',
  }) async {
    final bytes = await generateSalesReportPdf(
      bills: bills,
      company: company,
      filter: filter,
    );

    final filename = 'SalesReport_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';

    await Printing.sharePdf(
      bytes: bytes,
      filename: filename,
    );
  }

  /// Downloads / saves sales report PDF to device storage
  static Future<String?> downloadPdf(
    BuildContext context, {
    required List<BillModel> bills,
    CompanyModel? company,
    String filter = 'All',
  }) async {
    final bytes = await generateSalesReportPdf(
      bills: bills,
      company: company,
      filter: filter,
    );

    final filename = 'SalesReport_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
    String? savedFilePath;

    try {
      Directory? directory;
      if (Platform.isAndroid) {
        final downloadDir = Directory('/storage/emulated/0/Download');
        if (await downloadDir.exists()) {
          directory = downloadDir;
        } else {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      }

      if (directory != null) {
        final file = File('${directory.path}/$filename');
        await file.writeAsBytes(bytes, flush: true);
        savedFilePath = file.path;
      }
    } catch (e) {
      debugPrint('Direct PDF save error: $e');
    }

    // Also trigger native share sheet for user convenience
    try {
      await Printing.sharePdf(
        bytes: bytes,
        filename: filename,
      );
    } catch (_) {}

    return savedFilePath;
  }

  /// Exports and shares CSV document
  static Future<String?> exportCsv(
    BuildContext context, {
    required List<BillModel> bills,
    CompanyModel? company,
    String filter = 'All',
  }) async {
    final csvContent = generateSalesReportCsv(
      bills: bills,
      company: company,
      filter: filter,
    );

    final filename = 'SalesReport_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
    final bytes = Uint8List.fromList(utf8.encode(csvContent));
    String? savedFilePath;

    try {
      Directory? directory;
      if (Platform.isAndroid) {
        final downloadDir = Directory('/storage/emulated/0/Download');
        if (await downloadDir.exists()) {
          directory = downloadDir;
        } else {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      }

      if (directory != null) {
        final file = File('${directory.path}/$filename');
        await file.writeAsBytes(bytes, flush: true);
        savedFilePath = file.path;
      }
    } catch (e) {
      debugPrint('Direct CSV save error: $e');
    }

    // Share via Printing.sharePdf (supported for document bytes with custom filename extension)
    try {
      await Printing.sharePdf(
        bytes: bytes,
        filename: filename,
      );
    } catch (_) {}

    return savedFilePath;
  }

  static String _formatCurrency(double amount) {
    if (amount == amount.roundToDouble()) {
      final parts = amount.toInt().toString().split('');
      final buffer = StringBuffer();
      for (int i = 0; i < parts.length; i++) {
        if (i > 0 &&
            (parts.length - i) % 3 == 0 &&
            (parts.length - i) != parts.length) {
          buffer.write(',');
        }
        buffer.write(parts[i]);
      }
      return buffer.toString();
    } else {
      return amount.toStringAsFixed(2);
    }
  }
}
