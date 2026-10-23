import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../core/utils/number_to_words_helper.dart';
import '../controllers/create_bill_controller.dart';
import '../models/billing_model.dart';
import '../models/selected_product_model.dart';
import '../create_bill_ui/widgets/gst_cal.dart';

class InvoicePdfItem {
  final String name;
  final String? hsnCode;
  final int quantity;
  final String unit;
  final double rate;
  final double taxableValue;
  final double gstPercent;
  final double gstAmount;
  final double totalAmount;

  const InvoicePdfItem({
    required this.name,
    this.hsnCode,
    required this.quantity,
    this.unit = '',
    required this.rate,
    required this.taxableValue,
    required this.gstPercent,
    required this.gstAmount,
    required this.totalAmount,
  });

  factory InvoicePdfItem.fromSelectedProduct(SelectedProductItem item, {bool isPakka = true}) {
    final taxable = item.rate * item.quantity;
    final effectiveGst = isPakka ? item.gstPercent : 0.0;
    final gstAmt = isPakka ? (taxable * effectiveGst / 100) : 0.0;
    return InvoicePdfItem(
      name: item.name,
      hsnCode: item.hsnCode,
      quantity: item.quantity,
      unit: item.unit?.isNotEmpty == true ? item.unit! : 'NOS',
      rate: item.rate,
      taxableValue: taxable,
      gstPercent: effectiveGst,
      gstAmount: gstAmt,
      totalAmount: taxable + gstAmt,
    );
  }
}

class InvoicePdfData {
  final String companyName;
  final String companySubtitle;
  final String companyAddress;
  final String companyGstin;
  final String companyCity;
  final String companyPhone;
  final String companyState;

  final String invoiceNo;
  final String invoiceDate;
  final bool isPakka; // true: GST Invoice, false: Cash Memo
  final String paymentMode;
  final String placeOfSupply;
  final String billedBy;

  final String customerName;
  final String customerAddress;
  final String customerGstin;
  final String customerMobile;
  final String customerCity;
  final String customerCode;

  final List<String> categories;
  final List<InvoicePdfItem> items;
  final double subTotal;
  final double totalGst;
  final double discountRate;
  final String discountType;
  final double discountAmount;
  final double grandTotal;
  final double amountPaid;
  final String amountInWords;

  final String bankName;
  final String bankAccountNo;
  final String bankIfsc;
  final String bankBranch;

  const InvoicePdfData({
    required this.companyName,
    this.companySubtitle = '',
    this.companyAddress = '',
    this.companyGstin = '',
    this.companyCity = '',
    this.companyPhone = '',
    this.companyState = '',
    required this.invoiceNo,
    required this.invoiceDate,
    this.isPakka = true,
    this.paymentMode = '',
    this.placeOfSupply = '',
    this.billedBy = '',
    required this.customerName,
    this.customerAddress = '',
    this.customerGstin = '',
    this.customerMobile = '',
    this.customerCity = '',
    this.customerCode = '-',
    this.categories = const [],
    required this.items,
    required this.subTotal,
    required this.totalGst,
    this.discountRate = 0.0,
    this.discountType = 'percentage',
    this.discountAmount = 0.0,
    required this.grandTotal,
    required this.amountPaid,
    required this.amountInWords,
    this.bankName = '',
    this.bankAccountNo = '',
    this.bankIfsc = '',
    this.bankBranch = '',
  });

  factory InvoicePdfData.fromController({
    required CreateBillController controller,
    String? companyName,
    String? companySubtitle,
    String? companyAddress,
    String? companyGstin,
    String? companyCity,
    String? companyPhone,
    String? companyState,
    String? customerName,
    String? customerAddress,
    String? customerGstin,
    String? customerMobile,
    String? customerCity,
    String? customerCode,
    List<String>? categories,
    String? invoiceNo,
    String? invoiceDate,
    String? billedBy,
  }) {
    final isPakka = controller.selectedBillType == CreateBillType.pakkaBill;
    final items = controller.selectedProductsList
        .map((p) => InvoicePdfItem.fromSelectedProduct(p, isPakka: isPakka))
        .toList();

    final gstCalc = GstCal.calculate(
      items: controller.selectedProductsList,
      isPakka: isPakka,
      discountType: controller.discountType,
      discountRate: controller.discountRate,
    );

    final grandTotal = gstCalc.grandTotal;
    final words = grandTotal > 0
        ? NumberToWordsHelper.convert(grandTotal)
        : 'Zero Rupees Only';

    final walkIn = controller.walkInNameController.text.trim();
    final custName = customerName?.isNotEmpty == true
        ? customerName!
        : (walkIn.isNotEmpty
            ? walkIn
            : (controller.selectedCustomer?.isNotEmpty == true
                ? controller.selectedCustomer!
                : controller.customerNameController.text.trim()));

    final dateStr = invoiceDate ?? '';
    final invNo = invoiceNo ?? '';

    final payMode = controller.selectedPaymentMode == PaymentMode.upi
        ? 'UPI'
        : controller.selectedPaymentMode == PaymentMode.cash
            ? 'Cash'
            : controller.selectedPaymentMode == PaymentMode.credit
                ? 'Credit'
                : 'Bank';

    final amtPaid =
        double.tryParse(controller.amountReceivedController.text) ?? grandTotal;

    final derivedCategories = categories ??
        controller.selectedProductsList
            .map((i) => i.category?.isNotEmpty == true ? i.category! : i.name)
            .where((c) => c.trim().isNotEmpty)
            .toSet()
            .take(4)
            .toList();

    final finalCustCity = customerCity ?? controller.customerCityController.text.trim();
    final finalCompCity = companyCity ?? '';
    final pos = finalCustCity.isNotEmpty
        ? finalCustCity
        : (finalCompCity.isNotEmpty ? finalCompCity : '-');

    return InvoicePdfData(
      companyName: companyName ?? (controller.selectedFirm ?? ''),
      companySubtitle: companySubtitle ?? '',
      companyAddress: companyAddress ?? '',
      companyGstin: companyGstin ?? '',
      companyCity: finalCompCity,
      companyPhone: companyPhone ?? '',
      companyState: companyState ?? '',
      invoiceNo: invNo,
      invoiceDate: dateStr,
      isPakka: isPakka,
      paymentMode: payMode,
      placeOfSupply: pos,
      billedBy: billedBy ?? '',
      customerName: custName.isNotEmpty ? custName : 'Walk-in Customer',
      customerAddress:
          customerAddress ?? controller.customerAddressController.text.trim(),
      customerGstin:
          customerGstin ?? controller.customerGstinController.text.trim(),
      customerMobile:
          customerMobile ?? controller.customerMobileController.text.trim(),
      customerCity: finalCustCity,
      customerCode: customerCode?.isNotEmpty == true ? customerCode! : '-',
      categories: derivedCategories,
      items: items,
      subTotal: gstCalc.subTotal,
      totalGst: gstCalc.totalGst,
      discountRate: controller.discountRate,
      discountType: controller.discountType.value,
      discountAmount: gstCalc.discountAmount,
      grandTotal: grandTotal,
      amountPaid: amtPaid,
      amountInWords: words,
    );
  }

  factory InvoicePdfData.fromBillingModel({
    required BillingModel bill,
    String? companyName,
    String? companySubtitle,
    String? companyAddress,
    String? companyGstin,
    String? companyCity,
    String? companyPhone,
    String? companyState,
    String? customerName,
    String? customerAddress,
    String? customerGstin,
    String? customerMobile,
    String? customerCity,
    String? customerCode,
    List<String>? categories,
    List<InvoicePdfItem>? items,
  }) {
    final isPakka = bill.mode.toLowerCase() == 'pakka';
    final calcItems = items ??
        bill.lines.map((l) {
          final taxable = l.rate * l.qty;
          final gstP = isPakka ? (l.gstPercent ?? 0.0) : 0.0;
          final gstA = isPakka ? (taxable * gstP / 100) : 0.0;
          return InvoicePdfItem(
            name: l.product,
            hsnCode: null,
            quantity: l.qty,
            unit: 'NOS',
            rate: l.rate,
            taxableValue: taxable,
            gstPercent: gstP,
            gstAmount: gstA,
            totalAmount: l.lineTotal ?? (taxable + gstA),
          );
        }).toList();

    final grandTotal = bill.totalAmount > 0
        ? bill.totalAmount
        : calcItems.fold<double>(0.0, (sum, i) => sum + i.totalAmount);
    final subTotal = bill.subTotal > 0
        ? bill.subTotal
        : calcItems.fold<double>(0.0, (sum, i) => sum + i.taxableValue);
    final totalGst = isPakka
        ? (bill.gstAmount > 0
            ? bill.gstAmount
            : calcItems.fold<double>(0.0, (sum, i) => sum + i.gstAmount))
        : 0.0;

    final words = grandTotal > 0
        ? NumberToWordsHelper.convert(grandTotal)
        : 'Zero Rupees Only';

    final cust = customerName ??
        (bill.walkInName?.isNotEmpty == true
            ? bill.walkInName!
            : (bill.customer?.isNotEmpty == true ? bill.customer! : 'Walk-in Customer'));

    final payMode = bill.paymentMode.isNotEmpty ? bill.paymentMode.toUpperCase() : 'Cash';

    final dateStr = bill.date?.isNotEmpty == true
        ? (bill.date!.length >= 10 ? bill.date!.substring(0, 10) : bill.date!)
        : '';

    final derivedCategories = categories ??
        calcItems.map((i) => i.name).where((n) => n.trim().isNotEmpty).toSet().take(4).toList();

    final finalCustCity = customerCity ?? '';
    final finalCompCity = companyCity ?? '';
    final pos = finalCustCity.isNotEmpty
        ? finalCustCity
        : (finalCompCity.isNotEmpty ? finalCompCity : '-');

    return InvoicePdfData(
      companyName: companyName ?? '',
      companySubtitle: companySubtitle ?? '',
      companyAddress: companyAddress ?? '',
      companyGstin: companyGstin ?? '',
      companyCity: finalCompCity,
      companyPhone: companyPhone ?? '',
      companyState: companyState ?? '',
      invoiceNo: bill.invoiceNo,
      invoiceDate: dateStr,
      isPakka: isPakka,
      paymentMode: payMode,
      placeOfSupply: pos,
      billedBy: bill.createdBy ?? '',
      customerName: cust,
      customerAddress: customerAddress ?? '',
      customerGstin: customerGstin ?? '',
      customerMobile: customerMobile ?? '',
      customerCity: finalCustCity,
      customerCode: customerCode?.isNotEmpty == true ? customerCode! : '-',
      categories: derivedCategories,
      items: calcItems,
      subTotal: subTotal,
      totalGst: totalGst,
      discountRate: bill.discountRate ?? 0.0,
      discountType: bill.discountType ?? 'percentage',
      discountAmount: bill.discountAmount ?? 0.0,
      grandTotal: grandTotal,
      amountPaid: bill.amountPaid,
      amountInWords: words,
    );
  }
}

class InvoicePdfService {
  static Future<Uint8List> generatePdfBytes(InvoicePdfData data) async {
    final pdf = pw.Document();

    final fontRegular = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();
    final fontMedium = await PdfGoogleFonts.robotoMedium();

    pw.MemoryImage? logoImage;
    try {
      final logoData = await rootBundle.load('assets/images/logo.png');
      logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (_) {
      logoImage = null;
    }

    final isPakka = data.isPakka;
    final invoiceTitle = isPakka ? 'GST INVOICE' : 'CASH MEMO';
    final primaryBlue = PdfColor.fromHex('#0F3B82');
    final darkNavy = PdfColor.fromHex('#0B2B64');
    final titleNavy = PdfColor.fromHex('#0A2540');
    final subtitleBlue = PdfColor.fromHex('#3B82F6');
    final borderSlate = PdfColor.fromHex('#CBD5E1');
    final borderLight = PdfColor.fromHex('#E2E8F0');
    final bgLight = PdfColor.fromHex('#F8FAFC');
    final textDark = PdfColor.fromHex('#0F172A');
    final textSlate = PdfColor.fromHex('#475569');
    final textMuted = PdfColor.fromHex('#64748B');
    final textGstin = PdfColor.fromHex('#1E293B');
    final wordsBlue = PdfColor.fromHex('#1E3A8A');
    final greenBg = PdfColor.fromHex('#DCFCE7');
    final greenText = PdfColor.fromHex('#166534');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
              border: pw.Border.all(color: borderLight, width: 1.2),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // ==========================================
                // 1. TOP HEADER: LOGO + COMPANY & INVOICE DETAILS
                // ==========================================
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    // Left: Logo & Company Name & Categories
                    pw.Expanded(
                      flex: 6,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            children: [
                              if (logoImage != null)
                                pw.Container(
                                  width: 44,
                                  height: 44,
                                  child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                                )
                              else
                                pw.Container(
                                  width: 42,
                                  height: 42,
                                  decoration: pw.BoxDecoration(
                                    color: primaryBlue,
                                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                                  ),
                                  child: pw.Center(
                                    child: pw.Text(
                                      data.companyName.isNotEmpty
                                          ? data.companyName[0].toUpperCase()
                                          : 'C',
                                      style: pw.TextStyle(
                                        font: fontBold,
                                        fontSize: 20,
                                        color: PdfColors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              pw.SizedBox(width: 10),
                              pw.Expanded(
                                child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                      data.companyName.toUpperCase(),
                                      style: pw.TextStyle(
                                        font: fontBold,
                                        fontSize: 17,
                                        color: primaryBlue,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    if (data.companySubtitle.isNotEmpty) ...[
                                      pw.SizedBox(height: 2),
                                      pw.Text(
                                        data.companySubtitle,
                                        style: pw.TextStyle(
                                          font: fontBold,
                                          fontSize: 9,
                                          color: subtitleBlue,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (data.categories.isNotEmpty) ...[
                            pw.SizedBox(height: 8),
                            pw.Row(
                              children: data.categories.map((cat) {
                                return pw.Container(
                                  margin: const pw.EdgeInsets.only(right: 5),
                                  padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: pw.BoxDecoration(
                                    color: primaryBlue,
                                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
                                  ),
                                  child: pw.Text(
                                    cat.toUpperCase(),
                                    style: pw.TextStyle(
                                      font: fontBold,
                                      fontSize: 7,
                                      color: PdfColors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),

                    pw.SizedBox(width: 10),

                    // Right: Invoice Title & Meta Box
                    pw.Expanded(
                      flex: 4,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            invoiceTitle,
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 19,
                              color: titleNavy,
                              letterSpacing: 0.5,
                            ),
                          ),
                          pw.SizedBox(height: 6),
                          pw.Container(
                            padding: const pw.EdgeInsets.all(6),
                            decoration: pw.BoxDecoration(
                              color: bgLight,
                              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                              border: pw.Border.all(color: borderLight, width: 0.8),
                            ),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                _buildPdfMetaRow('Invoice No.', data.invoiceNo, fontBold, fontRegular, textMuted, textDark, labelWidth: 70),
                                _buildPdfMetaRow('Invoice Date', data.invoiceDate, fontBold, fontRegular, textMuted, textDark, labelWidth: 70),
                                _buildPdfMetaRow('Place of Supply', data.placeOfSupply.isNotEmpty ? data.placeOfSupply : '-', fontBold, fontRegular, textMuted, textDark, labelWidth: 70),
                                _buildPdfMetaRow('Reverse Charge', 'No', fontBold, fontRegular, textMuted, textDark, labelWidth: 70),
                                _buildPdfMetaRow('Invoice Type', isPakka ? 'Tax Invoice' : 'Cash Memo', fontBold, fontRegular, textMuted, textDark, labelWidth: 70),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 12),

                // ==========================================
                // 2. 3 INFO CARDS: BILL TO, SHIP TO, OTHER DETAILS
                // ==========================================
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Card 1: Bill To
                    pw.Expanded(
                      child: _buildPdfInfoCard(
                        title: 'BILL TO',
                        darkNavy: darkNavy,
                        borderSlate: borderSlate,
                        fontBold: fontBold,
                        content: [
                          pw.Text(
                            data.customerName,
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 10,
                              color: textDark,
                            ),
                          ),
                          if (data.customerAddress.isNotEmpty) ...[
                            pw.SizedBox(height: 2),
                            pw.Text(
                              data.customerAddress,
                              style: pw.TextStyle(
                                font: fontRegular,
                                fontSize: 8,
                                color: textSlate,
                              ),
                            ),
                          ],
                          if (data.customerGstin.isNotEmpty) ...[
                            pw.SizedBox(height: 3),
                            pw.Text(
                              'GSTIN : ${data.customerGstin}',
                              style: pw.TextStyle(
                                font: fontBold,
                                fontSize: 8,
                                color: textGstin,
                              ),
                            ),
                          ],
                          if (data.customerCity.isNotEmpty) ...[
                            pw.SizedBox(height: 2),
                            pw.Text(
                              'City : ${data.customerCity}',
                              style: pw.TextStyle(
                                font: fontRegular,
                                fontSize: 8,
                                color: textSlate,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    pw.SizedBox(width: 8),

                    // Card 2: Ship To
                    pw.Expanded(
                      child: _buildPdfInfoCard(
                        title: 'SHIP TO',
                        darkNavy: darkNavy,
                        borderSlate: borderSlate,
                        fontBold: fontBold,
                        content: [
                          pw.Text(
                            data.customerName,
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 10,
                              color: textDark,
                            ),
                          ),
                          if (data.customerAddress.isNotEmpty) ...[
                            pw.SizedBox(height: 2),
                            pw.Text(
                              data.customerAddress,
                              style: pw.TextStyle(
                                font: fontRegular,
                                fontSize: 8,
                                color: textSlate,
                              ),
                            ),
                          ],
                          if (data.customerGstin.isNotEmpty) ...[
                            pw.SizedBox(height: 3),
                            pw.Text(
                              'GSTIN : ${data.customerGstin}',
                              style: pw.TextStyle(
                                font: fontBold,
                                fontSize: 8,
                                color: textGstin,
                              ),
                            ),
                          ],
                          if (data.customerCity.isNotEmpty) ...[
                            pw.SizedBox(height: 2),
                            pw.Text(
                              'City : ${data.customerCity}',
                              style: pw.TextStyle(
                                font: fontRegular,
                                fontSize: 8,
                                color: textSlate,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    pw.SizedBox(width: 8),

                    // Card 3: Other Details
                    pw.Expanded(
                      child: _buildPdfInfoCard(
                        title: 'OTHER DETAILS',
                        darkNavy: darkNavy,
                        borderSlate: borderSlate,
                        fontBold: fontBold,
                        content: [
                          _buildPdfMetaRow('Customer Code', data.customerCode, fontBold, fontRegular, textMuted, textDark, labelWidth: 62),
                          _buildPdfMetaRow('Payment Mode', data.paymentMode, fontBold, fontRegular, textMuted, textDark, labelWidth: 62),
                          _buildPdfMetaRow('Due Date', data.invoiceDate, fontBold, fontRegular, textMuted, textDark, labelWidth: 62),
                          _buildPdfMetaRow('Billed By', data.billedBy.isNotEmpty ? data.billedBy : 'Admin', fontBold, fontRegular, textMuted, textDark, labelWidth: 62),
                          if (data.customerMobile.isNotEmpty)
                            _buildPdfMetaRow('Mobile', data.customerMobile, fontBold, fontRegular, textMuted, textDark, labelWidth: 62),
                        ],
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 12),

                // ==========================================
                // 3. PRODUCTS TABLE
                // ==========================================
                pw.Container(
                  decoration: pw.BoxDecoration(
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                    border: pw.Border.all(color: borderSlate, width: 0.8),
                  ),
                  child: pw.Column(
                    children: [
                      // Header
                      pw.Container(
                        decoration: pw.BoxDecoration(
                          color: darkNavy,
                          borderRadius: const pw.BorderRadius.vertical(top: pw.Radius.circular(3)),
                        ),
                        padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                        child: pw.Row(
                          children: [
                            _buildPdfThCell('Sr.\nNo.', flex: 1, fontBold: fontBold),
                            _buildPdfThCell('Product Description', flex: 5, align: pw.TextAlign.left, fontBold: fontBold),
                            _buildPdfThCell('HSN\nCode', flex: 2, fontBold: fontBold),
                            _buildPdfThCell('Qty', flex: 2, fontBold: fontBold),
                            _buildPdfThCell('Unit', flex: 2, fontBold: fontBold),
                            _buildPdfThCell('Rate\n(Rs)', flex: 2, fontBold: fontBold),
                            _buildPdfThCell('GST\n%', flex: 2, fontBold: fontBold),
                            _buildPdfThCell('Grand\nTotal (Rs)', flex: 3, fontBold: fontBold),
                          ],
                        ),
                      ),

                      // Rows
                      if (data.items.isEmpty)
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(vertical: 16),
                          child: pw.Center(
                            child: pw.Text(
                              'No products added to this bill yet',
                              style: pw.TextStyle(
                                font: fontMedium,
                                fontSize: 9,
                                color: textMuted,
                              ),
                            ),
                          ),
                        )
                      else
                        ...data.items.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          final itemTaxable = item.rate * item.quantity;
                          final itemGstPercent = isPakka ? (item.gstPercent > 0 ? item.gstPercent : 0.0) : 0.0;
                          final itemGrandTotal = itemTaxable + (itemTaxable * itemGstPercent / 100);
                          final isLast = index == data.items.length - 1;

                          return pw.Container(
                            decoration: pw.BoxDecoration(
                              color: PdfColors.white,
                              border: isLast
                                  ? null
                                  : pw.Border(
                                      bottom: pw.BorderSide(color: borderLight, width: 0.8),
                                    ),
                            ),
                            padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4.5),
                            child: pw.Row(
                              children: [
                                _buildPdfTdCell('${index + 1}', flex: 1, fontRegular: fontRegular, fontBold: fontBold),
                                _buildPdfTdCell(item.name, flex: 5, align: pw.TextAlign.left, isBold: true, fontRegular: fontRegular, fontBold: fontBold, color: textDark),
                                _buildPdfTdCell(item.hsnCode?.isNotEmpty == true ? item.hsnCode! : '-', flex: 2, fontRegular: fontRegular, fontBold: fontBold),
                                _buildPdfTdCell('${item.quantity}', flex: 2, isBold: true, fontRegular: fontRegular, fontBold: fontBold),
                                _buildPdfTdCell(item.unit.isNotEmpty ? item.unit : 'NOS', flex: 2, fontRegular: fontRegular, fontBold: fontBold),
                                _buildPdfTdCell(item.rate.toStringAsFixed(2), flex: 2, fontRegular: fontRegular, fontBold: fontBold),
                                _buildPdfTdCell(isPakka ? '${itemGstPercent.toStringAsFixed(0)}%' : '0%', flex: 2, fontRegular: fontRegular, fontBold: fontBold),
                                _buildPdfTdCell(_formatCurrency(itemGrandTotal), flex: 3, isBold: true, fontRegular: fontRegular, fontBold: fontBold),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),

                pw.SizedBox(height: 12),

                // ==========================================
                // 4. AMOUNT IN WORDS & TOTALS BLOCK
                // ==========================================
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Left Column: Words + Terms + Issued By
                    pw.Expanded(
                      flex: 6,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          // Amount in Words Box
                          pw.Container(
                            width: double.infinity,
                            padding: const pw.EdgeInsets.all(7),
                            decoration: pw.BoxDecoration(
                              color: bgLight,
                              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                              border: pw.Border.all(color: borderLight, width: 0.8),
                            ),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'Amount in Words:',
                                  style: pw.TextStyle(
                                    font: fontBold,
                                    fontSize: 8,
                                    color: wordsBlue,
                                  ),
                                ),
                                pw.SizedBox(height: 2),
                                pw.Text(
                                  data.amountInWords,
                                  style: pw.TextStyle(
                                    font: fontBold,
                                    fontSize: 9,
                                    color: textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          pw.SizedBox(height: 8),

                          // Terms & Conditions Card
                          _buildPdfInfoCard(
                            title: 'TERMS & CONDITIONS',
                            darkNavy: darkNavy,
                            borderSlate: borderSlate,
                            fontBold: fontBold,
                            content: [
                              pw.Text(
                                '1. Goods once sold will not be taken back.',
                                style: pw.TextStyle(font: fontRegular, fontSize: 7.5, color: textSlate),
                              ),
                              pw.SizedBox(height: 1),
                              pw.Text(
                                '2. Payment to be made within the due date.',
                                style: pw.TextStyle(font: fontRegular, fontSize: 7.5, color: textSlate),
                              ),
                              pw.SizedBox(height: 1),
                              pw.Text(
                                '3. Subject to ${data.companyCity.isNotEmpty ? data.companyCity : (data.customerCity.isNotEmpty ? data.customerCity : 'Local')} Jurisdiction only.',
                                style: pw.TextStyle(font: fontRegular, fontSize: 7.5, color: textSlate),
                              ),
                            ],
                          ),

                          pw.SizedBox(height: 8),

                          // Issued By Card
                          _buildPdfInfoCard(
                            title: 'ISSUED BY',
                            darkNavy: darkNavy,
                            borderSlate: borderSlate,
                            fontBold: fontBold,
                            content: [
                              _buildPdfMetaRow('Company', data.companyName, fontBold, fontRegular, textMuted, textDark, labelWidth: 55),
                              if (data.companyGstin.isNotEmpty)
                                _buildPdfMetaRow('GSTIN', data.companyGstin, fontBold, fontRegular, textMuted, textDark, labelWidth: 55),
                              if (data.companyCity.isNotEmpty)
                                _buildPdfMetaRow('City', data.companyCity, fontBold, fontRegular, textMuted, textDark, labelWidth: 55),
                            ],
                          ),
                        ],
                      ),
                    ),

                    pw.SizedBox(width: 10),

                    // Right Column: Tax Breakdown + Totals + Signature
                    pw.Expanded(
                      flex: 5,
                      child: pw.Column(
                        children: [
                          // Totals Box
                          pw.Container(
                            decoration: pw.BoxDecoration(
                              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                              border: pw.Border.all(color: borderSlate, width: 0.8),
                            ),
                            child: pw.Column(
                              children: [
                                _buildPdfSummaryLine(
                                  isPakka ? 'Taxable Amount' : 'Total Amount',
                                  'Rs ${_formatCurrency(data.subTotal)}',
                                  fontRegular,
                                  fontBold,
                                  textSlate,
                                  textDark,
                                ),
                                if (isPakka && data.totalGst > 0)
                                  _buildPdfSummaryLine(
                                    'Total GST',
                                    'Rs ${_formatCurrency(data.totalGst)}',
                                    fontRegular,
                                    fontBold,
                                    textSlate,
                                    textDark,
                                  ),
                                if (data.discountAmount > 0)
                                  _buildPdfSummaryLine(
                                    data.discountType == 'percentage'
                                        ? 'Discount (${data.discountRate == data.discountRate.roundToDouble() ? data.discountRate.toInt() : data.discountRate}%)'
                                        : 'Discount (Flat)',
                                    '-Rs ${_formatCurrency(data.discountAmount)}',
                                    fontRegular,
                                    fontBold,
                                    PdfColor.fromHex('#15803D'),
                                    PdfColor.fromHex('#15803D'),
                                  ),
                                // Invoice Total Bar
                                pw.Container(
                                  color: primaryBlue,
                                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                  child: pw.Row(
                                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                    children: [
                                      pw.Text(
                                        'Invoice Total',
                                        style: pw.TextStyle(
                                          font: fontBold,
                                          fontSize: 9,
                                          color: PdfColors.white,
                                        ),
                                      ),
                                      pw.Text(
                                        'Rs ${_formatCurrency(data.grandTotal)}',
                                        style: pw.TextStyle(
                                          font: fontBold,
                                          fontSize: 10,
                                          color: PdfColors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _buildPdfSummaryLine(
                                  'Rounded Off',
                                  'Rs 0.00',
                                  fontRegular,
                                  fontBold,
                                  textSlate,
                                  textDark,
                                ),
                                // Grand Total Bar
                                pw.Container(
                                  decoration: pw.BoxDecoration(
                                    color: greenBg,
                                    borderRadius: const pw.BorderRadius.vertical(bottom: pw.Radius.circular(5)),
                                  ),
                                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                  child: pw.Row(
                                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                    children: [
                                      pw.Text(
                                        'Grand Total',
                                        style: pw.TextStyle(
                                          font: fontBold,
                                          fontSize: 10,
                                          color: greenText,
                                        ),
                                      ),
                                      pw.Text(
                                        'Rs ${_formatCurrency(data.grandTotal)}',
                                        style: pw.TextStyle(
                                          font: fontBold,
                                          fontSize: 11,
                                          color: greenText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          pw.SizedBox(height: 12),

                          // Signature Block
                          pw.Container(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.end,
                              children: [
                                pw.Text(
                                  'For ${data.companyName}',
                                  style: pw.TextStyle(
                                    font: fontBold,
                                    fontSize: 8.5,
                                    color: textDark,
                                  ),
                                ),
                                pw.SizedBox(height: 18),
                                pw.Container(
                                  width: 110,
                                  height: 0.8,
                                  color: textMuted,
                                ),
                                pw.SizedBox(height: 3),
                                pw.Text(
                                  'Authorized Signatory',
                                  style: pw.TextStyle(
                                    font: fontMedium,
                                    fontSize: 8,
                                    color: textSlate,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 14),

                // ==========================================
                // 5. FOOTER: ADDRESS + GSTIN
                // ==========================================
                pw.Center(
                  child: pw.Text(
                    'Thank you for your business!',
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 9.5,
                      fontStyle: pw.FontStyle.italic,
                      color: primaryBlue,
                    ),
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Divider(color: borderLight, thickness: 0.8),
                pw.SizedBox(height: 4),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    if (data.companyAddress.isNotEmpty)
                      pw.Text(
                        data.companyAddress,
                        style: pw.TextStyle(
                          font: fontRegular,
                          fontSize: 7.5,
                          color: textSlate,
                        ),
                      )
                    else
                      pw.SizedBox(),
                    if (data.companyGstin.isNotEmpty)
                      pw.Text(
                        'GSTIN: ${data.companyGstin}',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 7.5,
                          color: textGstin,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  // --- PDF Helper Widgets ---

  static pw.Widget _buildPdfMetaRow(
    String label,
    String value,
    pw.Font fontBold,
    pw.Font fontRegular,
    PdfColor labelColor,
    PdfColor valueColor, {
    double labelWidth = 65,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.SizedBox(
            width: labelWidth,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                font: fontRegular,
                fontSize: 7.5,
                color: labelColor,
              ),
            ),
          ),
          pw.Text(
            ' :  ',
            style: pw.TextStyle(
              font: fontRegular,
              fontSize: 7.5,
              color: labelColor,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 8,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPdfInfoCard({
    required String title,
    required List<pw.Widget> content,
    required PdfColor darkNavy,
    required PdfColor borderSlate,
    required pw.Font fontBold,
  }) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        border: pw.Border.all(color: borderSlate, width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: pw.BoxDecoration(
              color: darkNavy,
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(5),
                bottomRight: pw.Radius.circular(6),
              ),
            ),
            child: pw.Text(
              title,
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 7.5,
                color: PdfColors.white,
                letterSpacing: 0.4,
              ),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(6.0),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: content,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPdfSummaryLine(
    String label,
    String value,
    pw.Font fontRegular,
    pw.Font fontBold,
    PdfColor labelColor,
    PdfColor valueColor,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              font: fontRegular,
              fontSize: 8,
              color: labelColor,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 8.5,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPdfThCell(
    String text, {
    required int flex,
    pw.TextAlign align = pw.TextAlign.center,
    required pw.Font fontBold,
  }) {
    return pw.Expanded(
      flex: flex,
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          font: fontBold,
          fontSize: 7,
          color: PdfColors.white,
          lineSpacing: 1.1,
        ),
      ),
    );
  }

  static pw.Widget _buildPdfTdCell(
    String text, {
    required int flex,
    pw.TextAlign align = pw.TextAlign.center,
    bool isBold = false,
    required pw.Font fontRegular,
    required pw.Font fontBold,
    PdfColor? color,
  }) {
    return pw.Expanded(
      flex: flex,
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          font: isBold ? fontBold : fontRegular,
          fontSize: 7.5,
          color: color ?? PdfColor.fromHex('#0F172A'),
        ),
      ),
    );
  }

  static String _formatCurrency(double val) {
    final isNegative = val < 0;
    final absVal = val.abs();
    final parts = absVal.toStringAsFixed(2).split('.');
    String integerPart = parts[0];
    final decimalPart = parts[1];

    if (integerPart.length > 3) {
      final lastThree = integerPart.substring(integerPart.length - 3);
      final rest = integerPart.substring(0, integerPart.length - 3);
      final buffer = StringBuffer();
      for (int i = 0; i < rest.length; i++) {
        if (i > 0 && (rest.length - i) % 2 == 0) {
          buffer.write(',');
        }
        buffer.write(rest[i]);
      }
      integerPart = '${buffer.toString()},$lastThree';
    }
    return '${isNegative ? '-' : ''}$integerPart.$decimalPart';
  }

  /// Print invoice directly
  static Future<void> printPdf(InvoicePdfData data) async {
    final bytes = await generatePdfBytes(data);
    try {
      await Printing.layoutPdf(
        onLayout: (format) async => bytes,
        name: 'Invoice_${data.invoiceNo}',
      );
    } catch (e) {
      if (e.toString().contains('MissingPluginException') ||
          e.toString().contains('No implementation found')) {
        throw Exception(
          'Printing plugin requires a full app restart. Please stop and re-run (flutter run) the app to compile native printer components.',
        );
      }
      rethrow;
    }
  }

  /// Share invoice PDF (opens native share sheet)
  static Future<void> sharePdf(InvoicePdfData data) async {
    final bytes = await generatePdfBytes(data);
    try {
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'Invoice_${data.invoiceNo}.pdf',
      );
    } catch (e) {
      if (e.toString().contains('MissingPluginException') ||
          e.toString().contains('No implementation found')) {
        throw Exception(
          'Share plugin requires a full app restart. Please stop and re-run (flutter run) the app to compile native components.',
        );
      }
      rethrow;
    }
  }

  /// Download/save invoice PDF to device storage
  static Future<String?> downloadPdf(BuildContext context, InvoicePdfData data) async {
    final bytes = await generatePdfBytes(data);
    final sanitizedNo = data.invoiceNo.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
    final filename = 'Invoice_$sanitizedNo.pdf';

    String? savedFilePath;

    // 1. Direct file write to storage
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
      debugPrint('Direct PDF file write error: $e');
    }

    // 2. Try native share/save sheet if plugin is loaded
    try {
      await Printing.sharePdf(
        bytes: bytes,
        filename: filename,
      );
    } catch (e) {
      debugPrint('Printing.sharePdf skipped (full app restart required): $e');
    }

    return savedFilePath;
  }
}

