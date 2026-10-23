import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rk_plast/features/create_bill/controllers/create_bill_controller.dart';
import 'package:rk_plast/features/customer/providers/customer_provider.dart';
import '../../../company/providers/company_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../l10n/generated/app_localizations.dart';

class AddCustomerForm extends StatefulWidget {
  final CreateBillController controller;

  const AddCustomerForm({
    super.key,
    required this.controller,
  });

  @override
  State<AddCustomerForm> createState() => _AddCustomerFormState();
}

class _AddCustomerFormState extends State<AddCustomerForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final name = widget.controller.customerNameController.text.trim();
    final contactPerson =
        widget.controller.customerContactPersonController.text.trim();
    final mobile = widget.controller.customerMobileController.text.trim();
    final gstNo = widget.controller.customerGstinController.text.trim();
    final address = widget.controller.customerAddressController.text.trim();
    final city = widget.controller.customerCityController.text.trim();
    final creditLimit =
        double.tryParse(widget.controller.customerCreditLimitController.text.trim()) ?? 0.0;
    final openingBalance =
        double.tryParse(widget.controller.customerOpeningBalanceController.text.trim()) ?? 0.0;
    final outstandingBalance =
        double.tryParse(widget.controller.customerOutstandingBalanceController.text.trim()) ??
            openingBalance;

    setState(() => _isSubmitting = true);

    try {
      final customerProv = context.read<CustomerProvider>();
      final companyProv = context.read<CompanyProvider>();
      final companyId = widget.controller.selectedCompanyId ??
          companyProv.selectedCompany?.id ??
          '';

      final created = await customerProv.createCustomer(
        companyId: companyId.isNotEmpty ? companyId : null,
        name: name,
        contactPerson: contactPerson.isNotEmpty ? contactPerson : null,
        mobile: mobile.isNotEmpty ? mobile : null,
        gstNo: gstNo.isNotEmpty ? gstNo : null,
        address: address.isNotEmpty ? address : null,
        city: city.isNotEmpty ? city : null,
        creditLimit: creditLimit,
        openingBalance: openingBalance,
        outstandingBalance: outstandingBalance,
      );

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        widget.controller.selectCustomer(created.name);
        widget.controller.clearCustomerForm();
        widget.controller.toggleAddNewCustomer(false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.customerAddedSuccess ?? 'Customer created successfully!'),
            backgroundColor: const Color(0xFF10B981),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = e.toString();
        if (errorMsg.startsWith('Exception: ')) {
          errorMsg = errorMsg.substring('Exception: '.length);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header Row with Title & Close Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n?.addNewCustomerTitle ?? 'Add New Customer',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  widget.controller.clearCustomerForm();
                  widget.controller.toggleAddNewCustomer(false);
                },
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 1. Customer Name (Mandatory)
          CustomTextField(
            label: '${l10n?.customerName ?? "Customer Name"} *',
            hintText: l10n?.enterCustomerName ?? 'Enter Customer Name',
            controller: widget.controller.customerNameController,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n?.pleaseSelectCustomerFirst ?? 'Customer Name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),

          // 1b. Contact Person
          CustomTextField(
            label: 'Contact Person',
            hintText: 'Enter Contact Person Name',
            controller: widget.controller.customerContactPersonController,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),

          // 2. Mobile (Mandatory) & GSTIN Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomTextField(
                  label: '${l10n?.customerPhone ?? "Mobile"} *',
                  hintText: l10n?.enterTenDigitMobile ?? 'Enter Mobile',
                  controller: widget.controller.customerMobileController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n?.pleaseEnterContactNo ?? 'Mobile is required';
                    }
                    if (value.trim().length < 10) {
                      return l10n?.enterValidMobile ?? 'Enter valid 10 digits';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  label: l10n?.customerGst ?? 'GSTIN',
                  hintText: l10n?.enterGstNumber ?? 'Enter GSTIN',
                  controller: widget.controller.customerGstinController,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(15),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 3. Billing Address (Mandatory)
          CustomTextField(
            label: '${l10n?.customerAddress ?? "Billing Address"} *',
            hintText: l10n?.enterAddress ?? 'Enter Billing Address',
            controller: widget.controller.customerAddressController,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n?.enterAddress ?? 'Billing Address is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),

          // 4. City
          CustomTextField(
            label: l10n?.customerCity ?? 'City',
            hintText: l10n?.enterCity ?? 'Enter City',
            controller: widget.controller.customerCityController,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),

          // 5. Credit Limit
          CustomTextField(
            label: l10n?.credit ?? 'Credit Limit',
            hintText: '0',
            controller: widget.controller.customerCreditLimitController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          const SizedBox(height: 14),

          // 6. Opening Balance & Outstanding Balance Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomTextField(
                  label: l10n?.openingBalance ?? 'Opening Balance',
                  hintText: '0',
                  controller: widget.controller.customerOpeningBalanceController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  label: l10n?.dueAmount ?? 'Outstanding Balance',
                  hintText: '0',
                  controller: widget.controller.customerOutstandingBalanceController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Action Buttons Row (Cancel & Save Customer)
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: OutlinedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            widget.controller.clearCustomerForm();
                            widget.controller.toggleAddNewCustomer(false);
                          },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFFCBD5E1),
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      l10n?.cancel ?? 'Cancel',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            l10n?.saveCustomer ?? 'Save Customer',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
