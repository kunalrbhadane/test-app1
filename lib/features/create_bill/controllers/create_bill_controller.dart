import 'package:flutter/material.dart';
import '../create_bill_ui/widgets/gst_cal.dart';
import '../models/discount_type.dart';
import '../models/draft_bill_model.dart';
import '../models/selected_product_model.dart';

enum CreateBillType {
  pakkaBill,
  kacchaBill,
}

enum BillCustomerType {
  registered,
  walkIn,
}

enum PaymentMode {
  cash,
  credit,
  upi,
  bank,
}

class CreateBillController extends ChangeNotifier {
  String? currentDraftId;

  int _currentStep = 1;
  final int totalSteps = 5;

  int get currentStep => _currentStep;

  // Step 3 State: Discount
  DiscountType _discountType = DiscountType.percentage;
  double _discountRate = 0.0;
  final TextEditingController discountRateController = TextEditingController();

  DiscountType get discountType => _discountType;
  double get discountRate => _discountRate;

  void setDiscountType(DiscountType type) {
    if (_discountType != type) {
      _discountType = type;
      amountReceivedController.text = _formatAmount(grandTotalAmount);
      notifyListeners();
    }
  }

  void setDiscountRateFromString(String val) {
    final parsed = double.tryParse(val.trim());
    final newRate = (parsed != null && parsed >= 0) ? parsed : 0.0;
    if (_discountRate != newRate) {
      _discountRate = newRate;
      amountReceivedController.text = _formatAmount(grandTotalAmount);
      notifyListeners();
    }
  }

  void clearDiscount() {
    _discountRate = 0.0;
    discountRateController.clear();
    amountReceivedController.text = _formatAmount(grandTotalAmount);
    notifyListeners();
  }

  // Step 1 State: Firms & Customers
  final List<String> firms = const [];

  List<String> _customers = [];
  List<String> get customers => _customers;

  String? _selectedFirm;
  String? get selectedFirm => _selectedFirm;

  String? _selectedCompanyId;
  String? get selectedCompanyId => _selectedCompanyId;

  CreateBillType? _selectedBillType = CreateBillType.pakkaBill;
  CreateBillType? get selectedBillType => _selectedBillType;

  BillCustomerType _customerType = BillCustomerType.registered;
  BillCustomerType get customerType => _customerType;

  String? _selectedCustomer;
  String? get selectedCustomer => _selectedCustomer;

  bool _isAddingNewCustomer = false;
  bool get isAddingNewCustomer => _isAddingNewCustomer;

  final TextEditingController walkInNameController = TextEditingController();
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController customerContactPersonController =
      TextEditingController();
  final TextEditingController customerMobileController = TextEditingController();
  final TextEditingController customerGstinController = TextEditingController();
  final TextEditingController customerFssaiController = TextEditingController();
  final TextEditingController customerAddressController = TextEditingController();
  final TextEditingController customerCityController = TextEditingController();
  final TextEditingController customerCreditLimitController =
      TextEditingController(text: '0');
  final TextEditingController customerOpeningBalanceController =
      TextEditingController(text: '0');
  final TextEditingController customerOutstandingBalanceController =
      TextEditingController(text: '0');

  // Step 2 State: Products & Items
  final List<String> products = const [];

  String? _selectedProduct;
  String? _selectedProductId;
  String? _selectedProductCustomId;
  String? _selectedProductHsn;
  String? _selectedProductUnit;
  double _selectedProductGst = 0.0;
  int _selectedProductPcsPerBox = 0;
  String? _selectedProductRuleKey;
  String? _selectedProductCategory;
  int _selectedProductCurrentStock = 0;
  String? _selectedBatchNumber;

  final TextEditingController inputGstPercentController =
      TextEditingController(text: '0');
  final TextEditingController inputBoxCountController =
      TextEditingController(text: '1');
  final TextEditingController inputQuantityController =
      TextEditingController(text: '1');
  final TextEditingController inputRateController =
      TextEditingController(text: '0');

  String? get selectedProduct => _selectedProduct;
  String? get selectedProductId => _selectedProductId;
  String? get selectedProductCustomId => _selectedProductCustomId;
  String? get selectedProductHsn => _selectedProductHsn;
  String? get selectedProductUnit => _selectedProductUnit;
  double get selectedProductGst => _selectedProductGst;
  int get selectedProductPcsPerBox => _selectedProductPcsPerBox;
  String? get selectedProductRuleKey => _selectedProductRuleKey;
  String? get selectedProductCategory => _selectedProductCategory;
  int get selectedProductCurrentStock => _selectedProductCurrentStock;
  String? get selectedBatchNumber => _selectedBatchNumber;

  void selectBatchNumber(String? batch) {
    _selectedBatchNumber = batch;
    notifyListeners();
  }

  void setInputGstPercent(double gst) {
    _selectedProductGst = gst;
    notifyListeners();
  }

  int _inputBoxCount = 1;
  int get inputBoxCount => _inputBoxCount;

  int _inputQuantity = 1;
  int get inputQuantity => _inputQuantity;

  /// Total pieces calculated from entered box quantity:
  /// boxes * pcsPerBox (or 1 if pcsPerBox is 0)
  int get totalPieces {
    final multiplier = _selectedProductPcsPerBox > 0 ? _selectedProductPcsPerBox : 1;
    return _inputQuantity * multiplier;
  }

  double _inputRate = 0.0;
  double get inputRate => _inputRate;

  /// Item total amount based on total pieces: rate * totalPieces
  double get inputTotalAmount => _inputRate * totalPieces;

  void setInputQuantityFromString(String val) {
    final parsed = int.tryParse(val.trim());
    if (parsed != null && parsed >= 0) {
      _inputQuantity = parsed;
      _inputBoxCount = parsed;
      notifyListeners();
    } else if (val.trim().isEmpty) {
      _inputQuantity = 0;
      _inputBoxCount = 0;
      notifyListeners();
    }
  }

  void setInputRateFromString(String val) {
    final parsed = double.tryParse(val.trim());
    if (parsed != null && parsed >= 0) {
      _inputRate = parsed;
      notifyListeners();
    }
  }

  List<SelectedProductItem> _selectedProductsList = [];
  List<SelectedProductItem> get selectedProductsList => _selectedProductsList;

  // Step 4 State: Payment & Memo Note
  PaymentMode _selectedPaymentMode = PaymentMode.cash;
  PaymentMode get selectedPaymentMode => _selectedPaymentMode;

  final TextEditingController amountReceivedController =
      TextEditingController(text: '0');
  final TextEditingController paymentReferenceController =
      TextEditingController();
  final TextEditingController memoNoteController = TextEditingController();

  void nextStep() {
    if (_currentStep < totalSteps) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 1) {
      _currentStep--;
      notifyListeners();
    }
  }

  void selectFirm(String? firm, {String? companyId}) {
    _selectedFirm = firm;
    if (companyId != null) {
      _selectedCompanyId = companyId;
    }
    _selectedCustomer = null;
    notifyListeners();
  }

  String _formatAmount(double amount) {
    final rounded = (amount * 100.0).round() / 100.0;
    return rounded == rounded.roundToDouble()
        ? rounded.toInt().toString()
        : rounded.toStringAsFixed(2);
  }

  void payFullAmount() {
    amountReceivedController.text = _formatAmount(grandTotalAmount);
    notifyListeners();
  }

  void selectBillType(CreateBillType type) {
    _selectedBillType = type;
    amountReceivedController.text = _formatAmount(grandTotalAmount);
    notifyListeners();
  }

  void setCustomerType(BillCustomerType type) {
    if (_customerType == type) return;
    _customerType = type;
    if (type == BillCustomerType.walkIn) {
      _selectedCustomer = null;
      _isAddingNewCustomer = false;
    } else {
      walkInNameController.clear();
    }
    notifyListeners();
  }

  void selectCustomer(String? customer) {
    _selectedCustomer = customer;
    notifyListeners();
  }

  void toggleAddNewCustomer(bool isAdding) {
    _isAddingNewCustomer = isAdding;
    notifyListeners();
  }

  void clearCustomerForm() {
    customerNameController.clear();
    customerContactPersonController.clear();
    customerMobileController.clear();
    customerGstinController.clear();
    customerFssaiController.clear();
    customerAddressController.clear();
    customerCityController.clear();
    customerCreditLimitController.text = '0';
    customerOpeningBalanceController.text = '0';
    customerOutstandingBalanceController.text = '0';
  }

  void saveNewCustomer() {
    final name = customerNameController.text.trim();
    if (name.isNotEmpty) {
      _customers = [..._customers, name];
      _selectedCustomer = name;
    }
    clearCustomerForm();
    _isAddingNewCustomer = false;
    notifyListeners();
  }

  // Step 2 Methods
  void selectProduct(String? product) {
    _selectedProduct = product;
    notifyListeners();
  }

  /// Increments input quantity. Returns null on success, or a warning
  /// message string if the stock limit would be exceeded.
  String? incrementInputQty() {
    final currentQty = int.tryParse(inputQuantityController.text.trim()) ?? _inputQuantity;
    if (_selectedProductCurrentStock > 0 && currentQty >= _selectedProductCurrentStock) {
      return 'Stock limit reached! Only $_selectedProductCurrentStock ${_selectedProductUnit ?? 'units'} available.';
    }
    _inputQuantity = currentQty + 1;
    inputQuantityController.text = _inputQuantity.toString();
    notifyListeners();
    return null;
  }

  void decrementInputQty() {
    final currentQty = int.tryParse(inputQuantityController.text.trim()) ?? _inputQuantity;
    if (currentQty > 1) {
      _inputQuantity = currentQty - 1;
      inputQuantityController.text = _inputQuantity.toString();
      notifyListeners();
    }
  }

  void updateInputProduct({
    required String id,
    String? productId,
    required String name,
    required double rate,
    String? hsnCode,
    String? unit,
    double gstPercent = 0.0,
    int pcsPerBox = 0,
    String? packagingRuleKey,
    String? category,
    int currentStock = 0,
  }) {
    _selectedProductId = id;
    _selectedProductCustomId = productId;
    _selectedProduct = name;
    _inputRate = rate;
    inputRateController.text = rate == rate.roundToDouble()
        ? rate.toInt().toString()
        : rate.toStringAsFixed(2);
    _selectedProductPcsPerBox = pcsPerBox;
    _inputBoxCount = 1;
    inputBoxCountController.text = '1';
    _inputQuantity = 1;
    inputQuantityController.text = '1';
    _selectedProductHsn = hsnCode;
    _selectedProductUnit = unit;
    _selectedProductGst = gstPercent;
    inputGstPercentController.text = _selectedProductGst == _selectedProductGst.roundToDouble()
        ? _selectedProductGst.toInt().toString()
        : _selectedProductGst.toString();
    _selectedProductRuleKey = packagingRuleKey;
    _selectedProductCategory = category;
    _selectedProductCurrentStock = currentStock;
    notifyListeners();
  }

  void clearInputProduct() {
    _selectedProductId = null;
    _selectedProductCustomId = null;
    _selectedProduct = null;
    _selectedProductHsn = null;
    _selectedProductUnit = null;
    _selectedProductGst = 0.0;
    inputGstPercentController.text = '0';
    _selectedProductPcsPerBox = 0;
    _selectedProductRuleKey = null;
    _selectedProductCategory = null;
    _selectedProductCurrentStock = 0;
    _selectedBatchNumber = null;
    _inputRate = 0.0;
    inputRateController.text = '0';
    _inputBoxCount = 1;
    inputBoxCountController.text = '1';
    _inputQuantity = 1;
    inputQuantityController.text = '1';
    notifyListeners();
  }

  void addProductToList() {
    final name = _selectedProduct;
    final prodId = _selectedProductId;
    if (name == null || prodId == null) {
      return;
    }
    final enteredBoxes = int.tryParse(inputQuantityController.text.trim()) ?? _inputQuantity;
    final multiplier = _selectedProductPcsPerBox > 0 ? _selectedProductPcsPerBox : 1;
    final qtyPieces = enteredBoxes * multiplier;
    final rate = double.tryParse(inputRateController.text.trim()) ?? _inputRate;
    final parsedGst = double.tryParse(inputGstPercentController.text.trim()) ?? _selectedProductGst;
    final effectiveGst = _selectedBillType == CreateBillType.pakkaBill ? parsedGst : 0.0;

    final existingIndex =
        _selectedProductsList.indexWhere((item) => item.id == prodId);

    if (existingIndex != -1) {
      final existing = _selectedProductsList[existingIndex];
      final newQty = existing.quantity + qtyPieces;
      final updatedItem = existing.copyWith(
        quantity: newQty,
        rate: rate,
        totalAmount: rate * newQty,
        gstPercent: effectiveGst,
        batchNumber: _selectedBatchNumber ?? existing.batchNumber,
      );
      final updatedList = List<SelectedProductItem>.from(_selectedProductsList);
      updatedList[existingIndex] = updatedItem;
      _selectedProductsList = updatedList;
    } else {
      final newItem = SelectedProductItem(
        id: prodId,
        productId: _selectedProductCustomId,
        name: name,
        quantity: qtyPieces,
        rate: rate,
        totalAmount: rate * qtyPieces,
        hsnCode: _selectedProductHsn,
        unit: _selectedProductUnit,
        gstPercent: effectiveGst,
        pcsPerBox: _selectedProductPcsPerBox,
        packagingRuleKey: _selectedProductRuleKey,
        category: _selectedProductCategory,
        currentStock: _selectedProductCurrentStock,
        batchNumber: _selectedBatchNumber,
      );
      _selectedProductsList = [..._selectedProductsList, newItem];
    }

    clearInputProduct();
    amountReceivedController.text = _formatAmount(grandTotalAmount);
    notifyListeners();
  }

  String? updateProductItem(String id, {int? quantity, double? rate}) {
    String? warning;
    _selectedProductsList = _selectedProductsList.map((item) {
      if (item.id == id) {
        final newQty = (quantity != null && quantity > 0) ? quantity : item.quantity;
        final newRate = (rate != null && rate >= 0) ? rate : item.rate;
        if (item.currentStock > 0 && newQty > item.currentStock) {
          warning =
              'Entered quantity ($newQty) exceeds available stock of ${item.currentStock} ${item.unit ?? 'units'}.';
        }
        return item.copyWith(
          quantity: newQty,
          rate: newRate,
          totalAmount: newRate * newQty,
        );
      }
      return item;
    }).toList();
    amountReceivedController.text = _formatAmount(grandTotalAmount);
    notifyListeners();
    return warning;
  }

  /// Increments product quantity. Returns null on success, or a warning
  /// message string if the stock limit has been reached.
  String? incrementProductQty(String id) {
    String? stockWarning;
    _selectedProductsList = _selectedProductsList.map((item) {
      if (item.id == id) {
        if (item.currentStock > 0 && item.quantity >= item.currentStock) {
          stockWarning =
              'Stock limit reached! Only ${item.currentStock} ${item.unit ?? 'units'} of "${item.name}" available.';
          return item;
        }
        final newQty = item.quantity + 1;
        return item.copyWith(
          quantity: newQty,
          totalAmount: item.rate * newQty,
        );
      }
      return item;
    }).toList();
    amountReceivedController.text = _formatAmount(grandTotalAmount);
    notifyListeners();
    return stockWarning;
  }

  void decrementProductQty(String id) {
    _selectedProductsList = _selectedProductsList.map((item) {
      if (item.id == id && item.quantity > 1) {
        final newQty = item.quantity - 1;
        return item.copyWith(
          quantity: newQty,
          totalAmount: item.rate * newQty,
        );
      }
      return item;
    }).toList();
    amountReceivedController.text = _formatAmount(grandTotalAmount);
    notifyListeners();
  }

  void removeProduct(String id) {
    _selectedProductsList =
        _selectedProductsList.where((item) => item.id != id).toList();
    amountReceivedController.text = _formatAmount(grandTotalAmount);
    notifyListeners();
  }

  // Step 4 Methods
  void selectPaymentMode(PaymentMode mode) {
    _selectedPaymentMode = mode;
    notifyListeners();
  }

  int get totalItemsCount => _selectedProductsList.length;

  int get totalQuantityCount {
    if (_selectedProductsList.isEmpty) return 0;
    return _selectedProductsList.fold<int>(
      0,
      (prev, element) => prev + element.quantity,
    );
  }

  GstCalculationResult get gstCalculation {
    final isPakka = _selectedBillType == CreateBillType.pakkaBill;
    return GstCal.calculate(
      items: _selectedProductsList,
      isPakka: isPakka,
      discountType: _discountType,
      discountRate: _discountRate,
    );
  }

  double get subTotalAmount => gstCalculation.subTotal;
  double get cgstAmount => gstCalculation.cgst;
  double get sgstAmount => gstCalculation.sgst;
  double get totalGstAmount => gstCalculation.totalGst;
  double get totalBeforeDiscountAmount => gstCalculation.totalBeforeDiscount;
  double get discountAmount => gstCalculation.discountAmount;
  double get grandTotalAmount => gstCalculation.grandTotal;
  double get totalAmountSum => grandTotalAmount;

  DraftBillModel toDraftModel() {
    currentDraftId ??= 'draft_${DateTime.now().millisecondsSinceEpoch}';
    return DraftBillModel(
      id: currentDraftId!,
      currentStep: _currentStep,
      selectedFirm: _selectedFirm,
      selectedCompanyId: _selectedCompanyId,
      selectedBillType: _selectedBillType == CreateBillType.kacchaBill ? 'kaccha' : 'pakka',
      selectedCustomer: _selectedCustomer,
      walkInName: walkInNameController.text.trim().isNotEmpty
          ? walkInNameController.text.trim()
          : null,
      isAddingNewCustomer: _isAddingNewCustomer,
      customerName: customerNameController.text.trim(),
      customerContactPerson: customerContactPersonController.text.trim(),
      customerMobile: customerMobileController.text.trim(),
      customerGstin: customerGstinController.text.trim(),
      customerFssai: customerFssaiController.text.trim(),
      customerAddress: customerAddressController.text.trim(),
      customerCity: customerCityController.text.trim(),
      customerCreditLimit: customerCreditLimitController.text.trim(),
      customerOpeningBalance: customerOpeningBalanceController.text.trim(),
      customerOutstandingBalance: customerOutstandingBalanceController.text.trim(),
      products: List<SelectedProductItem>.from(_selectedProductsList),
      selectedPaymentMode: _selectedPaymentMode.name,
      amountReceived: amountReceivedController.text.trim(),
      paymentReference: paymentReferenceController.text.trim(),
      memoNote: memoNoteController.text.trim(),
      discountType: _discountType.value,
      discountRate: _discountRate,
      savedAt: DateTime.now(),
    );
  }

  void loadFromDraft(DraftBillModel draft) {
    currentDraftId = draft.id;
    _currentStep = draft.currentStep.clamp(1, totalSteps);
    _selectedFirm = draft.selectedFirm;
    _selectedCompanyId = draft.selectedCompanyId;
    _selectedBillType = draft.selectedBillType == 'kaccha'
        ? CreateBillType.kacchaBill
        : CreateBillType.pakkaBill;
    _selectedCustomer = draft.selectedCustomer;
    walkInNameController.text = draft.walkInName ?? '';
    _customerType = (draft.walkInName != null && draft.walkInName!.isNotEmpty)
        ? BillCustomerType.walkIn
        : BillCustomerType.registered;
    _isAddingNewCustomer = draft.isAddingNewCustomer;
    customerNameController.text = draft.customerName ?? '';
    customerContactPersonController.text = draft.customerContactPerson ?? '';
    customerMobileController.text = draft.customerMobile ?? '';
    customerGstinController.text = draft.customerGstin ?? '';
    customerFssaiController.text = draft.customerFssai ?? '';
    customerAddressController.text = draft.customerAddress ?? '';
    customerCityController.text = draft.customerCity ?? '';
    customerCreditLimitController.text = draft.customerCreditLimit ?? '0';
    customerOpeningBalanceController.text = draft.customerOpeningBalance ?? '0';
    customerOutstandingBalanceController.text = draft.customerOutstandingBalance ?? '0';

    clearInputProduct();
    _selectedProductsList = List<SelectedProductItem>.from(draft.products);

    _selectedPaymentMode = PaymentMode.values.firstWhere(
      (e) => e.name == draft.selectedPaymentMode,
      orElse: () => PaymentMode.cash,
    );

    _discountType = DiscountType.fromString(draft.discountType);
    _discountRate = draft.discountRate;
    discountRateController.text = _discountRate > 0
        ? (_discountRate == _discountRate.roundToDouble()
            ? _discountRate.toInt().toString()
            : _discountRate.toString())
        : '';

    if (draft.amountReceived != null && draft.amountReceived!.isNotEmpty) {
      amountReceivedController.text = draft.amountReceived!;
    } else {
      amountReceivedController.text = _formatAmount(grandTotalAmount);
    }
    paymentReferenceController.text = draft.paymentReference ?? '';
    memoNoteController.text = draft.memoNote ?? '';

    notifyListeners();
  }

  void resetAll() {
    currentDraftId = null;
    _currentStep = 1;
    _selectedFirm = null;
    _selectedCompanyId = null;
    _selectedCustomer = null;
    _customerType = BillCustomerType.registered;
    _selectedBillType = CreateBillType.pakkaBill;
    _isAddingNewCustomer = false;
    walkInNameController.clear();
    clearCustomerForm();
    clearInputProduct();
    _selectedProductsList = [];
    _selectedPaymentMode = PaymentMode.cash;
    amountReceivedController.text = '0';
    paymentReferenceController.clear();
    memoNoteController.clear();
    _discountType = DiscountType.percentage;
    _discountRate = 0.0;
    discountRateController.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    walkInNameController.dispose();
    customerNameController.dispose();
    customerContactPersonController.dispose();
    customerMobileController.dispose();
    customerGstinController.dispose();
    customerFssaiController.dispose();
    customerAddressController.dispose();
    customerCityController.dispose();
    customerCreditLimitController.dispose();
    customerOpeningBalanceController.dispose();
    customerOutstandingBalanceController.dispose();

    inputGstPercentController.dispose();
    inputBoxCountController.dispose();
    inputQuantityController.dispose();
    inputRateController.dispose();
    amountReceivedController.dispose();
    paymentReferenceController.dispose();
    memoNoteController.dispose();
    discountRateController.dispose();
    super.dispose();
  }
}
