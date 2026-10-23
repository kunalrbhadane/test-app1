class ApiEndpoints {
  ApiEndpoints._();

  // ---------------- AUTH ----------------
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';

  // ---------------- COMPANIES ----------------
  static const String companies = '/companies';

  // ---------------- CUSTOMERS ----------------
  static const String customers = '/customers';

  // ---------------- BILLING ----------------
  static const String billing = '/billing';
  static const String billingAvailable = '/billing/available';
  static const String billingReturn = '/billing/return';

  /// Returns `/billing/{billId}/payment` for the PATCH partial-payment endpoint.
  static String billingPayment(String billId) => '/billing/$billId/payment';

  // ---------------- SIZE MASTERS ----------------
  static const String sizeMasters = '/size-masters';
  static const String sizeMastersGoodBottles = '/size-masters/get/good/bottels';

  // ---------------- NOTIFICATION / SUBSCRIBE ----------------
  static const String subscribe = '/subscribe';
  static const String notification = '/notification';

  // ---------------- PRODUCTION ----------------
  static const String productionUniqueBatch = '/production/unique/batch';
}

