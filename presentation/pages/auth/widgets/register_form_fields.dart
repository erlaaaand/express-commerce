import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/utils/validators.dart';

class RegisterFormFields extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onToggleConfirmPasswordVisibility;
  final String? Function(String?)? confirmPasswordValidator;

  const RegisterFormFields({
    super.key,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isPasswordVisible,
    required this.isConfirmPasswordVisible,
    required this.onTogglePasswordVisibility,
    required this.onToggleConfirmPasswordVisibility,
    required this.confirmPasswordValidator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          controller: usernameController,
          labelText: 'Username',
          hintText: 'Masukkan username Anda',
          prefixIcon: Icons.person_outline,
          validator: Validators.validateUsername,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: emailController,
          labelText: 'Email',
          hintText: 'Masukkan email Anda',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: Validators.validateEmail,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: passwordController,
          labelText: 'Password',
          hintText: 'Masukkan password Anda',
          prefixIcon: Icons.lock_outline,
          obscureText: !isPasswordVisible,
          validator: Validators.validatePassword,
          suffixIcon: IconButton(
            icon: Icon(
              isPasswordVisible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.textHint,
            ),
            onPressed: onTogglePasswordVisibility,
          ),
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: confirmPasswordController,
          labelText: 'Konfirmasi Password',
          hintText: 'Masukkan ulang password Anda',
          prefixIcon: Icons.lock_outline,
          obscureText: !isConfirmPasswordVisible,
          validator: confirmPasswordValidator,
          suffixIcon: IconButton(
            icon: Icon(
              isConfirmPasswordVisible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.textHint,
            ),
            onPressed: onToggleConfirmPasswordVisibility,
          ),
        ),
      ],
    );
  }
}
