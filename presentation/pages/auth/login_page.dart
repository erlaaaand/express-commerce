import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../home/home_page.dart';
import 'widgets/login_header.dart';
import 'widgets/login_form_fields.dart';
import 'widgets/login_debug_info.dart';
import 'widgets/login_register_link.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();
    final cartProvider = context.read<CartProvider>();

    debugPrint('Attempting login with email: ${_emailController.text.trim()}');

    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      debugPrint('Login successful!');
      
      try {
        await cartProvider.syncLocalCart();
      } catch (e) {
        debugPrint('Cart sync error (non-critical): $e');
      }

      Fluttertoast.showToast(
        msg: 'Login berhasil!',
        backgroundColor: AppColors.success,
        textColor: AppColors.white,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
        (_) => false,
      );
    } else {
      debugPrint('Login failed with error: ${authProvider.errorMessage}');
      
      final errorMessage = authProvider.errorMessage ?? 'Login gagal, coba lagi';
      
      Fluttertoast.showToast(
        msg: errorMessage,
        backgroundColor: AppColors.error,
        textColor: AppColors.white,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );

      if (errorMessage.length > 50) {
        _showErrorDialog(errorMessage);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.error),
            SizedBox(width: 8),
            Text('Login Gagal'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  const LoginHeader(),
                  const SizedBox(height: 50),
                  LoginFormFields(
                    emailController: _emailController,
                    passwordController: _passwordController,
                    isPasswordVisible: _isPasswordVisible,
                    onTogglePasswordVisibility: _togglePasswordVisibility,
                  ),
                  const SizedBox(height: 32),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return CustomButton(
                        text: 'Masuk',
                        onPressed: _handleLogin,
                        isLoading: authProvider.isLoading,
                        icon: Icons.login,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const LoginDebugInfo(),
                  const SizedBox(height: 16),
                  const LoginRegisterLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}