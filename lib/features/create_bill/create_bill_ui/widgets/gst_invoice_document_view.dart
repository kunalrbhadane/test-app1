import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/number_to_words_helper.dart';
import '../../../company/providers/company_provider.dart';
import '../../../customer/providers/customer_provider.dart';
import '../../../login/providers/auth_provider.dart';
import '../../controllers/create_bill_controller.dart';
import '../../models/discount_type.dart';
import '../../models/selected_product_model.dart';
import 'gst_cal.dart';

class GstInvoiceDocumentView extends StatefulWidget {
  final CreateBillController controller;

  const GstInvoiceDocumentView({super.key, required this.controller});

  @override
  State<GstInvoiceDocumentView> createState() => _GstInvoiceDocumentViewState();
}

class _GstInvoiceDocumentViewState extends State<GstInvoiceDocumentView> {
  final TransformationController _transformationController =
      TransformationController();
  double _currentScale = 1.0;
  TapDownDetails? _doubleTapDetails;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    setState(() {
      _currentScale = (_currentScale + 0.25).clamp(0.5, 3.5);
      _transformationController.value = Matrix4.diagonal3Values(
        _currentScale,
        _currentScale,
        1.0,
      );
    });
  }

  void _zoomOut() {
    setState(() {
      _currentScale = (_currentScale - 0.25).clamp(0.5, 3.5);
      _transformationController.value = Matrix4.diagonal3Values(
        _currentScale,
        _currentScale,
        1.0,
      );
    });
  }

  void _resetZoom() {
    setState(() {
      _currentScale = 1.0;
      _transformationController.value = Matrix4.identity();
    });
  }

  void _handleDoubleTap() {
    setState(() {
      if (_currentScale > 1.05) {
        _currentScale = 1.0;
        _transformationController.value = Matrix4.identity();
      } else {
        _currentScale = 2.0;
        final position = _doubleTapDetails?.localPosition ?? Offset.zero;
        final x = -position.dx * (_currentScale - 1);
        final y = -position.dy * (_currentScale - 1);
        _transformationController.value = Matrix4.identity()
          // ignore: deprecated_member_use
          ..translate(x, y)
          // ignore: deprecated_member_use
          ..scale(_currentScale);
      }
    });
  }

  Widget _buildZoomButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFCBD5E1)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF334155)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final companyProv = context.watch<CompanyProvider>();
    final customerProv = context.watch<CustomerProvider>();
    final authProv = context.watch<AuthProvider>();

    // 1. Resolve Company Details
    final userCompany =
        companyProv.selectedCompany ??
        (companyProv.companies.isNotEmpty ? companyProv.companies.first : null);

    final selectedCompId = controller.selectedCompanyId;
    final matchedCompany = selectedCompId != null && selectedCompId.isNotEmpty
        ? companyProv.companies.where((c) => c.id == selectedCompId).toList()
        : null;
    final activeCompany = (matchedCompany != null && matchedCompany.isNotEmpty)
        ? matchedCompany.first
        : userCompany;

    final companyName =
        controller.selectedFirm ?? activeCompany?.name ?? 'R. K. ENTERPRISES';
    final companyGstin = activeCompany?.gstNo ?? '';
    final companyAddress = [
      if (activeCompany?.address != null &&
          activeCompany!.address!.trim().isNotEmpty)
        activeCompany.address!.trim(),
      if (activeCompany?.city != null && activeCompany!.city!.trim().isNotEmpty)
        activeCompany.city!.trim(),
    ].join(', ');
    final companyRole =
        (activeCompany?.role != null && activeCompany!.role!.isNotEmpty)
        ? activeCompany.role!.toUpperCase().replaceAll('_', ' ')
        : (activeCompany?.shortCode ?? '');

    // 2. Resolve Customer Details
    final walkInText = controller.walkInNameController.text.trim();
    final selectedCustName = walkInText.isNotEmpty
        ? walkInText
        : (controller.selectedCustomer ??
              controller.customerNameController.text.trim());
    final matchedCustomer = customerProv.customers
        .where((c) => c.name.toLowerCase() == selectedCustName.toLowerCase())
        .toList();
    final activeCustomer = matchedCustomer.isNotEmpty
        ? matchedCustomer.first
        : null;

    final customerName = selectedCustName.isNotEmpty
        ? selectedCustName
        : 'Walk-in Customer';
    final customerAddress = activeCustomer?.address?.isNotEmpty == true
        ? activeCustomer!.address!
        : controller.customerAddressController.text.trim();
    final customerGstin = activeCustomer?.gstNo?.isNotEmpty == true
        ? activeCustomer!.gstNo!
        : controller.customerGstinController.text.trim();
    final customerCity = activeCustomer?.city?.isNotEmpty == true
        ? activeCustomer!.city!
        : controller.customerCityController.text.trim();
    final customerCode = activeCustomer?.customerId.isNotEmpty == true
        ? activeCustomer!.customerId
        : '-';
    final customerMobile = activeCustomer?.mobile?.isNotEmpty == true
        ? activeCustomer!.mobile!
        : controller.customerMobileController.text.trim();

    // 3. Invoice Meta
    final isPakka = controller.selectedBillType == CreateBillType.pakkaBill;
    final invoiceTitle = isPakka ? 'GST INVOICE' : 'CASH MEMO';
    final now = DateTime.now();
    final dateStr = _formatDate(now);
    final shortCode =
        activeCompany?.shortCode ?? userCompany?.shortCode ?? 'INV';
    final invoiceNo =
        '$shortCode/${now.year.toString().substring(2)}-${(now.year + 1).toString().substring(2)}/${now.millisecondsSinceEpoch.toString().substring(7)}';

    final paymentModeText = controller.selectedPaymentMode == PaymentMode.cash
        ? 'Cash'
        : controller.selectedPaymentMode == PaymentMode.credit
        ? 'Credit'
        : controller.selectedPaymentMode == PaymentMode.upi
        ? 'UPI'
        : 'Bank';

    final placeOfSupply = customerCity.isNotEmpty
        ? customerCity
        : (activeCompany?.city?.isNotEmpty == true
              ? activeCompany!.city!
              : '-');
    final billedBy = authProv.currentUser?.name.isNotEmpty == true
        ? authProv.currentUser!.name
        : 'Admin';

    // 4. Calculation Totals using GstCal
    final List<SelectedProductItem> items = controller.selectedProductsList;
    final gstCalc = GstCal.calculate(
      items: items,
      isPakka: isPakka,
      discountType: controller.discountType,
      discountRate: controller.discountRate,
    );

    final double subTotal = gstCalc.subTotal;
    final double totalGst = gstCalc.totalGst;
    final double discountAmount = gstCalc.discountAmount;
    final double grandTotal = gstCalc.grandTotal;
    final double amountReceived =
        double.tryParse(controller.amountReceivedController.text.trim()) ??
        grandTotal;
    final double dueAmount = (grandTotal - amountReceived).clamp(
      0.0,
      double.infinity,
    );

    final String amountInWords = grandTotal > 0
        ? NumberToWordsHelper.convert(grandTotal)
        : 'Zero Rupees Only';

    final distinctCategories = items
        .map((i) => i.category?.isNotEmpty == true ? i.category! : i.name)
        .where((c) => c.trim().isNotEmpty)
        .toSet()
        .take(4)
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Zoom Toolbar Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.zoom_in,
                            size: 14,
                            color: Color(0xFF0F172A),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${(_currentScale * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Double-tap / Pinch to zoom',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _buildZoomButton(
                      icon: Icons.remove,
                      tooltip: 'Zoom Out',
                      onTap: _zoomOut,
                    ),
                    const SizedBox(width: 6),
                    _buildZoomButton(
                      icon: Icons.refresh_rounded,
                      tooltip: 'Reset Fit',
                      onTap: _resetZoom,
                    ),
                    const SizedBox(width: 6),
                    _buildZoomButton(
                      icon: Icons.add,
                      tooltip: 'Zoom In',
                      onTap: _zoomIn,
                    ),
                  ],
                ),
              ),

              // Zoomable Invoice Content with Double-Tap & Pinch-to-Zoom
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(15),
                ),
                child: GestureDetector(
                  onDoubleTapDown: (details) => _doubleTapDetails = details,
                  onDoubleTap: _handleDoubleTap,
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    minScale: 1.0,
                    maxScale: 4.0,
                    panEnabled: true,
                    scaleEnabled: true,
                    clipBehavior: Clip.hardEdge,
                    boundaryMargin: const EdgeInsets.all(50),
                    onInteractionEnd: (_) {
                      final scale = _transformationController.value
                          .getMaxScaleOnAxis();
                      if (scale != _currentScale) {
                        setState(() {
                          _currentScale = scale;
                        });
                      }
                    },
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: 780,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ==========================================
                              // 1. TOP HEADER: LOGO + COMPANY & INVOICE DETAILS
                              // ==========================================
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Left: Logo & Details
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(
                                            'assets/images/logo.png',
                                            height: 52,
                                            errorBuilder: (_, __, ___) =>
                                                Container(
                                                  width: 48,
                                                  height: 48,
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFF0F3B82,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      companyName.isNotEmpty
                                                          ? companyName[0]
                                                                .toUpperCase()
                                                          : 'C',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontSize: 22,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                companyName.toUpperCase(),
                                                style: const TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.w900,
                                                  color: Color(0xFF0F3B82),
                                                  letterSpacing: 1.2,
                                                ),
                                              ),
                                              if (companyRole.isNotEmpty) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  companyRole,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF3B82F6),
                                                    letterSpacing: 1.5,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                      if (distinctCategories.isNotEmpty) ...[
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: distinctCategories.map((
                                            cat,
                                          ) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                right: 6.0,
                                              ),
                                              child: _buildPillTag(
                                                cat.toUpperCase(),
                                                const Color(0xFF0F3B82),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ],
                                  ),

                                  // Right: Invoice Title & Meta Table
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        invoiceTitle,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF0A2540),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFE2E8F0),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _buildMetaRow(
                                              'Invoice No.',
                                              invoiceNo,
                                            ),
                                            _buildMetaRow(
                                              'Invoice Date',
                                              dateStr,
                                            ),
                                            _buildMetaRow(
                                              'Place of Supply',
                                              placeOfSupply,
                                            ),
                                            _buildMetaRow(
                                              'Reverse Charge',
                                              'No',
                                            ),
                                            _buildMetaRow(
                                              'Invoice Type',
                                              isPakka
                                                  ? 'Tax Invoice'
                                                  : 'Cash Memo',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),

                              // ==========================================
                              // 2. 3 INFO CARDS: BILL TO, SHIP TO, OTHER DETAILS
                              // ==========================================
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Card 1: Bill To
                                  Expanded(
                                    child: _buildInfoCard(
                                      title: 'BILL TO',
                                      content: [
                                        Text(
                                          customerName,
                                          style: const TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        if (customerAddress.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            customerAddress,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF475569),
                                              height: 1.3,
                                            ),
                                          ),
                                        ],
                                        if (customerGstin.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Text(
                                            'GSTIN : $customerGstin',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                        ],
                                        if (customerCity.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            'City : $customerCity',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF475569),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Card 2: Ship To
                                  Expanded(
                                    child: _buildInfoCard(
                                      title: 'SHIP TO',
                                      content: [
                                        Text(
                                          customerName,
                                          style: const TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        if (customerAddress.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            customerAddress,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF475569),
                                              height: 1.3,
                                            ),
                                          ),
                                        ],
                                        if (customerGstin.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Text(
                                            'GSTIN : $customerGstin',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                        ],
                                        if (customerCity.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            'City : $customerCity',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF475569),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Card 3: Other Details
                                  Expanded(
                                    child: _buildInfoCard(
                                      title: 'OTHER DETAILS',
                                      content: [
                                        _buildMetaRow(
                                          'Customer Code',
                                          customerCode,
                                        ),
                                        _buildMetaRow(
                                          'Payment Mode',
                                          paymentModeText,
                                        ),
                                        _buildMetaRow('Due Date', dateStr),
                                        _buildMetaRow('Billed By', billedBy),
                                        if (customerMobile.isNotEmpty)
                                          _buildMetaRow(
                                            'Mobile',
                                            customerMobile,
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),

                              // ==========================================
                              // 3. PRODUCTS TABLE
                              // ==========================================
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(0xFFCBD5E1),
                                    width: 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: Column(
                                    children: [
                                      // Table Header
                                      Container(
                                        color: const Color(0xFF0B2B64),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 8,
                                        ),
                                        child: const Row(
                                          children: [
                                            _TableHeaderCell(
                                              'Sr.\nNo.',
                                              flex: 1,
                                            ),
                                            _TableHeaderCell(
                                              'Product Description',
                                              flex: 5,
                                              align: TextAlign.left,
                                            ),
                                            _TableHeaderCell(
                                              'HSN\nCode',
                                              flex: 2,
                                            ),
                                            _TableHeaderCell('Qty', flex: 2),
                                            _TableHeaderCell('Unit', flex: 2),
                                            _TableHeaderCell(
                                              'Rate\n(₹)',
                                              flex: 2,
                                            ),
                                            _TableHeaderCell('GST\n%', flex: 2),
                                            _TableHeaderCell(
                                              'Total (₹)',
                                              flex: 3,
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Table Rows
                                      if (items.isEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 24,
                                          ),
                                          child: const Center(
                                            child: Text(
                                              'No products added to this bill yet',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF94A3B8),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        )
                                      else
                                        ...List.generate(items.length, (index) {
                                          final item = items[index];
                                          final itemTaxable =
                                              item.rate * item.quantity;
                                          final itemGstPercent = isPakka
                                              ? (item.gstPercent > 0
                                                    ? item.gstPercent
                                                    : 0.0)
                                              : 0.0;
                                          final itemGrandTotal =
                                              itemTaxable +
                                              (itemTaxable *
                                                  itemGstPercent /
                                                  100);

                                          return Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Color(0xFFE2E8F0),
                                                  width: 1,
                                                ),
                                              ),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 9,
                                            ),
                                            child: Row(
                                              children: [
                                                _TableCell(
                                                  '${index + 1}',
                                                  flex: 1,
                                                ),
                                                _TableCell(
                                                  item.name,
                                                  flex: 5,
                                                  align: TextAlign.left,
                                                  isBold: true,
                                                ),
                                                _TableCell(
                                                  item.hsnCode?.isNotEmpty ==
                                                          true
                                                      ? item.hsnCode!
                                                      : '-',
                                                  flex: 2,
                                                ),
                                                _TableCell(
                                                  '${item.quantity}',
                                                  flex: 2,
                                                  isBold: true,
                                                ),
                                                _TableCell(
                                                  item.unit?.isNotEmpty == true
                                                      ? item.unit!
                                                      : 'NOS',
                                                  flex: 2,
                                                ),
                                                _TableCell(
                                                  item.rate.toStringAsFixed(2),
                                                  flex: 2,
                                                ),
                                                _TableCell(
                                                  isPakka
                                                      ? '${itemGstPercent.toStringAsFixed(0)}%'
                                                      : '0%',
                                                  flex: 2,
                                                ),
                                                _TableCell(
                                                  _formatCurrency(
                                                    itemGrandTotal,
                                                  ),
                                                  flex: 3,
                                                  isBold: true,
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // ==========================================
                              // 4. AMOUNT IN WORDS & TOTALS BLOCK
                              // ==========================================
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left: Amount in Words + Terms + Details
                                  Expanded(
                                    flex: 6,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Amount in Words
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF8FAFC),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFFE2E8F0),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Amount in Words:',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF1E3A8A),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                amountInWords,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF0F172A),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 12),

                                        // Terms & Conditions Card
                                        _buildInfoCard(
                                          title: 'TERMS & CONDITIONS',
                                          content: [
                                            const Text(
                                              '1. Goods once sold will not be taken back.',
                                              style: TextStyle(
                                                fontSize: 10.5,
                                                color: Color(0xFF475569),
                                              ),
                                            ),
                                            const Text(
                                              '2. Payment to be made within the due date.',
                                              style: TextStyle(
                                                fontSize: 10.5,
                                                color: Color(0xFF475569),
                                              ),
                                            ),
                                            Text(
                                              '3. Subject to ${activeCompany?.city?.isNotEmpty == true ? activeCompany!.city! : (customerCity.isNotEmpty ? customerCity : 'Local')} Jurisdiction only.',
                                              style: const TextStyle(
                                                fontSize: 10.5,
                                                color: Color(0xFF475569),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),

                                        // Company Reference Card
                                        _buildInfoCard(
                                          title: 'ISSUED BY',
                                          content: [
                                            _buildMetaRow(
                                              'Company',
                                              companyName,
                                            ),
                                            if (companyGstin.isNotEmpty)
                                              _buildMetaRow(
                                                'GSTIN',
                                                companyGstin,
                                              ),
                                            if (activeCompany?.city != null &&
                                                activeCompany!.city!.isNotEmpty)
                                              _buildMetaRow(
                                                'City',
                                                activeCompany.city!,
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Right: Tax Breakdown + Grand Total + Signature
                                  Expanded(
                                    flex: 5,
                                    child: Column(
                                      children: [
                                        // Tax & Total Box
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFFCBD5E1),
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              _buildSummaryLine(
                                                isPakka
                                                    ? 'Taxable Amount'
                                                    : 'Total Amount',
                                                '₹${_formatCurrency(subTotal)}',
                                              ),
                                              if (isPakka && totalGst > 0) ...[
                                                // _buildSummaryLine('CGST', '₹${_formatCurrency(cgst)}'),
                                                // _buildSummaryLine('SGST', '₹${_formatCurrency(sgst)}'),
                                                _buildSummaryLine(
                                                  'Total GST',
                                                  '₹${_formatCurrency(totalGst)}',
                                                ),
                                              ],
                                              if (discountAmount > 0) ...[
                                                _buildSummaryLine(
                                                  controller.discountType ==
                                                          DiscountType
                                                              .percentage
                                                      ? 'Discount (${controller.discountRate == controller.discountRate.roundToDouble() ? controller.discountRate.toInt() : controller.discountRate}%)'
                                                      : 'Discount (Flat)',
                                                  '-₹${_formatCurrency(discountAmount)}',
                                                  valueColor: const Color(
                                                    0xFF16A34A,
                                                  ),
                                                ),
                                              ],
                                              // Invoice Total Bar
                                              Container(
                                                color: const Color(0xFF0F3B82),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8,
                                                    ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    const Text(
                                                      'Invoice Total',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    Text(
                                                      '₹${_formatCurrency(grandTotal)}',
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              //_buildSummaryLine('Rounded Off', '₹0.00'),
                                              // Grand Total Green Bar
                                              Container(
                                                color: const Color(0xFFDCFCE7),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8,
                                                    ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    const Text(
                                                      'Grand Total',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        color: Color(
                                                          0xFF166534,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      '₹${_formatCurrency(grandTotal)}',
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        color: Color(
                                                          0xFF166534,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              _buildSummaryLine(
                                                'Amount Received',
                                                '₹${_formatCurrency(amountReceived)}',
                                                valueColor: const Color(
                                                  0xFF16A34A,
                                                ),
                                              ),
                                              _buildSummaryLine(
                                                'Remaining Amount',
                                                '₹${_formatCurrency(dueAmount)}',
                                                valueColor: dueAmount > 0
                                                    ? const Color(0xFFDC2626)
                                                    : const Color(0xFF16A34A),
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 18),

                                        // Signature Block
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              'For $companyName',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF0F172A),
                                              ),
                                            ),
                                            const SizedBox(height: 24),
                                            Container(
                                              width: 140,
                                              height: 1,
                                              color: const Color(0xFF94A3B8),
                                            ),
                                            const SizedBox(height: 4),
                                            const Text(
                                              'Authorized Signatory',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF475569),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // ==========================================
                              // 5. FOOTER: ADDRESS + GSTIN
                              // ==========================================
                              const Center(
                                child: Text(
                                  'Thank you for your business!',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.italic,
                                    color: Color(0xFF0F3B82),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Divider(
                                color: Color(0xFFE2E8F0),
                                thickness: 1,
                              ),
                              const SizedBox(height: 8),

                              // Dynamic Contact details row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (companyAddress.isNotEmpty)
                                    _buildFooterItem(
                                      Icons.location_on_rounded,
                                      companyAddress,
                                    )
                                  else
                                    const SizedBox.shrink(),
                                  if (companyGstin.isNotEmpty)
                                    Text(
                                      'GSTIN: $companyGstin',
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Helper Widgets ---

  static Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 95,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          const Text(
            ' :  ',
            style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildInfoCard({
    required String title,
    required List<Widget> content,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: const BoxDecoration(
              color: Color(0xFF0B2B64),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(9),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: content,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildSummaryLine(
    String label,
    String value, {
    Color? valueColor,
    FontWeight? fontWeight,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF475569),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: fontWeight ?? FontWeight.w700,
              color: valueColor ?? const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildPillTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  static Widget _buildFooterItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: const Color(0xFF0F3B82)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 10, color: Color(0xFF475569)),
        ),
      ],
    );
  }

  static String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
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
}

class _TableHeaderCell extends StatelessWidget {
  final String text;
  final int flex;
  final TextAlign align;

  const _TableHeaderCell(
    this.text, {
    required this.flex,
    this.align = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: align,
        style: const TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1.15,
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final int flex;
  final TextAlign align;
  final bool isBold;

  const _TableCell(
    this.text, {
    required this.flex,
    this.align = TextAlign.center,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          color: const Color(0xFF0F172A),
        ),
      ),
    );
  }
}
