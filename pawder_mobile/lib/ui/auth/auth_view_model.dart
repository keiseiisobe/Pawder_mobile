import 'package:flutter/material.dart';

class AuthViewModel extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    // TODO: 実際のGoogleログイン処理を実装
    await Future.delayed(const Duration(seconds: 1));

    _isAuthenticated = true;
    _isLoading = false;
    notifyListeners();
  }

  void signOut() {
    _isAuthenticated = false;
    notifyListeners();
  }
}

