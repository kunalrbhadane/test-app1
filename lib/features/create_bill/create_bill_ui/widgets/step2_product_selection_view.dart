import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rk_plast/features/create_bill/controllers/create_bill_controller.dart';
import 'package:rk_plast/features/production/models/production_batch_model.dart';
import 'package:rk_plast/features/production/providers/production_provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_dropdown_field.dart';
import '../../../../core/widgets/custom_searchable_dropdown.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../models/selected_product_model.dart';

import '../../providers/size_master_provider.dart';
import 'selected_product_list_item.dart';

class Step2ProductSelectionView extends StatelessWidget {
  final CreateBillController controller;

  const Step2ProductSelectionView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer<CreateBillController>(
      builder: (context, ctrl, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- CARD 1: PRODUCT INPUT FORM ---
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Size Key Dropdown
                  Consumer<SizeMasterProvider>(
                    builder: (context, sizeProv, _) {
                      final availableSizes = sizeProv.availableSizes;
                      final selectedSize = sizeProv.selectedSizeKey;

                      return CustomDropdownField(
                        label: l10n?.sizeKey ?? 'Size Key',
                        hintText: availableSizes.isEmpty
                            ? (l10n?.noSizeKeysFound ?? 'No size keys found')
                            : (l10n?.selectSizeKey ?? 'Select Size Key'),
                        value: availableSizes.contains(selectedSize)
                            ? selectedSize
                            : null,
                        items: availableSizes,
                        onChanged: (val) {
                          ctrl.clearInputProduct();
                          sizeProv.selectSizeKey(
                            val,
                            companyId: ctrl.selectedCompanyId,
                          );
                          context.read<ProductionProvider>().fetchUniqueBatches(
                            companyId: ctrl.selectedCompanyId,
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 14),

                  // Product Dropdown
                  Consumer<SizeMasterProvider>(
                    builder: (context, sizeProv, _) {
                      final bottleNames = sizeProv.bottles
                          .map((b) => b.name)
                          .where((n) => n.trim().isNotEmpty)
                          .toSet()
                          .toList();
                      final currentValue =
                          bottleNames.contains(ctrl.selectedProduct)
                          ? ctrl.selectedProduct
                          : null;

                      return CustomDropdownField(
                        label: l10n?.selectProduct ?? 'Product',
                        hintText: sizeProv.isLoading
                            ? (l10n?.loadingProducts ?? 'Loading products...')
                            : (bottleNames.isEmpty
                                  ? (l10n?.noProductsFound ??
                                        'No products found')
                                  : (l10n?.selectProduct ?? 'Select Product')),
                        value: currentValue,
                        items: bottleNames,
                        onChanged: (val) {
                          if (val == null) {
                            ctrl.clearInputProduct();
                            return;
                          }
                          ctrl.selectProduct(val);
                          if (sizeProv.bottles.isNotEmpty) {
                            final match = sizeProv.bottles
                                .where((b) => b.name == val)
                                .toList();
                            if (match.isNotEmpty) {
                              final b = match.first;
                              ctrl.updateInputProduct(
                                id: b.id,
                                productId: b.productId,
                                name: b.name,
                                rate: b.salePrice > 0
                                    ? b.salePrice
                                    : b.purchasePrice,
                                hsnCode: b.hsnCode,
                                unit: b.unit,
                                gstPercent: b.gstPercent,
                                pcsPerBox: b.pcsPerBox,
                                packagingRuleKey: b.packagingRuleKey,
                                category: b.category,
                                currentStock: b.currentStock,
                              );
                            }
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 14),

                  // Batch Searchable Dropdown & Selection
                  Consumer2<SizeMasterProvider, ProductionProvider>(
                    builder: (context, sizeProv, prodProv, _) {
                      final selectedSize = sizeProv.selectedSizeKey;
                      final availableBatches =
                          (selectedSize != null && selectedSize.isNotEmpty)
                          ? prodProv.getBatchesForSizeKey(selectedSize)
                          : prodProv.batches;

                      ProductionBatchModel? matchedBatch;
                      if (ctrl.selectedBatchNumber != null &&
                          ctrl.selectedBatchNumber!.isNotEmpty) {
                        final found = availableBatches
                            .where(
                              (b) => b.batchNumber == ctrl.selectedBatchNumber,
                            )
                            .toList();
                        if (found.isNotEmpty) {
                          matchedBatch = found.first;
                        } else {
                          matchedBatch = ProductionBatchModel(
                            batchNumber: ctrl.selectedBatchNumber!,
                            sizeKey: selectedSize ?? '',
                          );
                        }
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomSearchableDropdown<ProductionBatchModel>(
                            label: 'Batch',
                            hintText: prodProv.isLoading
                                ? 'Loading batches...'
                                : (availableBatches.isEmpty
                                      ? 'No batches found'
                                      : 'Select Batch'),
                            searchHint: 'Search batch number...',
                            items: availableBatches,
                            value: matchedBatch,
                            itemLabel: (b) => b.batchNumber,
                            itemSubtitle: (b) =>
                                'Good: ${b.netGoodCount} • Size: ${b.sizeKey} • ${b.currentStage.isNotEmpty ? b.currentStage.toUpperCase() : 'FINISHED'}',
                            isLoading: prodProv.isLoading,
                            onChanged: (b) {
                              ctrl.selectBatchNumber(b?.batchNumber);
                            },
                          ),
                          if (matchedBatch != null &&
                              matchedBatch.batchNumber.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFBBF7D0),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 15,
                                    color: Color(0xFF16A34A),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Batch: ${matchedBatch.batchNumber} • Good Bottles: ${matchedBatch.netGoodCount}${matchedBatch.currentStage.isNotEmpty ? ' • Stage: ${matchedBatch.currentStage.toUpperCase()}' : ''}',
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF15803D),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 14),

                  // 1. Box Quantity Field with pieces get indicator below on right
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                ctrl.selectedProductPcsPerBox > 0
                                    ? ' Quantity'
                                    : (l10n?.quantity ?? 'Quantity'),
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF475569),
                                ),
                              ),
                              if (ctrl.selectedProductPcsPerBox > 0) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: const Color(0xFFBFDBFE),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '${ctrl.selectedProductPcsPerBox} pcs/box',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1D4ED8),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFCBD5E1),
                            width: 1.2,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Center(
                          child: TextFormField(
                            controller: ctrl.inputQuantityController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textBody,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              hintText: '0',
                              suffixText: ctrl.selectedProductPcsPerBox > 0
                                  ? 'boxes'
                                  : (ctrl.selectedProductUnit ?? 'units'),
                              suffixStyle: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (val) {
                              ctrl.setInputQuantityFromString(val);
                              if (ctrl.selectedProductCurrentStock > 0) {
                                final totalPcs = ctrl.totalPieces;
                                if (totalPcs >
                                    ctrl.selectedProductCurrentStock) {
                                  ScaffoldMessenger.of(context)
                                      .removeCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(
                                            Icons.warning_amber_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              'Stock limit exceeded! Only ${ctrl.selectedProductCurrentStock} ${ctrl.selectedProductUnit ?? 'units'} available.',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: const Color(0xFFEF4444),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ),

                      // Show below the box on the right side how many pieces get
                      if (ctrl.selectedProductPcsPerBox > 0) ...[
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFBBF7D0),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  size: 13,
                                  color: Color(0xFF16A34A),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '= ${ctrl.totalPieces} Pieces (${ctrl.inputQuantity} × ${ctrl.selectedProductPcsPerBox})',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF15803D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 2. Rate & GST Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rate Box
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n?.rate ?? 'Rate (₹ / unit)',
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFCBD5E1),
                                  width: 1.2,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Center(
                                child: TextFormField(
                                  controller: ctrl.inputRateController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d*'),
                                    ),
                                  ],
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                  ),
                                  decoration: const InputDecoration(
                                    prefixText: '₹ ',
                                    prefixStyle: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onChanged: (val) =>
                                      ctrl.setInputRateFromString(val),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // GST (%) Input (Only for Pakka Bill, for Kaccha bills keep balanced column or single)
                      if (ctrl.selectedBillType ==
                          CreateBillType.pakkaBill) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n?.gstRate ?? 'GST (%)',
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF475569),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFCBD5E1),
                                    width: 1.2,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Center(
                                  child: TextField(
                                    controller: ctrl.inputGstPercentController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark,
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '0',
                                      suffixText: '%',
                                      suffixStyle: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF64748B),
                                      ),
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    onChanged: (val) {
                                      ctrl.setInputGstPercent(
                                        double.tryParse(val) ?? 0.0,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 3. Amount Field Below
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFBBF7D0),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.calculate_outlined,
                              size: 19,
                              color: Color(0xFF16A34A),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n?.amount ?? 'Item Total Amount',
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF166534),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '₹${ctrl.inputTotalAmount.toStringAsFixed(ctrl.inputTotalAmount == ctrl.inputTotalAmount.roundToDouble() ? 0 : 2)}',
                          style: const TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF15803D),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // + Add More Product Button
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: ctrl.selectedProductId != null
                          ? ctrl.addProductToList
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFE2E8F0),
                        disabledForegroundColor: const Color(0xFF94A3B8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        l10n?.addProductToBill ?? '+ Add More Product',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- SECTION 2: SELECTED PRODUCTS ---
            Text(
              l10n?.addedProducts ?? 'Selected Products',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textBody,
                letterSpacing: -0.1,
              ),
            ),
            const SizedBox(height: 12),

            // Products List Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ctrl.selectedProductsList.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 28.0),
                      child: Center(
                        child: Text(
                          l10n?.noProductsAddedYet ?? 'No products added yet',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: ctrl.selectedProductsList.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFFF1F5F9),
                      ),
                      itemBuilder: (context, index) {
                        final item = ctrl.selectedProductsList[index];
                        return SelectedProductListItem(
                          item: item,
                          onIncrement: () {
                            final warning = ctrl.incrementProductQty(item.id);
                            if (warning != null) {
                              ScaffoldMessenger.of(context)
                                  .removeCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(
                                        Icons.warning_amber_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          warning,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: const Color(0xFFEF4444),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          },
                          onDecrement: () => ctrl.decrementProductQty(item.id),
                          onDelete: () => ctrl.removeProduct(item.id),
                          onEdit: () =>
                              _showEditProductDialog(context, ctrl, item),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  void _showEditProductDialog(
    BuildContext context,
    CreateBillController ctrl,
    SelectedProductItem item,
  ) {
    final qtyController = TextEditingController(text: '${item.quantity}');
    final rateController = TextEditingController(
      text: item.rate.toStringAsFixed(
        item.rate == item.rate.roundToDouble() ? 0 : 2,
      ),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final parsedQty = int.tryParse(qtyController.text.trim()) ?? 0;
            final parsedRate =
                double.tryParse(rateController.text.trim()) ?? 0.0;
            final previewTotal = parsedQty * parsedRate;

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom:
                    MediaQuery.of(bottomSheetContext).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (item.currentStock > 0)
                                Padding(
                                  padding: const EdgeInsets.only(top: 3.0),
                                  child: Text(
                                    'Available Stock: ${item.currentStock} ${item.unit ?? 'units'}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: parsedQty > item.currentStock
                                          ? const Color(0xFFEF4444)
                                          : const Color(0xFF059669),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(bottomSheetContext),
                          icon: const Icon(
                            Icons.close,
                            color: Color(0xFF64748B),
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const Divider(
                      height: 24,
                      thickness: 1,
                      color: Color(0xFFF1F5F9),
                    ),

                    // Edit Fields Row
                    Row(
                      children: [
                        // Quantity Field
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Quantity',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF475569),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color:
                                        (item.currentStock > 0 &&
                                            parsedQty > item.currentStock)
                                        ? const Color(0xFFEF4444)
                                        : const Color(0xFFCBD5E1),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: TextFormField(
                                  controller: qtyController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  onChanged: (_) => setModalState(() {}),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Rate Field
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Rate (₹)',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF475569),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFCBD5E1),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: TextFormField(
                                  controller: rateController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d*'),
                                    ),
                                  ],
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                  decoration: const InputDecoration(
                                    prefixText: '₹ ',
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  onChanged: (_) => setModalState(() {}),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Total Calculation Preview Banner
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Item Subtotal:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF166534),
                            ),
                          ),
                          Text(
                            '₹${previewTotal.toStringAsFixed(previewTotal == previewTotal.roundToDouble() ? 0 : 2)}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF15803D),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(bottomSheetContext),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final newQty =
                                  int.tryParse(qtyController.text.trim()) ??
                                  item.quantity;
                              final newRate =
                                  double.tryParse(rateController.text.trim()) ??
                                  item.rate;

                              Navigator.pop(bottomSheetContext);

                              final warning = ctrl.updateProductItem(
                                item.id,
                                quantity: newQty <= 0 ? 1 : newQty,
                                rate: newRate < 0 ? 0 : newRate,
                              );

                              if (warning != null) {
                                ScaffoldMessenger.of(context)
                                    .removeCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(
                                          Icons.warning_amber_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            warning,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: const Color(0xFFEF4444),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Update',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
