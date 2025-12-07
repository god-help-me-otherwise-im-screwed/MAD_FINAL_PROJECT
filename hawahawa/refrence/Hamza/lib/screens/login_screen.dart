import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hawahawa/constants/colors.dart';
import 'package:hawahawa/providers/auth_provider.dart';
import 'package:hawahawa/widgets/scene_panel.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (_isSignUp) {
        await ref.read(authProvider.notifier).signup(
              _emailController.text.trim(),
              _passwordController.text,
              _nameController.text.trim(),
              _usernameController.text.trim(),
            );
      } else {
        await ref.read(authProvider.notifier).login(
              _emailController.text.trim(),
              _passwordController.text,
            );
      }

      // Wait a bit for state to update
      await Future.delayed(const Duration(milliseconds: 300));
      
      final authState = ref.read(authProvider);
      if (mounted) {
        if (authState.isAuthenticated) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isSignUp ? 'Account created successfully!' : 'Logged in successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (authState.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authState.error!),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: kDarkPrimary,
      appBar: AppBar(
        title: Text(_isSignUp ? 'SIGN UP' : 'LOGIN'),
        backgroundColor: kDarkPrimary,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ScenePanel(
            minWidth: 300,
            minHeight: 400,
            showBorder: true,
            borderWidth: 1,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.lock, size: 64, color: kDarkAccent),
                    const SizedBox(height: 24),
                    Text(
                      _isSignUp ? 'CREATE ACCOUNT' : 'WELCOME BACK',
                      style: const TextStyle(
                        color: kDarkText,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    if (_isSignUp)
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: kDarkText),
                        decoration: InputDecoration(
                          labelText: 'Display Name',
                          labelStyle: const TextStyle(color: kDarkText),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: kDarkAccent.withOpacity(0.5)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: kDarkAccent),
                          ),
                        ),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Enter a name' : null,
                      ),
                    if (_isSignUp) const SizedBox(height: 16),
                    if (_isSignUp)
                      TextFormField(
                        controller: _usernameController,
                        style: const TextStyle(color: kDarkText),
                        decoration: InputDecoration(
                          labelText: 'Username',
                          hintText: 'unique_username',
                          labelStyle: const TextStyle(color: kDarkText),
                          hintStyle: TextStyle(color: kDarkText.withOpacity(0.3)),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: kDarkAccent.withOpacity(0.5)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: kDarkAccent),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Enter a username';
                          if (val.length < 3) return 'Username must be 3+ characters';
                          if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(val)) {
                            return 'Only letters, numbers, and underscores';
                          }
                          return null;
                        },
                      ),
                    if (_isSignUp) const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      style: const TextStyle(color: kDarkText),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: const TextStyle(color: kDarkText),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: kDarkAccent.withOpacity(0.5)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: kDarkAccent),
                        ),
                      ),
                      validator: (val) => val == null || !val.contains('@')
                          ? 'Enter a valid email'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(color: kDarkText),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: kDarkText),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: kDarkAccent.withOpacity(0.5)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: kDarkAccent),
                        ),
                      ),
                      validator: (val) => val == null || val.length < 6
                          ? 'Password must be 6+ characters'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: authState.isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kDarkAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: authState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: kDarkText,
                              ),
                            )
                          : Text(_isSignUp ? 'SIGN UP' : 'LOGIN'),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isSignUp = !_isSignUp;
                        });
                      },
                      child: Text(
                        _isSignUp
                            ? 'Already have an account? Login'
                            : 'Don\'t have an account? Sign up',
                        style: const TextStyle(color: kDarkAccent),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
