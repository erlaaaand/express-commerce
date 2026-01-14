import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../providers/auth_provider.dart';

class CheckoutShippingForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController addressController;
  final TextEditingController notesController;
  final TextEditingController phoneController;

  const CheckoutShippingForm({
    super.key,
    required this.formKey,
    required this.addressController,
    required this.notesController,
    required this.phoneController,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Pengiriman',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              labelText: 'Email',
              hintText: authProvider.user?.email ?? '',
              enabled: false,
              prefixIcon: Icons.email_outlined,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: phoneController,
              labelText: 'Nomor Telepon',
              hintText: 'Masukkan nomor telepon',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: Validators.validatePhone,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: addressController,
              labelText: 'Alamat Lengkap',
              hintText: 'Jalan, RT/RW, Kelurahan, Kecamatan, Kota',
              prefixIcon: Icons.location_on_outlined,
              maxLines: 3,
              validator: (value) => Validators.validateMinLength(
                value,
                10,
                fieldName: 'Alamat',
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: notesController,
              labelText: 'Catatan (Opsional)',
              hintText: 'Contoh: Warna, ukuran, dll',
              prefixIcon: Icons.note_outlined,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}