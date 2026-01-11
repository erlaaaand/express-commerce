import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';

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
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildUsernameField(),
                  const SizedBox(height: 20),
                  _buildEmailField(),
                  const SizedBox(height: 20),
                  _buildPasswordField(),
                  const SizedBox(height: 20),
                  _buildConfirmPasswordField(),
                  const SizedBox(height: 32),
                  _buildRegisterButton(),
                  const SizedBox(height: 24),
                  _buildLoginLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daftar Akun Baru',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Buat akun untuk mulai berbelanja',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildUsernameField() {
    return CustomTextField(
      controller: _usernameController,
      labelText: 'Username',
      hintText: 'Masukkan username Anda',
      prefixIcon: Icons.person_outline,
      validator: Validators.validateUsername,
    );
  }

  Widget _buildEmailField() {
    return CustomTextField(
      controller: _emailController,
      labelText: 'Email',
      hintText: 'Masukkan email Anda',
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      validator: Validators.validateEmail,
    );
  }

  Widget _buildPasswordField() {
    return CustomTextField(
      controller: _passwordController,
      labelText: 'Password',
      hintText: 'Masukkan password Anda',
      prefixIcon: Icons.lock_outline,
      obscureText: !_isPasswordVisible,
      validator: Validators.validatePassword,
      suffixIcon: IconButton(
        icon: Icon(
          _isPasswordVisible
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: AppColors.textHint,
        ),
        onPressed: () {
          setState(() {
            _isPasswordVisible = !_isPasswordVisible;
          });
        },
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return CustomTextField(
      controller: _confirmPasswordController,
      labelText: 'Konfirmasi Password',
      hintText: 'Masukkan ulang password Anda',
      prefixIcon: Icons.lock_outline,
      obscureText: !_isConfirmPasswordVisible,
      validator: _validateConfirmPassword,
      suffixIcon: IconButton(
        icon: Icon(
          _isConfirmPasswordVisible
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: AppColors.textHint,
        ),
        onPressed: () {
          setState(() {
            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
          });
        },
      ),
    );
  }

  Widget _buildRegisterButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return CustomButton(
          text: 'Daftar',
          onPressed: _handleRegister,
          isLoading: authProvider.isLoading,
          icon: Icons.person_add,
        );
      },
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Sudah punya akun? ',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Text(
              'Masuk Sekarang',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}