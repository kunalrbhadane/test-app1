import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../company/models/company_model.dart';
import '../../../home/models/bill_model.dart';
import '../../services/sales_report_export_service.dart';

class ExportSalesSheet extends StatefulWidget {
  final List<BillModel> bills;
  final CompanyModel? company;
  final String selectedFilter;

  const ExportSalesSheet({
    super.key,
    required this.bills,
    this.company,
    required this.selectedFilter,
  });

  static Future<void> show(
    BuildContext context, {
    required List<BillModel> bills,
    CompanyModel? company,
    required String selectedFilter,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ExportSalesSheet(
        bills: bills,
        company: company,
        selectedFilter: selectedFilter,
      ),
    );
  }

  @override
  State<ExportSalesSheet> createState() => _ExportSalesSheetState();
}

class _ExportSalesSheetState extends State<ExportSalesSheet> {
  bool _isProcessing = false;
  String _processingAction = '';

  double get _totalSales =>
      widget.bills.fold(0.0, (sum, b) => sum + b.amount);
  double get _totalDue =>
      widget.bills.fold(0.0, (sum, b) => sum + b.dueAmount);

  Future<void> _handleAction(String actionName, Future<void> Function() action) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _processingAction = actionName;
    });

    try {
      await action();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: const Color(0xFFEF4444),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _processingAction = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final companyName = widget.company?.name.isNotEmpty == true
        ? widget.company!.name
        : l10n.activeFirm;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.ios_share_rounded,
                    color: AppColors.primaryBlue,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.exportSalesRecords,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${l10n.company}: $companyName',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, size: 22),
                color: const Color(0xFF94A3B8),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Summary Overview Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetricChip(l10n.totalInvoices, '${widget.bills.length}'),
                    _buildMetricChip('Filter', widget.selectedFilter),
                    _buildMetricChip(
                      l10n.totalSales,
                      '₹${_formatCurrency(_totalSales)}',
                      valueColor: AppColors.primaryBlue,
                    ),
                    _buildMetricChip(
                      l10n.totalDue,
                      '₹${_formatCurrency(_totalDue)}',
                      valueColor: _totalDue > 0 ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Processing State Banner
          if (_isProcessing) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Generating $_processingAction... Please wait',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1D4ED8),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Action 1: Print PDF Report
          _buildActionCard(
            title: l10n.printPreview,
            subtitle: 'Open full-page landscape layout for instant printing or preview',
            icon: Icons.print_rounded,
            iconBg: const Color(0xFFEFF6FF),
            iconColor: const Color(0xFF2563EB),
            onTap: widget.bills.isEmpty
                ? null
                : () => _handleAction(
                      'Print Preview',
                      () => SalesReportExportService.printReport(
                        bills: widget.bills,
                        company: widget.company,
                        filter: widget.selectedFilter,
                      ),
                    ),
          ),
          const SizedBox(height: 10),

          // Action 2: Share / Save PDF Document
          _buildActionCard(
            title: l10n.sharePdf,
            subtitle: 'Share formatted PDF via WhatsApp, Email, or Save to Downloads',
            icon: Icons.picture_as_pdf_rounded,
            iconBg: const Color(0xFFFEE2E2),
            iconColor: const Color(0xFFDC2626),
            onTap: widget.bills.isEmpty
                ? null
                : () => _handleAction(
                      'PDF Document',
                      () => SalesReportExportService.sharePdf(
                        bills: widget.bills,
                        company: widget.company,
                        filter: widget.selectedFilter,
                      ),
                    ),
          ),
          const SizedBox(height: 10),

          // Action 3: Export to CSV / Excel
          _buildActionCard(
            title: l10n.exportSpreadsheet,
            subtitle: 'Export structured spreadsheet table with all line items and metrics',
            icon: Icons.table_chart_rounded,
            iconBg: const Color(0xFFDCFCE7),
            iconColor: const Color(0xFF16A34A),
            onTap: widget.bills.isEmpty
                ? null
                : () => _handleAction(
                      'CSV Spreadsheet',
                      () => SalesReportExportService.exportCsv(
                        context,
                        bills: widget.bills,
                        company: widget.company,
                        filter: widget.selectedFilter,
                      ),
                    ),
          ),

          if (widget.bills.isEmpty) ...[
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'No sales records available to export for this selection.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricChip(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required VoidCallback? onTap,
  }) {
    final bool isDisabled = onTap == null || _isProcessing;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isDisabled ? const Color(0xFFF8FAFC) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1.1,
            ),
            boxShadow: [
              if (!isDisabled)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(icon, color: iconColor, size: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: isDisabled ? const Color(0xFF94A3B8) : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: isDisabled ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDisabled ? const Color(0xFFCBD5E1) : const Color(0xFF94A3B8),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
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
