import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityProvider extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _isConnected = true;
  bool _isChecking = false;

  bool get isConnected => _isConnected;
  bool get isChecking => _isChecking;

  ConnectivityProvider() {
    _init();
  }

  Future<void> _init() async {
    // Initial check
    await checkConnection();

    // Listen to network changes
    _subscription = _connectivity.onConnectivityChanged.listen((results) async {
      await _checkWithResults(results);
    });
  }

  /// Verifies active internet connectivity with a real lookup
  Future<bool> checkConnection() async {
    _isChecking = true;
    notifyListeners();

    try {
      final results = await _connectivity.checkConnectivity();
      final hasConnection = await _checkWithResults(results);
      _isChecking = false;
      notifyListeners();
      return hasConnection;
    } catch (e) {
      debugPrint('[ConnectivityProvider] check error: $e');
      _isConnected = false;
      _isChecking = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> _checkWithResults(List<ConnectivityResult> results) async {
    final hasNetworkInterface = results.any((r) => r != ConnectivityResult.none);

    if (!hasNetworkInterface) {
      _updateStatus(false);
      return false;
    }

    // Ping / DNS lookup test to ensure internet is actually reachable
    try {
      final lookup = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 4));
      final online = lookup.isNotEmpty && lookup[0].rawAddress.isNotEmpty;
      _updateStatus(online);
      return online;
    } on SocketException catch (_) {
      _updateStatus(false);
      return false;
    } on TimeoutException catch (_) {
      _updateStatus(false);
      return false;
    } catch (_) {
      _updateStatus(false);
      return false;
    }
  }

  void _updateStatus(bool status) {
    if (_isConnected != status) {
      _isConnected = status;
      debugPrint('[ConnectivityProvider] Network status changed => online: $_isConnected');
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
