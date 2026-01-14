import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/utils/validators.dart';

class LoginFormFields extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isPasswordVisible;
  final VoidCallback onTogglePasswordVisibility;

  const LoginFormFields({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.isPasswordVisible,
    required this.onTogglePasswordVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
      ],
    );
  }
}
