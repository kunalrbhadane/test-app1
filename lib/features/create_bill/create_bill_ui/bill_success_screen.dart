import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../dashboard/dashboard_screen.dart';
import '../models/billing_model.dart';
import '../services/invoice_pdf_service.dart';

class BillSuccessScreen extends StatefulWidget {
  final String billType;
  final String invoiceNo;
  final String date;
  final String customer;
  final String amount;
  final String paymentMode;
  final InvoicePdfData? pdfData;
  final BillingModel? billingModel;

  const BillSuccessScreen({
    super.key,
    required this.billType,
    required this.invoiceNo,
    required this.date,
    required this.customer,
    required this.amount,
    required this.paymentMode,
    this.pdfData,
    this.billingModel,
  });

  @override
  State<BillSuccessScreen> createState() => _BillSuccessScreenState();
}

class _BillSuccessScreenState extends State<BillSuccessScreen> {
  bool _isProcessing = false;
  bool _showLineItems = false;

  InvoicePdfData _getEffectivePdfData() {
    if (widget.pdfData != null) return widget.pdfData!;

    final isPakka = widget.billType.toLowerCase().contains('pakka') ||
        widget.billType.toLowerCase().contains('gst') ||
        (widget.billingModel?.mode.toLowerCase() == 'pakka');
    final double amt = widget.billingModel?.totalAmount ??
        (double.tryParse(widget.amount.replaceAll(',', '')) ?? 0.0);
    final double subTot = widget.billingModel?.subTotal ?? amt;
    final double gstTot = widget.billingModel?.gstAmount ?? 0.0;
    final double amtPaid = widget.billingModel?.amountPaid ?? amt;

    return InvoicePdfData(
      companyName: '',
      invoiceNo: widget.invoiceNo,
      invoiceDate: widget.date,
      isPakka: isPakka,
      customerName: widget.customer,
      paymentMode: widget.paymentMode,
      items: [],
      subTotal: subTot,
      totalGst: gstTot,
      grandTotal: amt,
      amountPaid: amtPaid,
      amountInWords: '',
    );
  }

  Future<void> _handlePrint() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final pdfData = _getEffectivePdfData();
      await InvoicePdfService.printPdf(pdfData);
    } catch (e) {
      if (mounted) {
        final msg = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleDownload() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final pdfData = _getEffectivePdfData();
      final path = await InvoicePdfService.downloadPdf(context, pdfData);
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              path != null
                  ? '${l10n?.invoiceSavedDownloads ?? "Invoice saved to Downloads"} ($path)'
                  : (l10n?.invoiceCreatedSuccess ?? 'Invoice PDF generated successfully'),
            ),
            backgroundColor: const Color(0xFF005CBD),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleShare() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final pdfData = _getEffectivePdfData();
      await InvoicePdfService.sharePdf(pdfData);
    } catch (e) {
      if (mounted) {
        final msg = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _copyInvoiceNo(String invNo) {
    Clipboard.setData(ClipboardData(text: invNo));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invoice No $invNo copied to clipboard'),
        backgroundColor: const Color(0xFF1E293B),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString();
    }
    return amount.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bill = widget.billingModel;
    final isPakka = widget.billType.toLowerCase().contains('pakka') ||
        (bill?.mode.toLowerCase() == 'pakka');

    final subTotal = bill?.subTotal ??
        (double.tryParse(widget.amount.replaceAll(',', '')) ?? 0.0);
    final gstAmount = bill?.gstAmount ?? 0.0;
    final totalAmount = bill?.totalAmount ?? subTotal;
    final amountPaid = bill?.amountPaid ?? totalAmount;
    final rawDue = bill?.dueAmount ?? (totalAmount - amountPaid).clamp(0.0, double.infinity);
    final dueAmount = (rawDue * 100.0).round() / 100.0;
    final totalQty = bill?.totalQty ??
        (bill?.lines.fold<int>(0, (prev, el) => prev + el.qty) ??
            widget.pdfData?.items.fold<int>(0, (prev, el) => prev + el.quantity) ??
            0);
    final totalItemsCount = bill?.lines.length ?? widget.pdfData?.items.length ?? 0;

    // Payment Status determination
    final rawStatus = bill?.paymentStatus?.toLowerCase() ?? '';
    final isFullyPaid = rawStatus == 'paid' || dueAmount <= 0.009;
    final isPartiallyPaid = rawStatus == 'partially' || (dueAmount > 0.009 && amountPaid > 0);

    final statusText = isFullyPaid
        ? (l10n?.paid ?? 'Paid')
        : (isPartiallyPaid ? (l10n?.partial ?? 'Partially Paid') : (l10n?.unpaid ?? 'Unpaid'));
    final statusBg = isFullyPaid
        ? const Color(0xFFDCFCE7)
        : (isPartiallyPaid ? const Color(0xFFFEF3C7) : const Color(0xFFFEE2E2));
    final statusColor = isFullyPaid
        ? const Color(0xFF15803D)
        : (isPartiallyPaid ? const Color(0xFFB45309) : const Color(0xFFB91C1C));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => DashboardScreen(),
          ),
          (route) => false,
        );
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Column(
            children: [
              // Scrollable main content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),

                      // Success Animation / Icon
                      Center(
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFDCFCE7),
                            border: Border.all(
                              color: const Color(0xFF86EFAC),
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.check_rounded,
                              color: Color(0xFF16A34A),
                              size: 48,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title
                      Text(
                        l10n?.billSuccess ?? 'Bill Generated Successfully!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Subtitle
                      Text(
                        '${l10n?.billNumber ?? "Invoice #"} ${widget.invoiceNo}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // --- MAIN INVOICE DETAILS CARD ---
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Card Top Header: Invoice No + Mode & Status Badges
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(17),
                                ),
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color(0xFFF1F5F9),
                                    width: 1.2,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Invoice No with Copy Button
                                  InkWell(
                                    onTap: () => _copyInvoiceNo(widget.invoiceNo),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 2,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            widget.invoiceNo,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.primaryBlue,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          const Icon(
                                            Icons.copy_rounded,
                                            size: 14,
                                            color: AppColors.primaryBlue,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Status Badges
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Bill Mode Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3.5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isPakka
                                              ? const Color(0xFFEFF6FF)
                                              : const Color(0xFFF1F5F9),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                            color: isPakka
                                                ? const Color(0xFFBFDBFE)
                                                : const Color(0xFFCBD5E1),
                                            width: 0.8,
                                          ),
                                        ),
                                        child: Text(
                                          isPakka
                                              ? (l10n?.pakka ?? 'PAKKA')
                                              : (l10n?.kaccha ?? 'KACCHA'),
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w700,
                                            color: isPakka
                                                ? const Color(0xFF1D4ED8)
                                                : const Color(0xFF475569),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),

                                      // Payment Status Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3.5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusBg,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          statusText,
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w700,
                                            color: statusColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Details Body
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  _buildDetailRow(l10n?.customer ?? 'Customer', widget.customer),
                                  const SizedBox(height: 11),
                                  _buildDetailRow(l10n?.date ?? 'Date', widget.date),
                                  const SizedBox(height: 11),
                                  _buildDetailRow(
                                    l10n?.chooseBillType ?? 'Bill Type',
                                    isPakka
                                        ? (l10n?.pakkaBill ?? 'Pakka Bill (GST Invoice)')
                                        : (l10n?.kacchaBill ?? 'Kaccha Bill (Cash Memo)'),
                                  ),
                                  const SizedBox(height: 11),
                                  _buildDetailRow(
                                    l10n?.itemsQuantity ?? 'Items / Quantity',
                                    '$totalItemsCount ${l10n?.items ?? "Items"}'
                                    '${totalQty > 0 ? ' • $totalQty ${l10n?.units ?? "Units"}' : ''}',
                                  ),
                                  const SizedBox(height: 11),
                                  _buildDetailRow(
                                    l10n?.paymentMode ?? 'Payment Mode',
                                    widget.paymentMode.toUpperCase(),
                                  ),

                                  const SizedBox(height: 14),
                                  const Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: Color(0xFFF1F5F9),
                                  ),
                                  const SizedBox(height: 14),

                                  // Financial Breakdown
                                  _buildDetailRow(
                                    l10n?.subTotal ?? 'Taxable / Subtotal',
                                    '₹${_formatAmount(subTotal)}',
                                  ),
                                  if (isPakka && gstAmount > 0) ...[
                                    const SizedBox(height: 9),
                                    _buildDetailRow(
                                      l10n?.gstAmount ?? 'GST Amount',
                                      '+ ₹${_formatAmount(gstAmount)}',
                                      valueColor: const Color(0xFF0284C7),
                                    ),
                                  ],
                                  const SizedBox(height: 9),
                                  _buildDetailRow(
                                    l10n?.totalAmount ?? 'Total Amount',
                                    '₹${_formatAmount(totalAmount)}',
                                    isBold: true,
                                    fontSize: 15,
                                    valueColor: AppColors.textDark,
                                  ),
                                  const SizedBox(height: 9),
                                  _buildDetailRow(
                                    l10n?.amountPaid ?? 'Amount Paid',
                                    '₹${_formatAmount(amountPaid)}',
                                    valueColor: const Color(0xFF15803D),
                                    isBold: true,
                                  ),
                                  if (dueAmount > 0.01) ...[
                                    const SizedBox(height: 9),
                                    _buildDetailRow(
                                      l10n?.dueAmount ?? 'Due Balance',
                                      '₹${_formatAmount(dueAmount)}',
                                      valueColor: const Color(0xFFDC2626),
                                      isBold: true,
                                    ),
                                  ],
                                  if (bill?.pushedToTally != null) ...[
                                    const SizedBox(height: 9),
                                    _buildDetailRow(
                                      l10n?.tallySync ?? 'Tally Sync',
                                      bill!.pushedToTally == true
                                          ? (l10n?.pushedToTally ?? 'Pushed to Tally')
                                          : (l10n?.syncPending ?? 'Sync Pending'),
                                      valueColor: bill.pushedToTally == true
                                          ? const Color(0xFF15803D)
                                          : const Color(0xFF64748B),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // --- LINE ITEMS PREVIEW (Collapsible) ---
                      if ((widget.pdfData?.items.isNotEmpty ?? false) ||
                          (bill?.lines.isNotEmpty ?? false)) ...[
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() => _showLineItems = !_showLineItems);
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.inventory_2_outlined,
                                            size: 18,
                                            color: Color(0xFF64748B),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${l10n?.productsInBill ?? "Billed Items"} ($totalItemsCount)',
                                            style: const TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textBody,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Icon(
                                        _showLineItems
                                            ? Icons.keyboard_arrow_up_rounded
                                            : Icons.keyboard_arrow_down_rounded,
                                        size: 22,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (_showLineItems) ...[
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Color(0xFFF1F5F9),
                                ),
                                if (widget.pdfData?.items.isNotEmpty ?? false)
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    itemCount: widget.pdfData!.items.length,
                                    separatorBuilder: (_, _) => const Divider(
                                      height: 14,
                                      thickness: 0.8,
                                      color: Color(0xFFF8FAFC),
                                    ),
                                    itemBuilder: (context, idx) {
                                      final item = widget.pdfData!.items[idx];
                                      return Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.name,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.textBody,
                                                  ),
                                                ),
                                                Text(
                                                  '${l10n?.quantity ?? "Qty"}: ${item.quantity} • ${l10n?.rate ?? "Rate"}: ₹${_formatAmount(item.rate)}'
                                                  '${isPakka && item.gstPercent > 0 ? ' • GST ${item.gstPercent.toStringAsFixed(0)}%' : ''}',
                                                  style: const TextStyle(
                                                    fontSize: 11.5,
                                                    color: Color(0xFF94A3B8),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            '₹${_formatAmount(item.totalAmount)}',
                                            style: const TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  )
                                else if (bill?.lines.isNotEmpty ?? false)
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    itemCount: bill!.lines.length,
                                    separatorBuilder: (_, _) => const Divider(
                                      height: 14,
                                      thickness: 0.8,
                                      color: Color(0xFFF8FAFC),
                                    ),
                                    itemBuilder: (context, idx) {
                                      final line = bill.lines[idx];
                                      final lineTotal = line.lineTotal ?? (line.qty * line.rate);
                                      return Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${l10n?.products ?? "Product"} #${idx + 1}',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.textBody,
                                                  ),
                                                ),
                                                Text(
                                                  '${l10n?.quantity ?? "Qty"}: ${line.qty} • ${l10n?.rate ?? "Rate"}: ₹${_formatAmount(line.rate)}'
                                                  '${line.gstPercent != null && line.gstPercent! > 0 ? ' • GST ${line.gstPercent!.toStringAsFixed(0)}%' : ''}',
                                                  style: const TextStyle(
                                                    fontSize: 11.5,
                                                    color: Color(0xFF94A3B8),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            '₹${_formatAmount(lineTotal)}',
                                            style: const TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                const SizedBox(height: 6),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      if (_isProcessing) ...[
                        const Center(
                          child: SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Action Buttons Row (Print, Download, Share)
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionTile(
                              icon: Icons.print_rounded,
                              label: l10n?.print ?? 'Print',
                              onTap: _handlePrint,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildActionTile(
                              icon: Icons.file_download_outlined,
                              label: l10n?.download ?? 'Download',
                              onTap: _handleDownload,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildActionTile(
                              icon: Icons.share_outlined,
                              label: l10n?.share ?? 'Share',
                              onTap: _handleShare,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Fixed Bottom Button: Back To Dashboard
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => DashboardScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n?.backToDashboard ?? 'Back To Dashboard',
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 13.5,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
              color: valueColor ?? const Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: AppColors.primaryBlue),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textBody,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
