import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthNotifier extends StateNotifier<bool> {
  AuthNotifier() : super(false);

  Future<void> login(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    print('Login attempt: $username');
    state = true;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    print('User logged out');
    state = false;
  }

  Future<void> signup(String username, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    print('Signup attempt: $username, $email');
    state = true;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier();
});