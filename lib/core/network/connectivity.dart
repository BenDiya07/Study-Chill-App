import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

final isOnlineProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.when(
    data: (results) => results.any((r) => r != ConnectivityResult.none),
    loading: () => true,
    error: (_, __) => true,
  );
});

class AuthInterceptor {
  String? _token;

  String? get token => _token;

  void setToken(String? token) => _token = token;

  Map<String, String> intercept(Map<String, String> headers) {
    final updated = Map<String, String>.from(headers);
    if (_token != null && _token!.isNotEmpty) {
      updated['Authorization'] = 'Bearer $_token';
    }
    return updated;
  }

  bool handleResponse(int statusCode) {
    if (statusCode == 401) {
      _token = null;
      return false;
    }
    return true;
  }
}

final authInterceptorProvider = Provider<AuthInterceptor>((ref) => AuthInterceptor());