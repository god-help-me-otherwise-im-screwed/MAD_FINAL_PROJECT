import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthNotifier extends StateNotifier<bool> {
  AuthNotifier() : super(false);

  /// Save authentication status to persistent storage
  Future<void> saveAuthStatus(bool isAuthenticated) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_authenticated', isAuthenticated);
      state = isAuthenticated;
    } catch (e) {
      print('Error saving auth status: $e');
    }
  }

  /// Load authentication status from persistent storage
  Future<bool> loadAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isAuthenticated = prefs.getBool('is_authenticated') ?? false;
      state = isAuthenticated;
      return isAuthenticated;
    } catch (e) {
      print('Error loading auth status: $e');
      return false;
    }
  }

  /// Clear saved authentication status and reset state
  Future<void> resetDebugData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('is_authenticated');
      state = false;
    } catch (e) {
      print('Error resetting auth debug data: $e');
    }
  }

  Future<void> login(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    print('Login attempt: $username');
    await saveAuthStatus(true);
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    print('User logged out');
    await saveAuthStatus(false);
  }

  Future<void> signup(String username, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    print('Signup attempt: $username, $email');
    await saveAuthStatus(true);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier();
});
