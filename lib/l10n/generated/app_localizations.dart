import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_mr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('mr'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'R.K. Plast'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @sales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get sales;

  /// No description provided for @returns.
  ///
  /// In en, this message translates to:
  /// **'Returns'**
  String get returns;

  /// No description provided for @customers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @loginToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage your billing & stock'**
  String get loginToContinue;

  /// No description provided for @getStartedNow.
  ///
  /// In en, this message translates to:
  /// **'Get Started now'**
  String get getStartedNow;

  /// No description provided for @logInToExplore.
  ///
  /// In en, this message translates to:
  /// **'log in to explore about our app'**
  String get logInToExplore;

  /// No description provided for @emailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Email or Phone'**
  String get emailOrPhone;

  /// No description provided for @contactNo.
  ///
  /// In en, this message translates to:
  /// **'Contact No'**
  String get contactNo;

  /// No description provided for @enterContactNo.
  ///
  /// In en, this message translates to:
  /// **'Enter Contact Number'**
  String get enterContactNo;

  /// No description provided for @enterTenDigitMobile.
  ///
  /// In en, this message translates to:
  /// **'Enter 10-digit mobile number'**
  String get enterTenDigitMobile;

  /// No description provided for @pleaseEnterContactNo.
  ///
  /// In en, this message translates to:
  /// **'Please enter contact number'**
  String get pleaseEnterContactNo;

  /// No description provided for @enterValidMobile.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 10-digit mobile number'**
  String get enterValidMobile;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get enterPassword;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get pleaseEnterPassword;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get login;

  /// No description provided for @loggingIn.
  ///
  /// In en, this message translates to:
  /// **'Signing In...'**
  String get loggingIn;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email or phone'**
  String get enterValidEmail;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @availableStock.
  ///
  /// In en, this message translates to:
  /// **'Available Stock'**
  String get availableStock;

  /// No description provided for @liveInventory.
  ///
  /// In en, this message translates to:
  /// **'Live Inventory'**
  String get liveInventory;

  /// No description provided for @totalInvoices.
  ///
  /// In en, this message translates to:
  /// **'Total Invoices'**
  String get totalInvoices;

  /// No description provided for @totalSales.
  ///
  /// In en, this message translates to:
  /// **'Total Sales'**
  String get totalSales;

  /// No description provided for @totalStock.
  ///
  /// In en, this message translates to:
  /// **'Total Stock'**
  String get totalStock;

  /// No description provided for @lowStockAlert.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Alert'**
  String get lowStockAlert;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get units;

  /// No description provided for @recentBills.
  ///
  /// In en, this message translates to:
  /// **'Recent Bills'**
  String get recentBills;

  /// No description provided for @pendingBills.
  ///
  /// In en, this message translates to:
  /// **'Pending Bills'**
  String get pendingBills;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @noStockItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No stock items found'**
  String get noStockItemsFound;

  /// No description provided for @noRecentBills.
  ///
  /// In en, this message translates to:
  /// **'No recent bills'**
  String get noRecentBills;

  /// No description provided for @draftBills.
  ///
  /// In en, this message translates to:
  /// **'Draft Bills'**
  String get draftBills;

  /// No description provided for @pendingDrafts.
  ///
  /// In en, this message translates to:
  /// **'Pending Drafts'**
  String get pendingDrafts;

  /// No description provided for @createBill.
  ///
  /// In en, this message translates to:
  /// **'Create Bill'**
  String get createBill;

  /// No description provided for @draftBill.
  ///
  /// In en, this message translates to:
  /// **'Draft Bill'**
  String get draftBill;

  /// No description provided for @createGstBill.
  ///
  /// In en, this message translates to:
  /// **'Create GST Bill'**
  String get createGstBill;

  /// No description provided for @createNonGstBill.
  ///
  /// In en, this message translates to:
  /// **'Create Cash Memo'**
  String get createNonGstBill;

  /// No description provided for @editBill.
  ///
  /// In en, this message translates to:
  /// **'Edit Bill'**
  String get editBill;

  /// No description provided for @billNumber.
  ///
  /// In en, this message translates to:
  /// **'Invoice #'**
  String get billNumber;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @customerName.
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get customerName;

  /// No description provided for @selectCustomer.
  ///
  /// In en, this message translates to:
  /// **'Select Customer'**
  String get selectCustomer;

  /// No description provided for @walkInCustomer.
  ///
  /// In en, this message translates to:
  /// **'Walk-in Customer'**
  String get walkInCustomer;

  /// No description provided for @customerCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get customerCity;

  /// No description provided for @customerPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get customerPhone;

  /// No description provided for @customerGst.
  ///
  /// In en, this message translates to:
  /// **'GSTIN'**
  String get customerGst;

  /// No description provided for @customerAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get customerAddress;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @selectProduct.
  ///
  /// In en, this message translates to:
  /// **'Select Product'**
  String get selectProduct;

  /// No description provided for @packagingRule.
  ///
  /// In en, this message translates to:
  /// **'Packaging Rule'**
  String get packagingRule;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @rate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rate;

  /// No description provided for @subTotal.
  ///
  /// In en, this message translates to:
  /// **'Sub Total'**
  String get subTotal;

  /// No description provided for @gstAmount.
  ///
  /// In en, this message translates to:
  /// **'GST Amount'**
  String get gstAmount;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @amountPaid.
  ///
  /// In en, this message translates to:
  /// **'Amount Paid'**
  String get amountPaid;

  /// No description provided for @dueAmount.
  ///
  /// In en, this message translates to:
  /// **'Due Amount'**
  String get dueAmount;

  /// No description provided for @paymentMode.
  ///
  /// In en, this message translates to:
  /// **'Payment Mode'**
  String get paymentMode;

  /// No description provided for @paymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Payment Status'**
  String get paymentStatus;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @partial.
  ///
  /// In en, this message translates to:
  /// **'Partially Paid'**
  String get partial;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @unpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get unpaid;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @upi.
  ///
  /// In en, this message translates to:
  /// **'UPI'**
  String get upi;

  /// No description provided for @bankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get bankTransfer;

  /// No description provided for @cheque.
  ///
  /// In en, this message translates to:
  /// **'Cheque'**
  String get cheque;

  /// No description provided for @credit.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get credit;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// No description provided for @saveInvoice.
  ///
  /// In en, this message translates to:
  /// **'Save Invoice'**
  String get saveInvoice;

  /// No description provided for @generatingInvoice.
  ///
  /// In en, this message translates to:
  /// **'Creating Invoice...'**
  String get generatingInvoice;

  /// No description provided for @invoiceCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Invoice created successfully!'**
  String get invoiceCreatedSuccess;

  /// No description provided for @invoicePreview.
  ///
  /// In en, this message translates to:
  /// **'Invoice Preview'**
  String get invoicePreview;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @selectFirm.
  ///
  /// In en, this message translates to:
  /// **'Select Firm'**
  String get selectFirm;

  /// No description provided for @chooseBillType.
  ///
  /// In en, this message translates to:
  /// **'Choose the type of bill you want to create'**
  String get chooseBillType;

  /// No description provided for @pakkaBill.
  ///
  /// In en, this message translates to:
  /// **'Pakka Bill'**
  String get pakkaBill;

  /// No description provided for @gstInvoice.
  ///
  /// In en, this message translates to:
  /// **'GST Invoice'**
  String get gstInvoice;

  /// No description provided for @kacchaBill.
  ///
  /// In en, this message translates to:
  /// **'Kaccha Bill'**
  String get kacchaBill;

  /// No description provided for @cashMemo.
  ///
  /// In en, this message translates to:
  /// **'Cash Memo'**
  String get cashMemo;

  /// No description provided for @pakka.
  ///
  /// In en, this message translates to:
  /// **'PAKKA'**
  String get pakka;

  /// No description provided for @kaccha.
  ///
  /// In en, this message translates to:
  /// **'KACCHA'**
  String get kaccha;

  /// No description provided for @registered.
  ///
  /// In en, this message translates to:
  /// **'Registered'**
  String get registered;

  /// No description provided for @walkIn.
  ///
  /// In en, this message translates to:
  /// **'Walk-in'**
  String get walkIn;

  /// No description provided for @addNewCustomer.
  ///
  /// In en, this message translates to:
  /// **'+ Add New Customer'**
  String get addNewCustomer;

  /// No description provided for @walkInName.
  ///
  /// In en, this message translates to:
  /// **'Walk-in Name'**
  String get walkInName;

  /// No description provided for @enterWalkInName.
  ///
  /// In en, this message translates to:
  /// **'Enter Walk-in Name'**
  String get enterWalkInName;

  /// No description provided for @stepFirmCustomer.
  ///
  /// In en, this message translates to:
  /// **'Firm & Customer'**
  String get stepFirmCustomer;

  /// No description provided for @stepProductSelect.
  ///
  /// In en, this message translates to:
  /// **'Select Products'**
  String get stepProductSelect;

  /// No description provided for @stepBillSummary.
  ///
  /// In en, this message translates to:
  /// **'Bill Summary'**
  String get stepBillSummary;

  /// No description provided for @stepPaymentOptions.
  ///
  /// In en, this message translates to:
  /// **'Payment Options'**
  String get stepPaymentOptions;

  /// No description provided for @stepInvoicePreview.
  ///
  /// In en, this message translates to:
  /// **'Invoice Preview'**
  String get stepInvoicePreview;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @saveDraftText.
  ///
  /// In en, this message translates to:
  /// **'Save Draft'**
  String get saveDraftText;

  /// No description provided for @previousText.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previousText;

  /// No description provided for @generateBillText.
  ///
  /// In en, this message translates to:
  /// **'Generate Bill'**
  String get generateBillText;

  /// No description provided for @deleteDraft.
  ///
  /// In en, this message translates to:
  /// **'Delete Draft'**
  String get deleteDraft;

  /// No description provided for @deleteDraftConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this saved draft?'**
  String get deleteDraftConfirm;

  /// No description provided for @draftDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Draft deleted successfully'**
  String get draftDeletedSuccess;

  /// No description provided for @noCustomersFoundFirm.
  ///
  /// In en, this message translates to:
  /// **'No customers found for this firm'**
  String get noCustomersFoundFirm;

  /// No description provided for @selectFirmFirst.
  ///
  /// In en, this message translates to:
  /// **'Select Firm first'**
  String get selectFirmFirst;

  /// No description provided for @pleaseSelectFirmFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a firm first'**
  String get pleaseSelectFirmFirst;

  /// No description provided for @pleaseSelectCustomerFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select or enter customer name'**
  String get pleaseSelectCustomerFirst;

  /// No description provided for @pleaseAddProductFirst.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one product before generating bill'**
  String get pleaseAddProductFirst;

  /// No description provided for @billedBy.
  ///
  /// In en, this message translates to:
  /// **'Billed by'**
  String get billedBy;

  /// No description provided for @financialBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Financial Breakdown'**
  String get financialBreakdown;

  /// No description provided for @productsInBill.
  ///
  /// In en, this message translates to:
  /// **'Products in Bill'**
  String get productsInBill;

  /// No description provided for @billedItems.
  ///
  /// In en, this message translates to:
  /// **'Billed Items'**
  String get billedItems;

  /// No description provided for @itemsQuantity.
  ///
  /// In en, this message translates to:
  /// **'Items / Quantity'**
  String get itemsQuantity;

  /// No description provided for @tallySync.
  ///
  /// In en, this message translates to:
  /// **'Tally Sync'**
  String get tallySync;

  /// No description provided for @pushedToTally.
  ///
  /// In en, this message translates to:
  /// **'Pushed to Tally'**
  String get pushedToTally;

  /// No description provided for @syncPending.
  ///
  /// In en, this message translates to:
  /// **'Sync Pending'**
  String get syncPending;

  /// No description provided for @backToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Back To Dashboard'**
  String get backToDashboard;

  /// No description provided for @sizeKey.
  ///
  /// In en, this message translates to:
  /// **'Size Key'**
  String get sizeKey;

  /// No description provided for @selectSizeKey.
  ///
  /// In en, this message translates to:
  /// **'Select Size Key'**
  String get selectSizeKey;

  /// No description provided for @noSizeKeysFound.
  ///
  /// In en, this message translates to:
  /// **'No size keys found'**
  String get noSizeKeysFound;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// No description provided for @loadingProducts.
  ///
  /// In en, this message translates to:
  /// **'Loading products...'**
  String get loadingProducts;

  /// No description provided for @packageRule.
  ///
  /// In en, this message translates to:
  /// **'Package Rule'**
  String get packageRule;

  /// No description provided for @selectRule.
  ///
  /// In en, this message translates to:
  /// **'Select Rule'**
  String get selectRule;

  /// No description provided for @noPackagingRulesFound.
  ///
  /// In en, this message translates to:
  /// **'No packaging rules found'**
  String get noPackagingRulesFound;

  /// No description provided for @bagsBoxes.
  ///
  /// In en, this message translates to:
  /// **'Bags / Boxes'**
  String get bagsBoxes;

  /// No description provided for @enterBagsBoxes.
  ///
  /// In en, this message translates to:
  /// **'Enter Bags/Boxes'**
  String get enterBagsBoxes;

  /// No description provided for @looseQty.
  ///
  /// In en, this message translates to:
  /// **'Loose Qty (Pcs)'**
  String get looseQty;

  /// No description provided for @enterLooseQty.
  ///
  /// In en, this message translates to:
  /// **'Enter Loose Qty'**
  String get enterLooseQty;

  /// No description provided for @totalQtyCalculated.
  ///
  /// In en, this message translates to:
  /// **'Total Qty (Pcs)'**
  String get totalQtyCalculated;

  /// No description provided for @ratePerPiece.
  ///
  /// In en, this message translates to:
  /// **'Rate / Unit (₹)'**
  String get ratePerPiece;

  /// No description provided for @enterRate.
  ///
  /// In en, this message translates to:
  /// **'Enter Rate'**
  String get enterRate;

  /// No description provided for @gstRate.
  ///
  /// In en, this message translates to:
  /// **'GST Rate (%)'**
  String get gstRate;

  /// No description provided for @selectGstRate.
  ///
  /// In en, this message translates to:
  /// **'Select GST Rate'**
  String get selectGstRate;

  /// No description provided for @itemTotal.
  ///
  /// In en, this message translates to:
  /// **'Item Total (₹)'**
  String get itemTotal;

  /// No description provided for @addProductToBill.
  ///
  /// In en, this message translates to:
  /// **'Add Product To Bill'**
  String get addProductToBill;

  /// No description provided for @updateProductInBill.
  ///
  /// In en, this message translates to:
  /// **'Update Product'**
  String get updateProductInBill;

  /// No description provided for @pleaseSelectProduct.
  ///
  /// In en, this message translates to:
  /// **'Please select a product'**
  String get pleaseSelectProduct;

  /// No description provided for @pleaseEnterValidQty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid quantity'**
  String get pleaseEnterValidQty;

  /// No description provided for @pleaseEnterValidRate.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid rate'**
  String get pleaseEnterValidRate;

  /// No description provided for @productAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Product added successfully'**
  String get productAddedSuccess;

  /// No description provided for @productUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Product updated successfully'**
  String get productUpdatedSuccess;

  /// No description provided for @addedProducts.
  ///
  /// In en, this message translates to:
  /// **'Added Products'**
  String get addedProducts;

  /// No description provided for @noProductsAddedYet.
  ///
  /// In en, this message translates to:
  /// **'No products added yet'**
  String get noProductsAddedYet;

  /// No description provided for @addAtLeastOneProduct.
  ///
  /// In en, this message translates to:
  /// **'Add at least one product to continue'**
  String get addAtLeastOneProduct;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @deleteProductConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this product?'**
  String get deleteProductConfirm;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @taxableAmount.
  ///
  /// In en, this message translates to:
  /// **'Taxable Amount'**
  String get taxableAmount;

  /// No description provided for @roundOff.
  ///
  /// In en, this message translates to:
  /// **'Round Off'**
  String get roundOff;

  /// No description provided for @netPayable.
  ///
  /// In en, this message translates to:
  /// **'Net Payable Amount'**
  String get netPayable;

  /// No description provided for @paymentDetails.
  ///
  /// In en, this message translates to:
  /// **'Payment Details'**
  String get paymentDetails;

  /// No description provided for @receivedAmount.
  ///
  /// In en, this message translates to:
  /// **'Received Amount (₹)'**
  String get receivedAmount;

  /// No description provided for @enterReceivedAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter Received Amount'**
  String get enterReceivedAmount;

  /// No description provided for @balanceDue.
  ///
  /// In en, this message translates to:
  /// **'Balance Due'**
  String get balanceDue;

  /// No description provided for @paymentRemarks.
  ///
  /// In en, this message translates to:
  /// **'Remarks / Notes'**
  String get paymentRemarks;

  /// No description provided for @enterRemarks.
  ///
  /// In en, this message translates to:
  /// **'Enter Remarks (Optional)'**
  String get enterRemarks;

  /// No description provided for @referenceNo.
  ///
  /// In en, this message translates to:
  /// **'Reference / Transaction ID'**
  String get referenceNo;

  /// No description provided for @enterReferenceNo.
  ///
  /// In en, this message translates to:
  /// **'Enter Reference No'**
  String get enterReferenceNo;

  /// No description provided for @selectPaymentMode.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Mode'**
  String get selectPaymentMode;

  /// No description provided for @generateInvoice.
  ///
  /// In en, this message translates to:
  /// **'Generate Invoice'**
  String get generateInvoice;

  /// No description provided for @salesLogs.
  ///
  /// In en, this message translates to:
  /// **'Sales Logs'**
  String get salesLogs;

  /// No description provided for @exportSales.
  ///
  /// In en, this message translates to:
  /// **'Export Sales'**
  String get exportSales;

  /// No description provided for @exportSalesRecords.
  ///
  /// In en, this message translates to:
  /// **'Export Sales Records'**
  String get exportSalesRecords;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPdf;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsv;

  /// No description provided for @print.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get print;

  /// No description provided for @printPreview.
  ///
  /// In en, this message translates to:
  /// **'Print / Preview PDF Report'**
  String get printPreview;

  /// No description provided for @sharePdf.
  ///
  /// In en, this message translates to:
  /// **'Share / Save PDF Report'**
  String get sharePdf;

  /// No description provided for @exportSpreadsheet.
  ///
  /// In en, this message translates to:
  /// **'Export as CSV / Excel'**
  String get exportSpreadsheet;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @grandTotal.
  ///
  /// In en, this message translates to:
  /// **'Grand Total'**
  String get grandTotal;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterPakka.
  ///
  /// In en, this message translates to:
  /// **'Pakka (GST)'**
  String get filterPakka;

  /// No description provided for @filterKaccha.
  ///
  /// In en, this message translates to:
  /// **'Kaccha (Cash)'**
  String get filterKaccha;

  /// No description provided for @totalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get totalRevenue;

  /// No description provided for @totalDue.
  ///
  /// In en, this message translates to:
  /// **'Total Due'**
  String get totalDue;

  /// No description provided for @noSalesBillsFound.
  ///
  /// In en, this message translates to:
  /// **'No sales bills found'**
  String get noSalesBillsFound;

  /// No description provided for @unableToLoadSales.
  ///
  /// In en, this message translates to:
  /// **'Unable to Load Sales Logs'**
  String get unableToLoadSales;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @salesReturns.
  ///
  /// In en, this message translates to:
  /// **'Sales Returns'**
  String get salesReturns;

  /// No description provided for @createReturn.
  ///
  /// In en, this message translates to:
  /// **'Create Return'**
  String get createReturn;

  /// No description provided for @recentSalesReturns.
  ///
  /// In en, this message translates to:
  /// **'Recent Sales Returns'**
  String get recentSalesReturns;

  /// No description provided for @noSalesReturnsFound.
  ///
  /// In en, this message translates to:
  /// **'No sales returns found'**
  String get noSalesReturnsFound;

  /// No description provided for @returnedQty.
  ///
  /// In en, this message translates to:
  /// **'Returned Qty'**
  String get returnedQty;

  /// No description provided for @returnAmount.
  ///
  /// In en, this message translates to:
  /// **'Return Amount'**
  String get returnAmount;

  /// No description provided for @returnValue.
  ///
  /// In en, this message translates to:
  /// **'Return Value'**
  String get returnValue;

  /// No description provided for @returnedProducts.
  ///
  /// In en, this message translates to:
  /// **'Returned Products'**
  String get returnedProducts;

  /// No description provided for @totalRtn.
  ///
  /// In en, this message translates to:
  /// **'Total Rtn'**
  String get totalRtn;

  /// No description provided for @returnReason.
  ///
  /// In en, this message translates to:
  /// **'Return Reason'**
  String get returnReason;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @recordReturn.
  ///
  /// In en, this message translates to:
  /// **'Record Return'**
  String get recordReturn;

  /// No description provided for @returnSuccess.
  ///
  /// In en, this message translates to:
  /// **'Return recorded successfully!'**
  String get returnSuccess;

  /// No description provided for @salesReturnDetails.
  ///
  /// In en, this message translates to:
  /// **'Sales Return Details'**
  String get salesReturnDetails;

  /// No description provided for @returnDate.
  ///
  /// In en, this message translates to:
  /// **'Return Date'**
  String get returnDate;

  /// No description provided for @originalBillNo.
  ///
  /// In en, this message translates to:
  /// **'Original Bill / Invoice #'**
  String get originalBillNo;

  /// No description provided for @selectBill.
  ///
  /// In en, this message translates to:
  /// **'Select Bill'**
  String get selectBill;

  /// No description provided for @returnItems.
  ///
  /// In en, this message translates to:
  /// **'Return Items'**
  String get returnItems;

  /// No description provided for @damageType.
  ///
  /// In en, this message translates to:
  /// **'Damage / Defect Type'**
  String get damageType;

  /// No description provided for @selectDamageType.
  ///
  /// In en, this message translates to:
  /// **'Select Type'**
  String get selectDamageType;

  /// No description provided for @refundAmount.
  ///
  /// In en, this message translates to:
  /// **'Refund Amount'**
  String get refundAmount;

  /// No description provided for @saveReturn.
  ///
  /// In en, this message translates to:
  /// **'Save Return'**
  String get saveReturn;

  /// No description provided for @recordPayment.
  ///
  /// In en, this message translates to:
  /// **'Record Payment'**
  String get recordPayment;

  /// No description provided for @amountToPay.
  ///
  /// In en, this message translates to:
  /// **'Amount to Pay'**
  String get amountToPay;

  /// No description provided for @paymentRecordedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment recorded successfully!'**
  String get paymentRecordedSuccess;

  /// No description provided for @paymentCollection.
  ///
  /// In en, this message translates to:
  /// **'Payment Collection'**
  String get paymentCollection;

  /// No description provided for @addPayment.
  ///
  /// In en, this message translates to:
  /// **'Add Payment'**
  String get addPayment;

  /// No description provided for @allCollections.
  ///
  /// In en, this message translates to:
  /// **'All Collections'**
  String get allCollections;

  /// No description provided for @collectionDate.
  ///
  /// In en, this message translates to:
  /// **'Collection Date'**
  String get collectionDate;

  /// No description provided for @collectedBy.
  ///
  /// In en, this message translates to:
  /// **'Collected By'**
  String get collectedBy;

  /// No description provided for @addNewPayment.
  ///
  /// In en, this message translates to:
  /// **'Add New Payment'**
  String get addNewPayment;

  /// No description provided for @noPaymentRecordsFound.
  ///
  /// In en, this message translates to:
  /// **'No payment records found'**
  String get noPaymentRecordsFound;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter Amount'**
  String get enterAmount;

  /// No description provided for @pleaseEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get pleaseEnterAmount;

  /// No description provided for @pleaseSelectCustomer.
  ///
  /// In en, this message translates to:
  /// **'Please select a customer'**
  String get pleaseSelectCustomer;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @enterNotes.
  ///
  /// In en, this message translates to:
  /// **'Enter Notes (Optional)'**
  String get enterNotes;

  /// No description provided for @company.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get company;

  /// No description provided for @switchCompany.
  ///
  /// In en, this message translates to:
  /// **'Switch Company'**
  String get switchCompany;

  /// No description provided for @selectCompany.
  ///
  /// In en, this message translates to:
  /// **'Select Active Company'**
  String get selectCompany;

  /// No description provided for @activeFirm.
  ///
  /// In en, this message translates to:
  /// **'Active Firm'**
  String get activeFirm;

  /// No description provided for @switchActiveCompany.
  ///
  /// In en, this message translates to:
  /// **'Switch Active Company'**
  String get switchActiveCompany;

  /// No description provided for @customersList.
  ///
  /// In en, this message translates to:
  /// **'Customers List'**
  String get customersList;

  /// No description provided for @addCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add Customer'**
  String get addCustomer;

  /// No description provided for @editCustomer.
  ///
  /// In en, this message translates to:
  /// **'Edit Customer'**
  String get editCustomer;

  /// No description provided for @customerAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Customer added successfully!'**
  String get customerAddedSuccess;

  /// No description provided for @addNewCustomerTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Customer'**
  String get addNewCustomerTitle;

  /// No description provided for @enterCustomerName.
  ///
  /// In en, this message translates to:
  /// **'Enter Customer Name'**
  String get enterCustomerName;

  /// No description provided for @enterCity.
  ///
  /// In en, this message translates to:
  /// **'Enter City'**
  String get enterCity;

  /// No description provided for @enterAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter Address'**
  String get enterAddress;

  /// No description provided for @enterGstNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter GST Number (Optional)'**
  String get enterGstNumber;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @gstin.
  ///
  /// In en, this message translates to:
  /// **'GSTIN'**
  String get gstin;

  /// No description provided for @openingBalance.
  ///
  /// In en, this message translates to:
  /// **'Opening Balance (₹)'**
  String get openingBalance;

  /// No description provided for @enterOpeningBalance.
  ///
  /// In en, this message translates to:
  /// **'Enter Opening Balance'**
  String get enterOpeningBalance;

  /// No description provided for @saveCustomer.
  ///
  /// In en, this message translates to:
  /// **'Save Customer'**
  String get saveCustomer;

  /// No description provided for @settingsAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Setting & Privacy'**
  String get settingsAndPrivacy;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get account;

  /// No description provided for @otherSettings.
  ///
  /// In en, this message translates to:
  /// **'OTHER SETTINGS'**
  String get otherSettings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @marathi.
  ///
  /// In en, this message translates to:
  /// **'मराठी (Marathi)'**
  String get marathi;

  /// No description provided for @printerSettings.
  ///
  /// In en, this message translates to:
  /// **'Printer Settings'**
  String get printerSettings;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @appInformation.
  ///
  /// In en, this message translates to:
  /// **'App Information'**
  String get appInformation;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get confirmLogout;

  /// No description provided for @logoutConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of RK Plast Billing?'**
  String get logoutConfirmationMessage;

  /// No description provided for @exitApplication.
  ///
  /// In en, this message translates to:
  /// **'Exit Application'**
  String get exitApplication;

  /// No description provided for @exitConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit the app?'**
  String get exitConfirmMessage;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get noInternet;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @createNewBill.
  ///
  /// In en, this message translates to:
  /// **'Create New Bill'**
  String get createNewBill;

  /// No description provided for @billSuccess.
  ///
  /// In en, this message translates to:
  /// **'Bill Created Successfully!'**
  String get billSuccess;

  /// No description provided for @paymentCollections.
  ///
  /// In en, this message translates to:
  /// **'Payment Collections'**
  String get paymentCollections;

  /// No description provided for @totalOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Total Outstanding'**
  String get totalOutstanding;

  /// No description provided for @totalCollected.
  ///
  /// In en, this message translates to:
  /// **'Total Collected'**
  String get totalCollected;

  /// No description provided for @noCollectionsFound.
  ///
  /// In en, this message translates to:
  /// **'No collections found'**
  String get noCollectionsFound;

  /// No description provided for @receivedAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Received Amount *'**
  String get receivedAmountRequired;

  /// No description provided for @invoiceTotal.
  ///
  /// In en, this message translates to:
  /// **'Invoice Total'**
  String get invoiceTotal;

  /// No description provided for @alreadyReceived.
  ///
  /// In en, this message translates to:
  /// **'Already Received'**
  String get alreadyReceived;

  /// No description provided for @beforePendingAmount.
  ///
  /// In en, this message translates to:
  /// **'Before pending Amount'**
  String get beforePendingAmount;

  /// No description provided for @receivingNow.
  ///
  /// In en, this message translates to:
  /// **'Receiving Now'**
  String get receivingNow;

  /// No description provided for @balanceAfterPayment.
  ///
  /// In en, this message translates to:
  /// **'Balance After Payment'**
  String get balanceAfterPayment;

  /// No description provided for @selectInvoice.
  ///
  /// In en, this message translates to:
  /// **'Select Invoice'**
  String get selectInvoice;

  /// No description provided for @paymentCollectionSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment Collection Saved Successfully!'**
  String get paymentCollectionSavedSuccess;

  /// No description provided for @savedDraftBills.
  ///
  /// In en, this message translates to:
  /// **'Saved Draft Bills'**
  String get savedDraftBills;

  /// No description provided for @noPendingDraftsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No pending drafts available'**
  String get noPendingDraftsAvailable;

  /// No description provided for @startFreshBill.
  ///
  /// In en, this message translates to:
  /// **'Start Fresh Bill'**
  String get startFreshBill;

  /// No description provided for @selectCompanyToViewBills.
  ///
  /// In en, this message translates to:
  /// **'Select a company to view its bills & data'**
  String get selectCompanyToViewBills;

  /// No description provided for @searchCompany.
  ///
  /// In en, this message translates to:
  /// **'Search company...'**
  String get searchCompany;

  /// No description provided for @billed.
  ///
  /// In en, this message translates to:
  /// **'Billed'**
  String get billed;

  /// No description provided for @prevReturned.
  ///
  /// In en, this message translates to:
  /// **'Prev Returned'**
  String get prevReturned;

  /// No description provided for @selectReturnItems.
  ///
  /// In en, this message translates to:
  /// **'Select Return Items'**
  String get selectReturnItems;

  /// No description provided for @addReason.
  ///
  /// In en, this message translates to:
  /// **'Add Reason'**
  String get addReason;

  /// No description provided for @enterReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Enter reason here .......'**
  String get enterReasonHint;

  /// No description provided for @returnProcessed.
  ///
  /// In en, this message translates to:
  /// **'Return Processed'**
  String get returnProcessed;

  /// No description provided for @productsReturnedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Products returned successfully'**
  String get productsReturnedSuccess;

  /// No description provided for @updatedInvoiceSummary.
  ///
  /// In en, this message translates to:
  /// **'Updated Invoice Summary'**
  String get updatedInvoiceSummary;

  /// No description provided for @invoiceFinancials.
  ///
  /// In en, this message translates to:
  /// **'Invoice Financials'**
  String get invoiceFinancials;

  /// No description provided for @enterAmountReceivedAgainstBill.
  ///
  /// In en, this message translates to:
  /// **'Enter amount received against this bill'**
  String get enterAmountReceivedAgainstBill;

  /// No description provided for @paidSoFar.
  ///
  /// In en, this message translates to:
  /// **'Paid So Far'**
  String get paidSoFar;

  /// No description provided for @payFullDue.
  ///
  /// In en, this message translates to:
  /// **'Pay Full Due'**
  String get payFullDue;

  /// No description provided for @enterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get enterValidAmount;

  /// No description provided for @amountCannotExceedDue.
  ///
  /// In en, this message translates to:
  /// **'Amount cannot exceed due'**
  String get amountCannotExceedDue;

  /// No description provided for @billTotal.
  ///
  /// In en, this message translates to:
  /// **'Bill Total'**
  String get billTotal;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get inStock;

  /// No description provided for @minStock.
  ///
  /// In en, this message translates to:
  /// **'Min Stock'**
  String get minStock;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @stock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stock;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @unfinishedDraftsRequireAttention.
  ///
  /// In en, this message translates to:
  /// **'unfinished drafts require attention.'**
  String get unfinishedDraftsRequireAttention;

  /// No description provided for @firm.
  ///
  /// In en, this message translates to:
  /// **'Firm'**
  String get firm;

  /// No description provided for @step.
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get step;

  /// No description provided for @deleteDraftConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this draft?'**
  String get deleteDraftConfirmation;

  /// No description provided for @searchCompanyHint.
  ///
  /// In en, this message translates to:
  /// **'Search company name or city...'**
  String get searchCompanyHint;

  /// No description provided for @noCompaniesFound.
  ///
  /// In en, this message translates to:
  /// **'No companies found'**
  String get noCompaniesFound;

  /// No description provided for @inclGst.
  ///
  /// In en, this message translates to:
  /// **'incl. GST'**
  String get inclGst;

  /// No description provided for @due.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get due;

  /// No description provided for @dueColon.
  ///
  /// In en, this message translates to:
  /// **'Due:'**
  String get dueColon;

  /// No description provided for @pcs.
  ///
  /// In en, this message translates to:
  /// **'pcs'**
  String get pcs;

  /// No description provided for @box.
  ///
  /// In en, this message translates to:
  /// **'box'**
  String get box;

  /// No description provided for @returned.
  ///
  /// In en, this message translates to:
  /// **'returned'**
  String get returned;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get lowStock;

  /// No description provided for @hsn.
  ///
  /// In en, this message translates to:
  /// **'HSN'**
  String get hsn;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @gst.
  ///
  /// In en, this message translates to:
  /// **'GST'**
  String get gst;

  /// No description provided for @invoiceSavedDownloads.
  ///
  /// In en, this message translates to:
  /// **'Invoice saved to Downloads'**
  String get invoiceSavedDownloads;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotifications;

  /// No description provided for @noNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'You are all caught up! Important alerts and updates will appear here.'**
  String get noNotificationsDesc;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @allNotifications.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allNotifications;

  /// No description provided for @filterWarnings.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get filterWarnings;

  /// No description provided for @filterLoans.
  ///
  /// In en, this message translates to:
  /// **'EMI & Loans'**
  String get filterLoans;

  /// No description provided for @notificationDetails.
  ///
  /// In en, this message translates to:
  /// **'Notification Details'**
  String get notificationDetails;

  /// No description provided for @severity.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get severity;

  /// No description provided for @relatedEntity.
  ///
  /// In en, this message translates to:
  /// **'Related Entity'**
  String get relatedEntity;

  /// No description provided for @billType.
  ///
  /// In en, this message translates to:
  /// **'Bill Type'**
  String get billType;

  /// No description provided for @unread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unread;

  /// No description provided for @markAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get markAsRead;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'mr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'mr':
      return AppLocalizationsMr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
