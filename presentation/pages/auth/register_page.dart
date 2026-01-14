import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import 'widgets/register_header.dart';
import 'widgets/register_form_fields.dart';
import 'widgets/register_button.dart';
import 'widgets/register_login_link.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Logic validasi tetap di sini karena membutuhkan akses ke controller lain
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (value != _passwordController.text) {
      return 'Password tidak cocok';
    }
    return null;
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.register(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Fluttertoast.showToast(
        msg: 'Registrasi berhasil! Silakan login',
        backgroundColor: AppColors.success,
        textColor: AppColors.white,
      );
      Navigator.pop(context);
    } else {
      Fluttertoast.showToast(
        msg: authProvider.errorMessage ?? 'Registrasi gagal',
        backgroundColor: AppColors.error,
        textColor: AppColors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const RegisterHeader(),
                  const SizedBox(height: 40),
                  RegisterFormFields(
                    usernameController: _usernameController,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    confirmPasswordController: _confirmPasswordController,
                    isPasswordVisible: _isPasswordVisible,
                    isConfirmPasswordVisible: _isConfirmPasswordVisible,
                    onTogglePasswordVisibility: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                    onToggleConfirmPasswordVisibility: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                    confirmPasswordValidator: _validateConfirmPassword,
                  ),
                  const SizedBox(height: 32),
                  RegisterButton(onPressed: _handleRegister),
                  const SizedBox(height: 24),
                  const RegisterLoginLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}